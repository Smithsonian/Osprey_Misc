-- Tables to store the database view from DAMS (OTMM)
--   for DPO projects 

-- dams_cdis_file_status_view_dpo
CREATE TABLE dams_cdis_file_status_view_dpo (
	vfcu_media_file_id varchar(12),
	file_name varchar(254),
	project_cd varchar(96),
	dams_uan varchar(96) DEFAULT NULL,
	to_dams_ingest_dt timestamp
);

CREATE INDEX dams_cdis_stat_damsuan_idx ON dams_cdis_file_status_view_dpo (dams_uan) USING btree;
CREATE INDEX dams_cdis_stat_fileid_idx ON dams_cdis_file_status_view_dpo (vfcu_media_file_id) USING btree;
CREATE INDEX dams_cdis_stat_filename_idx ON dams_cdis_file_status_view_dpo (file_name) USING btree;
CREATE INDEX dams_cdis_stat_pcd_idx ON dams_cdis_file_status_view_dpo (project_cd) USING btree;


-- dams_vfcu_file_view_dpo
CREATE TABLE dams_vfcu_file_view_dpo (
	vfcu_media_file_id varchar(12),
	project_cd varchar(96),
	media_file_name varchar(254),
	vfcu_pickup_loc varchar(254),
	vfcu_checksum varchar(32)
);

CREATE INDEX dams_vfcu_file_fileid_idx ON dams_vfcu_file_view_dpo (vfcu_media_file_id) USING btree;
CREATE INDEX dams_vfcu_file_mediafilename_idx ON dams_vfcu_file_view_dpo (media_file_name) USING btree;
CREATE INDEX dams_vfcu_file_pickuploc_idx ON dams_vfcu_file_view_dpo (vfcu_pickup_loc) USING btree;
CREATE INDEX dams_vfcu_file_projectid_idx ON dams_vfcu_file_view_dpo (project_cd) USING btree;
