#!/usr/bin/env python3
"""Archive files_exif rows for a project's folders to a zip, then delete them.

Standalone: needs only this folder, its requirements.txt and a settings.py
(copy settings.py.template). It does not import the Osprey web app.

Folders are selected by project_id and folders.date (inclusive range). Each
folder's EXIF rows go to one CSV, the CSVs go into one zip, and the zip is
re-read and checked before any row is deleted. Only the exported table_ids
are deleted, so rows the worker re-inserts during the run are kept.

Usage:
    python archive_exif.py --project-id 12 --from 2024-01-01 --to 2024-06-30

Exit code 0 on success (including nothing to archive or a declined delete),
1 on failure. Nothing is deleted unless the zip verified.
"""

from __future__ import annotations

import argparse
import csv
import datetime
import io
import logging
import os
import re
import runpy
import shutil
import sys
import zipfile
from array import array
from pathlib import Path
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
logger = logging.getLogger('archive_exif')

# Settings a settings.py must define; the rest have defaults.
REQUIRED_SETTINGS = ('host', 'database', 'user', 'password')
DEFAULT_SETTINGS = {
    'port': 3306,
    # Same session time zone as the Osprey app, so updated_at matches it.
    'time_zone': '-05:00',
    'exif_archive_folder': 'exif_archive',
    'log_folder': 'logs',
    'log_level': 'INFO',
}

# Uses idx_folders_project_date_folder.
SELECT_FOLDERS = """
    SELECT folder_id, project_folder, date, processing
    FROM folders
    WHERE project_id = %(project_id)s AND date BETWEEN %(date_from)s AND %(date_to)s AND delivered_to_dams = 0
    ORDER BY date, project_folder, folder_id
"""

# Legacy rows written by file_uid (transcription files) have no file_id and
# are not reachable from folders; they are out of scope here.
COUNT_FOLDER_ROWS = """
    SELECT COUNT(*) AS n
    FROM files f JOIN files_exif e ON e.file_id = f.file_id
    WHERE f.folder_id = %(folder_id)s
"""

EXPORT_FOLDER_ROWS = """
    SELECT e.table_id, e.file_id, f.file_name, e.filetype, e.taggroup,
           e.tag, e.tagid, e.value, e.updated_at
    FROM files f JOIN files_exif e ON e.file_id = f.file_id
    WHERE f.folder_id = %(folder_id)s
    ORDER BY e.file_id, e.table_id
"""

COLUMNS = ['table_id', 'file_id', 'file_name', 'filetype', 'taggroup', 'tag', 'tagid', 'value', 'updated_at']


class VerifyError(Exception):
    """The zip does not match what was exported; nothing may be deleted."""


class SettingsError(Exception):
    """settings.py is missing or incomplete."""


def load_settings(path):
    """Read a settings.py; relative folders in it resolve against its own folder."""
    path = Path(path)
    if not path.is_file():
        raise SettingsError('{} not found; copy settings.py.template to settings.py and fill it in'.format(path))
    values = {k: v for k, v in runpy.run_path(str(path)).items() if not k.startswith('_')}
    missing = [k for k in REQUIRED_SETTINGS if not values.get(k)]
    if missing:
        raise SettingsError('{} is missing: {}'.format(path, ', '.join(missing)))
    settings = SimpleNamespace(**{**DEFAULT_SETTINGS, **values})
    settings.port = int(settings.port)
    for key in ('exif_archive_folder', 'log_folder'):
        setattr(settings, key, path.parent / Path(getattr(settings, key)).expanduser())
    return settings


def setup_logging(settings):
    os.makedirs(settings.log_folder, exist_ok=True)
    handler = logging.FileHandler(Path(settings.log_folder) / 'archive_exif.log')
    handler.setFormatter(logging.Formatter('%(levelname)s | %(asctime)s | %(process)d | %(message)s',
                                           datefmt='%y-%b-%d %H:%M:%S'))
    logger.addHandler(handler)
    logger.setLevel(settings.log_level)


