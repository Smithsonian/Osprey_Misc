#!/usr/bin/env python3
#
# Update the files table to set the address of the IIIF image
#
############################################
# Import modules
############################################
import sys

# For MySQL
import pymysql

# Import settings from settings.py file
import settings

if len(sys.argv) == 2:
    project_id = sys.argv[1]
else:
    print("Usage: ./add_iiif_links.py [project_id]")
    sys.exit(1)


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
    print(e)
    sys.exit(1)


query = ("""
        update files set preview_image = concat('https://ids.si.edu/ids/deliveryService?id=', dams_uan) 
         where folder_id in (select folder_id from folders WHERE project_id= %(project_id)s)""")
results = cur.execute(query, {'project_id': project_id})



query = ("""
    insert into files_links  (file_id, link_name, link_url) 
        (select f.file_id, 'IIIF Manifest', concat('https://ids.si.edu/ids/manifest/', f.dams_uan)
        from files f
        where
        f.file_id NOT IN (
            SELECT file_id
            FROM files_links
            WHERE link_name = 'IIIF Manifest'
            )
            and folder_id in (select folder_id from folders WHERE project_id= %(project_id)s)"
    )""")
results = cur.execute(query, {'project_id': project_id})




query = ("""
    insert into files_links  (
        file_id,
        link_name,
        link_url
        )
        (
        select
            file_id,
            '<img src="/static/logo-iiif.png">',
            concat('https://iiif.si.edu/mirador/?manifest=https://ids.si.edu/ids/manifest/', dams_uan)
        from files f
        where
            f.dams_uan is not null and 
            f.file_id NOT IN (
                SELECT file_id
                FROM files_links
                WHERE link_name = '<img src="/static/logo-iiif.png">'
              )
                and folder_id in (select folder_id from folders WHERE project_id = %(project_id)s)
          """)
results = cur.execute(query, {'project_id': project_id})



query = ("""
    insert into files_links  (
        file_id,
        link_name,
        link_url
        )
        (
        select
            file_id,
            '<img src="/static/logo-iiif.png">',
            concat('https://iiif.si.edu/mirador/?manifest=https://ids.si.edu/ids/manifest/', dams_uan)
        from files f
        where
            f.dams_uan is not null and 
            f.file_id NOT IN (
                SELECT file_id
                FROM files_links
                WHERE link_name = '<img src="/static/logo-iiif.png">'
              )
                and folder_id in (select folder_id from folders WHERE project_id = %(project_id)s))""")
results = cur.execute(query, {'project_id': project_id})


