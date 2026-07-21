#!/usr/bin/env python3
#
# Script to update the Osprey statistics
# https://github.com/Smithsonian/Osprey
#
#

import sys
# MySQL
import pymysql
# Import settings from settings.py file
import settings

ver = "0.3"


if len(sys.argv) == 1:
    print("project_alias missing")
elif len(sys.argv) == 2:
    project_alias = sys.argv[1]
else:
    print("Wrong number of args")


# DB Connect
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
    print("Error in connection: {}".format(e))
    sys.exit(1)


# Get project details
query = ("SELECT * FROM projects WHERE project_alias = %(project_alias)s")
try:
    res = cur.execute(query, {'project_alias': project_alias})
except Exception as error:
    print("Error: {}".format(error))
    sys.exit(1)

project = cur.fetchall()

proj = project[0]

# Get project folders
query = ("SELECT * FROM folders WHERE project_id = %(project_id)s")
try:
    results = cur.execute(query, {'project_id': proj['project_id']})
except Exception as error:
    print("Error: {}".format(error))
    sys.exit(1)

folders = cur.fetchall()

# Loop folders
for folder in folders:
    folder_id = folder['folder_id']

    # Populate DAMS UAN
    query = ("UPDATE files f, "
             "    (SELECT "
             "        f.file_id, d.dams_uan "
             "      FROM "
             "          dams_cdis_file_status_view_dpo d, files f, folders fold, projects p "
             "      WHERE "
             "          fold.folder_id = f.folder_id AND "
             "          fold.project_id = p.project_id AND "
             "          d.project_cd = p.dams_project_cd AND "
             "          LOWER(d.file_name) = CONCAT(LOWER(f.file_name), '.tif') AND "
             "          f.folder_id = %(folder_id)s AND "
             "          f.dams_uan is NULL) d "
             " SET f.dams_uan = d.dams_uan "
             " WHERE "
             "      f.file_id = d.file_id")
    try:
        cur.execute(query, {'folder_id': folder_id})
    except Exception as error:
        print("Error: {}".format(error))
        sys.exit(1)

    # Check if all files have a DAMS UAN
    query = ("SELECT COUNT(*) as no_files "
             " FROM files "
             " WHERE folder_id = %(folder_id)s AND "
             "      dams_uan != '' AND "
             "      dams_uan IS NOT NULL")
    try:
        cur.execute(query, {'folder_id': folder_id})
    except Exception as error:
        print("Error: {}".format(error))
        sys.exit(1)

    no_files_ready = cur.fetchall()

    query = ("SELECT COUNT(*) as no_files "
                     "  FROM files "
                     "  WHERE folder_id = %(folder_id)s AND "
                     "      (dams_uan = '' OR dams_uan IS NULL)")
    try:
        cur.execute(query, {'folder_id': folder_id})
    except Exception as error:
        print("Error: {}".format(error))
        sys.exit(1)

    no_files_pending = cur.fetchall()

    if no_files_ready[0]['no_files'] > 0 and no_files_pending[0]['no_files'] == 0:
        # Update folders table set delivered_to_dams
        query = ("UPDATE folders "
                 "  SET "
                 "      delivered_to_dams = 0 "
                 "  WHERE folder_id = %(folder_id)s")
        try:
            cur.execute(query, {'folder_id': folder_id})
        except Exception as error:
            print("Error: {}".format(error))
            sys.exit(1)
        # Remove DAMS badge
        query = ("DELETE FROM folders_badges "
                 "  WHERE folder_id = %(folder_id)s AND "
                 "          badge_type = 'dams_status'")
        try:
            cur.execute(query, {'folder_id': folder_id})
        except Exception as error:
            print("Error: {}".format(error))
            sys.exit(1)
        # Tagging as delivered to DAMS
        query = ("INSERT INTO folders_badges "
                "       (folder_id, badge_type, badge_css, badge_text) "
                "   VALUES "
                "       (%(folder_id)s, 'dams_status', 'bg-success', 'Delivered to DAMS')")
        try:
            cur.execute(query, {'folder_id': folder_id})
        except Exception as error:
            print("Error: {}".format(error))
            sys.exit(1)
        # Set postprocessing
        query = ("INSERT INTO file_postprocessing (file_id, post_step, post_results) "
                 "   (SELECT file_id, 'ready_for_dams', 0 "
                 "       FROM ( "
                 "          SELECT "
                 "                f.file_id "
                 "          FROM "
                 "                files f, folders fol "
                 "          WHERE "
                 "               f.folder_id = fol.folder_id AND "
                 "              fol.project_id = %(project_id)s AND "
                 "               f.dams_uan IS NOT NULL "
                 "           ) a "
                 "   ) "
                 "   ON DUPLICATE KEY UPDATE post_results = 0")
        try:
            cur.execute(query, {'project_id': proj['project_id']})
        except Exception as error:
            print("Error: {}".format(error))
            sys.exit(1)
        query = ("INSERT INTO file_postprocessing (file_id, post_step, post_results) "
                 "   (SELECT file_id, 'in_dams', 0 "
                 "       FROM ( "
                 "          SELECT "
                 "                f.file_id "
                 "          FROM "
                 "                files f, folders fol "
                 "          WHERE "
                 "               f.folder_id = fol.folder_id AND "
                 "              fol.project_id = %(project_id)s AND "
                 "               f.dams_uan IS NOT NULL "
                 "           ) a "
                 "   ) "
                 "   ON DUPLICATE KEY UPDATE post_results = 0")
        try:
            cur.execute(query, {'project_id': proj['project_id']})
        except Exception as error:
            print("Error: {}".format(error))
            sys.exit(1)
        query = ("INSERT INTO file_postprocessing (file_id, post_step, post_results) "
                 "   (SELECT file_id, 'public', 0 "
                 "       FROM ( "
                 "          SELECT "
                 "                f.file_id "
                 "          FROM "
                 "                files f, folders fol "
                 "          WHERE "
                 "               f.folder_id = fol.folder_id AND "
                 "              fol.project_id = %(project_id)s AND "
                 "               f.dams_uan IS NOT NULL "
                 "           ) a "
                 "   ) "
                 "   ON DUPLICATE KEY UPDATE post_results = 0")
        try:
            cur.execute(query, {'project_id': proj['project_id']})
        except Exception as error:
            print("Error: {}".format(error))
            sys.exit(1)



