"""archive_exif.py: export, zip, verify, then delete only exported rows. No database needed."""

import csv
import datetime
import importlib.util
import io
import zipfile
from pathlib import Path
from unittest.mock import patch

import pytest

_spec = importlib.util.spec_from_file_location(
    'archive_exif', Path(__file__).resolve().parent / 'archive_exif.py')
archive_exif = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(archive_exif)

D = datetime.date(2024, 3, 1)
TS = datetime.datetime(2024, 3, 2, 10, 0)


def _folder(folder_id, name, processing=0):
    return {'folder_id': folder_id, 'project_folder': name, 'date': D, 'processing': processing}


def _row(table_id, file_id, value='v'):
    return {'table_id': table_id, 'file_id': file_id, 'file_name': 'f{}.tif'.format(file_id), 'filetype': 'TIF',
            'taggroup': 'EXIF', 'tag': 'Make', 'tagid': '0x010f', 'value': value, 'updated_at': TS}


class FakeDb:
    def __init__(self, folders, rows_by_folder):
        self.folders = folders
        self.rows_by_folder = rows_by_folder
        self.deletes = []  # params of each DELETE

    def query(self, sql, params=None):
        if sql == archive_exif.SELECT_FOLDERS:
            return self.folders
        if sql == archive_exif.COUNT_FOLDER_ROWS:
            return [{'n': len(self.rows_by_folder.get(params['folder_id'], []))}]
        raise AssertionError('unexpected query: {}'.format(sql))

    def iter_query(self, sql, params=None, chunk_size=5000):
        assert sql == archive_exif.EXPORT_FOLDER_ROWS
        rows = self.rows_by_folder.get(params['folder_id'], [])
        for i in range(0, len(rows), 2):  # small chunks to exercise chunking
            yield rows[i:i + 2]

    def execute(self, sql, params=None):
        assert sql.startswith('DELETE FROM files_exif WHERE table_id IN (')
        self.deletes.append(params)
        return len(params)

    def deleted_ids(self):
        return sorted(i for batch in self.deletes for i in batch)


def _run(tmp_path, folders, rows_by_folder, extra=()):
    db = FakeDb(folders, rows_by_folder)
    args = archive_exif.parse_args(['--project-id', '7', '--from', '2024-01-01', '--to', '2024-06-30', *extra])
    code = archive_exif.archive_exif(db, args, tmp_path)
    return code, db


def _zips(tmp_path):
    return sorted(tmp_path.glob('*.zip'))


def test_exports_zips_and_deletes_only_exported_ids(tmp_path):
    rows = {1: [_row(10, 1), _row(11, 1), _row(12, 2, 'line1\nline2')], 2: [_row(20, 3)]}
    code, db = _run(tmp_path, [_folder(1, 'A 01'), _folder(2, 'B/02')], rows, extra=['--yes'])
    assert code == 0
    [zp] = _zips(tmp_path)
    assert zp.name.startswith('exif_p7_2024-01-01_2024-06-30_')
    with zipfile.ZipFile(zp) as zf:
        assert sorted(zf.namelist()) == ['2024-03-01_A_01_1.csv', '2024-03-01_B_02_2.csv']
        with zf.open('2024-03-01_A_01_1.csv') as raw:
            data = list(csv.reader(io.TextIOWrapper(raw, encoding='utf-8', newline='')))
    assert data[0] == archive_exif.COLUMNS
    assert [r[0] for r in data[1:]] == ['10', '11', '12']
    assert data[3][7] == 'line1\nline2'
    assert db.deleted_ids() == [10, 11, 12, 20]
    # Work directory with the loose CSVs is removed after verification.
    assert [p.name for p in tmp_path.iterdir()] == [zp.name]


def test_delete_batches(tmp_path):
    rows = {1: [_row(i, 1) for i in range(1, 6)]}
    _, db = _run(tmp_path, [_folder(1, 'A')], rows, extra=['--yes', '--batch-size', '2'])
    assert [len(b) for b in db.deletes] == [2, 2, 1]


def test_processing_folders_skipped(tmp_path):
    rows = {1: [_row(10, 1)], 2: [_row(20, 2)]}
    _, db = _run(tmp_path, [_folder(1, 'A'), _folder(2, 'B', processing=1)], rows, extra=['--yes'])
    assert db.deleted_ids() == [10]
    with zipfile.ZipFile(_zips(tmp_path)[0]) as zf:
        assert zf.namelist() == ['2024-03-01_A_1.csv']


def test_folders_without_rows_left_out_of_zip(tmp_path):
    _run(tmp_path, [_folder(1, 'A'), _folder(2, 'B')], {1: [_row(10, 1)]}, extra=['--yes'])
    with zipfile.ZipFile(_zips(tmp_path)[0]) as zf:
        assert zf.namelist() == ['2024-03-01_A_1.csv']


def test_no_rows_writes_nothing(tmp_path):
    code, db = _run(tmp_path, [_folder(1, 'A')], {}, extra=['--yes'])
    assert code == 0
    assert db.deletes == []
    assert list(tmp_path.iterdir()) == []


