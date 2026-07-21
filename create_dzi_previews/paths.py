"""Preview output path helpers (aligned with worker/previews.py layout)."""

import os


def resolve_preview_base(folder_id, jpg_previews, transcription=0):
    """
    Preview directory for a folder, aligned with worker pipeline layout.
    transcription=1 -> {jpg_previews}/{folder_id}
    otherwise        -> {jpg_previews}/folder{folder_id}
    """
    if transcription == 1:
        return f"{jpg_previews}/{folder_id}"
    return f"{jpg_previews}/folder{folder_id}"


def dashboard_folder_name(tif_folder):
    """
    Return the dashboard folder name used for API lookup.

    INPUT_FOLDER is typically a TIF subfolder (e.g. .../USNM_20260707/tifs);
    the dashboard folder name is the parent directory name (USNM_20260707).
    """
    from pathlib import Path

    return Path(tif_folder).resolve().parent.name


def zoom_complete(preview_base, file_id):
    """Return True when both the .dzi descriptor and _files tile directory exist."""
    if not os.path.isfile(os.path.join(preview_base, f"{file_id}.dzi")):
        return False
    return os.path.isdir(os.path.join(preview_base, f"{file_id}_files"))
