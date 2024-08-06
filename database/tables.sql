-- MySQL version of the Osprey database 
--  version 2.7.11
--  2024-07-24

-- uuid v4 function
/* CREATE FUNCTION uuid_v4s()
    RETURNS CHAR(36)
BEGIN
    -- 1th and 2nd block are made of 6 random bytes
    SET @h1 = HEX(RANDOM_BYTES(4));
    SET @h2 = HEX(RANDOM_BYTES(2));

    -- 3th block will start with a 4 indicating the version, remaining is random
    SET @h3 = SUBSTR(HEX(RANDOM_BYTES(2)), 2, 3);

    -- 4th block first nibble can only be 8, 9 A or B, remaining is random
    SET @h4 = CONCAT(HEX(FLOOR(ASCII(RANDOM_BYTES(1)) / 64)+8),
                SUBSTR(HEX(RANDOM_BYTES(2)), 2, 3));

    -- 5th block is made of 6 random bytes
    SET @h5 = HEX(RANDOM_BYTES(6));

    -- Build the complete UUID
    RETURN LOWER(CONCAT(
        @h1, '-', @h2, '-4', @h3, '-', @h4, '-', @h5
    ));
end */


-- api_keys
CREATE TABLE `api_keys` (
  `table_id` mediumint NOT NULL AUTO_INCREMENT,
  `api_key` varchar(36) DEFAULT NULL,
  `uid` varchar(36) DEFAULT NULL,
  `expires_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usage_rate` smallint NOT NULL DEFAULT '100',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `api_keys_api_key_IDX` (`api_key`) USING BTREE
);


-- api_keys_usage
CREATE TABLE `api_keys_usage` (
  `tableid` int NOT NULL AUTO_INCREMENT,
  `api_key` varchar(36) DEFAULT NULL,
  `url` text,
  `params` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `valid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`tableid`),
  KEY `api_key_idx` (`api_key`) USING BTREE
);


-- dams_cdis_file_status_view_dpo
CREATE TABLE `dams_cdis_file_status_view_dpo` (
  `vfcu_media_file_id` varchar(12) DEFAULT NULL,
  `file_name` varchar(254) DEFAULT NULL,
  `project_cd` varchar(96) DEFAULT NULL,
  `dams_uan` varchar(96) DEFAULT NULL,
  `to_dams_ingest_dt` timestamp NULL DEFAULT NULL,
  KEY `dams_cdis_stat_damsuan_idx` (`dams_uan`) USING BTREE,
  KEY `dams_cdis_stat_fileid_idx` (`vfcu_media_file_id`) USING BTREE,
  KEY `dams_cdis_stat_filename_idx` (`file_name`) USING BTREE,
  KEY `dams_cdis_stat_pcd_idx` (`project_cd`) USING BTREE
);


-- dams_vfcu_file_view_dpo
CREATE TABLE `dams_vfcu_file_view_dpo` (
  `vfcu_media_file_id` varchar(12) DEFAULT NULL,
  `project_cd` varchar(96) DEFAULT NULL,
  `media_file_name` varchar(254) DEFAULT NULL,
  `vfcu_pickup_loc` varchar(254) DEFAULT NULL,
  `vfcu_checksum` varchar(32) DEFAULT NULL,
  KEY `dams_vfcu_file_fileid_idx` (`vfcu_media_file_id`) USING BTREE,
  KEY `dams_vfcu_file_mediafilename_idx` (`media_file_name`) USING BTREE,
  KEY `dams_vfcu_file_pickuploc_idx` (`vfcu_pickup_loc`) USING BTREE,
  KEY `dams_vfcu_file_projectid_idx` (`project_cd`) USING BTREE
);


-- data_reports
CREATE TABLE `data_reports` (
  `report_id` varchar(64) NOT NULL,
  `project_id` int NOT NULL,
  `report_title` varchar(264) NOT NULL,
  `report_title_brief` varchar(64) DEFAULT NULL,
  `query` text NOT NULL,
  `query_api` text NOT NULL,
  `query_updated` text NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `report_alias` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `data_reports_pid_idx` (`project_id`) USING BTREE,
  KEY `data_reports_rid_idx` (`report_id`) USING BTREE,
  KEY `data_reports_ralias_idx` (`report_alias`) USING BTREE,
  CONSTRAINT `project_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- dates_table
CREATE TABLE `dates_table` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `dayweek` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `holiday` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`table_id`),
  KEY `dates_table_date_IDX` (`date`) USING BTREE,
  KEY `dates_table_dayweek_IDX` (`dayweek`) USING BTREE,
  KEY `dates_table_holiday_IDX` (`holiday`) USING BTREE
);


