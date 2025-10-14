delete from external_data where dataset_key = 'conveyor_list';

-- generate table
insert into external_data (dataset_key, value1, value2)
(
with data as (select cast(replace(SUBSTRING_INDEX(f.file_name, '_', 1), 'USNMENT', '') as signed) as specimen_no from files f, folders fol where fol.folder_id = f.folder_id and fol.project_id = 241 and f.file_name not like '%-Calib-%' and f.file_name not like '%MDPP-Pol%' group by specimen_no), vals as (select min(specimen_no) as min_specimen, max(specimen_no) as max_specimen from data), entseq as (select cast(e.value1 as signed) as ent_no from external_data e, vals where e.dataset_key = 'usnment_conveyor' and e.value1 >= vals.min_specimen and e.value1 < vals.max_specimen) 

select 'conveyor_list', s.ent_no, case when data.specimen_no is null then 'Missing' else data.specimen_no end as specimen_no from entseq s left join data on (s.ent_no = data.specimen_no) order by s.ent_no
);

-- select report
select value1 as number_in_sequence, value2 as ent_no_found from external_data where dataset_key = 'conveyor_list';

-- updated_at
select max(updated_at) from external_data where dataset_key = 'conveyor_list';