#!/usr/bin/env python3
#
# Export reports of the folders to spreadsheets
#   mostly to use in Dropbox or similar.
#  Needs to be run with cron to update the files.
#
############################################
# Import modules
############################################
import sys
import locale
import json
import os
import requests
import pandas as pd
from openpyxl import Workbook

# Import settings from settings.py file
import settings

ver = "0.1.0"

# Set locale
locale.setlocale(locale.LC_ALL, 'en_US.utf8')

if os.path.exists(settings.export_to) is False:
    print(" Error, export location ({}) was not found.".format(settings.export_to))
    sys.exit(1)


############################################
def main():
    payload_api = {'api_key': settings.api_key}
    r = requests.post('{}/api/projects/{}'.format(settings.api_url, settings.project_alias), data=payload_api)
    if r.status_code != 200:
        # Something went wrong
        query_results = r.text.encode('utf-8')
        print("API Returned Error: {}".format(query_results))
        sys.exit(1)

    project_info = json.loads(r.text.encode('utf-8'))
    project_checks = project_info['project_checks']
    project_checks = project_checks.split(',')
    filename = "{}/project_status.xlsx".format(settings.export_to)
    workbook = Workbook()
    sheet = workbook.active

    i = 1
    for attrib, value in project_info.items():
        # print("{}: {}".format(attrib, value))
        if attrib == "folders" or attrib == "reports":
            continue
        elif attrib == "project_stats":
            sheet["A{}".format(i)] = "images_taken"
            sheet["B{}".format(i)] = value['images_taken']
            i += 1
            sheet["A{}".format(i)] = "objects_digitized"
            sheet["B{}".format(i)] = value['objects_digitized']
            i += 1
            continue
        if value == "":
            continue
        sheet["A{}".format(i)] = attrib
        sheet["B{}".format(i)] = value
        i += 1

    workbook.save(filename=filename)

    # Folders info
    filename = "{}/project_folders.xlsx".format(settings.export_to)
    workbook = Workbook()
    sheet = workbook.active

    i = 1
    for attrib, value in project_info.items():
        if attrib != "folders":
            continue
        else:
            folder_info = value
        for values in folder_info:
            for att, val in values.items():
                if att == "folder":
                    sheet["A{}".format(i)] = att
                    sheet["B{}".format(i)] = val
                    i += 1
            for att, val in values.items():            
                if att == "folder" or att == "delivered_to_dams" or att == "folder_path" or att == "error_info" or att == "file_errors" or att == "no_files" or att == "notes" or att == "project_id":
                    continue
                else:
                    sheet["B{}".format(i)] = att
                    sheet["C{}".format(i)] = val
                    i += 1

    workbook.save(filename=filename)


    folders_storage = "{}/folders".format(settings.export_to)
    if not os.path.exists(folders_storage):
        os.makedirs(folders_storage)
    
    folders_qc_storage = "{}/folders_qc".format(settings.export_to)
    if not os.path.exists(folders_qc_storage):
        os.makedirs(folders_qc_storage)

    for folder in project_info['folders']:
        folder_id = folder['folder_id']
        r = requests.post('{}/api/folders/{}'.format(settings.api_url, folder_id), data=payload_api)
        if r.status_code != 200:
            # Something went wrong
            query_results = r.text.encode('utf-8')
            print("API Returned Error: {}".format(query_results))
            sys.exit(1)

        folder_info = json.loads(r.text.encode('utf-8'))
        file_df = pd.DataFrame(folder_info['files'])
        # cols = ['file_id', 'file_name', 'file_timestamp', 'preview_image', 'updated_at']
        cols = ['file_id', 'file_name', 'file_timestamp', 'updated_at', 'tif_md5']
        for pcheck in project_checks:
            cols.append(pcheck)
        filename = "{}/{}.xlsx".format(folders_storage, folder_info['folder'])
        file_df.to_excel(filename, columns=cols, header=True, index=False)
        # Save QC, if any
        r = requests.post('{}/api/folders/qc/{}'.format(settings.api_url, folder_id), data=payload_api)
        if r.status_code != 200:
            # Something went wrong
            query_results = r.text.encode('utf-8')
            print("API Returned Error: {}".format(query_results))
            sys.exit(1)

        qc_info = json.loads(r.text.encode('utf-8'))
        file_df = pd.DataFrame(qc_info['qc'])
        # cols = ['file_name', 'file_qc', 'file_timestamp', 'full_name', 'qc_info', 'updated_at']
        filename = "{}/{}.xlsx".format(folders_qc_storage, folder_info['folder'])
        file_df.to_excel(filename, header=True, index=False)


############################################
# Main loop
############################################
if __name__=="__main__":
    main()
    

sys.exit(0)
