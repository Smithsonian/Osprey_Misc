#!/bin/bash
#
# Sync files for a project between the vendor and DAMS
#

PROJECT=""
CREATE_MD5=0


# MD5 files
if [ $CREATE_MD5 -ne 0 ]; then
    echo "$NOWTIME - Creating MD5 files. "
    for f in /server/"$PROJECT"/*; do
        if [ -d "$f" ]; then
            # $f is a directory
            echo "Running on $f"
            md5tool_parallel $f 12
        fi
    done
fi


# Run osprey_worker
cd /server/osprey/"$PROJECT"
source venv/bin/activate
python3 osprey_worker.py debug
deactivate


exit 0
