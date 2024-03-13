# Generate figures for statistics of the digitization projects

# library(ggplot2)
library(DBI)
library(RMariaDB)

source("settings.R")

con <- dbConnect(RMariaDB::MariaDB(), dbname = database, username = user, password = password, host = host, port = port)

# Images by day by vendor
# 0d305406-9df3-4b91-993f-425d5a38f898
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '0d305406-9df3-4b91-993f-425d5a38f898'")
n <- dbExecute(con, "
INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with digi_files as (
    select f.file_name, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 183) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
)
select '0d305406-9df3-4b91-993f-425d5a38f898', digi_files.creation_date, count(*) from digi_files group by digi_files.creation_date)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '0d305406-9df3-4b91-993f-425d5a38f898'"))

# stat
# 512549b6-9b2c-434c-8150-46c42d45e4ee
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '512549b6-9b2c-434c-8150-46c42d45e4ee'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with digi_files as (
    select f.file_name, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 183) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select creation_date, count(*) as no_images from digi_files group by creation_date
)
select '512549b6-9b2c-434c-8150-46c42d45e4ee', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_images) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '512549b6-9b2c-434c-8150-46c42d45e4ee'"))





# Folder by day by vendor
# 25259ff9-eac4-4cfd-b07f-1e01c9d53f4d
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '25259ff9-eac4-4cfd-b07f-1e01c9d53f4d'")
# n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (with jpc_files as (
#     select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
#     fe.tag='CreateDate' and f.file_id = fe.file_id
# )
# select '25259ff9-eac4-4cfd-b07f-1e01c9d53f4d', jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date)"))
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '25259ff9-eac4-4cfd-b07f-1e01c9d53f4d'"))
# 
# # stat
# # 67c16c2c-d990-46b8-9cb1-2eff57ece03d
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '67c16c2c-d990-46b8-9cb1-2eff57ece03d'")
# n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (with jpc_files as (
#     select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 186) and 
#     fe.tag='CreateDate' and f.file_id = fe.file_id
# ),
# vendor as (
# select jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date
# )
# select '67c16c2c-d990-46b8-9cb1-2eff57ece03d', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_refids) from vendor)"))
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '67c16c2c-d990-46b8-9cb1-2eff57ece03d'"))
# 





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
# d36e01fe-18df-42e7-935c-4ab8b6ee640a
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'd36e01fe-18df-42e7-935c-4ab8b6ee640a'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with digi_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 183) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select 'd36e01fe-18df-42e7-935c-4ab8b6ee640a', digi_date, DATEDIFF(osprey_date, digi_date) from digi_files
    )")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'd36e01fe-18df-42e7-935c-4ab8b6ee640a'"))
               

# Vendor to DPO - stat
# 5b05cba3-566d-4046-b5f6-12fb6cae6cfd
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '5b05cba3-566d-4046-b5f6-12fb6cae6cfd'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with digi_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 183) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select '5b05cba3-566d-4046-b5f6-12fb6cae6cfd', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(osprey_date, digi_date)) from digi_files)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '5b05cba3-566d-4046-b5f6-12fb6cae6cfd'"))

               
                              
# DPO to DAMS
# dfcc618d-abc5-431f-94de-f9dde169a500
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'dfcc618d-abc5-431f-94de-f9dde169a500'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, 
	DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date, 
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date
from files f, files_exif fe, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 183) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id and
	f.dams_uan = d.dams_uan 
	)
	select 'dfcc618d-abc5-431f-94de-f9dde169a500', osprey_date, avg(DATEDIFF(dams_date, osprey_date))
	from fdates f group by osprey_date
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'dfcc618d-abc5-431f-94de-f9dde169a500'"))
               
# stat
# 00e5714a-364a-4d01-860e-90e1027ad43b
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '00e5714a-364a-4d01-860e-90e1027ad43b'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, 
	DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date, 
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date
from files f, files_exif fe, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 183) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id and
	f.dams_uan = d.dams_uan 
	)
	select '00e5714a-364a-4d01-860e-90e1027ad43b', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(dams_date, osprey_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '00e5714a-364a-4d01-860e-90e1027ad43b'"))

               
               



# 
# # DPO to ID Manager
# # 9bcca149-0027-4c8d-bce7-b6f370f66767
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '9bcca149-0027-4c8d-bce7-b6f370f66767'")
# n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (
# with fdates as (
# select f.file_name, 
# 	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, 
# 	cast('2024-02-06' as date) as getty_date
# from files f
# where f.folder_id in (select folder_id from folders where project_id = 186)
# 	)
# 	select '9bcca149-0027-4c8d-bce7-b6f370f66767', osprey_date, avg(DATEDIFF(getty_date, osprey_date))
# 	from fdates f group by osprey_date
# 	)")
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '9bcca149-0027-4c8d-bce7-b6f370f66767'"))
# 
# # stat
# # 2f0a4c97-6d2b-47b1-a5ae-d2541515da43
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '2f0a4c97-6d2b-47b1-a5ae-d2541515da43'")
# n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (
# with fdates as (
# select f.file_name, 
# 	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, 
# 	cast('2024-02-06' as date) as getty_date
# from files f
# where f.folder_id in (select folder_id from folders where project_id = 186)
# 	)
# 	select '2f0a4c97-6d2b-47b1-a5ae-d2541515da43', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(getty_date, osprey_date))
# 	from fdates f
# 	)"))
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '2f0a4c97-6d2b-47b1-a5ae-d2541515da43'"))
#                
#                
               

dbDisconnect(con)

