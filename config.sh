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
#module load python/2.7.2
module load python/2.7.3
module load numpy/1.7.0
module load hdf5/1.8.8
module load zlib/1.2.5
module load lzo/2.06
#module load numpy/1.6.1
module load scipy/0.10.0
module load pytables/2.3.1_hdf5-1.8.8
module load MySQLdb/1.2.3
module load R/2.15.1
module load parallel/latest

FRFAST_BATCHES=5
BAM_SAMPLE_LIST='samples_03-04-14.txt'
BAM_SAMPLE_BATCH_PREFIX='sample_'
SCRIPT_DIR=/net/eichler/vol5/home/bnelsj/conifer_pipeline/scripts
FRFAST_COMMAND_GEN=/net/eichler/vol5/home/bnelsj/conifer_pipeline/frFAST/command_gen.py

PROJECT_DIR=/net/eichler/vol17/dutch_asperger/nobackups/conifer_test
PROJECT_NAME=dutch_asp
CONIFER_SCRIPT_DIR=/net/eichler/vol8/home/nkrumm/CoNIFER/scripts
CONIFER_TOOLS_DIR=/net/eichler/vol5/home/bnelsj/conifer_pipeline/conifer-tools/scripts
DEFAULT_EXOME_PATH=/net/grc/shared/scratch/nkrumm/INDEX/default_exome
TEMP_EXOME_DIR=/var/tmp/`whoami`
DEFAULT_EXOME_TRANS_PATH=/net/grc/shared/scratch/nkrumm/translate_tables/default_exome.translate.txt
DEFAULT_PROBEFILE=/net/eichler/vol8/home/nkrumm/CoNIFER/probe_files/probes.nimblegen.noheader.cut.txt
SVD_DISCARD=9
FAMILY_CALL_BATCHES=10
SVD_SAMPLE_LIST=$PROJECT_DIR/svd_sample_list.txt

pushd $PROJECT_DIR; mkdir -p hdf5 logs calls plots rpkm; popd