# Update public images
try:
    cur.execute("""
        with dams_images as (
            SELECT
                f.file_name,
                fol.date,
                fol.project_id
            FROM
                files f,
                folders fol
            WHERE
                f.folder_id = fol.folder_id AND
                dams_uan IS NOT NULL AND
                fol.project_id = %(project_id)s
            ),
        images as (
            SELECT
                count(distinct file_name) as total_img,
                project_id
            FROM
                dams_images
            GROUP BY
                project_id
            )

        UPDATE
            projects_stats p, images i
        SET
            p.images_public = i.total_img,
            p.updated_at = NOW()
        WHERE
            p.project_id = i.project_id
        """, {'project_id':  proj['project_id']})
except Exception as error:
    print("Error: {}".format(error))
    sys.exit(1)


# Clear stats
try:
    cur.execute("""
       delete from projects_stats_detail
        WHERE project_id = %(project_id)s
        """, {'project_id': proj['project_id']})
except Exception as error:
    print("Error: {}".format(error))
    sys.exit(1)


# Get calculation for objects
obj_calculation = proj['project_object_query']


# Get date range for project
query = ("SELECT "
         "  date_format(min(fol.date), '%%Y-%%m-%%d') as min_date, date_format(max(fol.date), '%%Y-%%m-%%d') as max_date "
         "  FROM folders fol"
         "  WHERE fol.project_id = %(project_id)s")
try:
    res = cur.execute(query, {'project_id': proj['project_id']})
except Exception as error:
    print("Error: {}".format(error))
    sys.exit(1)

project_dates = cur.fetchall()

proj_min_date = project_dates[0]['min_date']
proj_max_date = project_dates[0]['max_date']


# Query to calc
dates_query = """
        WITH 
        recursive dateseries AS (
                select %(min_date)s as Date, %(project_id)s as project_id
                    union all
                select Date + interval {interval}, %(project_id)s as project_id
                    from dateseries
                where Date < %(max_date)s),
        dpo_images AS (
            SELECT
                count(DISTINCT f.file_name) as no_images,
                fol.date,
                fol.project_id
            FROM
                files f,
                folders fol
            WHERE
                f.folder_id = fol.folder_id AND
                fol.project_id = %(project_id)s
            GROUP BY
                fol.date,
                fol.project_id
                ),
        dpo_objects AS (
            SELECT
                {obj_calculation} as no_objects,
                fol.date,
                fol.project_id
            FROM
                files f,
                folders fol
            WHERE
                f.folder_id = fol.folder_id AND
                fol.project_id = %(project_id)s
            GROUP BY
                fol.date,
                fol.project_id
                )
        INSERT INTO
              projects_stats_detail
              (project_id, time_interval, date, objects_digitized, images_captured)
              (
                SELECT
                  ds.project_id,
                  %(interval_type)s,
                  ds.Date,
                  coalesce(o.no_objects, 0),
                  coalesce(i.no_images, 0)
              FROM
                dateseries ds
                    LEFT JOIN dpo_images i ON (ds.date = i.date)
                    LEFT JOIN dpo_objects o ON (ds.date = o.date)
              )
        """

# daily
try:
    cur.mogrify(dates_query.format(interval='1 day', obj_calculation=obj_calculation),
                {'interval_type': 'daily', 'project_id': proj['project_id'], 'min_date': proj_min_date, 'max_date': proj_max_date})
except Exception as error:
    print("Error: {}".format(error))
    sys.exit(1)



cur.close()
conn.close()

sys.exit(0)
