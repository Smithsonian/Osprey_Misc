#!/usr/bin/env python3
#
# Script to update a folder when delivering to DAMS
# https://github.com/Smithsonian/Osprey_Misc
#
#
############################################
# Import modules
############################################
import sys
import logging
import time
import os
import subprocess
import shutil

# MySQL
import pymysql

# Import settings from settings_dams.py file
import settings_dams

ver = "0.1"


############################################
# Check args
############################################
if len(sys.argv) == 3:
    project_alias = sys.argv[1]
    dams_alias = sys.argv[2]
else:
    print("Wrong number of args")
    sys.exit(1)


############################################
# Logging
############################################
log_folder = "logs"

if not os.path.exists('logs'):
    os.makedirs('logs')

# Logging
current_time = time.strftime("%Y%m%d_%H%M%S", time.localtime())
logfile = '{}/autodams_{}_{}.log'.format(log_folder, project_alias, current_time)
logging.basicConfig(filename=logfile, filemode='a', level=logging.DEBUG,
                    format='%(levelname)s | %(asctime)s | %(filename)s:%(lineno)s | %(message)s',
                    datefmt='%y-%b-%d %H:%M:%S')
logger = logging.getLogger("dams")

logging.info("autodams version {}".format(ver))


############################################
# Connect
############################################
try:
    conn = pymysql.connect(host=settings_dams.host,
                           user=settings_dams.user,
                           passwd=settings_dams.password,
                           database=settings_dams.database,
                           port=settings_dams.port,
                           charset='utf8mb4',
                           cursorclass=pymysql.cursors.DictCursor,
                           autocommit=True)
    cur = conn.cursor()
except pymysql.Error as e:
    logging.error('System error: {}'.format(e))
    sys.exit(1)


############################################
# Run
############################################
try:
    cur.execute("SELECT * FROM projects WHERE project_alias = %(project_alias)s", {'project_alias': project_alias})
except Exception as error:
    logging.error("Error: {}".format(error))
    sys.exit(1)

project_info = cur.fetchall()[0]


dams_temp = settings_dams.data_to_temp.format(dams_alias)
dams_hotfolder = settings_dams.data_to.format(dams_alias)
from_folder = settings_dams.data_from.format(project_alias)

# Check for folders with QC passed
try:
    cur.execute("SELECT f.* FROM folders f, qc_folders qc WHERE f.project_id = %(project_id)s and f.delivered_to_dams = 9 AND f.folder_id = qc.folder_id AND qc.qc_status = 0", {'project_id': project_info['project_id']})
except Exception as error:
    logging.error("Error: {}".format(error))
    sys.exit(1)

folders = cur.fetchall()

for fold in folders:
    folder_id = fold['folder_id']
    folder_name = fold['project_folder']

    p = subprocess.Popen(['rsync', '-a', "{}/{}".format(from_folder, folder_name), dams_temp], 
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE)
    (out, err) = p.communicate()
    if p.returncode != 0:
        logging.error("Rsync error: {}".format(err))
        sys.exit(1)

    time.sleep(10)

    shutil.move("{}/{}".format(dams_temp, folder_name), dams_hotfolder)

    try:
        cur.execute("""
            INSERT INTO file_postprocessing
                    (file_id, post_results, post_step)
                (SELECT
                file_id,
                0 as post_results,
                'ready_for_dams' as post_step
                FROM
                (
                SELECT
                    file_id
                FROM
                    files
                WHERE
                    folder_id = %(folder_id)s
                )
                a
                ) ON
                DUPLICATE KEY UPDATE
                post_results = 0
            """, {'folder_id': folder_id})
    except Exception as error:
        logging.error("Error: {}".format(error))
        sys.exit(1)

    try:
        cur.execute("UPDATE folders SET delivered_to_dams = 1 WHERE folder_id = %(folder_id)s", {'folder_id': folder_id})
    except Exception as error:
        logging.error("Error: {}".format(error))
        sys.exit(1)

    try:
        cur.execute("""
            INSERT INTO file_postprocessing
                    (file_id, post_results, post_step)
                (SELECT
                file_id,
                0 as post_results,
                'ready_for_dams' as post_step
                FROM
                (
                SELECT
                    file_id
                FROM
                    files
                WHERE
                    folder_id = %(folder_id)s
                )
                a
                ) ON
                DUPLICATE KEY UPDATE
                post_results = 0
            """, {'folder_id': folder_id})
    except Exception as error:
        logging.error("Error: {}".format(error))
        sys.exit(1)

    try:
        cur.execute("""
                DELETE FROM folders_badges WHERE folder_id = %(folder_id)s AND badge_type = 'dams_status'
            """, {'folder_id': folder_id})
    except Exception as error:
        logging.error("Error: {}".format(error))
        sys.exit(1)

    try:
        cur.execute(
            "INSERT INTO folders_badges (folder_id, badge_type, badge_css, badge_text) VALUES (%(folder_id)s, 'dams_status', 'bg-secondary', 'Ready for DAMS')",
            {'folder_id': folder_id})
    except Exception as error:
        logging.error("Error: {}".format(error))
        sys.exit(1)


