#!/bin/bash

source config.sh

#Make list of HDF5 files
HDF5_FILES=`ls -d -1 $PROJECT_DIR'/hdf5/'*'.h5'`

#Calculate RPKM
#Requires GNU parallel
parallel -j6 "python "$CONIFER_SCRIPT_DIR"/calc_rpkm.py --min-probe-size=10 "$DEFAULT_PROBEFILE" \
	{} "$PROJECT_DIR"/rpkm/{/.}.h5" ::: $HDF5_FILES
