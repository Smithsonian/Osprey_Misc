# Osprey HPC

This folder contains scripts we are using when running Osprey in the Smithsonian High Performance Cluster, Hydra. 

In summary, the approach is to:

 * Create text file to indicate the project script is running, to avoid trying to run too many processes at the same time
 * Sync the running folder with the contents of the nearline storage, including removing folders that are being delivered to permanent storage (DAMS)
 * Run Osprey on the running folder 
 * Delete the text file created in the first step

A cron script runs every few hours to run this sequence of steps (`run.sh`)
