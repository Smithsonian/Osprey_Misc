#!/bin/bash
#
# Write file to indicate process is running

folder_name=`basename "$PWD"`

touch $HOME/osprey/$folder_name.txt

rsync -ruth --delete --progress --exclude-from='excluded.txt' --exclude="*.md5" --delete-excluded $HOME/nearline_storage/$folder_name/ $HOME/working_storage/$folder_name/

rsync -ruth --delete --progress --exclude-from='excluded.txt' --delete-excluded $HOME/nearline_storage/$folder_name/ $HOME/working_storage/$folder_name/
