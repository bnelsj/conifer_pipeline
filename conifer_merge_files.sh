#!/bin/bash

source config.sh
export PYTHONWARNINGS="ignore"

for num in `seq 1 24`
do
        if [ ! -s $PROJECT_DIR'/SVD_'$SVD_DISCARD'/chr'$num'.SVD'$SVD_DISCARD'.hdf5' ]
        then
                echo SVD file for chr $num was not created. Try rerunning submit_conifer_make_files.sh.
                exit 1
        fi
done

python $CONIFER_SCRIPT_DIR/03_merge_conifer_files.py \
	--outfile $PROJECT_DIR'/SVD_'$SVD_DISCARD'/all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5' \
	--infiles $PROJECT_DIR'/SVD_'$SVD_DISCARD'/chr'*'.SVD'$SVD_DISCARD'.hdf5'