-- file_md5
CREATE TABLE `file_md5` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `filetype` varchar(8) DEFAULT NULL,
  `md5` varchar(128) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `file_and_type` (`file_id`,`filetype`),
  KEY `file_md5_tid_idx` (`table_id`) USING BTREE,
  KEY `file_md5_file_id_idx` (`file_id`) USING BTREE,
  KEY `file_md5_filetype_idx` (`filetype`) USING BTREE,
  KEY `file_md5_file_id2_idx` (`file_id`,`filetype`) USING BTREE,
  CONSTRAINT `fmd5_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- file_postprocessing
CREATE TABLE `file_postprocessing` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `post_step` varchar(64) DEFAULT NULL,
  `post_results` int DEFAULT NULL,
  `post_info` text,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `table_id` (`table_id`),
  UNIQUE KEY `fpp_fileid_and_poststep` (`file_id`,`post_step`),
  UNIQUE KEY `fid_postst` (`file_id`,`post_step`),
  KEY `file_postprocessing_tid_idx` (`table_id`) USING BTREE,
  KEY `file_postprocessing_file_id_idx` (`file_id`) USING BTREE,
  KEY `file_postprocessing_post_step_idx` (`post_step`) USING BTREE,
  KEY `file_postprocessing_check_results_idx` (`post_results`) USING BTREE,
  CONSTRAINT `fpost_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- files
CREATE TABLE `files` (
  `file_id` int NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `file_name` varchar(254) DEFAULT NULL,
  `file_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `dams_uan` varchar(254) DEFAULT NULL,
  `preview_image` varchar(254) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uid` varchar(36) DEFAULT NULL,
  `file_ext` varchar(8) DEFAULT 'tif',
  `sensitive_contents` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`file_id`),
  UNIQUE KEY `files_constr` (`file_name`,`folder_id`),
  KEY `files_fileid_idx` (`file_id`) USING BTREE,
  KEY `files_folderid_idx` (`folder_id`) USING BTREE,
  KEY `files_ffid_idx` (`folder_id`,`file_id`) USING BTREE,
  KEY `files_fileuid_idx` (`uid`) USING BTREE,
  CONSTRAINT `fk_foldfile` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- files_checks
CREATE TABLE `files_checks` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `folder_id` int DEFAULT NULL,
  `file_check` varchar(64) DEFAULT NULL,
  `check_results` int DEFAULT NULL,
  `check_info` text,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `uid` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `filechecks_constr` (`file_id`,`file_check`),
  UNIQUE KEY `fid_check` (`file_id`,`file_check`),
  KEY `file_checks1_tid_idx` (`table_id`) USING BTREE,
  KEY `file_checks1_file_id_idx` (`file_id`) USING BTREE,
  KEY `file_checks1_file_check_idx` (`file_check`) USING BTREE,
  KEY `file_checks1_check_results_idx` (`check_results`) USING BTREE,
  KEY `file_checks1_fil_id_idx` (`file_id`,`check_results`) USING BTREE,
  KEY `file_checks1_fc_id_idx` (`folder_id`,`check_results`) USING BTREE,
  KEY `file_checks1_ff_id_idx` (`folder_id`,`file_id`) USING BTREE,
  KEY `file_checks1_file_uid_idx` (`uid`) USING BTREE,
  CONSTRAINT `fckecks_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fckecks_folders` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- files_exif
