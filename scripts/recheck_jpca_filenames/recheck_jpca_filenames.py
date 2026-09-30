#!/usr/bin/env python3
"""Re-run the JPCA filename check (RefID vs jpc_aspace_data / ArchivesSpace)
for every folder found on disk under a project path, then recalculate the
project's stats.

Independent of the web_app package: talks to the Osprey API only.
See README (recheck_jpca_filenames section) for usage and details.
"""

import argparse
import logging
import os
import sys
from logging.handlers import WatchedFileHandler
from pathlib import Path

import requests

# Must match the files_checks.file_check value the worker posts.
FILE_CHECK = "filename"
# The server may do two ASpace calls (60 s timeout each) per failed file.
REQUEST_TIMEOUT = 180
# Default log: web_app/logs/, next to ospreyapp.log / ospreyapi.log.
DEFAULT_LOG = Path(__file__).resolve().parent.parent / "logs" / "recheck_jpca_filenames.log"
# Same format as web_app/logger.py so all Osprey logs read alike.
LOG_FORMAT = "%(levelname)s | %(asctime)s | %(process)d | %(filename)s:%(lineno)s | %(message)s"
LOG_DATEFMT = "%y-%b-%d %H:%M:%S"

logger = logging.getLogger("recheck_jpca_filenames")


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--api-url", required=True,
                        help="Base API URL, e.g. https://osprey.example.org/api")
    parser.add_argument("--project-alias", required=True,
                        help="Project alias, e.g. jpc")
    parser.add_argument("--project-path", required=True, type=Path,
                        help="Directory whose subfolders are the project folders")
    parser.add_argument("--dry-run", action="store_true",
                        help="List the files that would be rechecked; post nothing")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Also print per-file lines to the console")
    parser.add_argument("--log-file", type=Path, default=DEFAULT_LOG,
                        help=f"Log file (default: {DEFAULT_LOG})")
    return parser.parse_args()


def setup_logging(log_file, verbose):
    """Console at INFO (DEBUG with -v); log file always at DEBUG."""
    formatter = logging.Formatter(LOG_FORMAT, datefmt=LOG_DATEFMT)
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG if verbose else logging.INFO)
    console.setFormatter(formatter)
    logger.addHandler(console)
    # Fails fast if the folder can't be created (e.g. permissions).
    log_file.parent.mkdir(parents=True, exist_ok=True)
    # WatchedFileHandler: plays well with logrotate, like web_app/logger.py.
    file_handler = WatchedFileHandler(log_file)
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    logger.setLevel(logging.DEBUG)


def api_post(session, url, data):
    """POST form data, raise on HTTP errors, return decoded JSON."""
    resp = session.post(url, data=data, timeout=REQUEST_TIMEOUT)
    resp.raise_for_status()
    return resp.json()


def get_db_folders(session, api_url, project_alias):
    """Map folder name -> folder_id for all DB folders of the project."""
    resp = session.get(f"{api_url}/projects/{project_alias}", timeout=REQUEST_TIMEOUT)
    resp.raise_for_status()
    folders = {}
    for row in resp.json().get("folders", []):
        # Duplicate names are ambiguous; keep a list so we can warn later.
        folders.setdefault(row["folder"], []).append(row["folder_id"])
    return folders


def files_to_recheck(session, api_url, api_key, folder_id):
    """Return files in the folder whose filename check is not OK."""
    payload = api_post(session, f"{api_url}/folders/{folder_id}", {"api_key": api_key})
    # Missing column means the check never ran for that file -> treat as pending.
    return [f for f in payload.get("files", []) if f.get(FILE_CHECK) != "OK"]


def recheck_file(session, api_url, api_key, project_alias, folder_id, file_id):
    """Trigger the server-side filename check. The server ignores 'value'
    for this check and recomputes the result itself."""
    data = {
        "api_key": api_key,
        "type": "file",
        "property": "filechecks",
        "file_check": FILE_CHECK,
        "value": 1,
        "check_info": "",
        "file_id": file_id,
        "folder_id": folder_id,
    }
    api_post(session, f"{api_url}/update/{project_alias}", data)


