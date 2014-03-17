#!/bin/bash

source config.sh

MEM_REQUEST=4G
PROC_REQUEST=10

#FRFAST_BATCHES=$1


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

#Set mrfast_template.txt
#SED_STRING=$DEFAULT_EXOME_PATH'/* '$TEMP_EXOME_DIR
#echo $SED_STRING
#sed -i 's|DEFAULT_EXOME_DIR TEMP_EXOME_DIR|'"$SED_STRING"'|' $SCRIPT_DIR'/mrfast_template.txt'
cp $SCRIPT_DIR'/mrfast_template_original.txt' $SCRIPT_DIR'/mrfast_template.txt'
echo 'mkdir -p '$TEMP_EXOME_DIR >> $SCRIPT_DIR'/mrfast_template.txt'
echo 'rsync '$DEFAULT_EXOME_PATH'/* '$TEMP_EXOME_DIR >> $SCRIPT_DIR'/mrfast_template.txt'


for f in $PROJECT_DIR/$BAM_SAMPLE_BATCH_PREFIX*
do 
	bname=`basename $f`
	bname_no_ext=`basename $f .sh`
	if [[ "$bname_no_ext" == "$bname" ]]
	then
		if [[ "$bname" == "$FIRSTSAMPLE" ]]
		then
			:
		else
			sed -i '1i\sampleID\tbam_path' $f
		fi

		python $FRFAST_COMMAND_GEN $f $PROJECT_DIR'/hdf5' $PROJECT_DIR'/logs' \
		$TEMP_EXOME_DIR'/default_exome.fa' $DEFAULT_EXOME_TRANS_PATH \
		--dont-rsync-index --disable-gui --single-host --disable-port-scan \
		--template-header-file=$SCRIPT_DIR'/mrfast_template.txt' > $f.sh
		chmod 755 $f.sh
	fi
done

for f in $PROJECT_DIR/$BAM_SAMPLE_BATCH_PREFIX*
do
        bname=`basename $f`
        bname_no_ext=`basename $f .sh`
        if [ $bname != $bname_no_ext  ]
        then
                qsub -q all.q -N $bname_no_ext -l mfree=$MEM_REQUEST -pe serial $PROC_REQUEST $f
        fi
done

