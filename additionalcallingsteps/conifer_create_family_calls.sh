#!/bin/bash

source config.sh

samples=`ptdump -c $CONIFER_FILE:/chr1/ | tr -d \' | awk {'print $3'} | tail -n +2`
nsamples=`echo -e "$samples" | wc -l`
batch_counter=1
line_counter=0
family_file=$PROJECT_DIR/batch_conifer_list.txt

for sample in $samples
do
	((line_counter++))
	if [ "$line_counter" -eq 1 ]
	then
		echo $sample,batch$batch_counter > $family_file
	else
		echo $sample,batch$batch_counter >> $family_file
	fi
	if [ $(( line_counter % $(($FAMILY_CALL_BATCH_SIZE + 1)) )) -eq 0  ]
	then
		((batch_counter++))
	fi
done

FAMILIES=`cut -f2 -d, $family_file`
SAMPLES=`cut -f1 -d, $family_file`

trap "echo Exited!; exit;" SIGINT SIGTERM

DRMAA_LIBRARY_PATH="/opt/uge/lib/lx-amd64/libdrmaa.so.1.0"
export DRMAA_LIBRARY_PATH
#Get conifer_file handle
CHRS=`seq 1 24`
NFAMILY_CPUS=$(($FAMILY_CALL_BATCH_SIZE + 1))
OUTFILE=$PROJECT_DIR'/calls/'$PROJECT_NAME'_all_calls_batches_SVD'$SVD_DISCARD'.csv'

python $CONIFER_TOOLS_DIR/01_create_calls.py --infile $CONIFER_FILE --chr $CHRS \
	--ncpu $NFAMILY_CPUS --outfile $OUTFILE --samples $SAMPLES --families $FAMILIES

