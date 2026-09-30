
# JPCA filename recheck (`recheck_jpca_filenames.py`)

Standalone script that re-runs only the `filename` check (RefID vs
`jpc_aspace_data`, with the live ArchivesSpace fallback) for a project, then
recalculates the project's stats. Use it when every other check has passed and
files are still flagged because their RefID wasn't in ASpace at first pass.

It does not import anything from `web_app`; it only calls the Osprey API, so it
can run on any host that can reach the API **and** has the project storage
mounted.

## Flow

1. `GET  /api/projects/<alias>` → map DB folder name → `folder_id`.
2. List subdirectories of `--project-path`; match each by name to a DB folder.
   Folders with no match, or with more than one DB folder of that name, are
   logged and skipped.
3. `POST /api/folders/<folder_id>` → files whose `filename` check is not `OK`
   (Failed, Pending, or never run).
4. For each such file, `POST /api/update/<alias>` with
   `type=file, property=filechecks, file_check=filename`. The server ignores
   the posted `value` and recomputes the check; on failure it queries ASpace
   and, if the RefID exists, inserts it into `jpc_aspace_data` and marks the
   check OK.
5. Re-reads the folder and logs how many files were fixed and which ones
   still fail (the update endpoint doesn't return the check result).
6. `POST /api/projects/<alias>/recalculate-stats` → recalculates every
   folder's stats (`file_errors`, `error_files` badge) and the project totals.

## Input

| Argument / env        | Description                                          |
|-----------------------|------------------------------------------------------|
| `--api-url`           | Base API URL, e.g. `https://osprey.example.org/api`  |
| `--project-alias`     | Project alias (JPCA projects: IDs 220, 248)          |
| `--project-path`      | Directory whose subfolders are the project folders   |
| `--dry-run`           | List files that would be rechecked; post nothing     |
| `-v`, `--verbose`     | Also print per-file lines to the console             |
| `--log-file`          | Log path (default `web_app/logs/recheck_jpca_filenames.log`) |
| `OSPREY_API_KEY` env  | **Admin** API key (kept out of argv / `ps`)          |

```bash
export OSPREY_API_KEY=<admin-key>
python3 scripts/recheck_jpca_filenames.py \
    --api-url https://osprey.example.org/api \
    --project-alias <jpca_alias> \
    --project-path /mnt/storage/<jpca_folder> --dry-run
```

## Output

- **Console (stderr):** INFO and above (DEBUG with `-v`).
- **Log file:** always DEBUG, appended across runs. Same format as
  `ospreyapp.log` / `ospreyapi.log`
  (`LEVEL | time | pid | file:line | message`). Each run starts with a
  `start:` line and ends with a `done:` summary (folders, files rechecked,
  still failing, unmatched folders, errors). Files that still fail are
  logged as `WARNING ... still failing: <file_name> (<file_id>)`.
- Uses `WatchedFileHandler`, so the existing logrotate setup for `logs/`
  covers it (check the logrotate glob matches `*.log`).

Quick checks:

```bash
grep 'done:' logs/recheck_jpca_filenames.log | tail -1
grep 'still failing:' logs/recheck_jpca_filenames.log
```

Exit codes: `0` success, `1` one or more API errors (the run continues
past per-file errors), `2` bad configuration.

## Requirements

- Python 3.8+
- `requests` (RHEL 8/9 `python3-requests` is fine; tested with 2.33)
- Admin API key; project storage mounted locally

## Notes

- Files are processed sequentially. Each failed file can cost the server up to
  two ArchivesSpace calls, so the client timeout is 180 s per request.
- Folders are matched by name only (`folders.project_folder`), not by path.
