#!/bin/bash

source config.sh
export PYTHONWARNINGS="ignore"

python $CONIFER_SCRIPT_DIR/03_merge_conifer_files.py --outfile 'SVD_'$SVD_DISCARD/'all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5' \
	--infiles 'SVD_'$SVD_DISCARD'/chr'*'.SVD'$SVD_DISCARD'.hdf5'
