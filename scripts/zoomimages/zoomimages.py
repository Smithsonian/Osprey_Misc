#!/usr/bin/env python3
#
# Generate DZI images for zooming
# https://github.com/Smithsonian/Osprey_Misc
#
#
 
import sys

# Uses https://github.com/competitive-edge/deepzoom.py
import deepzoom

from PIL import Image
import glob
import itertools
from pathlib import Path

# Parallel
import multiprocessing
from multiprocessing import Pool

Image.MAX_IMAGE_PIXELS = 1000000000


if len(sys.argv) == 3:
    jpg_path = sys.argv[1]
    no_workers = int(sys.argv[2])
else:
    print("Wrong number of args")
    sys.exit(1)


# Get list of files and iterate/parallelize
def generate_pyramids(filename, jpg_path):
    # Get filename without suffix
    filename_stem = Path(filename).stem
    creator = deepzoom.ImageCreator(
        tile_size=256,
        tile_overlap=2,
        tile_format="jpg",
        image_quality=0.8,
        resize_filter="bicubic",
    )
    # Create Deep Zoom image pyramid from source
    creator.create(filename, "{}/{}.dzi".format(jpg_path, filename_stem))
    return(filename_stem)


files = glob.glob("{}/*.jpg".format(jpg_path))

# Process files in parallel
inputs = zip(files, itertools.repeat(jpg_path))
with Pool(no_workers) as pool:
    pool.starmap(generate_pyramids, inputs)
    pool.close()
    pool.join()

