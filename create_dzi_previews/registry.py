"""Resolve folder_id and file_id from the Osprey Dashboard API.

All lookups are read-only; files and folders must already exist in the dashboard.
"""

from pathlib import Path

from create_dzi_previews.api import send_request
from create_dzi_previews.paths import dashboard_folder_name


def fetch_project_info(settings, logger):
    """POST {api_url}/projects/{project_alias} -> project info dict."""
    payload = {"api_key": settings.api_key}
    return send_request(
        f"{settings.api_url}/projects/{settings.project_alias}",
        payload,
        logger,
    )


def resolve_folder_id(project_info, tif_folder, logger):
    """
    Look up folder_id from the dashboard folder name (parent of tif_folder).

    Example: tif_folder=/data/USNM_20260707/tifs -> folder_name=USNM_20260707
    Returns (folder_id, transcription) or None if the folder is not in the project.
    """
    folder_name = dashboard_folder_name(tif_folder)
    transcription = project_info.get("transcription", 0)
    folders = project_info.get("folders") or []

    for folder in folders:
        if folder.get("folder") == folder_name:
            folder_id = folder.get("folder_id")
            logger.info(f"Resolved folder {folder_name!r} -> folder_id={folder_id}")
            return folder_id, transcription

    logger.error(f"Folder {folder_name!r} not found in project (from {tif_folder})")
    return None


def fetch_folder_info(settings, folder_id, logger):
    """POST {api_url}/folders/{folder_id} -> folder info dict."""
    payload = {"api_key": settings.api_key}
    return send_request(
        f"{settings.api_url}/folders/{folder_id}",
        payload,
        logger,
    )


def resolve_file_ids(folder_info, tif_paths, logger):
    """
    Map absolute TIF paths to dashboard file_id by matching filename stem.

    Dashboard stores file_name without extension; e.g. page001.tif -> stem page001.
    Returns (file_map, missing_paths).
    """
    stem_to_id = {
        f["file_name"]: f["file_id"]
        for f in (folder_info.get("files") or [])
    }
    file_map = {}
    missing = []
    for tif_path in tif_paths:
        stem = Path(tif_path).stem
        file_id = stem_to_id.get(stem)
        if file_id is None:
            logger.error(f"No API file_id for {Path(tif_path).name} (stem={stem!r})")
            missing.append(tif_path)
        else:
            file_map[tif_path] = file_id
    return file_map, missing


def discover_tifs(tif_folder):
    """Return sorted absolute paths of .tif files in tif_folder (non-recursive)."""
    folder = Path(tif_folder)
    tifs = []
    for entry in folder.iterdir():
        # Case-insensitive .tif match; worker uses .tif as main_files
        if entry.is_file() and entry.suffix.lower() == ".tif":
            tifs.append(str(entry.resolve()))
    return sorted(tifs)
