#!/usr/bin/env python3


import pymysql
import settings
import sys
from edan import edan
import requests

if len(sys.argv) == 1:
    print("folder_id missing")
elif len(sys.argv) == 2:
    folder_id = sys.argv[1]
elif len(sys.argv) == 3:
    folder_id = sys.argv[1]
    # Botany: NMNHBOTANY
    keywords = sys.argv[2]
else:
    print("Wrong number of args")


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


data = cur.execute("select file_id, file_name, preview_image from files where folder_id = %(folder_id)s", {'folder_id': folder_id})
rows = cur.fetchall()

print("Number of rows: {}".format(len(rows)))
i = 1

for row in rows:
    if row['file_name'] != "":
        print("Record has preview, skipping - file_id: {} ({})".format(row['file_id'], i))
        i += 1
    else:
        print("Working row {} - file_id: {}".format(i, row['file_id']))
        i += 1
        results = edan.edan_metadata_search("{} {}".format(row['file_name'], keywords), settings.AppID, settings.AppKey)
        if results['rowCount'] == 1:
            damsuan = results['rows'][0]['content']['uan']
            media = 'https://ids.si.edu/ids/deliveryService?id={}'.format(damsuan)
            test_url = "{}&max=200"
            r = requests.get(test_url )
            if r.status_code == 200:
                #Image found
                d = cur.execute(
                    "UPDATE files SET preview_image = %(preview_image)s, dams_uan = %(uan)s WHERE file_id = %(file_id)s",
                    {
                        'file_id': row['file_id'],
                        'uan': damsuan,
                        'preview_image': media
                    })
            else:
                print("Error checking the image")
                print(r.status_code)
                print(r.reason)
                print(damsuan)
                sys.exit(1)


cur.close()
conn.close()

