#!/bin/bash

source ~/conifer_pipeline/scripts/config.sh

if [ ! -s $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_calls_SVD'$SVD_DISCARD'.csv' ]
then
python 01b_merge_calls.py --conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/'$PROJECT_NAME'_all_chr_SVD'$SVD_DISCARD'.hdf5' \
	--call_file $PROJECT_DIR'/calls/'$PROJECT_NAME'_all_calls_batches_SVD'$SVD_DISCARD'.csv' \
	--outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_calls_SVD'$SVD_DISCARD'.csv'
else
	echo "Calls already merged. Filtering..."
fi


if [ ! -s $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_calls_SVD'$SVD_DISCARD'.csv' ]
then
python  $CONIFER_TOOLS_DIR/02_filter_calls.py \
	--conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/'$PROJECT_NAME'_all_chr_SVD'$SVD_DISCARD'.hdf5' \
	--call_file $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_calls_SVD'$SVD_DISCARD'.csv' \
	--outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_calls_SVD'$SVD_DISCARD'.csv'
else
	echo "Calls already filtered. Genotyping..."
fi

if [ ! -s $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_genotyped_calls_SVD'$SVD_DISCARD'.csv' ]
then
python 02b_family_genotype.py --conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/'$PROJECT_NAME'_all_chr_SVD'$SVD_DISCARD'.hdf5' \
        --call_file $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_calls_SVD'$SVD_DISCARD'.csv' \
	--outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_genotyped_calls_SVD'$SVD_DISCARD'.csv' \
else
	echo "Calls already genotyped. Concatenating..."
fi

if [ ! -s $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_concat_calls_SVD'$SVD_DISCARD'.csv' ]
then            
python 00_cat_calls.py \
    $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_genotyped_calls_SVD'$SVD_DISCARD'.csv' \
    $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_calls_SVD'$SVD_DISCARD'.csv' \
    --outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_concat_calls_SVD'$SVD_DISCARD'.csv'
else
	echo "Calls already concatenated. Translating ESP data..."
fi

if [ ! -s ESP.all_chr.qc.filtered.clustered.translated.csv ]
then
python translate_call_coords.py \
	--conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/'$PROJECT_NAME'_all_chr_SVD'$SVD_DISCARD'.hdf5' \
        --call_file ESP.all_chr.qc.filtered.clustered.csv \
        --out_file ESP.all_chr.qc.filtered.clustered.translated.csv
else
	echo "ESP data already translated. Clustering calls..."
fi

if [ ! -s $PROJECT_DIR'/calls/'$PROJECT_NAME'_fcalls_merged_filtered_genotyped_clustered_esp.csv' ]
then
python $CONIFER_TOOLS_DIR/03_cluster_calls_by_cohort.py \
        --infile $PROJECT_DIR'/calls/'$PROJECT_NAME'_merged_filtered_concat_calls_SVD'$SVD_DISCARD'.csv' \
        --esp_infile ESP.all_chr.qc.filtered.clustered.translated.csv \
        --outfile $PROJECT_DIR'/calls/'$PROJECT_NAME'_fcalls_merged_filtered_genotyped_clustered_esp.csv' \
        --cohort $PROJECT_NAME
else
	echo "Calls already clustered. Generating trio plots..."
fi

python QC02_plot_cnvrs_trio.py \
	--conifer_file $PROJECT_DIR'/SVD_'$SVD_DISCARD'/'$PROJECT_NAME'_all_chr_SVD'$SVD_DISCARD'.hdf5' \
	--call_file $PROJECT_DIR'/calls/'$PROJECT_NAME'_fcalls_merged_filtered_genotyped_clustered_esp.csv' \
	--out_dir $PROJECT_DIR/plots/trios \
	--cohort $PROJECT_NAME

