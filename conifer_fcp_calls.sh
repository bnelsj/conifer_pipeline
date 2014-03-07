#!/bin/bash

source config.sh

python  $PROJECT_DIR'/conifer-tools/scripts/02_filter_calls.py' \
	--conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5' \
	--call_file $PROJECT_DIR'/calls/calls_'$SVD_DISCARD'.csv' \
	--outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_filtered_calls.csv'

python $PROJECT_DIR'/conifer-tools/scripts/03_cluster_calls.py' \
        --infile $PROJECT_DIR'/calls/'$PROJECT_NAME'_filtered_calls.csv' \
        --outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_clustered_calls.csv'

python $PROJECT_DIR'/conifer-tools/scripts/plotting/QC02_plot_cnvrs.py' \
        --conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5' \
        --call_file $PROJECT_DIR'/calls'$PROJECT_NAME'_clustered_calls.csv' --out_dir 'plots'

