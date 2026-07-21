#!/usr/bin/env python3

# MySQL
import math

import mysql.connector
import settings
import sys


# Connect to Mysql 
try:
    conn = mysql.connector.connect(host=settings.host,
                            user=settings.user,
                            password=settings.password,
                            database=settings.database,
                            port=settings.port, 
                            autocommit=True, 
                            connection_timeout=60)
    conn.time_zone = '-04:00'
    cur = conn.cursor(dictionary=True)
except mysql.connector.Error as err:
    print(err)
    sys.exit(1)
    


res = cur.execute("SELECT * FROM transcription_qc_folders WHERE qc_status = 9")
folders = cur.fetchall()


for folder in folders:
    print(folder['folder_transcription_id'])
    res = cur.execute("SELECT count(*) as no_files FROM transcription_files WHERE folder_transcription_id = %(folder_transcription_id)s",
                            {'folder_transcription_id': folder['folder_transcription_id']})
    no_files = cur.fetchall()[0]
    res = cur.execute("delete from folders_badges where badge_type = 'transcription_qc_status' and folder_uid = %(folder_transcription_id)s",
                            {'folder_transcription_id': folder['folder_transcription_id']})
    res1 = cur.fetchall()
    sample_qc = math.ceil(no_files['no_files'] * 0.4)

    # how many are in place
    res = cur.execute("SELECT count(*) as no_files FROM transcription_qc WHERE folder_transcription_id = %(folder_transcription_id)s",
                            {'folder_transcription_id': folder['folder_transcription_id']})
    no_files_done = cur.fetchall()[0]
    sample_qc_toadd = sample_qc - no_files_done['no_files']
    if sample_qc_toadd > 0:
        print(f"sample_qc: {sample_qc}, no_files_done: {no_files_done['no_files']}, sample_qc_toadd: {sample_qc_toadd}")

        res = cur.execute("with ids as (SELECT file_transcription_id FROM transcription_qc WHERE folder_transcription_id = %(folder_transcription_id)s)" \
                            "SELECT file_transcription_id FROM transcription_files WHERE folder_transcription_id = %(folder_transcription_id)s and file_transcription_id not in (select file_transcription_id from ids) order by rand() limit %(sample_qc_toadd)s", 
                        {'folder_transcription_id': folder['folder_transcription_id'], 'sample_qc_toadd': sample_qc_toadd})
        new_files = cur.fetchall()
        for f in new_files:
            res = cur.execute("INSERT INTO transcription_qc (folder_transcription_id, transcription_source_id, file_transcription_id) VALUES (%(folder_transcription_id)s, '339d798d-2eb3-411b-8787-a8ba906ea3e4', %(file_transcription_id)s)", 
                                {'folder_transcription_id': folder['folder_transcription_id'], 'file_transcription_id': f['file_transcription_id']})
            res1 = cur.fetchall()
            print(f"Added file {f['file_transcription_id']} to transcription_qc")

