import os
import logging
from logging.handlers import RotatingFileHandler
from time import strftime
from time import localtime
import gzip
import shutil
import settings

# Logging
current_time = strftime("%Y%m%d_%H%M%S", localtime())


# From https://docs.python.org/3/howto/logging-cookbook.html#using-a-rotator-and-namer-to-customize-log-rotation-processing
def rotator(source, dest):
    with open(source, 'rb') as f_in:
        with gzip.open(dest, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)
    os.remove(source)


def namer(name):
    return name + ".gz"


log_level = logging.DEBUG

logfile = '{}/osprey_cron_{}.log'.format(settings.log_folder, current_time)
logging.basicConfig(level=log_level,
                    format='%(levelname)s | %(asctime)s | %(filename)s:%(lineno)s | %(message)s',
                    datefmt='%y-%b-%d %H:%M:%S',
                    handlers=[RotatingFileHandler(logfile, maxBytes=10000000, backupCount=10)])
logging.rotator = rotator
logging.namer = namer
logger = logging.getLogger("osprey_cron")
