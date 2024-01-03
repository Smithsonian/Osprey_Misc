#!/usr/bin/env python3
#
# Script to update all folders in a project
# https://github.com/Smithsonian/Osprey_Misc
#
#
############################################
# Import modules
############################################
import sys
import requests
import pymysql

# Import settings from settings.py file
import settings


############################################
# Functions
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
    logging.error(e)
    raise InvalidUsage('System error')



def update_folder_stats(folder_id):
    """
    Update the stats for the folder
    """
    payload = {'type': 'folder',
               'folder_id': folder_id,
               'api_key': settings.api_key,
               'property': 'stats',
               'value': '0'
               }
    r = requests.post('{}/api/update/{}'.format(settings.api_url, settings.project_alias),
                      data=payload)
    query_results = json.loads(r.text.encode('utf-8'))
    print("update_folder_stats: {}".format(query_results))
    if query_results["result"] is not True:
        print("API Returned Error: {}".format(query_results))
        print("Request: {}".format(str(r.request)))
        print("Headers: {}".format(r.headers))
        print("Payload: {}".format(payload))
        sys.exit(1)
    return True


############################################
# Run
############################################
default_payload = {'api_key': settings.api_key}
r = requests.post('{}/api/projects/{}'.format(settings.api_url, settings.project_alias), data=default_payload)
if r.status_code != 200:
    # Something went wrong
    query_results = r.text.encode('utf-8')
    print("API Returned Error: {}".format(query_results))
    sys.exit(1)
project_info = json.loads(r.text.encode('utf-8'))
if len(project_info['folders']) > 0:
    for folder in project_info['folders']:
        print("folder: {}".format(folder))
        update_folder_stats(folder["folder_id"])


sys.exit(0)