class Db:
    """Minimal MySQL access: autocommit, dict rows, streaming for exports."""

    def __init__(self, settings):
        import mysql.connector  # imported here so tests and --help run without the driver
        self._connector = mysql.connector
        self._settings = settings
        self._conn = self._connect()

    def _connect(self):
        s = self._settings
        conn = self._connector.connect(host=s.host, port=s.port, user=s.user, password=s.password,
                                       database=s.database, autocommit=True, connection_timeout=60)
        conn.time_zone = s.time_zone
        return conn

    def query(self, sql, params=None):
        self._conn.ping(reconnect=True, attempts=3, delay=1)
        cur = self._conn.cursor(dictionary=True)
        try:
            cur.execute(sql, params)
            return cur.fetchall()
        finally:
            cur.close()

    def iter_query(self, sql, params=None, chunk_size=5000):
        """Yield rows in chunks from an unbuffered cursor on its own connection,
        so a half-read stream never blocks queries on the main one."""
        conn = self._connect()
        try:
            cur = conn.cursor(dictionary=True)
            cur.execute(sql, params)
            while True:
                rows = cur.fetchmany(chunk_size)
                if not rows:
                    break
                yield rows
        finally:
            conn.close()

    def execute(self, sql, params=None):
        """Run one statement (DELETE) and return rowcount."""
        self._conn.ping(reconnect=True, attempts=3, delay=1)
        cur = self._conn.cursor()
        try:
            cur.execute(sql, params)
            return cur.rowcount
        finally:
            cur.close()

    def close(self):
        self._conn.close()


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split('\n\n')[0])
    parser.add_argument('--project-id', type=int, required=True)
    parser.add_argument('--from', dest='date_from', type=datetime.date.fromisoformat, required=True,
                        metavar='YYYY-MM-DD', help='first folder date (inclusive)')
    parser.add_argument('--to', dest='date_to', type=datetime.date.fromisoformat, required=True,
                        metavar='YYYY-MM-DD', help='last folder date (inclusive)')
    parser.add_argument('--out-dir', type=Path,
                        help='where the zip is written (default: exif_archive_folder in settings.py)')
    parser.add_argument('--settings', type=Path, default=HERE / 'settings.py',
                        help='settings file (default: settings.py next to this script)')
    parser.add_argument('--dry-run', action='store_true', help='list folders and row counts only')
    parser.add_argument('--no-delete', action='store_true', help='export and zip, keep the rows')
    parser.add_argument('--batch-size', type=int, default=5000, help='rows per DELETE (default: 5000)')
    parser.add_argument('--yes', action='store_true', help='delete without asking')
    args = parser.parse_args(argv)
    if args.date_from > args.date_to:
        parser.error('--from must not be after --to')
    if args.batch_size < 1:
        parser.error('--batch-size must be at least 1')
    return args


def select_folders(db, project_id, date_from, date_to):
    """Return (folders to archive, folders skipped because they are processing)."""
    rows = db.query(SELECT_FOLDERS, {'project_id': project_id, 'date_from': date_from, 'date_to': date_to})
    folders = [r for r in rows if not r['processing']]
    skipped = [r for r in rows if r['processing']]
    return folders, skipped


def csv_name(folder):
    name = re.sub(r'[^A-Za-z0-9._-]+', '_', str(folder['project_folder'] or '')).strip('_') or 'folder'
    return '{}_{}_{}.csv'.format(folder['date'], name, folder['folder_id'])


def export_folder(db, folder, work_dir):
    """Write one folder's rows to a CSV; return (path, exported table_ids)."""
    path = work_dir / csv_name(folder)
    table_ids = array('Q')
    with open(path, 'w', newline='', encoding='utf-8') as fh:
        writer = csv.writer(fh)
        writer.writerow(COLUMNS)
        for chunk in db.iter_query(EXPORT_FOLDER_ROWS, {'folder_id': folder['folder_id']}):
            writer.writerows([r[c] for c in COLUMNS] for r in chunk)
            table_ids.extend(r['table_id'] for r in chunk)
    return path, table_ids


def build_zip(csv_paths, zip_path):
    """Zip the CSVs; the zip only appears under its final name once complete."""
    part = zip_path.with_name(zip_path.name + '.part')
    with zipfile.ZipFile(part, 'w', compression=zipfile.ZIP_DEFLATED, allowZip64=True) as zf:
        for p in csv_paths:
            zf.write(p, arcname=p.name)
    os.replace(part, zip_path)


