#!/bin/bash
#
# Coordinate steps in a project
#

PROJECT=""

# Create folder for logs, if it doesn't exists
mkdir -p /var/log/osprey/
# Set perms
chown -R [uid]:[gid] /var/log/osprey/
chmod -R 744 /var/log/osprey/

# Today's date
NOW=`date +"%Y-%m-%d"`

###################################
#  MOUNTS
###################################
# Prepare the system by mounting required systems
/data/server/"$PROJECT"_pre.sh >> /var/log/osprey/"$NOW"_"$PROJECT"_pre.log

retVal=$?
NOWTIME=`date +"%Y-%m-%d %H:%M:%S"`
if [ $retVal -ne 0 ]; then
    echo "$NOWTIME - There was an error with pre script. Exiting." >> /var/log/osprey/"$NOW"_"$PROJECT".log
    exit 9
else
    echo "$NOWTIME - pre script completed." >> /var/log/osprey/"$NOW"_"$PROJECT".log
fi




###################################
#  SYNC FILES
###################################
# Sync files with DAMS and the vendor
/data/server/"$PROJECT"_sync.sh >> /var/log/osprey/"$NOW"_"$PROJECT"_sync.log

retVal=$?
NOWTIME=`date +"%Y-%m-%d %H:%M:%S"`
if [ $retVal -ne 0 ]; then
    echo "$NOWTIME - There was an error with sync script. Exiting." >> /var/log/osprey/"$NOW"_"$PROJECT".log
    exit 9
else
    echo "$NOWTIME - sync script completed." >> /var/log/osprey/"$NOW"_"$PROJECT".log
fi




###################################
#  OSPREY WORKER
###################################
# Run osprey_worker
/data/server/"$PROJECT"_worker.sh >> /var/log/osprey/"$NOW"_"$PROJECT"_worker.log

retVal=$?
NOWTIME=`date +"%Y-%m-%d %H:%M:%S"`
if [ $retVal -ne 0 ]; then
    echo "$NOWTIME - There was an error with worker script. Exiting." >> /var/log/osprey/"$NOW"_"$PROJECT".log
    exit 9
else
    echo "$NOWTIME - worker script completed." >> /var/log/osprey/"$NOW"_"$PROJECT".log
fi





###################################
#  CLEANUP OF DELIVERED FOLDERS
###################################
# # Archive preview folders
# bash "/data/server/$PROJECT_cleanup.sh" >> /var/log/osprey/"$NOW"_"$PROJECT"_cleanup.log

# retVal=$?
# NOWTIME=`date +"%Y-%m-%d %H:%M:%S"`
# if [ $retVal -ne 0 ]; then
#     echo "$NOWTIME - There was an error with cleanup script. Exiting." >> /var/log/osprey/"$NOW"_"$PROJECT".log
#     exit 9
# else
#     echo "$NOWTIME - cleanup script completed." >> /var/log/osprey/"$NOW"_"$PROJECT".log
# fi


NOWTIME=`date +"%Y-%m-%d %H:%M:%S"`
echo "$NOWTIME - Sleeping for 2 hours..."
sleep 7200

exit 0
