#!/bin/bash

source config.sh

PROC_REQUEST=10

python $CONIFER_TOOLS_DIR'/01_create_calls.py' \
	--infile $PROJECT_DIR'/SVD_'$SVD_DISCARD'/all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5' \
	-o $PROJECT_DIR'/calls/calls_'$SVD_DISCARD'.csv --ncpus '$PROC_REQUEST
