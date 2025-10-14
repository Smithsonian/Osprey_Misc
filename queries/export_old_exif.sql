-- Get projects
SELECT
    DISTINCT project_alias
FROM projects
WHERE project_id in (
    select project_id
    from folders    
    WHERE folder_id IN (
        select distinct folder_id from files where 
        file_id in (
            SELECT 
                distinct file_id 
            FROM 
                files_exif
        )
    )
);






-- Save to CSV in: /var/lib/mysql/osprey/
SELECT
    file_id, filetype, tag, taggroup, tagid, "value", updated_at
INTO OUTFILE 'botany_accessions_2024_files_exif.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM files_exif
WHERE file_id in (
    SELECT 
        file_id 
    FROM 
        files 
    WHERE folder_id IN (
        SELECT folder_id 
        FROM folders
        WHERE 
            project_id = 195
    )
);


-- count
SELECT
    count(*)
FROM files_exif
WHERE file_id in (
    SELECT 
        file_id 
    FROM 
        files 
    WHERE folder_id IN (
        SELECT folder_id 
        FROM folders
        WHERE 
            project_id = 201
    )
);

-- count all in table
SELECT
    count(*)
FROM files_exif;



-- DELETE
DELETE
FROM files_exif
WHERE file_id in (
    SELECT 
        file_id 
    FROM 
        files 
    WHERE folder_id IN (
        SELECT folder_id 
        FROM folders
        WHERE 
            project_id = 195
    )
);
