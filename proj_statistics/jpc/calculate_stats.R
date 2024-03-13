# Generate figures for statistics of the digitization projects

# library(ggplot2)
library(DBI)
library(RMariaDB)

source("settings.R")

con <- dbConnect(RMariaDB::MariaDB(), dbname = database, username = user, password = password, host = host, port = port)

# JPC ----
# 
# ## Creation of records in ASpace
# # 0bc65ec3-7a10-4e43-bada-e5b1dff01532
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '0bc65ec3-7a10-4e43-bada-e5b1dff01532'")
# n <- dbExecute(con, "
# INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (
# select '0bc65ec3-7a10-4e43-bada-e5b1dff01532', creation_date, count(*) from jpc_aspace_data where creation_date > '2023-08-22' group by creation_date)")
#                
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '0bc65ec3-7a10-4e43-bada-e5b1dff01532'"))
# 
# # stat
# # 274a5332-791b-463d-a379-c934e6761d58
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '274a5332-791b-463d-a379-c934e6761d58'")
# n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (
# with data as (select creation_date, count(*) as no_images from jpc_aspace_data where creation_date > '2023-08-22' group by creation_date)
# select '274a5332-791b-463d-a379-c934e6761d58', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_images) from data)"))
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '274a5332-791b-463d-a379-c934e6761d58'"))
#                



# ## % Digitized
# refids <- dbGetQuery(con, "select count(distinct refid) as val from jpc_aspace_data")
# digitized_refids <- dbGetQuery(con, "select count(distinct id1_value) as val from jpc_massdigi_ids where id_relationship ='refid_hmo'")
# 
# percentage <- round((digitized_refids['val']/refids['val']) * 100, 3)
# 
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '7c9ec798-d31b-4c73-b937-c3a9b1ad2b70'")
# n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) (SELECT '7c9ec798-d31b-4c73-b937-c3a9b1ad2b70', '", format(Sys.time(), "%Y-%m-%d") ,"', '", percentage, "')"))
# 
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '7c9ec798-d31b-4c73-b937-c3a9b1ad2b70'"))




# Images by day by vendor
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





# Folder by day by vendor
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






# 
# # Record in ASpace to Photo
# # aa6a5093-3ed2-4a1e-b382-76a8432add48
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'aa6a5093-3ed2-4a1e-b382-76a8432add48'")
# n <- dbExecute(con, "
# INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (with jpc_files as (
#     select f.file_name, SUBSTRING_INDEX(file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as created_at from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
#     fe.tag='CreateDate' and f.file_id = fe.file_id
# ),
# files_digi as (
#     select min(j.created_at) as min_date, refid from jpc_files j group by refid
# )
# select 'aa6a5093-3ed2-4a1e-b382-76a8432add48', jpc.creation_date, avg(DATEDIFF(f.min_date, jpc.creation_date)) from files_digi f, jpc_aspace_data jpc where jpc.refid = f.refid group by jpc.creation_date)")
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'aa6a5093-3ed2-4a1e-b382-76a8432add48'"))
# 
# # stat
# # 6667510a-937e-455c-a15b-b4911291c929
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '6667510a-937e-455c-a15b-b4911291c929'")
# n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (with jpc_files as (
#     select f.file_name, SUBSTRING_INDEX(file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as created_at from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
#     fe.tag='CreateDate' and f.file_id = fe.file_id
# ),
# files_digi as (
#     select min(j.created_at) as min_date, refid from jpc_files j group by refid
# )
# select '6667510a-937e-455c-a15b-b4911291c929', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(f.min_date, jpc.creation_date)) from files_digi f, jpc_aspace_data jpc where jpc.refid = f.refid)"))
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '6667510a-937e-455c-a15b-b4911291c929'"))





# Vendor to DPO
# 6c40554a-b546-48ab-8535-ff59d5a2806b
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '6c40554a-b546-48ab-8535-ff59d5a2806b'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select '6c40554a-b546-48ab-8535-ff59d5a2806b', digi_date, DATEDIFF(osprey_date, digi_date) from jpc_files
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

               
                              
# DPO to DAMS
# 51650169-dba0-407f-b22c-fe51ebeeb144
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '51650169-dba0-407f-b22c-fe51ebeeb144'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, 
	DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date, 
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date
from files f, files_exif fe, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 186) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id and
	f.dams_uan = d.dams_uan 
	)
	select '51650169-dba0-407f-b22c-fe51ebeeb144', osprey_date, avg(DATEDIFF(dams_date, osprey_date))
	from fdates f group by osprey_date
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '51650169-dba0-407f-b22c-fe51ebeeb144'"))
               
# stat
# 55404bf2-dc95-4a6d-957a-03ac59b3dc9f
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '55404bf2-dc95-4a6d-957a-03ac59b3dc9f'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, 
	DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date, 
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date
from files f, files_exif fe, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 186) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id and
	f.dams_uan = d.dams_uan 
	)
	select '55404bf2-dc95-4a6d-957a-03ac59b3dc9f', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(dams_date, osprey_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '55404bf2-dc95-4a6d-957a-03ac59b3dc9f'"))
               
               
               




# DPO to ID Manager
# 9bcca149-0027-4c8d-bce7-b6f370f66767
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '9bcca149-0027-4c8d-bce7-b6f370f66767'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, 
	cast('2024-02-06' as date) as getty_date
from files f
where f.folder_id in (select folder_id from folders where project_id = 186)
	)
	select '9bcca149-0027-4c8d-bce7-b6f370f66767', osprey_date, avg(DATEDIFF(getty_date, osprey_date))
	from fdates f group by osprey_date
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '9bcca149-0027-4c8d-bce7-b6f370f66767'"))

# stat
# 2f0a4c97-6d2b-47b1-a5ae-d2541515da43
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '2f0a4c97-6d2b-47b1-a5ae-d2541515da43'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, 
	cast('2024-02-06' as date) as getty_date
from files f
where f.folder_id in (select folder_id from folders where project_id = 186)
	)
	select '2f0a4c97-6d2b-47b1-a5ae-d2541515da43', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(getty_date, osprey_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '2f0a4c97-6d2b-47b1-a5ae-d2541515da43'"))
               
               
               

dbDisconnect(con)

