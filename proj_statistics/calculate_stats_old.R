
# Vendor to DPO
# 6c40554a-b546-48ab-8535-ff59d5a2806b
n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '6c40554a-b546-48ab-8535-ff59d5a2806b'")
n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value, file_name) 
(
select '6c40554a-b546-48ab-8535-ff59d5a2806b', DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date, 
        DATE_FORMAT(f.created_at, \"%Y-%m-%d\") as osprey_date, 
        f.file_name 
    from files f, files_exif fe 
        where f.folder_id in (select folder_id from folders where project_id = 186) and 
	        fe.tag='CreateDate' and f.file_id = fe.file_id
    )")
               
               
               # Add each day
               # 67593a22-85d5-4a55-94f6-571ff528e6f8
               n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '6c40554a-b546-48ab-8535-ff59d5a2806b'")
               n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value, file_name) 
(
    select '67593a22-85d5-4a55-94f6-571ff528e6f8', p.date, dt.date, file_name
    from projects_detail_statistics p left join dates_table dt on 
    		(dt.date > p.date and dt.date <= p.step_value)
        where step_id = '6c40554a-b546-48ab-8535-ff59d5a2806b'
)")
                              
                              # Remove weekends and holidays
                              n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE 
    step_id = '67593a22-85d5-4a55-94f6-571ff528e6f8' and step_value in (select date from dates_table where (dayweek = 'Saturday' OR dayweek = 'Sunday') or holiday = 1)")
                              # Insert summary
                              # 97c8c72f-d05d-41ad-82bd-b162657fe414
                              n <- dbExecute(con, "DELETE FROM projects_detail_statistics WHERE step_id = '97c8c72f-d05d-41ad-82bd-b162657fe414'")
                              n <- dbExecute(con, "INSERT INTO projects_detail_statistics (step_id, date, step_value) 
(
select '97c8c72f-d05d-41ad-82bd-b162657fe414', DATE_FORMAT(fe.value, \"%Y-%m-%d\") as digi_date, 
        DATE_FORMAT(f.created_at, \"%Y-%m-%d\") as osprey_date, 
        f.file_name 
    from projects_detail_statistics
        where step_id = '6c40554a-b546-48ab-8535-ff59d5a2806b'
    )")
                                             n <- dbExecute(con, paste0("UPDATE projects_detail_statistics_steps SET step_updated_on = CURRENT_TIME WHERE step_id = '97c8c72f-d05d-41ad-82bd-b162657fe414'"))
                                             