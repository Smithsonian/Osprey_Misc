#!flask/bin/python
#
# DPO Osprey Database Cleanup
#
# 
from logger import logger

import locale

# MySQL
import mysql.connector

import settings

# Set locale for number format
locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')


# Connect to Mysql
try:
    conn = mysql.connector.connect(host=settings.host,
                            user=settings.user,
                            password=settings.password,
                            database=settings.database,
                            port=settings.port, 
                            autocommit=True, 
                            connection_timeout=60)
    conn.time_zone = '-05:00'
    cur = conn.cursor(dictionary=True)
except mysql.connector.Error as err:
    logger.error(err)


def run_query(query, parameters=None):
    logger.info("parameters: {}".format(parameters))
    logger.info("query: {}".format(query))
    # Check connection to DB and reconnect if needed
    conn.ping(reconnect=True, attempts=3, delay=1)
    # Run query
    if parameters is None:
        results = cur.execute(query)
    else:
        results = cur.execute(query, parameters)
    return True


# Queries
res = run_query("DELETE FROM files_exif WHERE updated_at <= CURRENT_DATE() - INTERVAL 3 month")
res = run_query("delete from files_exif where taggroup = 'System'")
res = run_query("ANALYZE TABLE files_exif")

res = run_query("truncate invoice_recon")
res = run_query("ANALYZE TABLE invoice_recon")

res = run_query("ANALYZE TABLE files_checks")

