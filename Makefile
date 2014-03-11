source config.sh

coniferfcpcalls : $(PROJECT_DIR)/calls/calls_$(SVD_DISCARD).csv
	./conifer_fcp_calls.sh
conifercreatecalls : $(PROJECT_DIR)/SVD_$(SVD_DISCARD)/all_chr_*.hdf5
	./conifer_create_calls.sh
conifermergefiles : $(PROJECT_DIR)/SVD_$(SVD_DISCARD)/*.txt
	./conifer_merge_files.sh
makeconiferfiles : $(PROJECT_DIR)/rpkm/*.h5 conifer_make_files.sh
	./submit_conifer_make_files.sh
calcrpkm : $(PROJECT_DIR)/hdf5/*.h5
	./calc_rpkm.sh
frfasting : $(BAM_SAMPLE_LIST) mrfast_template_original.txt
	./run_batch_frfast.sh
