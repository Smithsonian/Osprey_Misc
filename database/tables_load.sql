-- MySQL version of the Osprey database 
--  version 2.2.0
--  2023-05-16

LOAD DATA LOCAL INFILE 'users.csv' 
	INTO TABLE users 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(user_id, username, full_name, pass, user_active, is_admin);



LOAD DATA LOCAL INFILE 'api_keys.csv' 
	INTO TABLE api_keys 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(table_id, api_key, uid, expires_on, usage_rate, updated_at);


LOAD DATA LOCAL INFILE 'projects.csv' 
	INTO TABLE projects
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'projects_media.csv' 
	INTO TABLE projects_media
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;



LOAD DATA LOCAL INFILE 'folders.csv' 
	INTO TABLE folders
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'folders_md5.csv' 
	INTO TABLE folders_md5
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
	
LOAD DATA LOCAL INFILE 'files.csv' 
	INTO TABLE files
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, folder_id, file_name, file_timestamp, dams_uan, preview_image, updated_at);
	

LOAD DATA LOCAL INFILE 'files_checks.csv' 
	INTO TABLE files_checks 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, folder_id, file_check, check_results, check_info, updated_at);
	
	
LOAD DATA LOCAL INFILE 'file_md5.csv' 
	INTO TABLE file_md5 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, filetype, md5, updated_at);
	
LOAD DATA LOCAL INFILE 'files_size.csv' 
	INTO TABLE files_size 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, filetype, filesize, updated_at);
	

LOAD DATA LOCAL INFILE 'files_links.csv' 
	INTO TABLE files_links
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'files_exif_1.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_2.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);

LOAD DATA LOCAL INFILE 'files_exif_3_1.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_3_2.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
	
LOAD DATA LOCAL INFILE 'files_exif_4.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_5.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);

LOAD DATA LOCAL INFILE 'files_exif_6_1.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_2.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_3.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);

LOAD DATA LOCAL INFILE 'files_exif_6_3_1.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_3_2.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_3_3.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_3_4.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);

LOAD DATA LOCAL INFILE 'files_exif_6_4_1_1.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_4_1_2.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_4_1_3.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_4_1_4.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_4_1_5.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
	
LOAD DATA LOCAL INFILE 'files_exif_6_4_2.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_4_3.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_4_4.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_6_4_5.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);

LOAD DATA LOCAL INFILE 'files_exif_7.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);

LOAD DATA LOCAL INFILE 'files_exif_8_1.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_8_2.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_8_3.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);
LOAD DATA LOCAL INFILE 'files_exif_8_4.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);

LOAD DATA LOCAL INFILE 'files_exif_9.csv' 
	INTO TABLE files_exif 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, tag, value, filetype, tagid, taggroup, updated_at);


LOAD DATA LOCAL INFILE 'file_postprocessing.csv' 
	INTO TABLE file_postprocessing 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(file_id, post_step, post_results, post_info, updated_at);


LOAD DATA LOCAL INFILE 'projects_stats.csv' 
	INTO TABLE projects_stats
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;



LOAD DATA LOCAL INFILE 'qc_projects.csv' 
	INTO TABLE qc_projects 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(table_id, project_id, user_id);


LOAD DATA LOCAL INFILE 'qc_settings.csv' 
	INTO TABLE qc_settings 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(project_id, qc_level, qc_percent, qc_threshold_critical, qc_threshold_major, qc_threshold_minor, qc_normal_percent, qc_reduced_percent, qc_tightened_percent);


LOAD DATA LOCAL INFILE 'qc_folders.csv' 
	INTO TABLE qc_folders 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(folder_id, qc_status, qc_by, qc_ip, qc_info, updated_at);


LOAD DATA LOCAL INFILE 'qc_files.csv' 
	INTO TABLE qc_files 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(folder_id, file_id, file_qc, qc_info, qc_by, qc_ip, updated_at);



LOAD DATA LOCAL INFILE 'dams_cdis_file_status_view_dpo.csv' 
	INTO TABLE dams_cdis_file_status_view_dpo 
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'dams_vfcu_file_view_dpo.csv' 
	INTO TABLE dams_vfcu_file_view_dpo
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;



LOAD DATA LOCAL INFILE 'projects_stats_detail.csv' 
	INTO TABLE projects_stats_detail
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;



LOAD DATA LOCAL INFILE 'projects_settings_1.csv' 
	INTO TABLE projects_settings
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(project_id, project_setting, settings_value);

LOAD DATA LOCAL INFILE 'projects_settings_2.csv' 
	INTO TABLE projects_settings
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(project_id, project_setting, settings_value);



LOAD DATA LOCAL INFILE 'data_reports.csv' 
	INTO TABLE data_reports
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS
	(report_id, project_id, report_title, report_title_brief, query, query_api, query_updated, updated_at);


LOAD DATA LOCAL INFILE 'units.txt' 
	INTO TABLE si_units
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n';
	
	
	
	
LOAD DATA LOCAL INFILE 'jpc_aspace_resources.csv' 
	INTO TABLE jpc_aspace_resources
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;


LOAD DATA LOCAL INFILE 'jpc_aspace_data.csv' 
	INTO TABLE jpc_aspace_data
	FIELDS TERMINATED BY ',' 
	ENCLOSED BY '\"'
	LINES TERMINATED BY '\n'
	IGNORE 1 ROWS;
	