# Check for delivered
try:
    cur.execute("SELECT * FROM folders WHERE project_id = %(project_id)s and delivered_to_dams = 1", {'project_id': project_info['project_id']})
except Exception as error:
    logging.error("Error: {}".format(error))
    sys.exit(1)

folders = cur.fetchall()

for fold in folders:
    folder_id = fold['folder_id']
    
    try:
        cur.execute("""
            INSERT INTO file_postprocessing
                    (file_id, post_results, post_step)
                (SELECT
                file_id,
                0 as post_results,
                'ready_for_dams' as post_step
                FROM
                (
                SELECT
                    file_id
                FROM
                    files
                WHERE
                    folder_id = %(folder_id)s
                )
                a
                ) ON
                DUPLICATE KEY UPDATE
                post_results = 0
            """, {'folder_id': folder_id})
    except Exception as error:
        logging.error("Error: {}".format(error))
        sys.exit(1)

    try:
        cur.execute("""
                UPDATE
                    files f,
                    (
                        SELECT
                        f.file_id,
                        d.dams_uan
                        FROM
                        dams_cdis_file_status_view_dpo d,
                        files f,
                        folders fold,
                        projects p
                        WHERE
                        fold.folder_id = f.folder_id AND
                        fold.project_id = p.project_id AND
                        d.project_cd = p.dams_project_cd AND
                        d.file_name = CONCAT(f.file_name, '.tif') AND
                        f.folder_id =   %(folder_id)s
                    ) d
                    SET
                    f.dams_uan = d.dams_uan
                    WHERE
                    f.file_id = d.file_id""", {'folder_id': folder_id})
    except Exception as error:
        logging.error("Error: {}".format(error))
        sys.exit(1)

    try:
        cur.execute("""
            INSERT INTO file_postprocessing
                    (file_id, post_results, post_step)
                (SELECT
                file_id,
                0 as post_results,
                'in_dams' as post_step
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
            """, {'folder_id': folder_id})
    except Exception as error:
        logging.error("Error: {}".format(error))
        sys.exit(1)

    cur.execute("""
                SELECT COUNT(*) as no_files FROM files WHERE folder_id = %(folder_id)s AND dams_uan != '' AND dams_uan IS NOT NULL
            """, {'folder_id': folder_id})
    no_files_ready = cur.fetchall()

    cur.execute("""
                SELECT COUNT(*) as no_files FROM files WHERE folder_id = %(folder_id)s AND (dams_uan = '' OR dams_uan IS NULL)
            """, {'folder_id': folder_id})
    no_files_pending = cur.fetchall()

    if no_files_ready[0]['no_files'] > 0 and no_files_pending[0]['no_files'] == 0:
        try:
            cur.execute("""
                    UPDATE
                        folders
                        SET
                        delivered_to_dams = 0
                        WHERE
                        folder_id = %(folder_id)s
                """, {'folder_id': folder_id})
        except Exception as error:
            logging.error("Error: {}".format(error))
            sys.exit(1)

        try:
            cur.execute("""
                    DELETE FROM folders_badges WHERE folder_id = %(folder_id)s AND badge_type = 'dams_status'
                """, {'folder_id': folder_id})
        except Exception as error:
            logging.error("Error: {}".format(error))
            sys.exit(1)

        try:
            cur.execute(
                "INSERT INTO folders_badges (folder_id, badge_type, badge_css, badge_text) VALUES (%(folder_id)s, 'dams_status', 'bg-success', 'Delivered to DAMS')",
                {'folder_id': folder_id})
        except Exception as error:
            logging.error("Error: {}".format(error))
            sys.exit(1)



cur.close()
conn.close()

sys.exit(0)
