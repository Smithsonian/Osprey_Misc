#!/usr/bin/env bash
# 
# Export the list of folders ready for dams and with approved QC

mysql -e "select concat('- ', project_folder) as pf from folders f, qc_folders qc where f.project_id = 201 and f.delivered_to_dams = 9 and f.folder_id = qc.folder_id and qc.qc_status=0;" > jpc.txt

sed -i '1d' jpc.txt
