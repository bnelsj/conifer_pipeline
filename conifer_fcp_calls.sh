#!/bin/bash

source config.sh

python  $CONIFER_TOOLS_DIR/02_filter_calls.py \
	--conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/'$PROJECT_NAME'all_chr_SVD'$SVD_DISCARD'.hdf5' \
	--call_file $PROJECT_DIR'/calls/'$PROJECT_NAME'_all_calls_batches_SVD'$SVD_DISCARD'.csv' \
	--outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_filtered_calls_SVD'$SVD_DISCARD'.csv'

python $CONIFER_TOOLS_DIR/03_cluster_calls.py \
        --infile $PROJECT_DIR'/calls/'$PROJECT_NAME'_filtered_calls_SVD'$SVD_DISCARD'.csv' \
        --outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_clustered_calls_SVD'$SVD_DISCARD'.csv'

python $CONIFER_TOOLS_DIR/plotting/QC02_plot_cnvrs.py \
        --conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5' \
        --call_file $PROJECT_DIR'/calls/'$PROJECT_NAME'_clustered_calls_SVD'$SVD_DISCARD'.csv' --out_dir $PROJECT_DIR'/plots'

