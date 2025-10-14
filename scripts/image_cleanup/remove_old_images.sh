#!/usr/bin/env bash
# 
# Delete images older than 4 months
# Run from fsosprey02
# 
# ./remove_old_images.sh 
# 

rsync -rth --progress /mnt/MassDigi/data/osprey_previews/ /data/old_osprey_previews/
find /mnt/MassDigi/data/osprey_previews/ -type f -mtime +120 -delete
find /mnt/MassDigi/data/osprey_previews/ -type d -empty -delete
