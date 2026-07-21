"""CLI orchestration for Deep Zoom preview generation.

Flow:
  1. Load settings and validate API credentials
  2. Resolve folder_id from the parent name of INPUT_FOLDER
  3. Map each TIF stem to file_id via the dashboard API
  4. Write DZI + tiles under OUTPUT_FOLDER/folder{folder_id}/
"""

import argparse
from datetime import timedelta
import logging
import os
import sys
import time
from concurrent.futures import ProcessPoolExecutor, as_completed

from create_dzi_previews import __version__
from create_dzi_previews.dzi import create_deepzoom_preview
from create_dzi_previews.paths import resolve_preview_base, zoom_complete
from create_dzi_previews.registry import (
    discover_tifs,
    fetch_folder_info,
    fetch_project_info,
    resolve_file_ids,
    resolve_folder_id,
)
from create_dzi_previews.settings_loader import load_settings, validate_settings


def _configure_logging(verbose=False):
    """Send log output to stderr; INFO by default, DEBUG with -v."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(levelname)s | %(message)s",
        stream=sys.stderr,
    )
    return logging.getLogger("create_dzi_previews")


def _process_one(file_id, tif_path, preview_base, force):
    """
    Generate DZI for one TIF (used by serial and parallel workers).
    Returns (status, file_id, tif_path) where status is ok|skipped|failed.
    """
    if not force and zoom_complete(preview_base, file_id):
        return "skipped", file_id, tif_path
    ok = create_deepzoom_preview(file_id, tif_path, preview_base)
    return ("ok" if ok else "failed"), file_id, tif_path


def _emit_run_summary(logger, folder_name, folder_id, tif_count, start_ts):
    elapsed = timedelta(seconds=int(time.monotonic() - start_ts))
    summary = (
        f"SUMMARY | folder={folder_name} folder_id={folder_id} "
        f"tifs={tif_count} elapsed={elapsed}"
    )
    logger.info(summary)
    print(summary)


def _cleanup_legacy_outputs(logger, preview_base):
    """
    Delete legacy top-level artifacts in preview_base (no recursion).
    Only removes: *.jpg/*.jpeg and *.tar* (e.g. .tar, .tar.gz, .tgz).
    """
    try:
        names = os.listdir(preview_base)
    except OSError as e:
        logger.warning(f"Could not list preview directory for cleanup: {e}")
        return

    removed = 0
    for name in names:
        path = os.path.join(preview_base, name)
        if not os.path.isfile(path):
            continue

        lower = name.lower()
        is_jpg = lower.endswith(".jpg") or lower.endswith(".jpeg")
        is_tar = lower.endswith(".tar") or (".tar." in lower) or lower.endswith(".tgz")
        if not (is_jpg or is_tar):
            continue

        try:
            os.remove(path)
        except OSError as e:
            logger.warning(f"Failed deleting legacy output {name}: {e}")
            continue

        removed += 1
        logger.info(f"Deleted legacy output: {name}")

    if removed:
        logger.info(f"Deleted {removed} legacy output file(s) from {preview_base}")


def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Generate Deep Zoom (.dzi + tiles) previews from TIF files",
    )
    parser.add_argument("input_folder", help="Folder containing .tif files")
    parser.add_argument("output_folder", help="Root preview directory (writes folder{folder_id}/ inside)")
    default_settings = os.environ.get("OSPREY_SETTINGS")
    parser.add_argument(
        "--settings",
        default=default_settings,
        help="Path to settings.py (default: $OSPREY_SETTINGS or ./settings.py)",
    )
    parser.add_argument("--force", action="store_true", help="Regenerate even when outputs exist")
    parser.add_argument(
        "--workers",
        type=int,
        default=1,
        help="Parallel TIF processing (default: 1)",
    )
    parser.add_argument("--version", action="version", version=f"create_dzi_previews {__version__}")
    parser.add_argument("-v", "--verbose", action="store_true", help="Debug logging")
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    logger = _configure_logging(args.verbose)
    start_ts = time.monotonic()

    input_folder = os.path.abspath(args.input_folder)
    output_folder = os.path.abspath(args.output_folder)
    folder_name = os.path.basename(os.path.dirname(input_folder))
    folder_id = None
    tif_count = 0

    def finish(exit_code):
        _emit_run_summary(logger, folder_name, folder_id, tif_count, start_ts)
        return exit_code

    if not os.path.isdir(input_folder):
        logger.error(f"Input folder does not exist: {input_folder}")
        return finish(1)

    # API credentials: api_url, api_key, project_alias
    try:
        settings = load_settings(args.settings)
        validate_settings(settings)
    except (FileNotFoundError, ImportError, ValueError) as e:
        logger.error(str(e))
        return finish(1)

    project_info = fetch_project_info(settings, logger)
    if project_info is None:
        logger.error("Failed to fetch project info from API")
        return finish(1)

    # folder name = parent of input (e.g. USNM_20260707 from .../USNM_20260707/tifs)
    folder_result = resolve_folder_id(project_info, input_folder, logger)
    if folder_result is None:
        return finish(1)
    folder_id, transcription = folder_result

    folder_info = fetch_folder_info(settings, folder_id, logger)
    if folder_info is None:
        logger.error(f"Failed to fetch folder info for folder_id={folder_id}")
        return finish(1)

    # e.g. /data/images/folder123/
    preview_base = resolve_preview_base(folder_id, output_folder, transcription)
    os.makedirs(preview_base, exist_ok=True)
    logger.info(f"Preview output: {preview_base}")
    _cleanup_legacy_outputs(logger, preview_base)

    tif_paths = discover_tifs(input_folder)
    tif_count = len(tif_paths)
    if not tif_paths:
        logger.error(f"No .tif files found in {input_folder}")
        return finish(1)
    logger.info(f"Found {tif_count} TIF file(s)")

    # Match filename stems to dashboard file_id (no API writes)
    file_map, missing = resolve_file_ids(folder_info, tif_paths, logger)
    if missing and not file_map:
        logger.error("No TIF files could be matched to API file records")
        return finish(1)

    workers = max(1, args.workers)
    tasks = [(file_id, tif_path) for tif_path, file_id in file_map.items()]

    counts = {"ok": 0, "skipped": 0, "failed": 0}

    if workers == 1:
        for file_id, tif_path in tasks:
            status, _, path = _process_one(file_id, tif_path, preview_base, args.force)
            counts[status] += 1
            if status == "failed":
                logger.error(f"Failed: {os.path.basename(path)}")
            elif status == "skipped":
                logger.info(f"Skipping (already exists): {os.path.basename(path)}")
    else:
        # Each worker loads a full TIF; keep --workers low on memory-constrained hosts
        logger.info(f"Processing with {workers} workers")
        with ProcessPoolExecutor(max_workers=workers) as executor:
            futures = {
                executor.submit(_process_one, file_id, tif_path, preview_base, args.force): tif_path
                for file_id, tif_path in tasks
            }
            for future in as_completed(futures):
                tif_path = futures[future]
                try:
                    status, file_id, path = future.result()
                except Exception as e:
                    logger.error(f"Worker error for {os.path.basename(tif_path)}: {e}")
                    counts["failed"] += 1
                    continue
                counts[status] += 1
                if status == "failed":
                    logger.error(f"Failed: {os.path.basename(path)}")
                elif status == "skipped":
                    logger.info(f"Skipping (already exists): {os.path.basename(path)}")

    failed_total = counts["failed"] + len(missing)
    logger.info(
        f"Done: {counts['ok']} created, {counts['skipped']} skipped, "
        f"{counts['failed']} failed, {len(missing)} unmatched"
    )
    return finish(1 if failed_total else 0)


if __name__ == "__main__":
    sys.exit(main())
