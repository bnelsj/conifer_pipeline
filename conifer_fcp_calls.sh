#!/bin/bash

source config.sh

python  $CONIFER_TOOLS_DIR/02_filter_calls.py \
	--conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5' \
	--call_file $PROJECT_DIR'/calls/all_calls_batches.csv' \
	--outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_filtered_calls.csv'

python $CONIFER_TOOLS_DIR/03_cluster_calls.py \
        --infile $PROJECT_DIR'/calls/'$PROJECT_NAME'_filtered_calls.csv' \
        --outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_clustered_calls.csv'

python $CONIFER_TOOLS_DIR/plotting/QC02_plot_cnvrs.py \
        --conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5' \
        --call_file $PROJECT_DIR'/calls/'$PROJECT_NAME'_clustered_calls.csv' --out_dir $PROJECT_DIR'/plots'

