"""Deep Zoom preview generation using vendored openzoom (same settings as Osprey Worker)."""

import logging
import os
import shutil

from create_dzi_previews.openzoom import ImageCreator

logger = logging.getLogger("create_dzi_previews")


def create_deepzoom_preview(file_id, source_path, dest_dir):
    """
    Create Deep Zoom preview under dest_dir.

    Writes {file_id}.dzi and {file_id}_files/ tile pyramid.
    Returns True on success, False on failure (partial output is removed).
    """
    zoom_folder = os.path.join(dest_dir, f"{file_id}_files")
    if os.path.exists(zoom_folder):
        shutil.rmtree(zoom_folder, ignore_errors=True)
    os.makedirs(dest_dir, exist_ok=True)

    dzi_path = os.path.join(dest_dir, f"{file_id}.dzi")
    if os.path.isfile(dzi_path):
        os.remove(dzi_path)

    # Parameters match worker/previews.py jpgpreview_zoom_to_dir
    creator = ImageCreator(
        tile_size=254,
        tile_format="jpg",
        image_quality=1.0,
        resize_filter="antialias",
    )
    try:
        creator.create(source_path, dzi_path)
    except Exception as e:
        logger.error(f"deepzoom create failed for {file_id}: {e}")
        # Remove partial outputs so a re-run starts clean
        if os.path.isfile(dzi_path):
            os.remove(dzi_path)
        if os.path.exists(zoom_folder):
            shutil.rmtree(zoom_folder, ignore_errors=True)
        return False

    logger.info(f"Zoom preview created for {file_id}")
    return True
