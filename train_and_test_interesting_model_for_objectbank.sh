#!/bin/bash

# Usage: sh train_and_test_interesting_model.sh <n-fold file path> <feature path> <model path>

DIR=$1
FEATUREBASE=$2
MODELBASE=$3

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

        MODELPATH=$MODELBASE/$FOLDNUM

        echo $MODELPATH

        TRAIN_POSITIVE_FEATURE=$FEATUREBASE/${FOLDNUM}_train_postive/features/feature.mat
        TRAIN_NEGATIVE_FEATURE=$FEATUREBASE/${FOLDNUM}_train_negative/features/feature.mat
        TEST_POSITIVE_FEATURE=$FEATUREBASE/${FOLDNUM}_test_postive/features/feature.mat
        TEST_NEGATIVE_FEATURE=$FEATUREBASE/${FOLDNUM}_test_negative/features/feature.mat

        echo $TRAIN_POSITIVE_FEATURE
        echo $TRAIN_NEGATIVE_FEATURE
        echo $TEST_POSITIVE_FEATURE
        echo $TEST_NEGATIVE_FEATURE
 
        mkdir -p $MODELPATH

        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchDetection('$TRAIN_POSITIVE_FEATURE', '$TRAIN_NEGATIVE_FEATURE', '$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH', 'objectbank_model', 1, -1)"
 
        #matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchDetection('$TRAIN_POSITIVE_FEATURE', '$TRAIN_NEGATIVE_FEATURE', '$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH', 'hsv_model', 1, 1893)"
  
        #matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchDetection('$TRAIN_POSITIVE_FEATURE', '$TRAIN_NEGATIVE_FEATURE', '$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH', 'edge_model', 1894, 2189)"
 
        #matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchDetection('$TRAIN_POSITIVE_FEATURE', '$TRAIN_NEGATIVE_FEATURE', '$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH', 'saliency_model', 2190, 2507)"

        #matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchDetection('$TRAIN_POSITIVE_FEATURE', '$TRAIN_NEGATIVE_FEATURE', '$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH', 'texture_model', 2508, 2566)"
 
        COUNT=$(($COUNT+1))
    fi
done

