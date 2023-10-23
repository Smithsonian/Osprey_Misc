#!/usr/bin/env python3
#
# Script to update a project when images are available via IDS and IIIF
# https://github.com/Smithsonian/Osprey_Misc
#
#
############################################
# Import modules
############################################
import sys

# MySQL
import pymysql

# Import settings from settings.py file
import settings

ver = "0.1"

project_alias = settings.project_alias

############################################
# Connect
############################################
try:
    conn = pymysql.connect(host=settings.host,
                           user=settings.user,
                           passwd=settings.password,
                           database=settings.database,
                           port=settings.port,
                           charset='utf8mb4',
                           cursorclass=pymysql.cursors.DictCursor,
                           autocommit=True)
    cur = conn.cursor()
except pymysql.Error as e:
    print('System error: {}'.format(e))
    sys.exit(1)


############################################
# Run
############################################

# Get folders
query = ("SELECT folder_id FROM folders WHERE project_id in (SELECT project_id from projects where project_alias = %(project_alias)s)")
cur.execute(query, {'project_alias': project_alias})
folders = cur.fetchall()

for folder in folders:
    try:
        cur.execute("""
                 UPDATE
                    files
                    SET
                    preview_image = CONCAT('https://ids.si.edu/ids/deliveryService?id=', dams_uan)
                    WHERE
                    folder_id = %(folder_id)s and dams_uan != '' and dams_uan is not null
            """, {'folder_id': folder['folder_id']})
    except Exception as error:
        print("Error: {}".format(error))

    try:
        cur.execute("""
            INSERT INTO file_postprocessing
                    (file_id, post_results, post_step)
                (SELECT
                 file_id,
                 0 as post_results,
                 'iiif_available' as post_step
                 FROM
                 (
                 SELECT
                    file_id
                 FROM
                    files
                 WHERE
                    folder_id = %(folder_id)s AND 
                    dams_uan != '' AND dams_uan IS NOT NULL
                 )
                a
                ) ON
                DUPLICATE KEY UPDATE
                post_results = 0
            """, {'folder_id': folder['folder_id']})
    except Exception as error:
        print("Error: {}".format(error))


    try:
        cur.execute("""
            INSERT IGNORE INTO files_links
                    (file_id, link_name, link_url)
                (SELECT
                 file_id,
                 '<img src="/static/logo-iiif.png"> Image in IIIF Mirador Viewer' as link_name,
                 CONCAT('https://iiif.si.edu/mirador/?manifest=https://ids.si.edu/ids/manifest/', dams_uan) as link_url
                 FROM
                    files
                 WHERE
                    folder_id = %(folder_id)s AND 
                    dams_uan != '' AND dams_uan IS NOT NULL
                )
            """, {'folder_id': folder['folder_id']})
    except Exception as error:
        print("Error: {}".format(error))


cur.close()
conn.close()

sys.exit(0)
