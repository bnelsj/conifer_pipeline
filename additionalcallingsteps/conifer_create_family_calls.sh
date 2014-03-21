#!/bin/bash

source config.sh

# Trap interrupts and exit instead of continuing the loop
trap "echo Exited!; exit;" SIGINT SIGTERM

DRMAA_LIBRARY_PATH="/opt/uge/lib/lx-amd64/libdrmaa.so.1.0"
export DRMAA_LIBRARY_PATH

#Get conifer_file handle
CONIFER_ANALYSIS_FILE=`grep 'conifer_file =' Makefile | awk {'print $3'}`

CHRS=`seq 1 24`

NFAMILY_CPUS=$(($FAMILY_CALL_BATCHES + 1))

FAMILIES=`cut -f2 -d, $PROJECT_DIR/batch_conifer_list.txt`
SAMPLES=`cut -f1 -d, $PROJECT_DIR/batch_conifer_list.txt`

OUTFILE=$PROJECT_DIR'/calls/'$PROJECT_NAME'_all_calls_batches_SVD'$SVD_DISCARD'.csv'
python $CONIFER_TOOLS_DIR/01_create_calls.py --infile $CONIFER_ANALYSIS_FILE --chr $CHRS \
	--ncpu $NFAMILY_CPUS --outfile $OUTFILE --samples $SAMPLES --families $FAMILIES


