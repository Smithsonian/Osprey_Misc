#!/usr/bin/env python3
#
# Osprey Worker utility
# https://github.com/Smithsonian/Osprey_worker
#
# Given a folder name, resolve the folder_id via the Osprey Dashboard API
# (for the project configured as settings.project_alias), then generate
# JPG derivatives from the original images in that folder:
#
#   * fullsize  — un-resized master JPG used as the IIIF image source
#                 (same as the pipeline's `fullsize` preview artifact)
#   * 160       — 160px-max thumbnail (same as the pipeline's `thumb_160`)
#   * 800       — 800px-max thumbnail (same as the pipeline's `thumb_800`)
#
# and save them under <output>/folder{folder_id}/, matching the layout the
# main pipeline writes to (fullsize at the folder root, thumbnails under
# 160/ and 800/ subfolders, named by file_id — see worker/previews.py).
#
# This is a standalone, read-only companion to osprey_worker.py: it does
# not register folders/files or post checks to the dashboard itself. If
# the folder isn't already known to the dashboard for settings.project_alias,
# the script exits with an error rather than creating one.
#
# If the source folder (settings.project_datastorage/FOLDER) isn't found on
# disk, generate_specimens.sh (expected to live alongside this script) is
# run as a fallback, and the path is checked again afterward; if it's still
# missing, the script exits with an error.
#
# Likewise, a source image whose filename isn't already registered as a
# file for that folder (i.e. it has no file_id yet) is skipped with an
# error, since there's no file_id to name its thumbnails after.
#
# Usage:
#   python export_fullsize_jpgs.py FOLDER --output DIR [options]
#
# Example:
#   python export_fullsize_jpgs.py 20260101_batch1 --output /data/exports
#   # -> writes /data/exports/folder1234/{stem}.jpg (fullsize)
#   #    and    /data/exports/folder1234/{160,800}/{file_id}.jpg (thumbs)
#
############################################
# Import modules
############################################
import argparse
import importlib.util
import logging
import os
import subprocess
import sys
import time
from pathlib import Path

# Importing worker.version also runs worker/__init__.py, which sets
# PIL.Image.MAX_IMAGE_PIXELS = 1000000000 (same decompression-bomb guard
# used by the rest of the codebase). worker.api has no settings dependency,
# so both are safe to import before settings.py is loaded.
from worker.version import __version__ as ver
from worker.api import send_request

from PIL import Image

THUMB_SIZES = (160, 800)


############################################
# Settings loading (same convention as osprey_worker.py)
############################################
def _load_settings(settings_path):
    """Load settings module from file path into sys.modules['settings']."""
    if not settings_path:
        settings_path = os.path.join(os.getcwd(), "settings.py")
    if not os.path.isfile(settings_path):
        print(f"Fatal: settings file not found: {settings_path}", file=sys.stderr)
        sys.exit(1)
    spec = importlib.util.spec_from_file_location("settings", settings_path)
    if spec is None or spec.loader is None:
        print(f"Fatal: cannot load settings from {settings_path}", file=sys.stderr)
        sys.exit(1)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    sys.modules["settings"] = mod
    return mod


def _parse_args():
    parser = argparse.ArgumentParser(
        description="Export fullsize, 160, and 800 JPG derivatives for one folder of a project"
    )
    parser.add_argument("--version", action="version", version=f"export-fullsize-jpgs (osprey-worker {ver})")
    parser.add_argument("folder", help="Folder name (as stored in the dashboard / on disk)")
    parser.add_argument(
        "--settings",
        default=os.environ.get("OSPREY_SETTINGS"),
        help="Path to settings.py (default: $OSPREY_SETTINGS or ./settings.py)",
    )
    parser.add_argument(
        "--output", "-o",
        required=True,
        help="Parent directory in which folder{folder_id} will be created",
    )
    parser.add_argument(
        "--quality", type=int, default=92,
        help="JPEG quality for all derivatives (default: 92, matches the main pipeline)",
    )
    parser.add_argument(
        "--workers", type=int, default=None,
        help="Parallel processes for JPG conversion (default: settings.num_workers)",
    )
    parser.add_argument(
        "--overwrite", action="store_true",
        help="Regenerate JPGs that already exist in the output folder (default: skip existing files)",
    )
    return parser.parse_args()


def _setup_logger():
    logger = logging.getLogger("osprey.export_fullsize")
    logger.setLevel(logging.INFO)
    if not logger.handlers:
        handler = logging.StreamHandler()
        handler.setFormatter(logging.Formatter("%(levelname)s | %(message)s"))
        logger.addHandler(handler)
    return logger


############################################
# Folder / file discovery
############################################
def find_folder_id(api_url, api_key, project_alias, folder_name, logger):
    """
    Look up folder_id for folder_name under project_alias via the dashboard API.
    Returns folder_id, or None if the project or folder could not be resolved.
    """
    project_info = send_request(
        f"{api_url}/projects/{project_alias}", {"api_key": api_key}, logger, log_res=False
    )
    if project_info is None:
        logger.error(f"Could not retrieve project info for '{project_alias}' from the API")
        return None
    for folder in project_info.get("folders", []):
        if folder.get("folder") == folder_name:
            return folder.get("folder_id")
    return None


