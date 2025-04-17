#!/bin/bash
#
# Sync files for a project between the vendor and DAMS
#

PROJECT=""
PROJECTID=""
PROJECT_VENDOR="/mnt/"
MASSDIGI_SHARE="/mnt/"
PROJECT_TEMP='/mnt/MassDigi/to_dams/temp/"$PROJECT"/'
PROJECT_TODAMS="/mnt/MassDigi/to_dams/"


# Update DAMS Status
cd /server_path/auto_check_DAMS
source venv/bin/activate
python3 autocheck_dams.py "$PROJECT"
deactivate


cd /server_path/

# Set done folders
echo "Getting done folders..."
mysql --defaults-file=mysql.cnf < "$PROJECT"_excluded.sql > "$PROJECT"_excluded.txt
sed -i '1d' "$PROJECT"_excluded.txt


echo "Getting folders to deliver to DAMS..."
# Get folders ready for DAMS, those that passed QC
mysql --defaults-file=mysql.cnf < "$PROJECT"_todams.sql > "$PROJECT"_postqc.txt
sed -i '1d' "$PROJECT"_postqc.txt


    # Move to share, one by one
    # Check if there are any folders in file 
    if [ -s "$PROJECT"_postqc.txt ]; then
        while IFS= read -r line
            do
            echo "$line"
            
            # Leave 1TB
            reqSpace=1000000000
            availSpace=$(df "$MASSDIGI_SHARE" | awk 'NR==2 { print $4 }')
            if (( availSpace < reqSpace )); then
                echo "Not enough space in share"
            else
                rsync -rthW --inplace --progress --exclude=".*" /data/project_data/[PROJECT]/"$line" "$PROJECT_TEMP"
                echo "Moving from temp..."
                mv "$PROJECT_TEMP"/"$line" "$PROJECT_TODAMS"
                # Tag in system as "Ready for DAMS"
                cd /server/folder_dams_process
                source venv/bin/activate
                python3 named_folder_todams.py "$line"
                deactivate
            fi
        done < "$PROJECT"_postqc.txt
    fi


# Copy from vendor location
echo "Syncing files from vendor..."
rsync -rthW --inplace --exclude="*.md5" --exclude=".*" --exclude="CaptureOne" --exclude="targets" --exclude-from="$PROJECT"_excluded.txt --delete-excluded --progress "$PROJECT_VENDOR"/ /server/"$PROJECT"/

retVal=$?
NOWTIME=`date +"%Y-%m-%d %H:%M:%S"`
if [ $retVal -ne 0 ]; then
    echo "$NOWTIME - There was an error with syncing. Exiting."
    exit 9
fi

exit 0
