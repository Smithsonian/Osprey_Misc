#!/bin/bash
#
# Update project statistics
#

cd ~/scripts/proj_statistics/nmnh_iz_unionoida
Rscript --vanilla calculate_stats.R

cd ~/scripts/proj_statistics/jpc
Rscript --vanilla calculate_stats.R

cd ~/scripts/proj_statistics/nmnh_is_botany
Rscript --vanilla calculate_stats.R

cd ~/scripts/proj_statistics/
Rscript --vanilla generate_figs.R


rsync -ruth --progress ~/scripts/proj_statistics/figs/ dt-vmdpoqc01.si.edu:/opt/webapp/static/figs/

cd
