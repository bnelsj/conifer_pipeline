#!/bin/bash
#$ -S /bin/bash
#$ -cwd


module load modules modules-init modules-gs
module load zlib/1.2.5
module load hdf5/1.8.8
module load bedtools/latest
module load python/2.7.2
module load lzo/2.06
module load pytables/2.3.1_hdf5-1.8.8 

source config.sh

BASE_DIR=$PROJECT_DIR'/SVD_'$SVD_DISCARD
mkdir -p $BASE_DIR

PROBES=$DEFAULT_PROBEFILE

LOGLEVEL="DEBUG"

#CHR=22

TMPDIR=/var/tmp/`whoami`
mkdir -p $TMPDIR
SCRIPT=$CONIFER_SCRIPT_DIR/02_create_conifer_file.py

# setup multithreaded numpy
export PYTHONPATH=/net/eichler/vol8/home/nkrumm/lib/python2.7/site-packages/:$PYTHONPATH
export LD_LIBRARY_PATH=/net/eichler/vol8/home/nkrumm/lib/lib/:$LD_LIBRARY_PATH
export OPENBLAS_NUM_THREADS=6
export OMP_NUM_THREADS=6
# turn off warnings
export PYTHONWARNINGS="ignore"



CONIFER_ANALYSIS_FILE="$BASE_DIR/chr${CHR}.SVD${SVD_DISCARD}.hdf5"
QC_REPORT="$BASE_DIR/chr${CHR}.SVD${SVD_DISCARD}.txt"

python $SCRIPT --outfile $CONIFER_ANALYSIS_FILE \
            --components_removed $SVD_DISCARD \
            --chromosomes $CHR \
            --probes $PROBES \
            --samples $SVD_SAMPLE_LIST \
            --loglevel $LOGLEVEL \
            --QC_report=$QC_REPORT