CREATE TABLE `files_exif` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `filetype` varchar(8) DEFAULT 'TIF',
  `tag` varchar(254) DEFAULT NULL,
  `taggroup` varchar(254) DEFAULT NULL,
  `tagid` varchar(128) DEFAULT NULL,
  `value` text,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `table_id` (`table_id`),
  UNIQUE KEY `fileexif_fileid` (`file_id`,`tag`,`filetype`),
  UNIQUE KEY `fid_type_tag` (`file_id`,`filetype`,`tagid`,`tag`,`taggroup`),
  KEY `files_exif1_tid_idx` (`table_id`) USING BTREE,
  KEY `files_exif1_file_id_idx` (`file_id`) USING BTREE,
  KEY `files_exif1_filetype_idx` (`filetype`) USING BTREE,
  KEY `files_exif1_fid_idx` (`file_id`,`filetype`) USING BTREE,
  KEY `files_exif1_tag_idx` (`tag`) USING BTREE,
  KEY `files_exif1_tagid_idx` (`tagid`) USING BTREE,
  KEY `files_exif1_taggroup_idx` (`taggroup`) USING BTREE,
  CONSTRAINT `fexif_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- files_links
CREATE TABLE `files_links` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `link_name` varchar(254) DEFAULT NULL,
  `link_url` varchar(254) DEFAULT NULL,
  `link_notes` varchar(254) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `link_aria` varchar(254) DEFAULT NULL,
  UNIQUE KEY `table_id` (`table_id`),
  KEY `files_links_tid_idx` (`table_id`) USING BTREE,
  KEY `files_links_fid_idx` (`file_id`) USING BTREE,
  KEY `files_links_lnk_idx` (`link_name`) USING BTREE,
  CONSTRAINT `flinks_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- files_size
CREATE TABLE `files_size` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `filetype` varchar(8) DEFAULT 'TIF',
  `filesize` varchar(64) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `filesize_fileid_filetype` (`file_id`,`filetype`),
  UNIQUE KEY `fid_ftype` (`file_id`,`filetype`),
  KEY `files_size_tid_idx` (`table_id`) USING BTREE,
  KEY `files_size_file_id_idx` (`file_id`) USING BTREE,
  KEY `files_size_filetype_idx` (`filetype`) USING BTREE,
  KEY `files_size_file_id2_idx` (`file_id`,`filetype`) USING BTREE,
  CONSTRAINT `fsize_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- folders
CREATE TABLE `folders` (
  `folder_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `project_folder` varchar(254) DEFAULT NULL,
  `folder_path` varchar(254) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `notes` text,
  `error_info` varchar(254) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `delivered_to_dams` int DEFAULT '9',
  `processing` tinyint(1) DEFAULT '0',
  `processing_md5` tinyint(1) DEFAULT '0',
  `no_files` int DEFAULT NULL,
  `file_errors` int DEFAULT '9',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `sensitive_contents` tinyint(1) DEFAULT '9',
  PRIMARY KEY (`folder_id`),
  KEY `folders_fid_idx` (`folder_id`) USING BTREE,
  KEY `folders_pid_idx` (`project_id`) USING BTREE,
  CONSTRAINT `fk_foldproj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- folders_badges
CREATE TABLE `folders_badges` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `badge_type` varchar(24) DEFAULT NULL,
  `badge_css` varchar(24) DEFAULT NULL,
  `badge_text` varchar(64) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `badge_type_text` (`folder_id`,`badge_type`,`badge_text`),
  UNIQUE KEY `fid_type_badge` (`folder_id`,`badge_type`),
  KEY `folders_badges_tid_idx` (`table_id`) USING BTREE,
  KEY `folders_badges_fid_idx` (`folder_id`) USING BTREE,
  KEY `folders_badges_type_fid_idx` (`badge_type`) USING BTREE,
  CONSTRAINT `fk_foldbadge` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- folders_links
CREATE TABLE `folders_links` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `link_text` varchar(254) DEFAULT NULL,
  `link_url` varchar(254) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  KEY `folders_links_tid_idx` (`table_id`) USING BTREE,
  KEY `folders_links_fid_idx` (`folder_id`) USING BTREE,
  CONSTRAINT `fk_foldlink` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- folders_md5
CREATE TABLE `folders_md5` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `md5_type` varchar(12) DEFAULT NULL,
  `md5` int DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `folderid_and_type` (`folder_id`,`md5_type`),
  UNIQUE KEY `folid_md5` (`folder_id`,`md5_type`),
  KEY `folders_md5_fid_idx` (`folder_id`) USING BTREE,
  KEY `folders_md5_tid_idx` (`table_id`) USING BTREE,
  CONSTRAINT `fk_foldmd5` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- general_stats
CREATE TABLE `general_stats` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `interval_stat` varchar(12) DEFAULT NULL,
  `date_stat` varchar(12) DEFAULT NULL,
  `sort_by` smallint DEFAULT NULL,
  `images` int DEFAULT NULL,
  `objects` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `table_id` (`table_id`),
  KEY `general_stats_tid_idx` (`interval_stat`) USING BTREE
);


-- informatics_software
CREATE TABLE `informatics_software` (
  `software_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `software_name` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `software_details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `repository` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `more_info` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sortby` int NOT NULL,
  PRIMARY KEY (`software_id`)
);


