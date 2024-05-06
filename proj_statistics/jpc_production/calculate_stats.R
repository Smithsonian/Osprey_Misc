# Generate figures for statistics of the digitization projects

# library(ggplot2)
library(DBI)
library(RMariaDB)

source("settings.R")

con <- dbConnect(RMariaDB::MariaDB(), dbname = database, username = user, password = password, host = host, port = port)

n <- dbExecute(con, "set time_zone = '-04:00';")

# JPC
## Creation of records in ASpace
# a378e4bc-3a3d-4829-95fc-83993e5fdf9a
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'a378e4bc-3a3d-4829-95fc-83993e5fdf9a'")
n <- dbExecute(con, "
INSERT INTO projects_detail_statistics (step_id, date, step_value)
(
with data as (
    select concat(DATE_FORMAT(creation_date, \"%Y-%m\"), '-01') as creation_date, count(*) as no_records from jpc_aspace_data group by concat(DATE_FORMAT(creation_date, \"%Y-%m\"), '-01'))
select 'a378e4bc-3a3d-4829-95fc-83993e5fdf9a', creation_date, 
no_records from data
               )")

n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'a378e4bc-3a3d-4829-95fc-83993e5fdf9a'"))

# stat
# 55b7349c-aec9-47fa-93db-80821b534640
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '55b7349c-aec9-47fa-93db-80821b534640'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value)
(
with data as (select concat(DATE_FORMAT(creation_date, \"%Y-%m\"), '-01') as creation_date, count(*) as no_records from jpc_aspace_data group by concat(DATE_FORMAT(creation_date, \"%Y-%m\"), '-01'))
select '55b7349c-aec9-47fa-93db-80821b534640', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_records) from data)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '55b7349c-aec9-47fa-93db-80821b534640'"))














# % Digitized
# d35e8e63-f271-49cd-a3c8-5487a3b9369c
refids <- dbGetQuery(con, "select count(distinct refid) as val from jpc_aspace_data")
digitized_refids <- dbGetQuery(con, "select count(distinct id1_value) as val from jpc_massdigi_ids where id_relationship ='refid_hmo'")

percentage <- round((digitized_refids['val']/refids['val']) * 100, 3)

n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'd35e8e63-f271-49cd-a3c8-5487a3b9369c'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) (SELECT 'd35e8e63-f271-49cd-a3c8-5487a3b9369c', '", format(Sys.time(), "%Y-%m-%d") ,"', '", percentage, "')"))

n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'd35e8e63-f271-49cd-a3c8-5487a3b9369c'"))

# Area Figure
# 8ed2cb9b-0687-4c21-bac6-d7681b03fa62
refids <- dbGetQuery(con, "select count(distinct refid) as val from jpc_aspace_data")
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '8ed2cb9b-0687-4c21-bac6-d7681b03fa62'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
   with data as (
  select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date 
  from files f, files_exif fe where f.folder_id in 
  (select folder_id from folders where (project_id = 201 or project_id = 186)) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
data2 as (
select refid, min(creation_date) as creation_date from data
group by refid)
, data3 as (
select
  creation_date,
  count(refid) over (order by creation_date) as cumulative_sum
from data2
)
select creation_date, cumulative_sum from data3 group by creation_date, cumulative_sum

)
select '8ed2cb9b-0687-4c21-bac6-d7681b03fa62', jpc.creation_date, 
               cumulative_sum
               from jpc_files jpc)"))


n <- dbExecute(con, paste0("UPDATE projects_detail_statistics SET step_value = (step_value/",
        as.integer(refids['val'][1,1])
        ,") * 100 WHERE step_id = '8ed2cb9b-0687-4c21-bac6-d7681b03fa62'"))


n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '8ed2cb9b-0687-4c21-bac6-d7681b03fa62'"))






# Archival items (Folders) by day by vendor----
# eeb367ee-7731-40cd-bd7d-887674f9c9b6
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'eeb367ee-7731-40cd-bd7d-887674f9c9b6'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 201) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
)
select 'eeb367ee-7731-40cd-bd7d-887674f9c9b6', jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'eeb367ee-7731-40cd-bd7d-887674f9c9b6'"))

# stat
# 55b6279d-c2d2-4561-bc42-9f42c441d783
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '55b6279d-c2d2-4561-bc42-9f42c441d783'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 201) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date
)
select '55b6279d-c2d2-4561-bc42-9f42c441d783', from_unixtime( avg(unix_timestamp(creation_date))), avg(no_refids) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '55b6279d-c2d2-4561-bc42-9f42c441d783'"))

