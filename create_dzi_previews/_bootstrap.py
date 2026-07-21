"""Ensure the package parent directory is on sys.path."""

import os
import sys


def ensure_package_path():
    """
    Add the directory containing the create_dzi_previews package to sys.path.

    Required when running via run.py or __main__.py directly instead of
    `python -m create_dzi_previews` from the parent directory.
    """
    parent = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    if parent not in sys.path:
        sys.path.insert(0, parent)