-- jpc_aspace_data
CREATE TABLE `jpc_aspace_data` (
  `table_id` varchar(64) NOT NULL,
  `resource_id` varchar(128) NOT NULL,
  `refid` varchar(64) NOT NULL,
  `archive_box` varchar(64) NOT NULL,
  `archive_type` varchar(254) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `archive_folder` varchar(64) NOT NULL,
  `unit_title` varchar(168) DEFAULT NULL,
  `url` varchar(254) DEFAULT NULL,
  `notes` text,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `creation_date` date DEFAULT NULL,
  `mod_date` date DEFAULT NULL,
  `scopecontent` text,
  KEY `jpc_aspace_data_box_idx` (`archive_box`) USING BTREE,
  KEY `jpc_aspace_data_folder_idx` (`archive_folder`) USING BTREE,
  KEY `jpc_aspace_data_name_idx` (`unit_title`) USING BTREE,
  KEY `jpc_aspace_data_refid_idx` (`refid`) USING BTREE,
  KEY `jpc_aspace_data_resid_idx` (`resource_id`) USING BTREE,
  KEY `jpc_aspace_data_type_idx` (`archive_type`) USING BTREE
);


-- jpc_aspace_resources
CREATE TABLE `jpc_aspace_resources` (
  `table_id` varchar(64) NOT NULL,
  `resource_id` varchar(128) NOT NULL,
  `repository_id` varchar(128) NOT NULL,
  `resource_title` varchar(128) NOT NULL,
  `resource_tree` varchar(128) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `jpc_aspace_resources_resid_idx` (`resource_id`) USING BTREE,
  KEY `jpc_aspace_resources_tid_idx` (`table_id`) USING BTREE
);


