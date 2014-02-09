#!/bin/bash

# Usage: sh extract_image_features_n_fold.sh <n-fold file path> <output path>

DIR=$1
OUTPUTBASE=$2

MATLAB_LIBPATH="~/project/Aesthetics/low_level Feature Extraction"
GBVSPATH=~/project/Aesthetics/gbvs/gbvs

FILES=$(find $DIR -type f | sort -n -t . -k 3)
COUNT=0
for f in $FILES  # fold files
do
    echo $f
    if [[ "$f" =~ fold_[0-9]*_.*\.txt ]]
    then
        FILETITLE=$(echo "$f" | sed 's/.*\/\(.*\)\.txt/\1/')

        IMAGEPATH=$OUTPUTBASE/$FILETITLE/images
        FEATUREPATH=$OUTPUTBASE/$FILETITLE/features
        # temoprarily remove previous generated features
        rm $FEATUREPATH/*
        mkdir -p $FEATUREPATH
        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchFeatureExtraction('$IMAGEPATH', '$FEATUREPATH', 'feature', '$GBVSPATH')"
        COUNT=$(($COUNT+1))
    fi
done

