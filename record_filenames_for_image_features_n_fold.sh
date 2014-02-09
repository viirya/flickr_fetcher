#!/bin/bash

# Usage: sh record_filenames_for_image_features_n_fold.sh <n-fold file path> <output path>

DIR=$1
OUTPUTBASE=$2

MATLAB_LIBPATH="~/project/Aesthetics/low_level Feature Extraction"

FILES=$(find $DIR -type f | sort -n -t . -k 3)
COUNT=0
for f in $FILES  # fold files
do
    echo $f
    if [[ "$f" =~ fold_[0-9]*_.*\.txt ]]
    then
        FILETITLE=$(echo "$f" | sed 's/.*\/\(.*\)\.txt/\1/')

        IMAGEPATH=$OUTPUTBASE/$FILETITLE/images
        RESULTPATH=$OUTPUTBASE/$FILETITLE/feature_imagefilenames
        mkdir -p $RESULTPATH
        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchFeatureExtractionRecordFilename('$IMAGEPATH', '$RESULTPATH', 'image_filenames')"
        COUNT=$(($COUNT+1))
    fi
done

