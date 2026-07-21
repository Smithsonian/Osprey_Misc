"""Entry point for: python -m create_dzi_previews (from parent directory)."""

import os
import sys

# Also works when invoked as: python create_dzi_previews/__main__.py
_parent = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _parent not in sys.path:
    sys.path.insert(0, _parent)

from create_dzi_previews.cli import main

sys.exit(main())
