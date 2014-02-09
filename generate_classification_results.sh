#!/bin/bash

# Usage: sh generate_classification_results.sh <n-fold file path> <data path> <diff path> <result path>

DIR=$1
DATABASE=$2
DIFFBASE=$3
RESULTBASE=$4

MATLAB_LIBPATH="~/project/Aesthetics/PhotoAssessment"

FILES=$(find $DIR -type f | sort -n -t . -k 3)
COUNT=0
for f in $FILES  # fold files
do
    echo $f
    if [[ "$f" =~ fold_[0-9]*_train_postive\.txt ]]
    then
        FILETITLE=$(echo "$f" | sed 's/.*\/\(.*\)\.txt/\1/')
        FOLDNUM=$(echo "$f" | sed 's/.*\/\(fold_[0-9]*\).*\.txt/\1/')

        RESULTPATH=$RESULTBASE/$FOLDNUM

        TESTING_DIFF_FILE=$DIFFBASE/$FOLDNUM/testing_result_diff.mat

        POSITIVE_FILES=$DATABASE/${FOLDNUM}_test_postive/feature_imagefilenames/image_filenames.mat
        NEGATIVE_FILES=$DATABASE/${FOLDNUM}_test_negative/feature_imagefilenames/image_filenames.mat

        echo $POSITIVE_FILES
        echo $NEGATIVE_FILES
 
        mkdir -p $RESULTPATH

        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchGenerateClassificationResults('$POSITIVE_FILES', '$NEGATIVE_FILES', '$TESTING_DIFF_FILE', '$RESULTPATH')"
 
        COUNT=$(($COUNT+1))
    fi
done

