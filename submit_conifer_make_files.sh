#!/bin/bash

source config.sh

#Make svd_sample_list
echo 'file,sampleID' > $SVD_SAMPLE_LIST

for f in $PROJECT_DIR/rpkm/*.h5
do
base_f=`basename $f .h5`
echo $f','$base_f >> $SVD_SAMPLE_LIST
done

#Submit conifer_make_files.sh for each chromosome
MEM_REQUEST='6G'
PROC_REQUEST=6

echo Submitting CoNIFER files...

parallel 'qsub -sync y -l mfree='$MEM_REQUEST' -N s{} -v CHR={} -pe serial '$PROC_REQUEST' conifer_make_files.sh' ::: `seq 1 24`
