-- DDL Export for database: dpo_osprey
-- Generated: 2026-06-17 20:22:26.205655

USE `dpo_osprey`;

-- ----------------------------
-- Table: api_keys
-- ----------------------------
DROP TABLE IF EXISTS `api_keys`;
CREATE TABLE `api_keys` (
  `table_id` mediumint NOT NULL AUTO_INCREMENT,
  `api_key` varchar(36) DEFAULT NULL,
  `uid` varchar(36) DEFAULT NULL,
  `expires_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usage_rate` smallint NOT NULL DEFAULT '100',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `api_user` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `api_keys_api_key_IDX` (`api_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3;

-- Indices for api_keys
CREATE UNIQUE INDEX `api_keys_api_key_IDX` ON `api_keys` (`api_key`) USING BTREE;

-- ----------------------------
-- Table: api_keys_usage
-- ----------------------------
DROP TABLE IF EXISTS `api_keys_usage`;
CREATE TABLE `api_keys_usage` (
  `tableid` int NOT NULL AUTO_INCREMENT,
  `api_key` varchar(36) DEFAULT NULL,
  `url` text,
  `params` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `valid` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`tableid`),
  KEY `api_key_idx` (`api_key`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- Indices for api_keys_usage
CREATE  INDEX `api_key_idx` ON `api_keys_usage` (`api_key`) USING BTREE;

-- ----------------------------
-- Table: dams_cdis_file_status_view_dpo
-- ----------------------------
DROP TABLE IF EXISTS `dams_cdis_file_status_view_dpo`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Indices for dams_cdis_file_status_view_dpo
CREATE  INDEX `dams_cdis_stat_damsuan_idx` ON `dams_cdis_file_status_view_dpo` (`dams_uan`) USING BTREE;
CREATE  INDEX `dams_cdis_stat_fileid_idx` ON `dams_cdis_file_status_view_dpo` (`vfcu_media_file_id`) USING BTREE;
CREATE  INDEX `dams_cdis_stat_filename_idx` ON `dams_cdis_file_status_view_dpo` (`file_name`) USING BTREE;
CREATE  INDEX `dams_cdis_stat_pcd_idx` ON `dams_cdis_file_status_view_dpo` (`project_cd`) USING BTREE;

-- ----------------------------
-- Table: dams_vfcu_file_view_dpo
-- ----------------------------
DROP TABLE IF EXISTS `dams_vfcu_file_view_dpo`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Indices for dams_vfcu_file_view_dpo
CREATE  INDEX `dams_vfcu_file_fileid_idx` ON `dams_vfcu_file_view_dpo` (`vfcu_media_file_id`) USING BTREE;
CREATE  INDEX `dams_vfcu_file_mediafilename_idx` ON `dams_vfcu_file_view_dpo` (`media_file_name`) USING BTREE;
CREATE  INDEX `dams_vfcu_file_pickuploc_idx` ON `dams_vfcu_file_view_dpo` (`vfcu_pickup_loc`) USING BTREE;
CREATE  INDEX `dams_vfcu_file_projectid_idx` ON `dams_vfcu_file_view_dpo` (`project_cd`) USING BTREE;

-- ----------------------------
-- Table: data_reports
-- ----------------------------
DROP TABLE IF EXISTS `data_reports`;
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
  `pregenerated` tinyint(1) NOT NULL DEFAULT '0',
  `pregen_filename` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `data_reports_pid_idx` (`project_id`) USING BTREE,
  KEY `data_reports_rid_idx` (`report_id`) USING BTREE,
  KEY `data_reports_ralias_idx` (`report_alias`) USING BTREE,
  CONSTRAINT `project_id` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for data_reports
CREATE  INDEX `data_reports_pid_idx` ON `data_reports` (`project_id`) USING BTREE;
CREATE  INDEX `data_reports_rid_idx` ON `data_reports` (`report_id`) USING BTREE;
CREATE  INDEX `data_reports_ralias_idx` ON `data_reports` (`report_alias`) USING BTREE;

-- ----------------------------
-- Table: dates_table
-- ----------------------------
DROP TABLE IF EXISTS `dates_table`;
CREATE TABLE `dates_table` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `dayweek` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `holiday` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`table_id`),
  KEY `dates_table_date_IDX` (`date`) USING BTREE,
  KEY `dates_table_dayweek_IDX` (`dayweek`) USING BTREE,
  KEY `dates_table_holiday_IDX` (`holiday`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1099 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for dates_table
CREATE  INDEX `dates_table_date_IDX` ON `dates_table` (`date`) USING BTREE;
CREATE  INDEX `dates_table_dayweek_IDX` ON `dates_table` (`dayweek`) USING BTREE;
CREATE  INDEX `dates_table_holiday_IDX` ON `dates_table` (`holiday`) USING BTREE;

-- ----------------------------
-- Table: ento_pollinators_data
-- ----------------------------
DROP TABLE IF EXISTS `ento_pollinators_data`;
CREATE TABLE `ento_pollinators_data` (
  `barcode` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `damaged` tinyint(1) NOT NULL DEFAULT '0',
  `digitized_by` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `digitized_on` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `double_sided_labels` tinyint(1) DEFAULT NULL,
  `drawer_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `drawer_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `images_count` smallint DEFAULT NULL,
  `insect_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `multi_insect` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pin_content` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remarks` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `size` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sphere` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state_change` tinyint(1) DEFAULT NULL,
  `tray_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unable_to_scan_labels` tinyint(1) DEFAULT NULL,
  `unit_tray_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`barcode`),
  UNIQUE KEY `ento_pollinators_data_unique` (`barcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for ento_pollinators_data
CREATE UNIQUE INDEX `ento_pollinators_data_unique` ON `ento_pollinators_data` (`barcode`) USING BTREE;

-- ----------------------------
-- Table: external_data
-- ----------------------------
DROP TABLE IF EXISTS `external_data`;
CREATE TABLE `external_data` (
  `tableid` bigint unsigned NOT NULL AUTO_INCREMENT,
  `dataset_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value1` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `value2` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tableid`),
  UNIQUE KEY `tableid` (`tableid`),
  KEY `external_data_dataset_key_IDX` (`dataset_key`) USING BTREE,
  KEY `external_data_value1_IDX` (`value1`) USING BTREE,
  KEY `external_data_value2_IDX` (`value2`) USING BTREE,
  KEY `external_data_updated_at_IDX` (`updated_at`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=31011422 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for external_data
CREATE UNIQUE INDEX `tableid` ON `external_data` (`tableid`) USING BTREE;
CREATE  INDEX `external_data_dataset_key_IDX` ON `external_data` (`dataset_key`) USING BTREE;
CREATE  INDEX `external_data_value1_IDX` ON `external_data` (`value1`) USING BTREE;
CREATE  INDEX `external_data_value2_IDX` ON `external_data` (`value2`) USING BTREE;
CREATE  INDEX `external_data_updated_at_IDX` ON `external_data` (`updated_at`) USING BTREE;

-- ----------------------------
-- Table: file_md5
-- ----------------------------
DROP TABLE IF EXISTS `file_md5`;
CREATE TABLE `file_md5` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `file_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `filetype` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT 'tif',
  `md5` varchar(128) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `file_and_type` (`file_id`,`filetype`),
  KEY `file_md5_file_id_idx` (`file_id`) USING BTREE,
  KEY `file_md5_filetype_idx` (`filetype`) USING BTREE,
  KEY `file_md5_file_uid_IDX` (`file_uid`) USING BTREE,
  CONSTRAINT `fmd5_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22205969 DEFAULT CHARSET=utf8mb3;

-- Indices for file_md5
CREATE UNIQUE INDEX `file_and_type` ON `file_md5` (`file_id`, `filetype`) USING BTREE;
CREATE  INDEX `file_md5_file_id_idx` ON `file_md5` (`file_id`) USING BTREE;
CREATE  INDEX `file_md5_filetype_idx` ON `file_md5` (`filetype`) USING BTREE;
CREATE  INDEX `file_md5_file_uid_IDX` ON `file_md5` (`file_uid`) USING BTREE;

-- ----------------------------
-- Table: file_postprocessing
-- ----------------------------
DROP TABLE IF EXISTS `file_postprocessing`;
CREATE TABLE `file_postprocessing` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `post_step` varchar(64) DEFAULT NULL,
  `post_results` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `post_info` text,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `fpp_fileid_and_poststep` (`file_id`,`post_step`),
  KEY `file_postprocessing_tid_idx` (`table_id`) USING BTREE,
  KEY `file_postprocessing_file_id_idx` (`file_id`) USING BTREE,
  KEY `file_postprocessing_post_step_idx` (`post_step`) USING BTREE,
  KEY `file_postprocessing_check_results_idx` (`post_results`) USING BTREE,
  CONSTRAINT `fpost_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30106018 DEFAULT CHARSET=utf8mb3;

-- Indices for file_postprocessing
CREATE UNIQUE INDEX `fpp_fileid_and_poststep` ON `file_postprocessing` (`file_id`, `post_step`) USING BTREE;
CREATE  INDEX `file_postprocessing_tid_idx` ON `file_postprocessing` (`table_id`) USING BTREE;
CREATE  INDEX `file_postprocessing_file_id_idx` ON `file_postprocessing` (`file_id`) USING BTREE;
CREATE  INDEX `file_postprocessing_post_step_idx` ON `file_postprocessing` (`post_step`) USING BTREE;
CREATE  INDEX `file_postprocessing_check_results_idx` ON `file_postprocessing` (`post_results`) USING BTREE;

-- ----------------------------
-- Table: files
-- ----------------------------
DROP TABLE IF EXISTS `files`;
CREATE TABLE `files` (
  `file_id` int NOT NULL AUTO_INCREMENT,
  `file_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `folder_id` int DEFAULT NULL,
  `folder_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
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
  KEY `files_folder_uid_IDX` (`folder_uid`) USING BTREE,
  CONSTRAINT `fk_foldfile` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4586779 DEFAULT CHARSET=utf8mb3;

-- Indices for files
CREATE UNIQUE INDEX `files_constr` ON `files` (`file_name`, `folder_id`) USING BTREE;
CREATE  INDEX `files_fileid_idx` ON `files` (`file_id`) USING BTREE;
CREATE  INDEX `files_folderid_idx` ON `files` (`folder_id`) USING BTREE;
CREATE  INDEX `files_ffid_idx` ON `files` (`folder_id`, `file_id`) USING BTREE;
CREATE  INDEX `files_fileuid_idx` ON `files` (`uid`) USING BTREE;
CREATE  INDEX `files_folder_uid_IDX` ON `files` (`folder_uid`) USING BTREE;

-- ----------------------------
-- Table: files_checks
-- ----------------------------
DROP TABLE IF EXISTS `files_checks`;
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
) ENGINE=InnoDB AUTO_INCREMENT=94685196 DEFAULT CHARSET=utf8mb3;

-- Indices for files_checks
CREATE UNIQUE INDEX `fid_check` ON `files_checks` (`file_id`, `file_check`) USING BTREE;
CREATE  INDEX `file_checks1_tid_idx` ON `files_checks` (`table_id`) USING BTREE;
CREATE  INDEX `file_checks1_file_id_idx` ON `files_checks` (`file_id`) USING BTREE;
CREATE  INDEX `file_checks1_file_check_idx` ON `files_checks` (`file_check`) USING BTREE;
CREATE  INDEX `file_checks1_check_results_idx` ON `files_checks` (`check_results`) USING BTREE;
CREATE  INDEX `file_checks1_fil_id_idx` ON `files_checks` (`file_id`, `check_results`) USING BTREE;
CREATE  INDEX `file_checks1_fc_id_idx` ON `files_checks` (`folder_id`, `check_results`) USING BTREE;
CREATE  INDEX `file_checks1_ff_id_idx` ON `files_checks` (`folder_id`, `file_id`) USING BTREE;
CREATE  INDEX `file_checks1_file_uid_idx` ON `files_checks` (`uid`) USING BTREE;

-- ----------------------------
-- Table: files_exif
-- ----------------------------
DROP TABLE IF EXISTS `files_exif`;
CREATE TABLE `files_exif` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `file_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `filetype` varchar(8) DEFAULT 'TIF',
  `tag` varchar(254) DEFAULT NULL,
  `taggroup` varchar(254) DEFAULT NULL,
  `tagid` varchar(128) DEFAULT NULL,
  `value` text,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `table_id` (`table_id`),
  KEY `files_exif1_file_id_idx` (`file_id`) USING BTREE,
  KEY `files_exif1_fid_idx` (`file_id`,`filetype`) USING BTREE,
  KEY `files_exif1_tag_idx` (`tag`) USING BTREE,
  KEY `files_exif1_taggroup_idx` (`taggroup`) USING BTREE,
  KEY `files_exif_updated_at_IDX` (`updated_at`) USING BTREE,
  CONSTRAINT `fexif_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1810466061 DEFAULT CHARSET=utf8mb3;

-- Indices for files_exif
CREATE UNIQUE INDEX `table_id` ON `files_exif` (`table_id`) USING BTREE;
CREATE  INDEX `files_exif1_file_id_idx` ON `files_exif` (`file_id`) USING BTREE;
CREATE  INDEX `files_exif1_fid_idx` ON `files_exif` (`file_id`, `filetype`) USING BTREE;
CREATE  INDEX `files_exif1_tag_idx` ON `files_exif` (`tag`) USING BTREE;
CREATE  INDEX `files_exif1_taggroup_idx` ON `files_exif` (`taggroup`) USING BTREE;
CREATE  INDEX `files_exif_updated_at_IDX` ON `files_exif` (`updated_at`) USING BTREE;

-- ----------------------------
-- Table: files_links
-- ----------------------------
DROP TABLE IF EXISTS `files_links`;
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
) ENGINE=InnoDB AUTO_INCREMENT=3948221 DEFAULT CHARSET=utf8mb3;

-- Indices for files_links
CREATE UNIQUE INDEX `table_id` ON `files_links` (`table_id`) USING BTREE;
CREATE  INDEX `files_links_tid_idx` ON `files_links` (`table_id`) USING BTREE;
CREATE  INDEX `files_links_fid_idx` ON `files_links` (`file_id`) USING BTREE;
CREATE  INDEX `files_links_lnk_idx` ON `files_links` (`link_name`) USING BTREE;

-- ----------------------------
-- Table: files_size
-- ----------------------------
DROP TABLE IF EXISTS `files_size`;
CREATE TABLE `files_size` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `file_id` int DEFAULT NULL,
  `file_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `filetype` varchar(8) DEFAULT 'TIF',
  `filesize` varchar(64) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `fid_ftype` (`file_id`,`filetype`),
  KEY `files_size_file_id_idx` (`file_id`) USING BTREE,
  KEY `files_size_filetype_idx` (`filetype`) USING BTREE,
  CONSTRAINT `fsize_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12448796 DEFAULT CHARSET=utf8mb3;

-- Indices for files_size
CREATE UNIQUE INDEX `fid_ftype` ON `files_size` (`file_id`, `filetype`) USING BTREE;
CREATE  INDEX `files_size_file_id_idx` ON `files_size` (`file_id`) USING BTREE;
CREATE  INDEX `files_size_filetype_idx` ON `files_size` (`filetype`) USING BTREE;

-- ----------------------------
-- Table: folders
-- ----------------------------
DROP TABLE IF EXISTS `folders`;
CREATE TABLE `folders` (
  `folder_id` int NOT NULL AUTO_INCREMENT,
  `folder_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
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
  `previews` tinyint NOT NULL DEFAULT '0',
  `no_files_total` int DEFAULT NULL,
  `no_files_errors` int DEFAULT NULL,
  `no_files_ok` int DEFAULT NULL,
  PRIMARY KEY (`folder_id`),
  KEY `folders_pid_idx` (`project_id`) USING BTREE,
  KEY `folders_status_IDX` (`status`) USING BTREE,
  KEY `folders_previews_IDX` (`previews`) USING BTREE,
  KEY `idx_folders_project_date_folder` (`project_id`,`date` DESC,`project_folder` DESC),
  KEY `idx_folders_project_delivered_folder` (`project_id`,`delivered_to_dams`,`project_folder`),
  KEY `idx_folders_project_delivered` (`project_id`,`delivered_to_dams`,`folder_id`),
  CONSTRAINT `fk_foldproj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8752 DEFAULT CHARSET=utf8mb3;

-- Indices for folders
CREATE  INDEX `folders_pid_idx` ON `folders` (`project_id`) USING BTREE;
CREATE  INDEX `folders_status_IDX` ON `folders` (`status`) USING BTREE;
CREATE  INDEX `folders_previews_IDX` ON `folders` (`previews`) USING BTREE;
CREATE  INDEX `idx_folders_project_date_folder` ON `folders` (`project_id`, `date`, `project_folder`) USING BTREE;
CREATE  INDEX `idx_folders_project_delivered_folder` ON `folders` (`project_id`, `delivered_to_dams`, `project_folder`) USING BTREE;
CREATE  INDEX `idx_folders_project_delivered` ON `folders` (`project_id`, `delivered_to_dams`, `folder_id`) USING BTREE;

-- ----------------------------
-- Table: folders_badges
-- ----------------------------
DROP TABLE IF EXISTS `folders_badges`;
CREATE TABLE `folders_badges` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `folder_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `badge_type` varchar(24) DEFAULT NULL,
  `badge_css` varchar(24) DEFAULT NULL,
  `badge_text` varchar(64) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `folder_transcription_id` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `badge_type_text` (`folder_id`,`badge_type`,`badge_text`),
  UNIQUE KEY `fid_type_badge` (`folder_id`,`badge_type`),
  KEY `folders_badges_fid_idx` (`folder_id`) USING BTREE,
  KEY `folders_badges_type_fid_idx` (`badge_type`) USING BTREE,
  KEY `folders_badges_folder_uid_IDX` (`folder_uid`) USING BTREE,
  KEY `idx_folders_badges_type_uid` (`badge_type`,`folder_uid`)
) ENGINE=InnoDB AUTO_INCREMENT=197876 DEFAULT CHARSET=utf8mb3;

-- Indices for folders_badges
CREATE UNIQUE INDEX `badge_type_text` ON `folders_badges` (`folder_id`, `badge_type`, `badge_text`) USING BTREE;
CREATE UNIQUE INDEX `fid_type_badge` ON `folders_badges` (`folder_id`, `badge_type`) USING BTREE;
CREATE  INDEX `folders_badges_fid_idx` ON `folders_badges` (`folder_id`) USING BTREE;
CREATE  INDEX `folders_badges_type_fid_idx` ON `folders_badges` (`badge_type`) USING BTREE;
CREATE  INDEX `folders_badges_folder_uid_IDX` ON `folders_badges` (`folder_uid`) USING BTREE;
CREATE  INDEX `idx_folders_badges_type_uid` ON `folders_badges` (`badge_type`, `folder_uid`) USING BTREE;

-- ----------------------------
-- Table: folders_cleanup
-- ----------------------------
DROP TABLE IF EXISTS `folders_cleanup`;
CREATE TABLE `folders_cleanup` (
  `folder_id` int NOT NULL,
  `project_id` int NOT NULL,
  `project_folder` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `linked_to_ids` tinyint(1) DEFAULT '0',
  `osprey_prev_deleted` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`folder_id`),
  KEY `folders_fid_idx` (`folder_id`) USING BTREE,
  KEY `folders_pid_idx` (`project_id`) USING BTREE,
  CONSTRAINT `fk_foldclean` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for folders_cleanup
CREATE  INDEX `folders_fid_idx` ON `folders_cleanup` (`folder_id`) USING BTREE;
CREATE  INDEX `folders_pid_idx` ON `folders_cleanup` (`project_id`) USING BTREE;

-- ----------------------------
-- Table: folders_links
-- ----------------------------
DROP TABLE IF EXISTS `folders_links`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for folders_links
CREATE  INDEX `folders_links_tid_idx` ON `folders_links` (`table_id`) USING BTREE;
CREATE  INDEX `folders_links_fid_idx` ON `folders_links` (`folder_id`) USING BTREE;

-- ----------------------------
-- Table: folders_md5
-- ----------------------------
DROP TABLE IF EXISTS `folders_md5`;
CREATE TABLE `folders_md5` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `folder_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `md5_type` varchar(12) DEFAULT NULL,
  `md5` int DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `folderid_and_type` (`folder_id`,`md5_type`),
  UNIQUE KEY `folid_md5` (`folder_id`,`md5_type`),
  KEY `folders_md5_fid_idx` (`folder_id`) USING BTREE,
  KEY `folders_md5_tid_idx` (`table_id`) USING BTREE,
  KEY `folders_md5_folder_uid_IDX` (`folder_uid`) USING BTREE,
  CONSTRAINT `fk_foldmd5` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30475059 DEFAULT CHARSET=utf8mb3;

-- Indices for folders_md5
CREATE UNIQUE INDEX `folderid_and_type` ON `folders_md5` (`folder_id`, `md5_type`) USING BTREE;
CREATE UNIQUE INDEX `folid_md5` ON `folders_md5` (`folder_id`, `md5_type`) USING BTREE;
CREATE  INDEX `folders_md5_fid_idx` ON `folders_md5` (`folder_id`) USING BTREE;
CREATE  INDEX `folders_md5_tid_idx` ON `folders_md5` (`table_id`) USING BTREE;
CREATE  INDEX `folders_md5_folder_uid_IDX` ON `folders_md5` (`folder_uid`) USING BTREE;

-- ----------------------------
-- Table: folders_transcription
-- ----------------------------
DROP TABLE IF EXISTS `folders_transcription`;
CREATE TABLE `folders_transcription` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `folder_transcription_id` varchar(36) DEFAULT NULL,
  `folder` varchar(254) NOT NULL,
  `project_id` int NOT NULL,
  `folder_path` text,
  `transcription_text` text,
  `status` smallint DEFAULT '9',
  `delivered_to_dams` smallint DEFAULT '9',
  `no_files` int DEFAULT '0',
  `previews` smallint DEFAULT '9',
  `no_files_total` int DEFAULT '0',
  `no_files_error` int DEFAULT '0',
  `no_files_ok` int DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  KEY `folder_transcription_id_idx` (`folder_transcription_id`) USING BTREE,
  KEY `proj_id_for` (`project_id`),
  CONSTRAINT `proj_id_for` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb3;

-- Indices for folders_transcription
CREATE  INDEX `folder_transcription_id_idx` ON `folders_transcription` (`folder_transcription_id`) USING BTREE;
CREATE  INDEX `proj_id_for` ON `folders_transcription` (`project_id`) USING BTREE;

-- ----------------------------
-- Table: general_stats
-- ----------------------------
DROP TABLE IF EXISTS `general_stats`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for general_stats
CREATE UNIQUE INDEX `table_id` ON `general_stats` (`table_id`) USING BTREE;
CREATE  INDEX `general_stats_tid_idx` ON `general_stats` (`interval_stat`) USING BTREE;

-- ----------------------------
-- Table: informatics_software
-- ----------------------------
DROP TABLE IF EXISTS `informatics_software`;
CREATE TABLE `informatics_software` (
  `software_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `software_name` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `software_details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `repository` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `more_info` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sortby` int NOT NULL,
  PRIMARY KEY (`software_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for informatics_software

-- ----------------------------
-- Table: invoice_alembo_binary
-- ----------------------------
DROP TABLE IF EXISTS `invoice_alembo_binary`;
CREATE TABLE `invoice_alembo_binary` (
  `DATUM-INGEVULD` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CLIENT BATCH` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DETA BATCH` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IMAGE` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DUPLICATED` int DEFAULT NULL,
  `VERBATIM LOCALITY` int DEFAULT NULL,
  `COUNTRY` int DEFAULT NULL,
  `STATE` int DEFAULT NULL,
  `COUNTY` int DEFAULT NULL,
  `PRECISE LOCALITY` int DEFAULT NULL,
  `BIO-REGION` int DEFAULT NULL,
  `VERBATIM GEOREFERENCING` int DEFAULT NULL,
  `ELEVATION / ALTITUDE COLLECTED` int DEFAULT NULL,
  `HABITAT` int DEFAULT NULL,
  `COLLECTION METHOD` int DEFAULT NULL,
  `COLLECTING DATE` int DEFAULT NULL,
  `COLLECTOR` int DEFAULT NULL,
  `IDENTIFICATION LABEL` int DEFAULT NULL,
  `IDENTIFIER DATA` int DEFAULT NULL,
  `TYPE NUMBERS` int DEFAULT NULL,
  `TYPE STATUS` int DEFAULT NULL,
  `HOPKINS NUMBERS` int DEFAULT NULL,
  `OTHER NUMBERS` int DEFAULT NULL,
  `SEX` int DEFAULT NULL,
  `NOTE` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: invoice_alembo_values
-- ----------------------------
DROP TABLE IF EXISTS `invoice_alembo_values`;
CREATE TABLE `invoice_alembo_values` (
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `howmany` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `totals` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: invoice_recon
-- ----------------------------
DROP TABLE IF EXISTS `invoice_recon`;
CREATE TABLE `invoice_recon` (
  `tableid` int NOT NULL AUTO_INCREMENT,
  `file_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `randomint` int NOT NULL,
  `file_id` int DEFAULT NULL,
  `dams_uan` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tableid`),
  KEY `invoice_recon_filename_IDX` (`file_name`) USING BTREE,
  KEY `invoice_recon_randomint_IDX` (`randomint`) USING BTREE,
  KEY `invoice_recon_timestamp_IDX` (`timestamp`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=6666372 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for invoice_recon
CREATE  INDEX `invoice_recon_filename_IDX` ON `invoice_recon` (`file_name`) USING BTREE;
CREATE  INDEX `invoice_recon_randomint_IDX` ON `invoice_recon` (`randomint`) USING BTREE;
CREATE  INDEX `invoice_recon_timestamp_IDX` ON `invoice_recon` (`timestamp`) USING BTREE;

-- ----------------------------
-- Table: invoice_recon_transcription
-- ----------------------------
DROP TABLE IF EXISTS `invoice_recon_transcription`;
CREATE TABLE `invoice_recon_transcription` (
  `tableid` int NOT NULL AUTO_INCREMENT,
  `file_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `randomint` int NOT NULL,
  `project_id` smallint NOT NULL,
  `file_transcription_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tableid`),
  KEY `invoice_recon_filename_IDX` (`file_name`) USING BTREE,
  KEY `invoice_recon_randomint_IDX` (`randomint`) USING BTREE,
  KEY `invoice_recon_transcription_project_id_IDX` (`project_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=523335 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for invoice_recon_transcription
CREATE  INDEX `invoice_recon_filename_IDX` ON `invoice_recon_transcription` (`file_name`) USING BTREE;
CREATE  INDEX `invoice_recon_randomint_IDX` ON `invoice_recon_transcription` (`randomint`) USING BTREE;
CREATE  INDEX `invoice_recon_transcription_project_id_IDX` ON `invoice_recon_transcription` (`project_id`) USING BTREE;

-- ----------------------------
-- Table: jpc_aspace_boxes
-- ----------------------------
DROP TABLE IF EXISTS `jpc_aspace_boxes`;
CREATE TABLE `jpc_aspace_boxes` (
  `project_folder` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `box` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `archive_box` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: jpc_aspace_data
-- ----------------------------
DROP TABLE IF EXISTS `jpc_aspace_data`;
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
  `content_warnings` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `manualkeep` tinyint(1) DEFAULT '0',
  KEY `jpc_aspace_data_box_idx` (`archive_box`) USING BTREE,
  KEY `jpc_aspace_data_folder_idx` (`archive_folder`) USING BTREE,
  KEY `jpc_aspace_data_name_idx` (`unit_title`) USING BTREE,
  KEY `jpc_aspace_data_refid_idx` (`refid`) USING BTREE,
  KEY `jpc_aspace_data_resid_idx` (`resource_id`) USING BTREE,
  KEY `jpc_aspace_data_type_idx` (`archive_type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for jpc_aspace_data
CREATE  INDEX `jpc_aspace_data_box_idx` ON `jpc_aspace_data` (`archive_box`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_folder_idx` ON `jpc_aspace_data` (`archive_folder`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_name_idx` ON `jpc_aspace_data` (`unit_title`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_refid_idx` ON `jpc_aspace_data` (`refid`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_resid_idx` ON `jpc_aspace_data` (`resource_id`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_type_idx` ON `jpc_aspace_data` (`archive_type`) USING BTREE;

-- ----------------------------
-- Table: jpc_aspace_data_1
-- ----------------------------
DROP TABLE IF EXISTS `jpc_aspace_data_1`;
CREATE TABLE `jpc_aspace_data_1` (
  `table_id` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `resource_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `refid` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `archive_box` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `archive_type` varchar(254) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `archive_folder` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `unit_title` varchar(168) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `url` varchar(254) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `creation_date` date DEFAULT NULL,
  `mod_date` date DEFAULT NULL,
  `scopecontent` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `content_warnings` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  KEY `jpc_aspace_data_box_idx` (`archive_box`) USING BTREE,
  KEY `jpc_aspace_data_folder_idx` (`archive_folder`) USING BTREE,
  KEY `jpc_aspace_data_name_idx` (`unit_title`) USING BTREE,
  KEY `jpc_aspace_data_refid_idx` (`refid`) USING BTREE,
  KEY `jpc_aspace_data_resid_idx` (`resource_id`) USING BTREE,
  KEY `jpc_aspace_data_type_idx` (`archive_type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for jpc_aspace_data_1
CREATE  INDEX `jpc_aspace_data_box_idx` ON `jpc_aspace_data_1` (`archive_box`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_folder_idx` ON `jpc_aspace_data_1` (`archive_folder`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_name_idx` ON `jpc_aspace_data_1` (`unit_title`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_refid_idx` ON `jpc_aspace_data_1` (`refid`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_resid_idx` ON `jpc_aspace_data_1` (`resource_id`) USING BTREE;
CREATE  INDEX `jpc_aspace_data_type_idx` ON `jpc_aspace_data_1` (`archive_type`) USING BTREE;

-- ----------------------------
-- Table: jpc_aspace_resources
-- ----------------------------
DROP TABLE IF EXISTS `jpc_aspace_resources`;
CREATE TABLE `jpc_aspace_resources` (
  `table_id` varchar(64) NOT NULL,
  `resource_id` varchar(128) NOT NULL,
  `repository_id` varchar(128) NOT NULL,
  `resource_title` varchar(128) NOT NULL,
  `resource_tree` varchar(128) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `manualkeep` tinyint(1) DEFAULT '0',
  KEY `jpc_aspace_resources_resid_idx` (`resource_id`) USING BTREE,
  KEY `jpc_aspace_resources_tid_idx` (`table_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for jpc_aspace_resources
CREATE  INDEX `jpc_aspace_resources_resid_idx` ON `jpc_aspace_resources` (`resource_id`) USING BTREE;
CREATE  INDEX `jpc_aspace_resources_tid_idx` ON `jpc_aspace_resources` (`table_id`) USING BTREE;

-- ----------------------------
-- Table: jpc_aspace_resources1
-- ----------------------------
DROP TABLE IF EXISTS `jpc_aspace_resources1`;
CREATE TABLE `jpc_aspace_resources1` (
  `table_id` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `resource_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `repository_id` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `resource_title` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `resource_tree` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Table: jpc_massdigi_ids
-- ----------------------------
DROP TABLE IF EXISTS `jpc_massdigi_ids`;
CREATE TABLE `jpc_massdigi_ids` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `id_relationship` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id1_value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `id2_value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `folder_id` int DEFAULT NULL,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `table_id` (`table_id`),
  KEY `jpc_massdigi_ids_id_relationship_IDX` (`id_relationship`) USING BTREE,
  KEY `jpc_massdigi_ids_id1_value_IDX` (`id1_value`) USING BTREE,
  KEY `jpc_massdigi_ids_id2_value_IDX` (`id2_value`) USING BTREE,
  KEY `jpc_massdigi_ids_folder_id_IDX` (`folder_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for jpc_massdigi_ids
CREATE UNIQUE INDEX `table_id` ON `jpc_massdigi_ids` (`table_id`) USING BTREE;
CREATE  INDEX `jpc_massdigi_ids_id_relationship_IDX` ON `jpc_massdigi_ids` (`id_relationship`) USING BTREE;
CREATE  INDEX `jpc_massdigi_ids_id1_value_IDX` ON `jpc_massdigi_ids` (`id1_value`) USING BTREE;
CREATE  INDEX `jpc_massdigi_ids_id2_value_IDX` ON `jpc_massdigi_ids` (`id2_value`) USING BTREE;
CREATE  INDEX `jpc_massdigi_ids_folder_id_IDX` ON `jpc_massdigi_ids` (`folder_id`) USING BTREE;

-- ----------------------------
-- Table: projects
-- ----------------------------
DROP TABLE IF EXISTS `projects`;
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
  `preview_filter` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `transcription` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`project_id`),
  KEY `projects_pjd_idx` (`proj_id`) USING BTREE,
  KEY `projects_palias_idx` (`project_alias`) USING BTREE,
  KEY `projects_status_idx` (`project_status`) USING BTREE,
  KEY `idx_filter` (`skip_project`,`project_section`)
) ENGINE=InnoDB AUTO_INCREMENT=258 DEFAULT CHARSET=utf8mb3;

-- Indices for projects
CREATE  INDEX `projects_pjd_idx` ON `projects` (`proj_id`) USING BTREE;
CREATE  INDEX `projects_palias_idx` ON `projects` (`project_alias`) USING BTREE;
CREATE  INDEX `projects_status_idx` ON `projects` (`project_status`) USING BTREE;
CREATE  INDEX `idx_filter` ON `projects` (`skip_project`, `project_section`) USING BTREE;

-- ----------------------------
-- Table: projects_detail_statistics
-- ----------------------------
DROP TABLE IF EXISTS `projects_detail_statistics`;
CREATE TABLE `projects_detail_statistics` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `step_value` varchar(24) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `step_id` varchar(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_name` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`table_id`)
) ENGINE=InnoDB AUTO_INCREMENT=276899821 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for projects_detail_statistics

-- ----------------------------
-- Table: projects_detail_statistics_steps
-- ----------------------------
DROP TABLE IF EXISTS `projects_detail_statistics_steps`;
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
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for projects_detail_statistics_steps

-- ----------------------------
-- Table: projects_informatics
-- ----------------------------
DROP TABLE IF EXISTS `projects_informatics`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for projects_informatics
CREATE UNIQUE INDEX `projects_informatics_proj_id_IDX` ON `projects_informatics` (`proj_id`) USING BTREE;

-- ----------------------------
-- Table: projects_links
-- ----------------------------
DROP TABLE IF EXISTS `projects_links`;
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
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3;

-- Indices for projects_links
CREATE  INDEX `projects_links_prid_idx` ON `projects_links` (`project_id`) USING BTREE;
CREATE  INDEX `projects_links_pid_idx` ON `projects_links` (`proj_id`) USING BTREE;

-- ----------------------------
-- Table: projects_settings
-- ----------------------------
DROP TABLE IF EXISTS `projects_settings`;
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
) ENGINE=InnoDB AUTO_INCREMENT=3092 DEFAULT CHARSET=utf8mb3;

-- Indices for projects_settings
CREATE UNIQUE INDEX `pid_projset` ON `projects_settings` (`project_id`, `project_setting`, `settings_value`) USING BTREE;
CREATE  INDEX `projects_set_pid_idx` ON `projects_settings` (`project_id`) USING BTREE;
CREATE  INDEX `projects_set_pset_idx` ON `projects_settings` (`project_setting`) USING BTREE;

-- ----------------------------
-- Table: projects_stats
-- ----------------------------
DROP TABLE IF EXISTS `projects_stats`;
CREATE TABLE `projects_stats` (
  `project_id` int NOT NULL,
  `collex_total` int DEFAULT '0',
  `collex_to_digitize` int DEFAULT '0',
  `collex_ready` int DEFAULT '0',
  `objects_digitized` int DEFAULT '0',
  `images_taken` int DEFAULT '0',
  `images_in_dams` int DEFAULT '0',
  `images_in_cis` int DEFAULT '0',
  `images_public` int DEFAULT '0',
  `no_records_in_cis` int DEFAULT '0',
  `no_records_in_collexweb` int DEFAULT '0',
  `no_records_in_collectionssiedu` int DEFAULT '0',
  `no_records_in_gbif` int DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `other_stat` varchar(100) DEFAULT NULL,
  `other_name` varchar(100) DEFAULT NULL,
  `other_icon` varchar(100) DEFAULT NULL,
  `other_stat_calc` varchar(254) DEFAULT NULL,
  `project_ok` int DEFAULT '0',
  `project_err` int DEFAULT '0',
  UNIQUE KEY `idx_projects_stats_project_id` (`project_id`),
  KEY `projects_stats_pid_idx` (`project_id`) USING BTREE,
  KEY `idx_project_id` (`project_id`),
  CONSTRAINT `pstats_proj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for projects_stats
CREATE UNIQUE INDEX `idx_projects_stats_project_id` ON `projects_stats` (`project_id`) USING BTREE;
CREATE  INDEX `projects_stats_pid_idx` ON `projects_stats` (`project_id`) USING BTREE;
CREATE  INDEX `idx_project_id` ON `projects_stats` (`project_id`) USING BTREE;

-- ----------------------------
-- Table: projects_stats_detail
-- ----------------------------
DROP TABLE IF EXISTS `projects_stats_detail`;
CREATE TABLE `projects_stats_detail` (
  `project_id` int DEFAULT NULL,
  `time_interval` varchar(96) DEFAULT NULL,
  `stat_date` date DEFAULT NULL,
  `objects_digitized` int DEFAULT NULL,
  `images_captured` int DEFAULT NULL,
  `project_cd` text,
  KEY `projects_stats_detail_pid_idx` (`project_id`) USING BTREE,
  KEY `projects_stats_detail_ti_idx` (`time_interval`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for projects_stats_detail
CREATE  INDEX `projects_stats_detail_pid_idx` ON `projects_stats_detail` (`project_id`) USING BTREE;
CREATE  INDEX `projects_stats_detail_ti_idx` ON `projects_stats_detail` (`time_interval`) USING BTREE;

-- ----------------------------
-- Table: qc_files
-- ----------------------------
DROP TABLE IF EXISTS `qc_files`;
CREATE TABLE `qc_files` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `folder_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `file_id` int DEFAULT NULL,
  `file_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `file_qc` int DEFAULT '9',
  `qc_info` varchar(254) DEFAULT NULL,
  `qc_by` int DEFAULT NULL,
  `qc_ip` varchar(64) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  KEY `qc_files_fid_idx` (`file_id`) USING BTREE,
  KEY `qc_files_fold_idx` (`folder_id`) USING BTREE,
  CONSTRAINT `qc_files` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `qc_fold` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=382325 DEFAULT CHARSET=utf8mb3;

-- Indices for qc_files
CREATE  INDEX `qc_files_fid_idx` ON `qc_files` (`file_id`) USING BTREE;
CREATE  INDEX `qc_files_fold_idx` ON `qc_files` (`folder_id`) USING BTREE;

-- ----------------------------
-- Table: qc_folders
-- ----------------------------
DROP TABLE IF EXISTS `qc_folders`;
CREATE TABLE `qc_folders` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `folder_id` int DEFAULT NULL,
  `folder_uid` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `qc_status` int DEFAULT '9',
  `qc_by` int DEFAULT NULL,
  `qc_ip` varchar(64) DEFAULT NULL,
  `qc_info` varchar(254) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `qc_level` varchar(64) DEFAULT 'Normal',
  `folder_transcription_id` varchar(36) DEFAULT NULL,
  PRIMARY KEY (`table_id`),
  KEY `qc_folders_qby_idx` (`qc_by`) USING BTREE,
  KEY `qc_folders_qstat_idx` (`qc_status`) USING BTREE,
  KEY `qc_folders_qlevel_idx` (`qc_level`) USING BTREE,
  KEY `idx_qc_folders_folder_uid` (`folder_uid`),
  KEY `idx_qc_folders_folder_id` (`folder_id`),
  CONSTRAINT `qfol_fol` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5699 DEFAULT CHARSET=utf8mb3;

-- Indices for qc_folders
CREATE  INDEX `qc_folders_qby_idx` ON `qc_folders` (`qc_by`) USING BTREE;
CREATE  INDEX `qc_folders_qstat_idx` ON `qc_folders` (`qc_status`) USING BTREE;
CREATE  INDEX `qc_folders_qlevel_idx` ON `qc_folders` (`qc_level`) USING BTREE;
CREATE  INDEX `idx_qc_folders_folder_uid` ON `qc_folders` (`folder_uid`) USING BTREE;
CREATE  INDEX `idx_qc_folders_folder_id` ON `qc_folders` (`folder_id`) USING BTREE;

-- ----------------------------
-- Table: qc_projects
-- ----------------------------
DROP TABLE IF EXISTS `qc_projects`;
CREATE TABLE `qc_projects` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `project_id` int DEFAULT NULL,
  `user_id` smallint DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  KEY `qc_projects_fid_idx` (`project_id`) USING BTREE,
  KEY `qc_projects_pid_idx` (`user_id`) USING BTREE,
  CONSTRAINT `qcp_proj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `qcp_uid1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=395 DEFAULT CHARSET=utf8mb3;

-- Indices for qc_projects
CREATE  INDEX `qc_projects_fid_idx` ON `qc_projects` (`project_id`) USING BTREE;
CREATE  INDEX `qc_projects_pid_idx` ON `qc_projects` (`user_id`) USING BTREE;

-- ----------------------------
-- Table: qc_settings
-- ----------------------------
DROP TABLE IF EXISTS `qc_settings`;
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
  `qc_filenames` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`project_id`),
  KEY `qc_settings_pid_idx` (`project_id`) USING BTREE,
  CONSTRAINT `qset_proj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for qc_settings
CREATE  INDEX `qc_settings_pid_idx` ON `qc_settings` (`project_id`) USING BTREE;

-- ----------------------------
-- Table: sensitive_contents
-- ----------------------------
DROP TABLE IF EXISTS `sensitive_contents`;
CREATE TABLE `sensitive_contents` (
  `file_id` int NOT NULL,
  `sensitive_contents` tinyint DEFAULT '0',
  `user_id` smallint NOT NULL,
  `override` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sensitive_info` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  UNIQUE KEY `sensitive_contents_file_id_IDX` (`file_id`) USING BTREE,
  KEY `sensitive_contents_sensitive_contents_IDX` (`sensitive_contents`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for sensitive_contents
CREATE UNIQUE INDEX `sensitive_contents_file_id_IDX` ON `sensitive_contents` (`file_id`) USING BTREE;
CREATE  INDEX `sensitive_contents_sensitive_contents_IDX` ON `sensitive_contents` (`sensitive_contents`) USING BTREE;

-- ----------------------------
-- Table: si_units
-- ----------------------------
DROP TABLE IF EXISTS `si_units`;
CREATE TABLE `si_units` (
  `unit_id` varchar(12) NOT NULL,
  `unit_fullname` varchar(128) NOT NULL,
  PRIMARY KEY (`unit_id`),
  KEY `si_units_id_idx` (`unit_id`) USING BTREE,
  KEY `idx_unit_id` (`unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for si_units
CREATE  INDEX `si_units_id_idx` ON `si_units` (`unit_id`) USING BTREE;
CREATE  INDEX `idx_unit_id` ON `si_units` (`unit_id`) USING BTREE;

-- ----------------------------
-- Table: transcript_test
-- ----------------------------
DROP TABLE IF EXISTS `transcript_test`;
CREATE TABLE `transcript_test` (
  `tableid` int NOT NULL AUTO_INCREMENT,
  `filename` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `field` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alembo` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`tableid`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indices for transcript_test

-- ----------------------------
-- Table: transcription_fields
-- ----------------------------
DROP TABLE IF EXISTS `transcription_fields`;
CREATE TABLE `transcription_fields` (
  `field_id` varchar(36) NOT NULL,
  `transcription_source_id` varchar(36) DEFAULT NULL,
  `sort_by` smallint DEFAULT NULL,
  `field_name` varchar(250) DEFAULT NULL,
  `field_cost` float DEFAULT NULL,
  `field_notes` varchar(250) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`field_id`),
  KEY `fields_source_id_t` (`transcription_source_id`),
  CONSTRAINT `fields_source_id_t` FOREIGN KEY (`transcription_source_id`) REFERENCES `transcription_sources` (`transcription_source_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_fields
CREATE  INDEX `fields_source_id_t` ON `transcription_fields` (`transcription_source_id`) USING BTREE;

-- ----------------------------
-- Table: transcription_files
-- ----------------------------
DROP TABLE IF EXISTS `transcription_files`;
CREATE TABLE `transcription_files` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `file_transcription_id` varchar(36) DEFAULT NULL,
  `folder_transcription_id` varchar(36) DEFAULT NULL,
  `file_name` varchar(254) NOT NULL,
  `file_ext` varchar(10) NOT NULL,
  `dams_uan` text,
  `preview_image` text,
  `file_size` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `file_timestamp` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`table_id`),
  KEY `file_transcription_id_idx` (`file_transcription_id`) USING BTREE,
  KEY `fmd5_files_t` (`folder_transcription_id`),
  CONSTRAINT `fmd5_files_t` FOREIGN KEY (`folder_transcription_id`) REFERENCES `transcription_folders` (`folder_transcription_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=103284 DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_files
CREATE  INDEX `file_transcription_id_idx` ON `transcription_files` (`file_transcription_id`) USING BTREE;
CREATE  INDEX `fmd5_files_t` ON `transcription_files` (`folder_transcription_id`) USING BTREE;

-- ----------------------------
-- Table: transcription_files_checks
-- ----------------------------
DROP TABLE IF EXISTS `transcription_files_checks`;
CREATE TABLE `transcription_files_checks` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `file_transcription_id` varchar(36) DEFAULT NULL,
  `file_check` varchar(64) DEFAULT NULL,
  `check_results` int DEFAULT NULL,
  `check_info` text,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `filechecks_constr` (`file_transcription_id`,`file_check`),
  KEY `file_checks2_tid_idx` (`table_id`) USING BTREE,
  KEY `file_checks2_file_id_idx` (`file_transcription_id`) USING BTREE,
  KEY `file_checks2_file_check_idx` (`file_check`) USING BTREE,
  KEY `file_checks2_check_results_idx` (`check_results`) USING BTREE,
  KEY `file_checks2_fil_id_idx` (`file_transcription_id`,`check_results`) USING BTREE,
  CONSTRAINT `fckecks_t_files` FOREIGN KEY (`file_transcription_id`) REFERENCES `transcription_files` (`file_transcription_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=760957 DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_files_checks
CREATE UNIQUE INDEX `filechecks_constr` ON `transcription_files_checks` (`file_transcription_id`, `file_check`) USING BTREE;
CREATE  INDEX `file_checks2_tid_idx` ON `transcription_files_checks` (`table_id`) USING BTREE;
CREATE  INDEX `file_checks2_file_id_idx` ON `transcription_files_checks` (`file_transcription_id`) USING BTREE;
CREATE  INDEX `file_checks2_file_check_idx` ON `transcription_files_checks` (`file_check`) USING BTREE;
CREATE  INDEX `file_checks2_check_results_idx` ON `transcription_files_checks` (`check_results`) USING BTREE;
CREATE  INDEX `file_checks2_fil_id_idx` ON `transcription_files_checks` (`file_transcription_id`, `check_results`) USING BTREE;

-- ----------------------------
-- Table: transcription_files_links
-- ----------------------------
DROP TABLE IF EXISTS `transcription_files_links`;
CREATE TABLE `transcription_files_links` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_transcription_id` varchar(36) DEFAULT NULL,
  `link_name` varchar(254) DEFAULT NULL,
  `link_url` varchar(254) DEFAULT NULL,
  `link_notes` varchar(254) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `link_aria` varchar(254) DEFAULT NULL,
  UNIQUE KEY `table_id` (`table_id`),
  KEY `files_links2_tid_idx` (`table_id`) USING BTREE,
  KEY `files_links2_fid_idx` (`file_transcription_id`) USING BTREE,
  KEY `files_links2_lnk_idx` (`link_name`) USING BTREE,
  CONSTRAINT `flinks2_files` FOREIGN KEY (`file_transcription_id`) REFERENCES `transcription_files` (`file_transcription_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_files_links
CREATE UNIQUE INDEX `table_id` ON `transcription_files_links` (`table_id`) USING BTREE;
CREATE  INDEX `files_links2_tid_idx` ON `transcription_files_links` (`table_id`) USING BTREE;
CREATE  INDEX `files_links2_fid_idx` ON `transcription_files_links` (`file_transcription_id`) USING BTREE;
CREATE  INDEX `files_links2_lnk_idx` ON `transcription_files_links` (`link_name`) USING BTREE;

-- ----------------------------
-- Table: transcription_files_text
-- ----------------------------
DROP TABLE IF EXISTS `transcription_files_text`;
CREATE TABLE `transcription_files_text` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `file_transcription_id` varchar(36) DEFAULT NULL,
  `field_id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `transcription_notes` text,
  `transcription_text` text,
  `validation` smallint NOT NULL DEFAULT '9',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  KEY `file_md5_file_id_idx` (`file_transcription_id`) USING BTREE,
  CONSTRAINT `fmd5_files_id_t` FOREIGN KEY (`file_transcription_id`) REFERENCES `transcription_files` (`file_transcription_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=44596 DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_files_text
CREATE  INDEX `file_md5_file_id_idx` ON `transcription_files_text` (`file_transcription_id`) USING BTREE;

-- ----------------------------
-- Table: transcription_folders
-- ----------------------------
DROP TABLE IF EXISTS `transcription_folders`;
CREATE TABLE `transcription_folders` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `folder_transcription_id` varchar(36) DEFAULT NULL,
  `folder` varchar(254) NOT NULL,
  `project_id` int NOT NULL,
  `folder_path` text,
  `status` smallint DEFAULT '9',
  `delivered_to_dams` smallint DEFAULT '9',
  `no_files` int DEFAULT '0',
  `previews` smallint DEFAULT '9',
  `no_files_total` int DEFAULT '0',
  `no_files_errors` int DEFAULT '0',
  `no_files_ok` int DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `error_info` text,
  `date` date DEFAULT NULL,
  `file_errors` smallint DEFAULT '9',
  PRIMARY KEY (`table_id`),
  KEY `folder_transcription_id_idx` (`folder_transcription_id`) USING BTREE,
  KEY `idx_transcription_folders_project_date_folder` (`project_id`,`date` DESC,`folder` DESC),
  KEY `idx_transcription_folders_id` (`folder_transcription_id`),
  CONSTRAINT `proj_id_for_key` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1575 DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_folders
CREATE  INDEX `folder_transcription_id_idx` ON `transcription_folders` (`folder_transcription_id`) USING BTREE;
CREATE  INDEX `idx_transcription_folders_project_date_folder` ON `transcription_folders` (`project_id`, `date`, `folder`) USING BTREE;
CREATE  INDEX `idx_transcription_folders_id` ON `transcription_folders` (`folder_transcription_id`) USING BTREE;

-- ----------------------------
-- Table: transcription_qc
-- ----------------------------
DROP TABLE IF EXISTS `transcription_qc`;
CREATE TABLE `transcription_qc` (
  `table_id` int NOT NULL AUTO_INCREMENT,
  `folder_transcription_id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `transcription_source_id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `file_transcription_id` varchar(36) DEFAULT NULL,
  `qc_results` smallint DEFAULT '9',
  `qc_notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  KEY `transcription_qc_files_t` (`file_transcription_id`),
  CONSTRAINT `transcription_qc_files_t` FOREIGN KEY (`file_transcription_id`) REFERENCES `transcription_files` (`file_transcription_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1982 DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_qc
CREATE  INDEX `transcription_qc_files_t` ON `transcription_qc` (`file_transcription_id`) USING BTREE;

-- ----------------------------
-- Table: transcription_qc_folders
-- ----------------------------
DROP TABLE IF EXISTS `transcription_qc_folders`;
CREATE TABLE `transcription_qc_folders` (
  `table_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `folder_transcription_id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `transcription_source_id` varchar(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `qc_status` int DEFAULT '9',
  `qc_by` int DEFAULT NULL,
  `qc_ip` varchar(64) DEFAULT NULL,
  `qc_info` varchar(254) DEFAULT NULL,
  `qc_level` varchar(64) DEFAULT 'Normal',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`table_id`),
  UNIQUE KEY `table_id` (`table_id`),
  KEY `qc_folders_fid_idx` (`folder_transcription_id`) USING BTREE,
  KEY `qc_folders_sid_idx` (`transcription_source_id`) USING BTREE,
  KEY `qc_folders_qby_idx` (`qc_by`) USING BTREE,
  KEY `qc_folders_qstat_idx` (`qc_status`) USING BTREE,
  CONSTRAINT `qcfol_fol` FOREIGN KEY (`folder_transcription_id`) REFERENCES `transcription_folders` (`folder_transcription_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1064 DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_qc_folders
CREATE UNIQUE INDEX `table_id` ON `transcription_qc_folders` (`table_id`) USING BTREE;
CREATE  INDEX `qc_folders_fid_idx` ON `transcription_qc_folders` (`folder_transcription_id`) USING BTREE;
CREATE  INDEX `qc_folders_sid_idx` ON `transcription_qc_folders` (`transcription_source_id`) USING BTREE;
CREATE  INDEX `qc_folders_qby_idx` ON `transcription_qc_folders` (`qc_by`) USING BTREE;
CREATE  INDEX `qc_folders_qstat_idx` ON `transcription_qc_folders` (`qc_status`) USING BTREE;

-- ----------------------------
-- Table: transcription_qc_settings
-- ----------------------------
DROP TABLE IF EXISTS `transcription_qc_settings`;
CREATE TABLE `transcription_qc_settings` (
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
  `qc_filenames` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  PRIMARY KEY (`project_id`),
  KEY `tqc_settings_pid_idx` (`project_id`) USING BTREE,
  CONSTRAINT `tqset_proj` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_qc_settings
CREATE  INDEX `tqc_settings_pid_idx` ON `transcription_qc_settings` (`project_id`) USING BTREE;

-- ----------------------------
-- Table: transcription_sources
-- ----------------------------
DROP TABLE IF EXISTS `transcription_sources`;
CREATE TABLE `transcription_sources` (
  `transcription_source_id` varchar(36) NOT NULL,
  `project_id` smallint DEFAULT NULL,
  `transcription_source_name` text,
  `transcription_source_notes` text,
  `transcription_source_date` date DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`transcription_source_id`),
  KEY `transcription_files_sources_project_id_IDX` (`project_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- Indices for transcription_sources
CREATE  INDEX `transcription_files_sources_project_id_IDX` ON `transcription_sources` (`project_id`) USING BTREE;

-- ----------------------------
-- Table: users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `user_id` smallint NOT NULL AUTO_INCREMENT,
  `username` varchar(64) DEFAULT NULL,
  `full_name` varchar(254) DEFAULT NULL,
  `pass` varchar(32) DEFAULT NULL,
  `user_active` tinyint(1) DEFAULT '1',
  `is_admin` tinyint(1) DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `email` varchar(100) DEFAULT NULL,
  `internal` int DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `users_unique` (`email`),
  KEY `users_uid_idx` (`user_id`) USING BTREE,
  KEY `users_un_idx` (`username`) USING BTREE,
  KEY `users_ua_idx` (`user_active`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=utf8mb3;

-- Indices for users
CREATE UNIQUE INDEX `users_unique` ON `users` (`email`) USING BTREE;
CREATE  INDEX `users_uid_idx` ON `users` (`user_id`) USING BTREE;
CREATE  INDEX `users_un_idx` ON `users` (`username`) USING BTREE;
CREATE  INDEX `users_ua_idx` ON `users` (`user_active`) USING BTREE;