def run_generate_specimens(script_dir, folder_name, logger):
    """
    Run generate_specimens.sh (expected to live alongside this script) for
    folder_name. Used as a fallback both when the folder isn't found via the
    API and when the source folder isn't found on disk — e.g. to
    create/register the specimens for it. Returns True if the script was
    found and exited 0, False otherwise.
    """
    script_path = os.path.join(script_dir, "generate_specimens.sh")
    if not os.path.isfile(script_path):
        logger.error(f"generate_specimens.sh not found at {script_path}")
        return False
    logger.info(f"Running {script_path} '{folder_name}'...")
    try:
        result = subprocess.run(
            ["bash", script_path, folder_name],
            capture_output=True, text=True, timeout=600,
        )
    except subprocess.TimeoutExpired:
        logger.error(f"generate_specimens.sh timed out for folder '{folder_name}'")
        return False
    except OSError as e:
        logger.error(f"Could not run generate_specimens.sh: {e}")
        return False
    if result.stdout:
        logger.info(f"generate_specimens.sh stdout: {result.stdout.strip()}")
    if result.stderr:
        logger.info(f"generate_specimens.sh stderr: {result.stderr.strip()}")
    if result.returncode != 0:
        logger.error(f"generate_specimens.sh exited with code {result.returncode}")
        return False
    return True


def fetch_stem_to_file_id(api_url, api_key, folder_id, logger):
    """
    Fetch the files already registered for folder_id and return a
    {filename_stem: file_id} map. Thumbnails are named by file_id (matching
    the dashboard convention), so a source image only gets 160/800 previews
    if it's already registered as a file for this folder.
    """
    folder_info = send_request(
        f"{api_url}/folders/{folder_id}", {"api_key": api_key}, logger, log_res=False
    )
    if folder_info is None:
        return None
    return {f["file_name"]: f["file_id"] for f in folder_info.get("files", [])}


def find_source_images(source_folder, main_files_suffix):
    """
    Recursively walk source_folder and return sorted paths of files whose
    suffix matches main_files_suffix (e.g. ".tif").
    """
    images = []
    for root, _dirs, files in os.walk(source_folder):
        for name in files:
            if Path(name).suffix == main_files_suffix:
                images.append(os.path.join(root, name))
    images.sort()
    return images


############################################
# JPG conversion
############################################
def _save_fullsize_jpg(img, dest_path, quality=92):
    """
    Save img as a full-resolution JPG at dest_path, preserving the embedded
    ICC color profile and converting to RGB/L if needed. Matches
    worker.previews._save_fullsize_jpg, used by the main pipeline for the
    'fullsize' preview artifact.
    """
    original_profile = img.info.get("icc_profile")
    out = img
    if out.mode not in ("RGB", "L"):
        out = out.convert("RGB")
    out.save(dest_path, "jpeg", icc_profile=original_profile, quality=quality)


def _save_jpg_preview(img, dest_path, max_size, quality=92):
    """
    Save a resized JPG preview of img at dest_path, longest side == max_size.
    Matches worker.previews._save_jpg_preview, used by the main pipeline for
    the 'thumb_160' / 'thumb_800' preview artifacts.
    """
    original_profile = img.info.get("icc_profile")
    width_o, height_o = img.size
    ratio = min(max_size / width_o, max_size / height_o)
    newsize = (round(width_o * ratio), round(height_o * ratio))
    resized = img.resize(newsize)
    if resized.mode not in ("RGB", "L"):
        resized = resized.convert("RGB")
    resized.save(dest_path, "jpeg", icc_profile=original_profile, quality=quality)


def convert_previews(src_path, dest_paths, quality=92):
    """
    Generate the requested preview artifacts for one source image.
    dest_paths is a dict with any of the keys 'fullsize', 160, 800, mapping
    to the output path for that artifact; only the artifacts present are
    (re)generated. Opens the source image once and reuses it for all of them.
    """
    with Image.open(src_path) as img:
        if img.size[0] == 0 or img.size[1] == 0:
            raise ValueError(f"Image has zero width or height: {src_path}")
        if "fullsize" in dest_paths:
            _save_fullsize_jpg(img, dest_paths["fullsize"], quality=quality)
        for size in THUMB_SIZES:
            if size in dest_paths:
                _save_jpg_preview(img, dest_paths[size], size, quality=quality)


def _convert_one(task):
    """Worker task for parallel conversion. Must stay a top-level function to be picklable."""
    src_path, dest_paths, quality = task
    try:
        convert_previews(src_path, dest_paths, quality=quality)
        return src_path, True, None
    except Exception as e:
        return src_path, False, str(e)


