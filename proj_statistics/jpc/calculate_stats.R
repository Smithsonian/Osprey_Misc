# Generate figures for statistics of the digitization projects

# library(ggplot2)
library(DBI)
library(RMariaDB)

source("settings.R")

con <- dbConnect(RMariaDB::MariaDB(), dbname = database, username = user, password = password, host = host, port = port)

n <- dbExecute(con, "set time_zone = '-04:00';")

# JPC
# # ## % Digitized
# refids <- dbGetQuery(con, "select count(distinct refid) as val from jpc_aspace_data")
# digitized_refids <- dbGetQuery(con, "select count(distinct id1_value) as val from jpc_massdigi_ids where id_relationship ='refid_hmo'")
# 
# percentage <- round((digitized_refids['val']/refids['val']) * 100, 3)
# 
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '7c9ec798-d31b-4c73-b937-c3a9b1ad2b70'")
# n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) (SELECT '7c9ec798-d31b-4c73-b937-c3a9b1ad2b70', '", format(Sys.time(), "%Y-%m-%d") ,"', '", percentage, "')"))
# 
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '7c9ec798-d31b-4c73-b937-c3a9b1ad2b70'"))




# Images by day by vendor ----
# 131bcf0b-1e86-4810-bc80-e4828087af54
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '131bcf0b-1e86-4810-bc80-e4828087af54'")
n <- dbExecute(con, "
INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select f.file_name, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
)
select '131bcf0b-1e86-4810-bc80-e4828087af54', jpc.creation_date, count(*) from jpc_files jpc group by jpc.creation_date)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '131bcf0b-1e86-4810-bc80-e4828087af54'"))

# stat
# 7140864f-a218-4af1-b8c3-e69df721c1a0
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '7140864f-a218-4af1-b8c3-e69df721c1a0'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select f.file_name, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select jpc.creation_date, count(*) as no_images from jpc_files jpc group by jpc.creation_date
)
select '7140864f-a218-4af1-b8c3-e69df721c1a0', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_images) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '7140864f-a218-4af1-b8c3-e69df721c1a0'"))





# Archival items (Folders) by day by vendor----
# 25259ff9-eac4-4cfd-b07f-1e01c9d53f4d
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '25259ff9-eac4-4cfd-b07f-1e01c9d53f4d'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
)
select '25259ff9-eac4-4cfd-b07f-1e01c9d53f4d', jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '25259ff9-eac4-4cfd-b07f-1e01c9d53f4d'"))

# stat
# 67c16c2c-d990-46b8-9cb1-2eff57ece03d
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '67c16c2c-d990-46b8-9cb1-2eff57ece03d'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date
)
select '67c16c2c-d990-46b8-9cb1-2eff57ece03d', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_refids) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '67c16c2c-d990-46b8-9cb1-2eff57ece03d'"))







# Vendor to DPO----
# 6c40554a-b546-48ab-8535-ff59d5a2806b
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '6c40554a-b546-48ab-8535-ff59d5a2806b'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select file_name,  '6c40554a-b546-48ab-8535-ff59d5a2806b', digi_date, DATEDIFF(osprey_date, digi_date)  from jpc_files 
    )")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '6c40554a-b546-48ab-8535-ff59d5a2806b'"))
               

# Vendor to DPO - stat
# d85447d5-89ac-4814-9083-c840b614a4a3 
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'd85447d5-89ac-4814-9083-c840b614a4a3'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select 'd85447d5-89ac-4814-9083-c840b614a4a3', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(osprey_date, digi_date)) from jpc_files)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'd85447d5-89ac-4814-9083-c840b614a4a3'"))




# DPO to QC ----
# 51650169-dba0-407f-b22c-fe51ebeeb144
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '51650169-dba0-407f-b22c-fe51ebeeb144'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol
where f.folder_id in (select folder_id from folders where project_id = 186) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id
	)
	select file_name, '51650169-dba0-407f-b22c-fe51ebeeb144', osprey_date, DATEDIFF(qc_date, osprey_date)
	from fdates f 
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '51650169-dba0-407f-b22c-fe51ebeeb144'"))
               
# stat
# 55404bf2-dc95-4a6d-957a-03ac59b3dc9f
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '55404bf2-dc95-4a6d-957a-03ac59b3dc9f'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol
where f.folder_id in (select folder_id from folders where project_id = 186) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id
	)
	select '55404bf2-dc95-4a6d-957a-03ac59b3dc9f', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(qc_date, osprey_date))
	from fdates f 
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '55404bf2-dc95-4a6d-957a-03ac59b3dc9f'"))
               
               
               





# QC to DAMS----
# 73f9b27c-0eb3-489a-8f8b-e284b439aed5
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '73f9b27c-0eb3-489a-8f8b-e284b439aed5'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 186) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select file_name, '73f9b27c-0eb3-489a-8f8b-e284b439aed5', qc_date, DATEDIFF(dams_date, qc_date)
	from fdates f 	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '73f9b27c-0eb3-489a-8f8b-e284b439aed5'"))
               
# stat
# d01e5ebc-53df-4fcf-9a08-5cc91f07212b
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'd01e5ebc-53df-4fcf-9a08-5cc91f07212b'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 186) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select 'd01e5ebc-53df-4fcf-9a08-5cc91f07212b', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(dams_date, qc_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'd01e5ebc-53df-4fcf-9a08-5cc91f07212b'"))
                              
                              
                              
                              



# DaMS ingest to Getty
# 9bcca149-0027-4c8d-bce7-b6f370f66767
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '9bcca149-0027-4c8d-bce7-b6f370f66767'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(
with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	cast('2024-02-06' as date) as getty_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 186) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select file_name, '9bcca149-0027-4c8d-bce7-b6f370f66767', dams_date, DATEDIFF(getty_date, dams_date)
	from fdates f 
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '9bcca149-0027-4c8d-bce7-b6f370f66767'"))

# stat
# 2f0a4c97-6d2b-47b1-a5ae-d2541515da43
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '2f0a4c97-6d2b-47b1-a5ae-d2541515da43'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	cast('2024-02-06' as date) as getty_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 186) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select '2f0a4c97-6d2b-47b1-a5ae-d2541515da43', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(getty_date, dams_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '2f0a4c97-6d2b-47b1-a5ae-d2541515da43'"))
               
               
               

dbDisconnect(con)

