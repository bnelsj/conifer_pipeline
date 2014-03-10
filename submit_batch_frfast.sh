#!/bin/bash

source config.sh

MEM_REQUEST=4G
PROC_REQUEST=10

for f in $PROJECT_DIR/$BAM_SAMPLE_BATCH_PREFIX*
do
	bname=`basename $f`
	bname_no_ext=`basename $f .sh`
	if [ $bname != $bname_no_ext  ]
	then
		qsub -q all.q -N $bname -l mfree=$MEM_REQUEST -pe serial $PROC_REQUEST $f
	fi
done
