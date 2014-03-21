#! /bin/bash

module load modules
module load modules-init 
module load modules-gs/prod
module load modules-eichler/prod
module load java/6u13
module load bedtools/2.17.0
module load samtools/0.1.18
module load perl/5.14.2
module load mpc/0.8.2
module load mpfr/3.1.0
module load gmp/5.0.2
module load gcc/4.7.0
#module unload python/2.7.2
module load python/2.7.2
#module load python/2.7.3
module load numpy/1.6.1
module load hdf5/1.8.8
module load zlib/1.2.5
module load lzo/2.06
module load scipy/0.10.0
module load pytables/2.3.1_hdf5-1.8.8
module load MySQLdb/1.2.3
module load R/2.15.1
module load parallel/latest

export FRFAST_BATCHES=2
export BAM_SAMPLE_LIST='samples_trimmed.txt'
export BAM_SAMPLE_BATCH_PREFIX='sample_'
export SCRIPT_DIR=/net/eichler/vol5/home/bnelsj/esp_conifer/scripts
export FRFAST_COMMAND_GEN=/net/eichler/vol5/home/bnelsj/conifer_pipeline/frFAST/command_gen.py

export PROJECT_DIR=/net/eichler/vol5/home/bnelsj/esp_conifer/broad
export PROJECT_NAME=esp_broad
export CONIFER_SCRIPT_DIR=/net/eichler/vol8/home/nkrumm/CoNIFER/scripts
export CONIFER_TOOLS_DIR=/net/eichler/vol5/home/bnelsj/esp_conifer/conifer-tools/scripts
export DEFAULT_EXOME_PATH=/net/grc/shared/scratch/nkrumm/INDEX/default_exome
export TEMP_EXOME_DIR=/var/tmp/`whoami`
export DEFAULT_EXOME_TRANS_PATH=/net/grc/shared/scratch/nkrumm/translate_tables/default_exome.translate.txt
export DEFAULT_PROBEFILE=/net/eichler/vol8/home/nkrumm/CoNIFER/probe_files/probes.nimblegen.noheader.cut.txt
export SVD_DISCARD=70
export FAMILY_CALL_BATCHES=314

export SVD_SAMPLE_LIST=$PROJECT_DIR/svd_sample_list.txt

pushd $PROJECT_DIR > /dev/null; mkdir -p hdf5 logs calls plots rpkm; popd > /dev/null
