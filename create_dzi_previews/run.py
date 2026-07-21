#!/usr/bin/env python3
"""Run create_dzi_previews from any working directory.

Usage:
  python create_dzi_previews/run.py INPUT_FOLDER OUTPUT_FOLDER --settings settings.py

Or from inside this folder:
  python run.py INPUT_FOLDER OUTPUT_FOLDER --settings ../settings.py
"""

import os
import sys

# Bootstrap before package imports (this file lives inside the package directory)
_parent = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _parent not in sys.path:
    sys.path.insert(0, _parent)

from create_dzi_previews.cli import main

if __name__ == "__main__":
    sys.exit(main())
