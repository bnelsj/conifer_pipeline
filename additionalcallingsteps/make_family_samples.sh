#!/bin/bash

source config.sh

NSAMPLES=`wc -l $PROJECT_DIR/batch_conifer_sample_list.txt | awk {'print $1'}`

line_counter=0
batch_counter=1
family_file=$PROJECT_DIR/batch_conifer_list.txt
header=0

if [ "$FAMILY_CALL_BATCHES" -eq 1  ]
then
        BATCH_SIZE=$NSAMPLES
else
        BATCH_SIZE=$((NSAMPLES / FAMILY_CALL_BATCHES))
fi

BATCH_SIZE=10

for line in `cat $PROJECT_DIR/batch_conifer_sample_list.txt`
do
        bname=`basename $line .h5`
        if [ "$header" -eq "1" ]
        then
                header=0
                continue
        fi
        ((line_counter++))
        if [ "$line_counter" -eq 1 ]
        then
                echo $bname,batch$batch_counter > $family_file
        else
                echo $bname,batch$batch_counter >> $family_file
                if [ $(( line_counter % $(($BATCH_SIZE + 1)) )) -eq 0  ]
                then
                        ((batch_counter++))
                fi
        fi
done

FAMILIES=`cut -f2 -d, $family_file`
SAMPLES=`cut -f1 -d, $family_file`
