module load R/2.15.1

# Trap interrupts and exit instead of continuing the loop
trap "echo Exited!; exit;" SIGINT SIGTERM

DRMAA_LIBRARY_PATH="/opt/uge/lib/lx-amd64/libdrmaa.so.1.0"
export DRMAA_LIBRARY_PATH

#CONIFER_ANALYSIS_FILE="/net/grc/shared/scratch/nkrumm/ESP2000/SVD/SVD21_QC_10bpmin_allchr.h5"
CONIFER_ANALYSIS_FILE=$PROJECT_DIR'/SVD_'$SVD_DISCARD'/all_chr_'$PROJECT_NAME'_SVD'$SVD_DISCARD'.hdf5'

OUTDIR=$PROJECT_DIR'/calls_'$SVD_DISCARD
mkdir -p 'calls_'$SVD_DISCARD

CHRS=`seq 1 24`

QCDIR="$OUTDIR/QC"
mkdir -p $QCDIR

CALLSDIR="$OUTDIR/calls"
PLOTDIR="$OUTDIR/plots"

FAMILIES=$(cut -f2 -d, epi4k_samples_02-04-13_batches.txt)
SAMPLES=$(cut -f1 -d, epi4k_samples_02-04-13_batches.txt)

NCPUS=200
OUTFILE=$OUTDIR'/all_calls_batches_'$SVD_DISCARD'.csv'
python $PROJECT_DIR'/conifer-tools/scripts/01_create_calls.py' --infile=$CONIFER_ANALYSIS_FILE \
	--chr $CHRS --ncpus $NCPUS --outfile=$OUTFILE --samples $SAMPLES --families $FAMILIES


