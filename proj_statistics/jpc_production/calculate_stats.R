# Generate figures for statistics of the digitization projects

# library(ggplot2)
library(DBI)
library(RMariaDB)

source("settings.R")

con <- dbConnect(RMariaDB::MariaDB(), dbname = database, username = user, password = password, host = host, port = port)

n <- dbExecute(con, "set time_zone = '-04:00';")

# JPC
## Creation of records in ASpace
# 8c57719a-fd21-4ea0-92e4-e72c7d2c9399
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '8c57719a-fd21-4ea0-92e4-e72c7d2c9399'")
n <- dbExecute(con, "
INSERT INTO projects_detail_statistics (step_id, date, step_value)
(
with data as (
    select concat(DATE_FORMAT(creation_date, \"%Y-%m\"), '-01') as creation_date, count(*) as no_records from jpc_aspace_data group by concat(DATE_FORMAT(creation_date, \"%Y-%m\"), '-01'))
select '8c57719a-fd21-4ea0-92e4-e72c7d2c9399', creation_date, 
no_records from data
               )")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '8c57719a-fd21-4ea0-92e4-e72c7d2c9399'"))


# stat
# b85726f3-9fef-4212-8350-0014fb3e2b78
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'b85726f3-9fef-4212-8350-0014fb3e2b78'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value)
(
with data as (select concat(DATE_FORMAT(creation_date, \"%Y-%m\"), '-01') as creation_date, count(*) as no_records from jpc_aspace_data group by concat(DATE_FORMAT(creation_date, \"%Y-%m\"), '-01'))
select 'b85726f3-9fef-4212-8350-0014fb3e2b78', '", format(Sys.time(), "%Y-%m-%d") ,"', avg(no_records) from data)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'b85726f3-9fef-4212-8350-0014fb3e2b78'"))














# % Digitized
# 0a8c5896-1541-418c-9575-06951d337439

refids <- dbGetQuery(con, "select count(distinct refid) as val from jpc_aspace_data")
digitized_refids <- dbGetQuery(con, "select count(DISTINCT SUBSTRING_INDEX(f.file_name, '_', 2)) as val
  from files f where f.folder_id in 
  (select folder_id from folders where project_id = 220)")


percentage <- round((digitized_refids['val']/328910) * 100, 3)

n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '0a8c5896-1541-418c-9575-06951d337439'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) (SELECT '0a8c5896-1541-418c-9575-06951d337439', '", format(Sys.time(), "%Y-%m-%d") ,"', '", percentage, "')"))

n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '0a8c5896-1541-418c-9575-06951d337439'"))

# Area Figure
# 4972817c-1222-4892-981f-d71baed57734
refids <- dbGetQuery(con, "select count(distinct refid) as val from jpc_aspace_data")
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '4972817c-1222-4892-981f-d71baed57734'")

n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
   with data as (
  select SUBSTRING_INDEX(f.file_name, '_', 1) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date 
  from files f, files_exif fe where f.folder_id in 
  (select folder_id from folders where project_id = 220) and 
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
select '4972817c-1222-4892-981f-d71baed57734', jpc.creation_date, 
               cumulative_sum
               from jpc_files jpc)"))

n <- dbExecute(con, paste0("UPDATE projects_detail_statistics SET step_value = (step_value/",
        as.integer(refids['val'][1,1])
        ,") * 100 WHERE step_id = '4972817c-1222-4892-981f-d71baed57734'"))


n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '4972817c-1222-4892-981f-d71baed57734'"))






# Archival items (Folders) by day by vendor----
# 8c57719a-fd21-4ea0-92e4-e72c7d2c9399
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '8c57719a-fd21-4ea0-92e4-e72c7d2c9399'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_', 2) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 220) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
)
select '8c57719a-fd21-4ea0-92e4-e72c7d2c9399', jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '8c57719a-fd21-4ea0-92e4-e72c7d2c9399'"))

# stat
# 7fcff8ec-8935-48fe-aa55-00e98d7837d0
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '7fcff8ec-8935-48fe-aa55-00e98d7837d0'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_', 2) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 220) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date
)
select '7fcff8ec-8935-48fe-aa55-00e98d7837d0', from_unixtime( avg(unix_timestamp(creation_date))), avg(no_refids) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '7fcff8ec-8935-48fe-aa55-00e98d7837d0'"))

# timeline
# 8c57719a-fd21-4ea0-92e4-e72c7d2c9399
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '8c57719a-fd21-4ea0-92e4-e72c7d2c9399'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with jpc_files as (
    select SUBSTRING_INDEX(f.file_name, '_', 2) as refid, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as creation_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 220) and 
    fe.tag='CreateDate' and f.file_id = fe.file_id
),
vendor as (
select jpc.creation_date, count(distinct refid) as no_refids from jpc_files jpc group by jpc.creation_date
)
select '8c57719a-fd21-4ea0-92e4-e72c7d2c9399', from_unixtime( avg(unix_timestamp(creation_date))), avg(no_refids) from vendor)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '8c57719a-fd21-4ea0-92e4-e72c7d2c9399'"))







# Vendor to DPO----
# f025d1f1-d60e-4d0d-a419-b0c6e0d5113f
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'f025d1f1-d60e-4d0d-a419-b0c6e0d5113f'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
    (
    with jpc_files as (
    	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 220) and 
    	fe.tag='CreateDate' and f.file_id = fe.file_id
    	)
    select file_name,  'f025d1f1-d60e-4d0d-a419-b0c6e0d5113f', digi_date, DATEDIFF(osprey_date, digi_date)  from jpc_files 
    )")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'f025d1f1-d60e-4d0d-a419-b0c6e0d5113f'"))
               

