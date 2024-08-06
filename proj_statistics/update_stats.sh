#!/bin/bash
#
# Update project statistics
#

cd nmnh_iz_unionoida
/opt/R/4.2.3/bin/Rscript --vanilla calculate_stats.R

cd ../jpc_production
/opt/R/4.2.3/bin/Rscript --vanilla calculate_stats.R

cd ../nmnh_is_botany
/opt/R/4.2.3/bin/Rscript --vanilla calculate_stats.R

cd ../
/opt/R/4.2.3/bin/Rscript --vanilla generate_figs.R


rsync -ruth --progress figs/ si-vmosprey01.si.edu:/var/www/html/static/figs/
rsync -ruth --progress figs/ si-vmosprey02.si.edu:/var/www/html/static/figs/

cd
