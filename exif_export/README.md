# EXIF archive

`archive_exif.py` moves `files_exif` rows out of the Osprey database: it
exports the rows for a project's folders to CSV, zips them, checks the zip,
and then deletes the exported rows. It is run by hand, not from the nightly
job.

It is standalone: it does not import the Osprey web app and can be copied
anywhere with this folder's files. It needs Python 3.9+ and its own
`requirements.txt`.

## Setup

```bash
cd scripts/exif_export
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
cp settings.py.template settings.py   # then set the DB credentials
```

`settings.py` holds the DB password: keep it out of version control (it is
in this folder's `.gitignore`). Each value can also come from the environment
variable named in the template. Relative folders in it (`exif_archive_folder`,
`log_folder`) resolve against the folder `settings.py` is in. The DB user
needs `SELECT` on `folders`, `files` and `files_exif`, and `DELETE` on
`files_exif`.

## Usage

```bash
# See what would be archived:
.venv/bin/python archive_exif.py --project-id 12 --from 2024-01-01 --to 2024-06-30 --dry-run
# Archive and delete (asks before deleting):
.venv/bin/python archive_exif.py --project-id 12 --from 2024-01-01 --to 2024-06-30
```

| Flag | Meaning |
| --- | --- |
| `--project-id` | Project whose folders are archived (required). |
| `--from`, `--to` | Range of `folders.date`, both ends included (required). |
| `--out-dir` | Where the zip is written. Default: `exif_archive_folder` in `settings.py`. |
| `--settings` | Settings file. Default: `settings.py` next to the script. |
| `--dry-run` | List matching folders and their row counts; write and delete nothing. |
| `--no-delete` | Export and zip, but keep the rows. |
| `--batch-size` | Rows per `DELETE` (default 5000). |
| `--yes` | Delete without the confirmation prompt (for unattended runs). |

Without `--yes`, the script asks before deleting; with no terminal to ask
(cron, a pipe) it keeps the rows.

## What it does

1. Selects folders with `project_id` and `date` in range. Folders with
   `processing = 1` are skipped and reported.
2. Writes one CSV per folder, `{date}_{project_folder}_{folder_id}.csv`, with
   columns `table_id, file_id, file_name, filetype, taggroup, tag, tagid,
   value, updated_at`. Folders without EXIF rows get no CSV.
3. Zips the CSVs into `exif_p{project_id}_{from}_{to}_{timestamp}.zip`
   (written as `.part` and renamed when complete), then re-reads the zip and
   checks every CSV's row count against what was exported.
4. Deletes only the exported `table_id`s, in batches, one commit per batch.
   Rows the worker re-inserts during the run are kept.

If anything fails before the delete, nothing is deleted and the CSVs are left
in `.exif_p{...}` under the output folder for inspection. Exit code is 0 on
success (including nothing to archive or a declined delete), 1 on failure.
Progress and errors go to `<log_folder>/archive_exif.log`.

## Notes

- Legacy rows written by `file_uid` (transcription files, `file_id` NULL)
  are not linked to folders and are not archived.
- InnoDB does not shrink the table file after deletes; run
  `OPTIMIZE TABLE files_exif` in a maintenance window to reclaim space.
- The Osprey app's `/sysadmin/schema/` counts come from `exif_counts`,
  refreshed nightly by `scripts/count_exif.py`, so they lag until then.

## Tests

No database is needed; the tests use a fake one.

```bash
.venv/bin/pip install -r requirements-dev.txt
.venv/bin/python -m pytest
```
