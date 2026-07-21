#!/bin/bash
#
# Setup mounts where required
#

for DIR in nearline_storage/jpc_production/*; do
    if [ -d $DIR ]; then

        # Count .md5 files in subdirectories
        count=$(find "$DIR" -type f -name "*.md5" | wc -l)

        thisfol=`basename $DIR`
        # Check if there are exactly two .md5 files
        if [ "$count" -eq 2 ]; then
            echo "Syncing $thisfol "
            rsync -rth --info=progress2 --exclude=".*" $DIR working_storage/jpc_production/
        else
            if [ -d working_storage/jpc_production/$thisfol ]; then
                echo "Deleting $thisfol "
                rm -r working_storage/jpc_production/$thisfol
            fi
        fi
    fi
done
