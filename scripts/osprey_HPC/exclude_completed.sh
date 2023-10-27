#!/bin/bash
#
# Exclude folders tagged as "Ready for DAMS" or "Delivered to DAMS"
# Not run in Hydra due to firewall blocking access to db
# 

excluded_file="[OSPREY FOLDER]/excluded.txt"

# Write the folders to exclude to file
mysql -e "select concat('- ', project_folder) as pf from folders where project_id = [PROJECT_ID] and delivered_to_dams != 9;" > $excluded_file

# Remove first line
sed -i '1d' $excluded_file
