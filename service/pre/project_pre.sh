#!/bin/bash
#
# Setup mounts where required
#

# Check mount
if grep -qs '/mnt/vendor' /proc/mounts; then
    NOW=`date +"%Y-%m-%d %H:%M:%S"`
    echo "$NOW - /mnt/vendor is mounted."
    exit 0
else
    # Not mounted, try mounting 
    echo "$NOW - /mnt/vendor is not mounted, trying to mount."
    # MOUNT COMMAND
    mount -t cifs -o vers=3.0,username="",password="",uid=,gid= //server/folder /mnt/vendor
    sleep 5
    if grep -qs '/mnt/vendor' /proc/mounts; then
        NOW=`date +"%Y-%m-%d %H:%M:%S"`
        echo "$NOW - /mnt/vendor is mounted."
        exit 0
    else
        NOW=`date +"%Y-%m-%d %H:%M:%S"`
        echo "$NOW - ERROR: /mnt/vendor couldn't be mounted"
        exit 9
    fi
fi
