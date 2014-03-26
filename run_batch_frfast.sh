#!/bin/bash

source config.sh

MEM_REQUEST=4G
PROC_REQUEST=10

NSAMPLES=`wc -l $PROJECT_DIR'/'$BAM_SAMPLE_LIST | awk {'print $1'}`

if [ $FRFAST_BATCHES -gt $NSAMPLES  ]
then
	echo 'Too many batches ('$FRFAST_BATCHES') for number of bam files ('$NSAMPLES').'
	exit 1
fi

if [ $(( NSAMPLES % FRFAST_BATCHES)) -eq 0 ]
then
	NLINES=$(( NSAMPLES / FRFAST_BATCHES ))
else
	NLINES=$(( NSAMPLES / FRFAST_BATCHES + 1 ))
fi

firstsample=$PROJECT_DIR/$BAM_SAMPLE_BATCH_PREFIX'00'

split -d -l $NLINES $PROJECT_DIR'/'$BAM_SAMPLE_LIST $PROJECT_DIR'/'$BAM_SAMPLE_BATCH_PREFIX

cp $SCRIPT_DIR'/mrfast_template_original.txt' $SCRIPT_DIR'/mrfast_template.txt'
echo 'mkdir -p '$TEMP_EXOME_DIR >> $SCRIPT_DIR'/mrfast_template.txt'
echo 'rsync '$DEFAULT_EXOME_PATH'/* '$TEMP_EXOME_DIR >> $SCRIPT_DIR'/mrfast_template.txt'

frfast_counter=0
for f in $PROJECT_DIR/$BAM_SAMPLE_BATCH_PREFIX*
do 
	if [[ "$f" == "$firstsample" ]]
	then
		:
	else
		sed -i '1i\sampleID\tbam_path' $f
	fi

	python $FRFAST_COMMAND_GEN $f $PROJECT_DIR'/hdf5' $PROJECT_DIR'/logs' \
	$TEMP_EXOME_DIR'/default_exome.fa' $DEFAULT_EXOME_TRANS_PATH \
	--dont-rsync-index --disable-gui --single-host --disable-port-scan \
	--template-header-file=$SCRIPT_DIR'/mrfast_template.txt' \
	> $PROJECT_DIR'/frfast_job_'$frfast_counter'.sh'
	chmod 755 $PROJECT_DIR'/frfast_job_'$frfast_counter'.sh'
	((frfast_counter++))
done

echo Submitting frfast jobs...

frfast_jobs=`ls -d -1 $PROJECT_DIR'/frfast_job_'*'.sh'`
parallel -j6 qsub -q all.q -N {/.} -sync y -l mfree=$MEM_REQUEST -pe serial $PROC_REQUEST {} ::: $frfast_jobs
