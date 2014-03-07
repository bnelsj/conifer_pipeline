#!/bin/bash
#Arguments: samplefile batches

source config.sh

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

FIRSTSAMPLE=$BAM_SAMPLE_BATCH_PREFIX'00'

split -d -l $NLINES $PROJECT_DIR'/'$BAM_SAMPLE_LIST $PROJECT_DIR'/'$BAM_SAMPLE_BATCH_PREFIX

for f in $PROJECT_DIR/$BAM_SAMPLE_BATCH_PREFIX*
do 
	bname=`basename $f`
	bname_no_ext=`basename $f .sh`
	echo $f $bname
	if [[ "$bname_no_ext" == "$bname" ]]
	then
		if [[ "$bname" == "$FIRSTSAMPLE" ]]
		then
			:
		else
			sed -i '1i\sampleID\tbam_path' $f
		fi
		python $FRFAST_COMMAND_GEN $PROJECT_DIR/$f $PROJECT_DIR/hdf5 $PROJECT_DIR/logs \
		$DEFAULT_EXOME_PATH $DEFAULT_EXOME_TRANS_PATH \
		--dont-rsync-index --disable-gui --single-host --disable-port-scan > $f.sh
		chmod 755 $f.sh
	fi
done
