#Modify then source config.sh before running make

conifer_file = $(CONIFER_FILE)
batch_call_file = $(PROJECT_DIR)/calls/$(PROJECT_NAME)_all_calls_batches_SVD$(SVD_DISCARD).csv
merge_file = $(PROJECT_DIR)/calls/$(PROJECT_NAME)_merged_calls_SVD$(SVD_DISCARD).csv
merge_filter_file = $(PROJECT_DIR)/calls/$(PROJECT_NAME)_merged_filtered_calls_SVD$(SVD_DISCARD).csv
merge_filter_cluster_file = $(PROJECT_DIR)/calls/$(PROJECT_NAME)_merged_filtered_clustered_calls_SVD$(SVD_DISCARD).csv
merge_filter_geno_file = $(PROJECT_DIR)/calls/$(PROJECT_NAME)_merged_filtered_genotyped_calls_SVD$(SVD_DISCARD).csv
merge_filter_concat_file = $(PROJECT_DIR)/calls/$(PROJECT_NAME)_merged_filtered_concat_calls_SVD$(SVD_DISCARD).csv
esp_in = ESP.all_chr.qc.filtered.clustered.csv
esp_out = ESP.all_chr.qc.filtered.clustered.translated.csv
mfgc_esp = $(PROJECT_DIR)/calls/$(PROJECT_NAME)_fcalls_merged_filtered_genotyped_clustered_esp.csv

make_plots : $(merge_filter_cluster_file)
	python $(CONIFER_TOOLS_DIR)/plotting/QC02_plot_cnvrs.py \
	--conifer_file $(conifer_file) --call_file $(merge_filter_cluster_file) \
	--out_dir $(PROJECT_DIR)/plots

$(merge_filter_cluster_file) : $(merge_filter_file)
	python $(CONIFER_TOOLS_DIR)/03_cluster_calls.py \
	--infile $(merge_filter_file) --outfile $(merge_filter_cluster_file)

plot_cnvrs_trio : $(mfgc_esp) $(conifer_file)
	python QC02_plot_cnvrs_trio.py --conifer_file $(conifer_file) --call_file $(mfgc_esp) \
	--out_dir $(PROJECT_DIR)/plots/trios --cohort $(PROJECT_NAME)

$(mfgc_esp) : $(esp_out) $(merge_filter_concat_file) 
	python $(CONIFER_TOOLS_DIR)/03_cluster_calls_by_cohort.py --infile $(merge_filter_concat_file) \
	--esp_infile $(esp_out) --outfile $(mfgc_esp) --cohort $(PROJECT_NAME)

$(esp_out) : $(esp_in)
	python translate_call_coords.py --conifer_file $(conifer_file) \
	--call_file $(esp_in) --outfile $(esp_out)

$(merge_filter_concat_file) : $(merge_filter_geno_file) $(merge_filter_file)
	python 00_cat_calls.py $(merge_filter_geno_file) $(merge_filter_file) \
	--outfile $(merge_filter_concat_file)

$(merge_filter_geno_file) : $(merge_filter_file)
	python 02b_family_genotype.py --conifer_file $(conifer_file) \
	--call_file $(merge_filter_file) --outfile $(merge_filter_geno_file)

$(merge_filter_file) : $(merge_file) $(conifer_file)
	python $(CONIFER_TOOLS_DIR)/02_filter_calls.py --conifer_file $(conifer_file) \
	--call_file $(merge_file) --outfile $(merge_filter_file)

$(merge_file) : $(conifer_file) $(batch_call_file)
	python 01b_merge_calls.py --conifer_file $(conifer_file) \
	--call_file $(batch_call_file) --outfile $(merge_file)

$(batch_call_file) : $(conifer_file)
	./conifer_create_family_calls.sh

.PHONY : clean

clean :
	rm -rf $(PROJECT_DIR)/calls/* $(PROJECT_DIR)/plots/*
