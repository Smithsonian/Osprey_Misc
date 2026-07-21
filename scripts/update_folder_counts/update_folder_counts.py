#!/usr/bin/env python3

# MySQL
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
    

project_id = 220


res = cur.execute("SELECT folder_id FROM folders WHERE project_id = %(project_id)s",
                        {'project_id': project_id})
folders = cur.fetchall()

for folder in folders:
    print(folder['folder_id'])
    res = cur.execute("SELECT count(*) as no_files FROM files WHERE folder_id = %(folder_id)s",
                            {'folder_id': folder['folder_id']})
    no_files = cur.fetchall()[0]
    res = cur.execute("UPDATE folders SET no_files_total = %(no_files)s WHERE folder_id= %(folder_id)s", {'folder_id': folder['folder_id'], 'no_files': no_files['no_files']})
    res = cur.execute("SELECT count(distinct f.file_id) as no_files FROM files f, files_checks fc WHERE f.folder_id = %(folder_id)s and f.file_id = fc.file_id and fc.check_results = 1",
                            {'folder_id': folder['folder_id']})
    no_error_files = cur.fetchall()[0]
    res = cur.execute("UPDATE folders SET no_files_errors = %(no_files)s WHERE folder_id= %(folder_id)s", {'folder_id': folder['folder_id'], 'no_files': no_error_files['no_files']})
    # 
    res = cur.execute("""
                    with no_checks as (SELECT count(*) as no_checks FROM projects_settings WHERE project_id = %(project_id)s and project_setting = 'project_checks'),
                    no_files as (
                    SELECT f.file_id, count(*) as no_files FROM files f, files_checks fc 
                    WHERE f.folder_id = %(folder_id)s and f.file_id = fc.file_id and fc.check_results = 0
                    group by f.file_id)
                    select count(no_files.file_id) as ok_files from no_files, no_checks where no_files.no_files = no_checks.no_checks
                        """,
                            {'folder_id': folder['folder_id'], 'project_id': project_id})
    no_ok_files = cur.fetchall()[0]
    res = cur.execute("UPDATE folders SET no_files_ok = %(no_files)s WHERE folder_id= %(folder_id)s", {'folder_id': folder['folder_id'], 'no_files': no_ok_files['ok_files']})