############################################
# Main
############################################
def main():
    args = _parse_args()
    logger = _setup_logger()

    settings = _load_settings(args.settings)
    for name in ("project_alias", "api_url", "api_key", "project_datastorage", "main_files"):
        if not getattr(settings, name, None):
            logger.error(f"settings.{name} is not configured")
            sys.exit(1)

    script_dir = os.path.dirname(os.path.abspath(__file__))

    logger.info(
        f"Looking up folder_id for project='{settings.project_alias}' folder='{args.folder}'..."
    )
    folder_id = find_folder_id(
        settings.api_url, settings.api_key, settings.project_alias, args.folder, logger
    )
    if folder_id is None:
        logger.error(
            f"Folder '{args.folder}' not found for project '{settings.project_alias}' via the API. "
            "This script only exports folders the dashboard already knows about "
            "(it does not create folder records itself)."
        )
        sys.exit(1)
    logger.info(f"Resolved folder '{args.folder}' -> folder_id={folder_id}")

    stem_to_file_id = fetch_stem_to_file_id(settings.api_url, settings.api_key, folder_id, logger)
    if stem_to_file_id is None:
        logger.error(f"Could not retrieve the file list for folder_id={folder_id} via the API")
        sys.exit(1)

    source_folder = os.path.join(settings.project_datastorage, args.folder)
    if not os.path.isdir(source_folder):
        logger.info(f"Source folder not found on disk: {source_folder}")
        run_generate_specimens(script_dir, args.folder, logger)
        if not os.path.isdir(source_folder):
            logger.error(f"Source folder still not found on disk (even after running generate_specimens.sh): {source_folder}")
            sys.exit(1)
        logger.info(f"Source folder now found on disk: {source_folder}")

    images = find_source_images(source_folder, settings.main_files)
    if not images:
        logger.error(f"No files with suffix '{settings.main_files}' found under {source_folder}")
        sys.exit(1)
    logger.info(f"Found {len(images)} source image(s) in {source_folder}")

    dest_dir = os.path.join(args.output, f"folder{folder_id}")
    thumb_dirs = {size: os.path.join(dest_dir, str(size)) for size in THUMB_SIZES}
    os.makedirs(dest_dir, exist_ok=True)
    for thumb_dir in thumb_dirs.values():
        os.makedirs(thumb_dir, exist_ok=True)
    logger.info(
        f"Writing previews to {dest_dir} "
        f"(fullsize, {', '.join(str(s) for s in THUMB_SIZES)})"
    )

    tasks = []
    skipped = 0
    unregistered = []
    for src_path in images:
        stem = Path(src_path).stem
        file_id = stem_to_file_id.get(stem)
        if file_id is None:
            unregistered.append(src_path)
            continue

        candidate_paths = {"fullsize": os.path.join(dest_dir, f"{stem}.jpg")}
        for size in THUMB_SIZES:
            candidate_paths[size] = os.path.join(thumb_dirs[size], f"{file_id}.jpg")

        if args.overwrite:
            missing = candidate_paths
        else:
            missing = {k: v for k, v in candidate_paths.items() if not os.path.isfile(v)}
        if not missing:
            skipped += 1
            continue
        tasks.append((src_path, missing, args.quality))

    if unregistered:
        shown = ", ".join(Path(p).name for p in unregistered[:10])
        more = " ..." if len(unregistered) > 10 else ""
        logger.error(
            f"{len(unregistered)} file(s) have no matching file_id in the dashboard for this "
            f"folder and were skipped: {shown}{more}"
        )

    if skipped:
        logger.info(
            f"Skipping {skipped} file(s) that already have all previews (use --overwrite to redo)"
        )

    if not tasks:
        if unregistered:
            sys.exit(1)
        logger.info("Nothing to do; all previews already exist")
        return True

    workers = args.workers if args.workers is not None else getattr(settings, "num_workers", 1)
    workers = max(1, workers)

    start = time.monotonic()
    ok_count = 0
    errors = []
    total = len(tasks)

    def _progress(i):
        if i == 1 or i == total or i % 10 == 0:
            logger.info(f"Converted {i}/{total}")

    if workers > 1:
        from concurrent.futures import ProcessPoolExecutor, as_completed
        with ProcessPoolExecutor(max_workers=workers) as executor:
            futures = {executor.submit(_convert_one, t): t[0] for t in tasks}
            for i, future in enumerate(as_completed(futures), start=1):
                src_path, ok, err = future.result()
                if ok:
                    ok_count += 1
                else:
                    errors.append((src_path, err))
                    logger.error(f"Failed to convert {src_path}: {err}")
                _progress(i)
    else:
        for i, t in enumerate(tasks, start=1):
            src_path, ok, err = _convert_one(t)
            if ok:
                ok_count += 1
            else:
                errors.append((src_path, err))
                logger.error(f"Failed to convert {src_path}: {err}")
            _progress(i)

    elapsed = time.monotonic() - start
    logger.info(
        f"Done: {ok_count}/{total} converted, {len(errors)} failed, "
        f"{skipped} skipped, {len(unregistered)} unregistered ({elapsed:.1f}s)"
    )

    if errors or unregistered:
        sys.exit(1)
    return True


if __name__ == "__main__":
    main()