def recalculate_folder_stats(session, api_url, api_key, project_alias, folder_id):
    """Recalculate stats for every folder in the project plus project totals."""
    return api_post(session, f"{api_url}/update/{project_alias}",
                    {'type': 'folder',
                        'folder_id': folder_id,
                        'api_key': api_key,
                        'property': 'stats',
                        'value': '0'
                        })


def main():
    args = parse_args()
    try:
        setup_logging(args.log_file, args.verbose)
    except OSError as err:
        print(f"cannot open log file {args.log_file}: {err}", file=sys.stderr)
        return 2
    logger.info("start: project=%s path=%s api=%s dry_run=%s",
                args.project_alias, args.project_path, args.api_url, args.dry_run)

    # Read from env so the key doesn't show up in `ps` or shell history.
    api_key = os.environ.get("OSPREY_API_KEY")
    if not api_key:
        logger.error("OSPREY_API_KEY is not set")
        return 2
    if not args.project_path.is_dir():
        logger.error("project path is not a directory: %s", args.project_path)
        return 2

    api_url = args.api_url.rstrip("/")
    disk_folders = sorted(p.name for p in args.project_path.iterdir() if p.is_dir())
    logger.info("%d folder(s) found under %s", len(disk_folders), args.project_path)

    stats = {"folders": 0, "unmatched": 0, "files": 0, "still_failing": 0, "errors": 0}
    with requests.Session() as session:
        try:
            db_folders = get_db_folders(session, api_url, args.project_alias)
        except (requests.RequestException, ValueError) as err:
            logger.error("could not load project folders: %s", err)
            return 1

        for name in disk_folders:
            ids = db_folders.get(name, [])
            if len(ids) != 1:
                # 0 = not registered yet; >1 = ambiguous name. Either way skip.
                logger.warning("skipping %s: %d matching DB folder(s)", name, len(ids))
                stats["unmatched"] += 1
                continue
            folder_id = ids[0]
            stats["folders"] += 1

            try:
                files = files_to_recheck(session, api_url, api_key, folder_id)
            except (requests.RequestException, ValueError) as err:
                logger.error("folder %s (%s): could not list files: %s", name, folder_id, err)
                stats["errors"] += 1
                continue
            logger.info("folder %s (%s): %d file(s) to recheck", name, folder_id, len(files))

            for f in files:
                if args.dry_run:
                    logger.info("  [dry-run] %s (%s)", f["file_name"], f["file_id"])
                    continue
                try:
                    recheck_file(session, api_url, api_key, args.project_alias,
                                 folder_id, f["file_id"])
                    stats["files"] += 1
                    logger.debug("  rechecked %s (%s)", f["file_name"], f["file_id"])
                except (requests.RequestException, ValueError) as err:
                    # Keep going; one bad file shouldn't stop the run.
                    logger.error("  %s (%s): %s", f["file_name"], f["file_id"], err)
                    stats["errors"] += 1

            if files and not args.dry_run:
                # The update endpoint doesn't return the check result, so re-read
                # the folder to log which files still fail after the recheck.
                try:
                    still_failing = files_to_recheck(session, api_url, api_key, folder_id)
                except (requests.RequestException, ValueError) as err:
                    logger.error("folder %s (%s): could not re-read results: %s",
                                 name, folder_id, err)
                    stats["errors"] += 1
                    continue
                stats["still_failing"] += len(still_failing)
                logger.info("folder %s (%s): %d fixed, %d still failing", name, folder_id,
                            len(files) - len(still_failing), len(still_failing))
                for f in still_failing:
                    logger.warning("  still failing: %s (%s)", f["file_name"], f["file_id"])

            # if not args.dry_run:
            try:
                res = recalculate_folder_stats(session, api_url, api_key, args.project_alias, folder_id)
                logger.info(f"folder {folder_id} stats recalculated")
            except (requests.RequestException, ValueError) as err:
                logger.error("project stats recalculation failed: %s", err)
                stats["errors"] += 1

    logger.info("done: %(folders)d folder(s), %(files)d file(s) rechecked, "
                "%(still_failing)d still failing, %(unmatched)d unmatched folder(s), "
                "%(errors)d error(s)", stats)
    return 1 if stats["errors"] else 0


if __name__ == "__main__":
    sys.exit(main())