-- jpc_massdigi_ids
CREATE TABLE `jpc_massdigi_ids` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_relationship` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id1_value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id2_value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `table_id` (`table_id`)
);


-- projects
CREATE TABLE `projects` (
  `project_id` int NOT NULL AUTO_INCREMENT,
  `proj_id` varchar(36) DEFAULT NULL,
  `project_title` varchar(254) DEFAULT NULL,
  `project_alias` varchar(64) DEFAULT NULL,
  `project_unit` varchar(24) DEFAULT NULL,
  `project_checks` varchar(254) DEFAULT 'raw_pair,magick,jhove,tifpages,unique_file',
  `project_postprocessing` char(254) DEFAULT NULL,
  `project_status` varchar(24) DEFAULT NULL,
  `project_description` text,
  `project_type` varchar(24) DEFAULT 'production',
  `project_method` varchar(24) DEFAULT NULL,
  `project_manager` varchar(96) DEFAULT NULL,
  `project_section` varchar(4) DEFAULT NULL,
  `project_coordurl` char(254) DEFAULT NULL,
  `project_area` varchar(64) DEFAULT NULL,
  `project_start` date DEFAULT NULL,
  `project_end` date DEFAULT NULL,
  `project_datastorage` varchar(254) DEFAULT NULL,
  `project_img_2_object` varchar(8) DEFAULT NULL,
  `stats_estimated` tinyint(1) DEFAULT '1',
  `images_estimated` tinyint(1) DEFAULT '0',
  `objects_estimated` tinyint(1) DEFAULT '0',
  `qc_status` tinyint DEFAULT '0',
  `project_notice` text,
  `projects_order` smallint DEFAULT NULL,
  `skip_project` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `dams_project_cd` varchar(254) DEFAULT NULL,
  `project_object_query` varchar(254) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'count(f.file_name)',
  `obj_type` varchar(16) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'Objects',
  `stats_page` tinyint NOT NULL DEFAULT '0',
  `project_message` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`project_id`),
  KEY `projects_pid_idx` (`project_id`) USING BTREE,
  KEY `projects_pjd_idx` (`proj_id`) USING BTREE,
  KEY `projects_palias_idx` (`project_alias`) USING BTREE,
  KEY `projects_status_idx` (`project_status`) USING BTREE
);


-- projects_detail_statistics
CREATE TABLE `projects_detail_statistics` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `step_value` varchar(24) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `step_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_name` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`table_id`)
);


-- projects_detail_statistics_steps
CREATE TABLE `projects_detail_statistics_steps` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `project_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_order` int NOT NULL,
  `step_info` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `step_units` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `step_updated_on` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `step_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stat_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'column',
  `round_val` int DEFAULT '2',
  `css` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'primary',
  `active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`table_id`)
);


-- projects_informatics
CREATE TABLE `projects_informatics` (
  `proj_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `project_title` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `project_unit` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `records` bigint DEFAULT '0',
  `other_impacts` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pm` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `project_start` date DEFAULT NULL,
  `project_end` date DEFAULT NULL,
  `info_link` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `website_link` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `github_link` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date_estimate` tinyint(1) DEFAULT '0',
  `project_status` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ongoing',
  `records_estimated` tinyint(1) NOT NULL DEFAULT '0',
  `records_redundant` tinyint(1) DEFAULT '0',
  UNIQUE KEY `projects_informatics_proj_id_IDX` (`proj_id`) USING BTREE
);


-- projects_links
CREATE TABLE `projects_links` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `proj_id` binary(16) DEFAULT NULL,
  `link_type` varchar(24) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'yt',
  `link_title` varchar(254) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `url` varchar(254) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`table_id`),
  KEY `projects_links_prid_idx` (`project_id`) USING BTREE,
  KEY `projects_links_pid_idx` (`proj_id`) USING BTREE,
  CONSTRAINT `fk_projid` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- projects_settings
CREATE TABLE `projects_settings` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `project_setting` varchar(32) DEFAULT NULL,
  `settings_value` varchar(96) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `settings_details` text,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `pid_projset` (`project_id`,`project_setting`,`settings_value`),
  KEY `projects_set_pid_idx` (`project_id`) USING BTREE,
  KEY `projects_set_pset_idx` (`project_setting`) USING BTREE
);


