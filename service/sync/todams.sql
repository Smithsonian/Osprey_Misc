select f.project_folder from folders f, qc_folders qc where f.project_id = [PROJECTID] and f.delivered_to_dams = 9 and f.folder_id = qc.folder_id and qc.qc_status=0;