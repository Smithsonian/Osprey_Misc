#!/usr/bin/env python3
#
# Export JPGs from a project or folder
#
############################################
# Import modules
############################################
import sys
import urllib.request
import math

# MySQL
import pymysql

# Import settings from settings.py file
import settings

ver = "0.4.0"

if len(sys.argv) == 3:
    sample_size = None
    folder_id = sys.argv[2]
    export_to = sys.argv[1]
elif len(sys.argv) == 4:
    sample_size = sys.argv[3]
    folder_id = sys.argv[2]
    export_to = sys.argv[1]
else:
    print("Usage: ./export_jpgs.py [destination] [folder_id] [percent_sample - optional]")
    sys.exit(1)


###################
def main():
    # Connect to db
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

    if sample_size is None:
        query = ("SELECT COALESCE(preview_image, concat('{}', '/preview_image/', file_id)) as image, file_name "
                 "  FROM files WHERE folder_id = %(folder_id)s".format(settings.api_url))
    else:
        query = ("SELECT count(*) as no_files FROM files WHERE folder_id = %(folder_id)s")
        cur.execute(query, {'folder_id': folder_id})
        no_files = cur.fetchall()
        query = ("SELECT COALESCE(preview_image, concat('{}', '/preview_image/', file_id)) as image, file_name "
                 "  FROM files WHERE folder_id = %(folder_id)s ORDER BY RAND() LIMIT {}".format(
                    settings.api_url,
                          math.ceil(no_files[0]['no_files'] * (float(sample_size) / 100.0))))
    try:
        cur.execute(query , {'folder_id': folder_id})
    except Exception as error:
        print("Error: {}".format(error))
    files = cur.fetchall()
    i = 1
    i_total = len(files)
    for file in files:
        try:
            print("Downloading {} ({}/{})...".format(file['image'], i, i_total))
            save_file = "{}/{}.jpg".format(export_to, file['file_name'])
            urllib.request.urlretrieve(file['image'], filename=save_file)
            i += 1
        except urllib.error.URLError:
            print("File download error: {}".format(save_file))
        print("File downloaded: {}".format(file['file_name']))

    cur.close()
    conn.close()


############################################
# Main loop
############################################
if __name__ == "__main__":
    main()


sys.exit(0)