# timeline
# 62120a44-dd0b-462b-9c60-1bfa8b170854
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '62120a44-dd0b-462b-9c60-1bfa8b170854'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 201) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date
)
select '62120a44-dd0b-462b-9c60-1bfa8b170854', from_unixtime( avg(unix_timestamp(creation_date))), avg(no_refids) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '62120a44-dd0b-462b-9c60-1bfa8b170854'"))







# Vendor to DPO----
# 784fe57a-439c-491d-93eb-0619df01d4f6
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '784fe57a-439c-491d-93eb-0619df01d4f6'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 201) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select file_name,  '784fe57a-439c-491d-93eb-0619df01d4f6', digi_date, DATEDIFF(osprey_date, digi_date)  from jpc_files 
    )")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '784fe57a-439c-491d-93eb-0619df01d4f6'"))
               

# Vendor to DPO - stat
# 4e1da114-59c7-49dc-a331-86d45a1b7ea8
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '4e1da114-59c7-49dc-a331-86d45a1b7ea8'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 201) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select '4e1da114-59c7-49dc-a331-86d45a1b7ea8', from_unixtime( avg(unix_timestamp(osprey_date))), avg(DATEDIFF(osprey_date, digi_date)) from jpc_files)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '4e1da114-59c7-49dc-a331-86d45a1b7ea8'"))




# DPO to QC ----
# 76d1a3a3-c8b5-4854-a187-f1e49e061205
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '76d1a3a3-c8b5-4854-a187-f1e49e061205'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol
where f.folder_id in (select folder_id from folders where project_id = 201) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id
	)
	select file_name, '76d1a3a3-c8b5-4854-a187-f1e49e061205', osprey_date, DATEDIFF(qc_date, osprey_date)
	from fdates f 
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '76d1a3a3-c8b5-4854-a187-f1e49e061205'"))
               
# stat
# a1779c2f-48c1-4f99-967e-cc83817b7cf7
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'a1779c2f-48c1-4f99-967e-cc83817b7cf7'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol
where f.folder_id in (select folder_id from folders where project_id = 201) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id
	)
	select 'a1779c2f-48c1-4f99-967e-cc83817b7cf7', from_unixtime( avg(unix_timestamp(qc_date))), avg(DATEDIFF(qc_date, osprey_date))
	from fdates f 
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'a1779c2f-48c1-4f99-967e-cc83817b7cf7'"))
               
               
               





# QC to DAMS----
# 3146acec-3590-43b1-a9d3-6079b2cfce52
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '3146acec-3590-43b1-a9d3-6079b2cfce52'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 201) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select file_name, '3146acec-3590-43b1-a9d3-6079b2cfce52', qc_date, DATEDIFF(dams_date, qc_date)
	from fdates f 	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '3146acec-3590-43b1-a9d3-6079b2cfce52'"))
               
# stat
# 96972b9f-d431-41e2-8969-48ad86e57b62
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '96972b9f-d431-41e2-8969-48ad86e57b62'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 201) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select '96972b9f-d431-41e2-8969-48ad86e57b62', from_unixtime( avg(unix_timestamp(dams_date))), avg(DATEDIFF(dams_date, qc_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '96972b9f-d431-41e2-8969-48ad86e57b62'"))
                              
                              
                              
                              



# DaMS ingest to Getty
# 594c57d9-9356-491e-8507-6fdb886a2bf5
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '594c57d9-9356-491e-8507-6fdb886a2bf5'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(
with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	cast('2024-02-06' as date) as getty_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 201) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select file_name, '594c57d9-9356-491e-8507-6fdb886a2bf5', dams_date, DATEDIFF(getty_date, dams_date)
	from fdates f 
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '594c57d9-9356-491e-8507-6fdb886a2bf5'"))

# stat
# abcd1a4f-2f49-4908-b2b4-59c24711a742
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'abcd1a4f-2f49-4908-b2b4-59c24711a742'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	cast('2024-02-06' as date) as getty_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 201) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select 'abcd1a4f-2f49-4908-b2b4-59c24711a742', from_unixtime( avg(unix_timestamp(getty_date))), avg(DATEDIFF(getty_date, dams_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'abcd1a4f-2f49-4908-b2b4-59c24711a742'"))
               
               
               

dbDisconnect(con)