def test_dry_run_deletes_and_writes_nothing(tmp_path, capsys):
    code, db = _run(tmp_path, [_folder(1, 'A')], {1: [_row(10, 1), _row(11, 1)]}, extra=['--dry-run'])
    assert code == 0
    assert db.deletes == []
    assert list(tmp_path.iterdir()) == []
    assert '1 folders, 2 rows would be archived' in capsys.readouterr().out


def test_no_delete_keeps_rows(tmp_path):
    _, db = _run(tmp_path, [_folder(1, 'A')], {1: [_row(10, 1)]}, extra=['--no-delete'])
    assert db.deletes == []
    assert len(_zips(tmp_path)) == 1


def test_declined_prompt_keeps_rows(tmp_path):
    with patch('builtins.input', return_value='n'):
        _, db = _run(tmp_path, [_folder(1, 'A')], {1: [_row(10, 1)]})
    assert db.deletes == []


def test_prompt_without_tty_keeps_rows(tmp_path):
    with patch('builtins.input', side_effect=EOFError):
        _, db = _run(tmp_path, [_folder(1, 'A')], {1: [_row(10, 1)]})
    assert db.deletes == []


def test_confirmed_prompt_deletes(tmp_path):
    with patch('builtins.input', return_value='y'):
        _, db = _run(tmp_path, [_folder(1, 'A')], {1: [_row(10, 1)]})
    assert db.deleted_ids() == [10]


def test_failed_verification_blocks_delete(tmp_path):
    with patch.object(archive_exif, 'verify_zip', side_effect=archive_exif.VerifyError('mismatch')):
        with pytest.raises(archive_exif.VerifyError):
            _run(tmp_path, [_folder(1, 'A')], {1: [_row(10, 1)]}, extra=['--yes'])
    # CSVs are kept for inspection.
    assert len(list(tmp_path.glob('.exif_p7_*/*.csv'))) == 1


def test_verify_zip_detects_row_count_mismatch(tmp_path):
    p = tmp_path / 'a.csv'
    p.write_text(','.join(archive_exif.COLUMNS) + '\n1,2,f,TIF,G,T,I,"multi\nline",x\n', encoding='utf-8')
    zp = tmp_path / 'a.zip'
    archive_exif.build_zip([p], zp)
    archive_exif.verify_zip(zp, {'a.csv': 1})
    with pytest.raises(archive_exif.VerifyError):
        archive_exif.verify_zip(zp, {'a.csv': 2})
    with pytest.raises(archive_exif.VerifyError):
        archive_exif.verify_zip(zp, {'a.csv': 1, 'b.csv': 1})


def _write_settings(path, body):
    path.write_text(body, encoding='utf-8')
    return path


def test_load_settings_defaults_and_relative_folders(tmp_path):
    s = archive_exif.load_settings(_write_settings(
        tmp_path / 'settings.py', "host = 'db'\ndatabase = 'osprey'\nuser = 'u'\npassword = 'p'\n"))
    assert s.port == 3306
    assert s.time_zone == '-05:00'
    assert s.exif_archive_folder == tmp_path / 'exif_archive'
    assert s.log_folder == tmp_path / 'logs'


def test_load_settings_reports_missing_values(tmp_path):
    with pytest.raises(archive_exif.SettingsError, match='password'):
        archive_exif.load_settings(_write_settings(
            tmp_path / 'settings.py', "host = 'db'\ndatabase = 'osprey'\nuser = 'u'\npassword = ''\n"))


def test_main_without_settings_file_fails_cleanly(tmp_path, capsys):
    code = archive_exif.main(['--project-id', '1', '--from', '2024-01-01', '--to', '2024-01-31',
                              '--settings', str(tmp_path / 'settings.py')])
    assert code == 1
    assert 'settings.py.template' in capsys.readouterr().err


def test_main_uses_settings_folder_and_returns_1_on_failure(tmp_path):
    settings_file = _write_settings(
        tmp_path / 'settings.py', "host = 'db'\ndatabase = 'osprey'\nuser = 'u'\npassword = 'p'\n")
    seen = {}

    def fake_archive(db, args, out_dir):
        seen['out_dir'] = out_dir
        raise RuntimeError('db down')

    with patch.object(archive_exif, 'Db'), patch.object(archive_exif, 'archive_exif', side_effect=fake_archive):
        code = archive_exif.main(['--project-id', '1', '--from', '2024-01-01', '--to', '2024-01-31',
                                  '--settings', str(settings_file)])
    assert code == 1
    assert seen['out_dir'] == tmp_path / 'exif_archive'
    assert (tmp_path / 'logs' / 'archive_exif.log').is_file()


def test_rejects_reversed_dates():
    with pytest.raises(SystemExit):
        archive_exif.parse_args(['--project-id', '1', '--from', '2024-02-01', '--to', '2024-01-31'])