def verify_zip(zip_path, expected):
    """Check the zip reads back and each CSV has the expected number of data rows.

    expected maps member name -> row count. Rows are counted with csv.reader,
    not by lines, since EXIF values can contain newlines.
    """
    with zipfile.ZipFile(zip_path) as zf:
        bad = zf.testzip()
        if bad is not None:
            raise VerifyError('corrupt member in {}: {}'.format(zip_path, bad))
        names = set(zf.namelist())
        if names != set(expected):
            raise VerifyError('zip members do not match exported CSVs: missing {}, extra {}'.format(
                sorted(set(expected) - names), sorted(names - set(expected))))
        for name, n_expected in expected.items():
            with zf.open(name) as raw:
                reader = csv.reader(io.TextIOWrapper(raw, encoding='utf-8', newline=''))
                header = next(reader, None)
                n = sum(1 for _ in reader)
            if header != COLUMNS or n != n_expected:
                raise VerifyError('{}: expected {} rows, found {}'.format(name, n_expected, n))


def delete_rows(db, table_ids, batch_size):
    """Delete the given table_ids in batches (autocommit: one commit each); return rows deleted."""
    deleted = 0
    for i in range(0, len(table_ids), batch_size):
        batch = table_ids[i:i + batch_size]
        sql = 'DELETE FROM files_exif WHERE table_id IN ({})'.format(', '.join(['%s'] * len(batch)))
        deleted += db.execute(sql, tuple(batch))
    return deleted


def confirm(prompt):
    try:
        return input(prompt).strip().lower() in ('y', 'yes')
    except EOFError:
        return False


def dry_run(db, folders):
    total = 0
    for f in folders:
        n = int(db.query(COUNT_FOLDER_ROWS, {'folder_id': f['folder_id']})[0]['n'])
        total += n
        print('{}\t{}\t{}\t{} rows'.format(f['folder_id'], f['date'], f['project_folder'], n))
    print('{} folders, {} rows would be archived'.format(len(folders), total))
    return total


def archive_exif(db, args, out_dir):
    folders, skipped = select_folders(db, args.project_id, args.date_from, args.date_to)
    for f in skipped:
        logger.warning("skipping folder {} ({}): processing".format(f['folder_id'], f['project_folder']))
        print('skipped folder {} ({}): processing'.format(f['folder_id'], f['project_folder']))
    if not folders:
        print('no folders to archive')
        return 0
    if args.dry_run:
        dry_run(db, folders)
        return 0

    run_ts = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    out_dir.mkdir(parents=True, exist_ok=True)
    stem = 'exif_p{}_{}_{}_{}'.format(args.project_id, args.date_from, args.date_to, run_ts)
    work_dir = out_dir / ('.' + stem)
    work_dir.mkdir()

    # On any failure the CSVs stay in work_dir for inspection and nothing is deleted.
    exported = []  # (folder, csv path, table_ids)
    for f in folders:
        path, ids = export_folder(db, f, work_dir)
        if not ids:
            path.unlink()
            continue
        exported.append((f, path, ids))
        logger.info("folder {} exported {} rows".format(f['folder_id'], len(ids)))
    total = sum(len(ids) for _, _, ids in exported)
    if not exported:
        shutil.rmtree(work_dir)
        print('{} folders, no EXIF rows to archive'.format(len(folders)))
        return 0

    zip_path = out_dir / (stem + '.zip')
    build_zip([p for _, p, _ in exported], zip_path)
    verify_zip(zip_path, {p.name: len(ids) for _, p, ids in exported})
    shutil.rmtree(work_dir)
    logger.info("{} rows from {} folders verified in {}".format(total, len(exported), zip_path))
    print('{} rows from {} folders archived to {}'.format(total, len(exported), zip_path))

    if args.no_delete:
        print('--no-delete: rows kept in files_exif')
        return 0
    if not args.yes and not confirm('Delete {} rows from files_exif? [y/N] '.format(total)):
        print('rows kept in files_exif')
        return 0

    deleted = 0
    for f, _, ids in exported:
        n = delete_rows(db, ids, args.batch_size)
        deleted += n
        logger.info("folder {} deleted {} rows".format(f['folder_id'], n))
    logger.info("deleted {} of {} exported rows".format(deleted, total))
    print('deleted {} rows from files_exif'.format(deleted))
    return 0


def main(argv=None) -> int:
    args = parse_args(argv)
    try:
        settings = load_settings(args.settings)
    except SettingsError as err:
        print(err, file=sys.stderr)
        return 1
    setup_logging(settings)
    out_dir = args.out_dir or settings.exif_archive_folder
    db = None
    try:
        db = Db(settings)
        archive_exif(db, args, out_dir)
    except Exception:
        logger.exception("failed")
        print('archive_exif failed; see {} for any rows already deleted'.format(
            Path(settings.log_folder) / 'archive_exif.log'), file=sys.stderr)
        return 1
    finally:
        if db is not None:
            db.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
