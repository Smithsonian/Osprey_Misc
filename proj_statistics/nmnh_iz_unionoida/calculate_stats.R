# Generate figures for statistics of the digitization projects

# library(ggplot2)
library(DBI)
library(RMariaDB)

source("settings.R")

con <- dbConnect(RMariaDB::MariaDB(), dbname = database, username = user, password = password, host = host, port = port)

n <- dbExecute(con, "set time_zone = '-04:00';")

# nmnh_unionioda
# 8d8a1e3f-61fc-491f-bfd8-98f84b1f590f


# Images by day by vendor ----
# c2bc3c4d-f1b5-4661-866c-341a6770b109
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'c2bc3c4d-f1b5-4661-866c-341a6770b109'")
n <- dbExecute(con, "
INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_',4) as file_name, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 183) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
)
select 'c2bc3c4d-f1b5-4661-866c-341a6770b109', jpc.creation_date, count(distinct file_name) from jpc_files jpc group by jpc.creation_date)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'c2bc3c4d-f1b5-4661-866c-341a6770b109'"))

# stat
# b3b33f4b-798f-47a4-933a-0112906b6389
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'b3b33f4b-798f-47a4-933a-0112906b6389'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with proj_files as (
    select SUBSTRING_INDEX(f.file_name, '_',4) as file_name, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 183) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select proj.creation_date, count(distinct file_name) as no_spec from proj_files proj group by proj.creation_date
)
select 'b3b33f4b-798f-47a4-933a-0112906b6389', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_spec) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'b3b33f4b-798f-47a4-933a-0112906b6389'"))






# Vendor to DPO----
# 8d5f36fa-dfda-4efd-9766-821a8bfe588b
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '8d5f36fa-dfda-4efd-9766-821a8bfe588b'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 183) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select file_name,  '8d5f36fa-dfda-4efd-9766-821a8bfe588b', digi_date, DATEDIFF(osprey_date, digi_date)  from jpc_files 
    )")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '8d5f36fa-dfda-4efd-9766-821a8bfe588b'"))
               

# Vendor to DPO - stat
# 15dc3be5-ec68-4a7d-b703-6796e56c4235
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '15dc3be5-ec68-4a7d-b703-6796e56c4235'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 183) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select '15dc3be5-ec68-4a7d-b703-6796e56c4235', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(osprey_date, digi_date)) from jpc_files)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '15dc3be5-ec68-4a7d-b703-6796e56c4235'"))




# DPO to QC ----
# cf4ef9bc-f7bc-445a-8e62-27166eab24eb
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'cf4ef9bc-f7bc-445a-8e62-27166eab24eb'")
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
	select file_name, 'cf4ef9bc-f7bc-445a-8e62-27166eab24eb', osprey_date, DATEDIFF(qc_date, osprey_date)
	from fdates f 
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'cf4ef9bc-f7bc-445a-8e62-27166eab24eb'"))
               
# stat
# d2ea2035-d145-43ca-80a5-7a311201b629
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'd2ea2035-d145-43ca-80a5-7a311201b629'")
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
	select 'd2ea2035-d145-43ca-80a5-7a311201b629', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(qc_date, osprey_date))
	from fdates f 
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'd2ea2035-d145-43ca-80a5-7a311201b629'"))
               
               
               





# QC to DAMS----
# 6b570015-6561-48c6-93f9-099b4b02445a
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '6b570015-6561-48c6-93f9-099b4b02445a'")
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
	select file_name, '6b570015-6561-48c6-93f9-099b4b02445a', qc_date, DATEDIFF(dams_date, qc_date)
	from fdates f 	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '6b570015-6561-48c6-93f9-099b4b02445a'"))
               
# stat
# 47f6a1a3-1d93-4568-9885-a32d8cbbacca
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '47f6a1a3-1d93-4568-9885-a32d8cbbacca'")
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
	select '47f6a1a3-1d93-4568-9885-a32d8cbbacca', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(dams_date, qc_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '47f6a1a3-1d93-4568-9885-a32d8cbbacca'"))

               
               

dbDisconnect(con)