-- projects_stats
CREATE TABLE `projects_stats` (
  `project_id` int NOT NULL,
  `collex_total` int DEFAULT NULL,
  `collex_to_digitize` int DEFAULT NULL,
  `collex_ready` int DEFAULT NULL,
  `objects_digitized` int DEFAULT NULL,
  `images_taken` int DEFAULT '0',
  `images_in_dams` int DEFAULT NULL,
  `images_in_cis` int DEFAULT NULL,
  `images_public` int DEFAULT NULL,
  `no_records_in_cis` int DEFAULT NULL,
  `no_records_in_collexweb` int DEFAULT NULL,
  `no_records_in_collectionssiedu` int DEFAULT NULL,
  `no_records_in_gbif` int DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `other_stat` varchar(100) DEFAULT NULL,
  `other_name` varchar(100) DEFAULT NULL,
  `other_icon` varchar(100) DEFAULT NULL,
  `other_stat_calc` varchar(254) DEFAULT NULL,
  UNIQUE KEY `idx_projects_stats_project_id` (`project_id`),
  KEY `projects_stats_pid_idx` (`project_id`) USING BTREE,
  CONSTRAINT `pstats_proj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- projects_stats_detail
CREATE TABLE `projects_stats_detail` (
  `project_id` int DEFAULT NULL,
  `time_interval` varchar(96) DEFAULT NULL,
  `stat_date` date DEFAULT NULL,
  `objects_digitized` int DEFAULT NULL,
  `images_captured` int DEFAULT NULL,
  `project_cd` text,
  KEY `projects_stats_detail_pid_idx` (`project_id`) USING BTREE,
  KEY `projects_stats_detail_ti_idx` (`time_interval`) USING BTREE
);


-- qc_files
CREATE TABLE `qc_files` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `file_id` int DEFAULT NULL,
  `file_qc` int DEFAULT '9',
  `qc_info` varchar(254) DEFAULT NULL,
  `qc_by` int DEFAULT NULL,
  `qc_ip` varchar(64) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `table_id` (`table_id`),
  KEY `qc_files_fid_idx` (`file_id`) USING BTREE,
  KEY `qc_files_fold_idx` (`folder_id`) USING BTREE,
  CONSTRAINT `qc_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `qc_fold` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- qc_folders
CREATE TABLE `qc_folders` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `qc_status` int DEFAULT '9',
  `qc_by` int DEFAULT NULL,
  `qc_ip` varchar(64) DEFAULT NULL,
  `qc_info` varchar(254) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `qc_level` varchar(64) DEFAULT 'Normal',
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `table_id` (`table_id`),
  KEY `qc_folders_fid_idx` (`folder_id`) USING BTREE,
  KEY `qc_folders_qby_idx` (`qc_by`) USING BTREE,
  KEY `qc_folders_qstat_idx` (`qc_status`) USING BTREE,
  KEY `qc_folders_qlevel_idx` (`qc_level`) USING BTREE,
  CONSTRAINT `qfol_fol` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- qc_projects
CREATE TABLE `qc_projects` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `user_id` smallint DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `table_id` (`table_id`),
  KEY `qc_projects_fid_idx` (`project_id`) USING BTREE,
  KEY `qc_projects_pid_idx` (`user_id`) USING BTREE,
  CONSTRAINT `qcp_proj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `qcp_uid1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- qc_settings
CREATE TABLE `qc_settings` (
  `project_id` int NOT NULL,
  `qc_level` varchar(24) DEFAULT 'Normal',
  `qc_percent` varchar(8) DEFAULT '10',
  `qc_threshold_critical` varchar(8) DEFAULT '0',
  `qc_threshold_major` varchar(8) DEFAULT '0.015',
  `qc_threshold_minor` varchar(8) DEFAULT '0.04',
  `qc_normal_percent` varchar(8) DEFAULT '10',
  `qc_reduced_percent` varchar(8) DEFAULT '5',
  `qc_tightened_percent` varchar(8) DEFAULT '40',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`project_id`),
  KEY `qc_settings_pid_idx` (`project_id`) USING BTREE,
  CONSTRAINT `qset_proj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
);


-- sensitive_contents
CREATE TABLE `sensitive_contents` (
  `file_id` int NOT NULL,
  `sensitive_contents` tinyint DEFAULT '0',
  `user_id` smallint NOT NULL,
  `override` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sensitive_info` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  UNIQUE KEY `sensitive_contents_file_id_IDX` (`file_id`) USING BTREE,
  KEY `sensitive_contents_sensitive_contents_IDX` (`sensitive_contents`) USING BTREE
);


-- si_units
CREATE TABLE `si_units` (
  `unit_id` varchar(12) NOT NULL,
  `unit_fullname` varchar(128) NOT NULL,
  PRIMARY KEY (`unit_id`),
  KEY `si_units_id_idx` (`unit_id`) USING BTREE
);


-- users
CREATE TABLE `users` (
  `user_id` smallint NOT NULL AUTO_INCREMENT,
  `username` varchar(64) DEFAULT NULL,
  `full_name` varchar(254) DEFAULT NULL,
  `pass` varchar(32) DEFAULT NULL,
  `user_active` tinyint(1) DEFAULT '1',
  `is_admin` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  KEY `users_uid_idx` (`user_id`) USING BTREE,
  KEY `users_un_idx` (`username`) USING BTREE,
  KEY `users_ua_idx` (`user_active`) USING BTREE
);