# Vendor to DPO - stat
# c7ee26d1-1b95-4e3a-bae6-a1aac7419e85
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'c7ee26d1-1b95-4e3a-bae6-a1aac7419e85'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
    (
    with jpc_files as (
    	select f.file_name, DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date, DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date from files f, files_exif fe where f.folder_id in (select folder_id from folders where project_id = 220) and 
    	fe.tag='CreateDate' and f.file_id = fe.file_id
    	)
    select 'c7ee26d1-1b95-4e3a-bae6-a1aac7419e85', from_unixtime( avg(unix_timestamp(osprey_date))), avg(DATEDIFF(osprey_date, digi_date)) from jpc_files)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'c7ee26d1-1b95-4e3a-bae6-a1aac7419e85'"))




# DPO to QC ----
# b42bbc49-40ec-442a-8d84-82a9b46e93f7
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'b42bbc49-40ec-442a-8d84-82a9b46e93f7'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
    (with fdates as (
    select f.file_name, 
    	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date,
    	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
    from files f, qc_folders q, folders fol
    where f.folder_id in (select folder_id from folders where project_id = 220) and 
    	f.folder_id = fol.folder_id and 
    	fol.folder_id = q.folder_id
    	)
    	select file_name, 'b42bbc49-40ec-442a-8d84-82a9b46e93f7', osprey_date, DATEDIFF(qc_date, osprey_date)
    	from fdates f 
	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'b42bbc49-40ec-442a-8d84-82a9b46e93f7'"))
               
# stat
# 1c3a4084-fa1e-4245-9c2b-ccaf3399fb05
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '1c3a4084-fa1e-4245-9c2b-ccaf3399fb05'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(with fdates as (
select f.file_name, 
	DATE_FORMAT(f.created_at, \"%Y-%m-%d\") osprey_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol
where f.folder_id in (select folder_id from folders where project_id = 220) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id
	)
	select '1c3a4084-fa1e-4245-9c2b-ccaf3399fb05', from_unixtime( avg(unix_timestamp(qc_date))), avg(DATEDIFF(qc_date, osprey_date))
	from fdates f 
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '1c3a4084-fa1e-4245-9c2b-ccaf3399fb05'"))
               
               
               





# QC to DAMS----
# 2bb9fc5e-a409-48c9-8c13-c0cf5176bd43
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '2bb9fc5e-a409-48c9-8c13-c0cf5176bd43'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
(with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 220) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select file_name, '2bb9fc5e-a409-48c9-8c13-c0cf5176bd43', qc_date, DATEDIFF(dams_date, qc_date)
	from fdates f 	)")
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '2bb9fc5e-a409-48c9-8c13-c0cf5176bd43'"))
               
# stat
# 4348a552-c699-4bf0-a8fa-cd42d5f55467
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '4348a552-c699-4bf0-a8fa-cd42d5f55467'")
n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
with fdates as (
select f.file_name,
	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
	DATE_FORMAT(q.updated_at, \"%Y-%m-%d\") qc_date
from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
where f.folder_id in (select folder_id from folders where project_id = 220) and 
	f.folder_id = fol.folder_id and 
	fol.folder_id = q.folder_id and 
	f.dams_uan = d.dams_uan 
	)
	select '4348a552-c699-4bf0-a8fa-cd42d5f55467', from_unixtime( avg(unix_timestamp(dams_date))), avg(DATEDIFF(dams_date, qc_date))
	from fdates f
	)"))
n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '4348a552-c699-4bf0-a8fa-cd42d5f55467'"))
                              
                              
                              
                              



# DaMS ingest to Getty
# 594c57d9-9356-491e-8507-6fdb886a2bf5
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '594c57d9-9356-491e-8507-6fdb886a2bf5'")
# n <- dbExecute(con, "INSERT INTO projects_detail_statistics (file_name, step_id, date, step_value) 
# (
# with fdates as (
# select f.file_name,
# 	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
# 	cast('2024-02-06' as date) as getty_date
# from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
# where f.folder_id in (select folder_id from folders where project_id = 220) and 
# 	f.folder_id = fol.folder_id and 
# 	fol.folder_id = q.folder_id and 
# 	f.dams_uan = d.dams_uan 
# 	)
# 	select file_name, '594c57d9-9356-491e-8507-6fdb886a2bf5', dams_date, DATEDIFF(getty_date, dams_date)
# 	from fdates f 
# 	)")
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '594c57d9-9356-491e-8507-6fdb886a2bf5'"))

# stat
# abcd1a4f-2f49-4908-b2b4-59c24711a742
# n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = 'abcd1a4f-2f49-4908-b2b4-59c24711a742'")
# n <- dbExecute(con, paste0("INSERT INTO projects_detail_statistics (step_id, date, step_value) 
# (
# with fdates as (
# select f.file_name,
# 	DATE_FORMAT(d.to_dams_ingest_dt, \"%Y-%m-%d\") dams_date,
# 	cast('2024-02-06' as date) as getty_date
# from files f, qc_folders q, folders fol, dams_cdis_file_status_view_dpo d
# where f.folder_id in (select folder_id from folders where project_id = 220) and 
# 	f.folder_id = fol.folder_id and 
# 	fol.folder_id = q.folder_id and 
# 	f.dams_uan = d.dams_uan 
# 	)
# 	select 'abcd1a4f-2f49-4908-b2b4-59c24711a742', from_unixtime( avg(unix_timestamp(getty_date))), avg(DATEDIFF(getty_date, dams_date))
# 	from fdates f
# 	)"))
# n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = 'abcd1a4f-2f49-4908-b2b4-59c24711a742'"))
               
               
               

dbDisconnect(con)

