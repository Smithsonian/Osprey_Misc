#!/bin/bash
#

cd $HOME/osprey/$1

folder_name=`basename "$PWD"`


if test -f $HOME/osprey/$folder_name.txt
then
	echo "File exists."
	exit
else
	./pre_script.sh
	qsub $HOME/jobs/osprey/$folder_name.job
fi




