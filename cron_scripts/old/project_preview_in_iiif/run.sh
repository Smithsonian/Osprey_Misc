#!/bin/bash
#
# Export the reports from Osprey to Dropbox
#
source venv/bin/activate

python3 project_preview_in_iiif.py

deactivate

