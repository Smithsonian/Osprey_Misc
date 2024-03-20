# Generate figures for statistics of the digitization projects

# library(ggplot2)
library(DBI)
library(RMariaDB)

source("settings.R")

con <- dbConnect(RMariaDB::MariaDB(), dbname = database, username = user, password = password, host = host, port = port)

n <- dbExecute(con, "set time_zone = '-04:00';")

# botany_accessions
# 96e6027f-f05c-4429-92d5-fd3e094b5bd1


# Images by day by vendor ----
# 70992012-c8f2-4979-b9b5-79862927bee6
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '70992012-c8f2-4979-b9b5-79862927bee6'")
n <- dbExecute(con, "
INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_',4) as file_name, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 195) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
)
select '70992012-c8f2-4979-b9b5-79862927bee6', jpc.creation_date, count(distinct file_name) from jpc_files jpc group by jpc.creation_date)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '70992012-c8f2-4979-b9b5-79862927bee6'"))

# stat
# b5cdc68f-bf07-4791-a961-b310c750b25b
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'b5cdc68f-bf07-4791-a961-b310c750b25b'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with proj_files as (
    select SUBSTRING_INDEX(f.file_name, '_',4) as file_name, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 195) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select proj.creation_date, count(distinct file_name) as no_spec from proj_files proj group by proj.creation_date
)
select 'b5cdc68f-bf07-4791-a961-b310c750b25b', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_spec) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'b5cdc68f-bf07-4791-a961-b310c750b25b'"))






# Vendor to DPO----
# 6cc391aa-cef6-4492-9f10-0c99264b86eb
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '6cc391aa-cef6-4492-9f10-0c99264b86eb'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 195) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select file_name,  '6cc391aa-cef6-4492-9f10-0c99264b86eb', digi_date, DATEDIFF(osprey_date, digi_date)  from jpc_files 
    )")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '6cc391aa-cef6-4492-9f10-0c99264b86eb'"))
               

# Vendor to DPO - stat
# a0b4082d-cf8c-420a-acb1-6ab26155452e
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'a0b4082d-cf8c-420a-acb1-6ab26155452e'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with jpc_files as (
	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 195) and 
	fe.tag='CreateDate' and f.file_id = fe.file_id
	)
select 'a0b4082d-cf8c-420a-acb1-6ab26155452e', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(osprey_date, digi_date)) from jpc_files)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'a0b4082d-cf8c-420a-acb1-6ab26155452e'"))




# DPO to QC ----
# 69866040-9fc6-45bd-91a2-9f4edfe79ebc
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '69866040-9fc6-45bd-91a2-9f4edfe79ebc'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol
where f.folder_id in (select folder_id from folders where project_id = 195) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id
	)
	select file_name, '69866040-9fc6-45bd-91a2-9f4edfe79ebc', osprey_date, DATEDIFF(qc_date, osprey_date)
	from fdates f 
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '69866040-9fc6-45bd-91a2-9f4edfe79ebc'"))
               
# stat
# 6dd9ea0d-e3bd-4fc9-84b2-682880ac13dd
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '6dd9ea0d-e3bd-4fc9-84b2-682880ac13dd'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol
where f.folder_id in (select folder_id from folders where project_id = 195) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id
	)
	select '6dd9ea0d-e3bd-4fc9-84b2-682880ac13dd', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(qc_date, osprey_date))
	from fdates f 
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '6dd9ea0d-e3bd-4fc9-84b2-682880ac13dd'"))
               
               
               





# QC to DAMS----
# cc06d5af-2ec8-4aa3-ad92-0c94d41b3830
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'cc06d5af-2ec8-4aa3-ad92-0c94d41b3830'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 195) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select file_name, 'cc06d5af-2ec8-4aa3-ad92-0c94d41b3830', qc_date, DATEDIFF(dams_date, qc_date)
	from fdates f 	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'cc06d5af-2ec8-4aa3-ad92-0c94d41b3830'"))
               
# stat
# e5c3020c-f2e9-4dd7-b309-64acc3faf372
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'e5c3020c-f2e9-4dd7-b309-64acc3faf372'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 195) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select 'e5c3020c-f2e9-4dd7-b309-64acc3faf372', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(DATEDIFF(dams_date, qc_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'e5c3020c-f2e9-4dd7-b309-64acc3faf372'"))

               
               

dbDisconnect(con)

