/*This script replaces " with "" for the purposes of the the csv extract and insert into the Alembo DETA system*/
SET @folders = CONCAT(
/*ADD FOLDERS TO PULL FOR ALEMBO BELOW*/
QUOTE('USNMENT-MDPP-Pol-0538_20260408_10kfh-sm'), ',',
QUOTE('USNMENT-MDPP-Pol-0149_20251120_10kfh-sm')
/*ADD FOLDERS TO PULL FOR ALEMBO ABOVE*/
);

SET SESSION group_concat_max_len = 1000000;


SET @cols_sql = CONCAT(
    'SELECT GROUP_CONCAT(
        CONCAT(
            ''MAX(CASE WHEN transcription_fields.field_name = '',
            QUOTE(field_name),
            '' THEN REPLACE(
                transcription_files_text.transcription_text,
                CHAR(34),
                CONCAT(CHAR(34), CHAR(34))
            ) END) AS `'',
            REPLACE(field_name, ''`'', ''``''),
            ''`''
        )
        ORDER BY sort_by
        SEPARATOR '', ''
    )
    INTO @cols
    FROM (
        SELECT DISTINCT
            transcription_fields.field_name,
            transcription_fields.sort_by

        FROM transcription_files

        LEFT JOIN transcription_folders
            ON transcription_files.folder_transcription_id =
               transcription_folders.folder_transcription_id

        LEFT JOIN transcription_qc
            ON transcription_files.file_transcription_id =
               transcription_qc.file_transcription_id

        LEFT JOIN transcription_qc_folders
            ON transcription_folders.folder_transcription_id =
               transcription_qc_folders.folder_transcription_id

        LEFT JOIN transcription_files_text
            ON transcription_files.file_transcription_id =
               transcription_files_text.file_transcription_id

        LEFT JOIN transcription_fields
            ON transcription_files_text.field_id =
               transcription_fields.field_id

        LEFT JOIN alembo_ids
            ON REPLACE(
                transcription_files.file_name,
                ''_a_label'',
                ''''
            ) = alembo_ids.image

        WHERE transcription_folders.project_id = 250
          AND transcription_folders.folder IN (',
    @folders,
    ')
          AND transcription_fields.field_name IS NOT NULL

    ) AS field_list'
);

PREPARE cols_stmt FROM @cols_sql;
EXECUTE cols_stmt;
DEALLOCATE PREPARE cols_stmt;


SET @sql = CONCAT(
    'SELECT

        REPLACE(
            alembo_ids.id,
            CHAR(34),
            CONCAT(CHAR(34), CHAR(34))
        ) AS `ID`,

        REPLACE(
            transcription_folders.folder,
            CHAR(34),
            CONCAT(CHAR(34), CHAR(34))
        ) AS `Client Batch`,

        REPLACE(
            alembo_ids.deta_batch,
            CHAR(34),
            CONCAT(CHAR(34), CHAR(34))
        ) AS `DETA Batch`,

        REPLACE(
            REPLACE(
                transcription_files.file_name,
                ''_a_label'',
                ''''
            ),
            CHAR(34),
            CONCAT(CHAR(34), CHAR(34))
        ) AS `Image`,

        ',
        @cols,
        ',

        REPLACE(
            TRIM(
                SUBSTRING_INDEX(
                    transcription_qc.qc_notes,
                    ''|'',
                    1
                )
            ),
            CHAR(34),
            CONCAT(CHAR(34), CHAR(34))
        ) AS `Feedback Type`,

        REPLACE(
            TRIM(
                CASE
                    WHEN LOCATE(''|'', transcription_qc.qc_notes) > 0
                    THEN SUBSTRING(
                        transcription_qc.qc_notes,
                        LOCATE(''|'', transcription_qc.qc_notes) + 1
                    )
                    ELSE NULL
                END
            ),
            CHAR(34),
            CONCAT(CHAR(34), CHAR(34))
        ) AS `Feedback`,

        REPLACE(
            CASE
                WHEN transcription_qc.qc_results = 3 THEN ''Minor Issue''
                WHEN transcription_qc.qc_results = 2 THEN ''Major Issue''
                WHEN transcription_qc.qc_results = 1 THEN ''Critical Issue''
                ELSE CAST(transcription_qc.qc_results AS CHAR)
            END,
            CHAR(34),
            CONCAT(CHAR(34), CHAR(34))
        ) AS `Label QC Result`,

        REPLACE(
            CASE
                WHEN transcription_qc_folders.qc_status = 9 THEN ''Pending QC Completion''
                WHEN transcription_qc_folders.qc_status = 1 THEN ''Transcription QC Failed''
                WHEN transcription_qc_folders.qc_status = 0 THEN ''Transcription QC Passed''
                ELSE CAST(transcription_qc_folders.qc_status AS CHAR)
            END,
            CHAR(34),
            CONCAT(CHAR(34), CHAR(34))
        ) AS `Folder QC Status`

    FROM transcription_files

    LEFT JOIN transcription_folders
        ON transcription_files.folder_transcription_id =
           transcription_folders.folder_transcription_id

    LEFT JOIN transcription_qc
        ON transcription_files.file_transcription_id =
           transcription_qc.file_transcription_id

    LEFT JOIN transcription_qc_folders
        ON transcription_folders.folder_transcription_id =
           transcription_qc_folders.folder_transcription_id

    LEFT JOIN transcription_files_text
        ON transcription_files.file_transcription_id =
           transcription_files_text.file_transcription_id

    LEFT JOIN transcription_fields
        ON transcription_files_text.field_id =
           transcription_fields.field_id

    LEFT JOIN alembo_ids
        ON REPLACE(
            transcription_files.file_name,
            ''_a_label'',
            ''''
        ) = alembo_ids.image

    WHERE transcription_folders.project_id = 250
      AND transcription_folders.folder IN (',
    @folders,
    ')

    GROUP BY
        transcription_files.file_transcription_id,
        alembo_ids.id,
        transcription_folders.folder,
        alembo_ids.deta_batch,
        transcription_files.file_name,
        transcription_qc.qc_notes,
        transcription_qc.qc_results,
        transcription_qc_folders.qc_status

    ORDER BY
        transcription_folders.folder ASC,
        transcription_files.file_name ASC'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
