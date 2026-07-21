#!/bin/bash
#

cd /home/idm/villanueval/scripts/osprey_db_cleanup

source venv/bin/activate

pip install -U pip
pip install -U -r requirements.txt

./osprey_db_cleanup.py

deactivate

cd
