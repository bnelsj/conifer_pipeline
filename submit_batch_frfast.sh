#!/bin/bash

source config.sh

MEM_REQUEST=4G
PROC_REQUEST=10

for f in $BAM_SAMPLE_BATCH_PREFIX*
do
	bname=`basename $f .sh`
	if [ $f = $bname  ]
	then
		qsub -q all.q -N $bname $f -l mfree=$MEM_REQUEST -pe serial $PROC_REQUEST
	fi
done
