source config.sh

# Trap interrupts and exit instead of continuing the loop
trap "echo Exited!; exit;" SIGINT SIGTERM

DRMAA_LIBRARY_PATH="/opt/uge/lib/lx-amd64/libdrmaa.so.1.0"
export DRMAA_LIBRARY_PATH

CONIFER_ANALYSIS_FILE=$PROJECT_DIR'/SVD_'$SVD_DISCARD'/'$PROJECT_NAME'_all_chr_SVD'$SVD_DISCARD'.hdf5'
NSAMPLES=`wc -l $PROJECT_DIR/$BAM_SAMPLE_LIST | awk {'print $1'}`
CHRS=`seq 1 24`

line_counter=0
batch_counter=1
family_file=$PROJECT_DIR/batch_conifer_list.txt
first_line=1

for line in `cut -f1 -d, $SVD_SAMPLE_LIST`
do
	bname=`basename $line .h5`
        if [ "$first_line" -eq "1" ]
        then
		first_line=0
		continue
	fi
	((line_counter++))
	if [ "$line_counter" -eq 1 ]
	then
		echo $bname,batch$batch_counter > $family_file
	else
                echo $bname,batch$batch_counter >> $family_file
                if [ $(( line_counter % $FAMILY_CALL_BATCHES )) -eq 0  ]
                then
                        ((batch_counter++))
                fi
        fi
done

FAMILIES=`cut -f2 -d, $family_file`
SAMPLES=`cut -f1 -d, $family_file`

OUTFILE=$PROJECT_DIR'/calls/'$PROJECT_NAME'_all_calls_batches_SVD'$SVD_DISCARD'.csv'
python $CONIFER_TOOLS_DIR/01_create_calls.py --infile $CONIFER_ANALYSIS_FILE --chr $CHRS \
	--ncpu $FAMILY_CALL_BATCHES --outfile $OUTFILE --samples $SAMPLES --families $FAMILIES


