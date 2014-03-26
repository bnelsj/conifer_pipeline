#Modify then source config.sh before running make.

all : conifermergefiles

conifermergefiles : $(PROJECT_DIR)/SVD_$(SVD_DISCARD)/*.txt
	./conifer_merge_files.sh

$(PROJECT_DIR)/SVD_$(SVD_DISCARD)/*.txt : $(PROJECT_DIR)/rpkm/*.h5 conifer_make_files.sh config.sh
	./submit_conifer_make_files.sh

$(PROJECT_DIR)/rpkm/*.h5 : $(PROJECT_DIR)/hdf5/*.h5
	./calc_rpkm.sh

$(PROJECT_DIR)/hdf5/*.h5 : $(PROJECT_DIR)/$(BAM_SAMPLE_LIST) mrfast_template_original.txt
	./run_batch_frfast.sh

.PHONY : clean

clean :
	rm -rf rpkm/ hdf5/ calls/ plots/ logs/
