#!/bin/bash

# Usage: sh test_interesting_model.sh <n-fold file path> <feature path> <model path> <result path>

DIR=$1
FEATUREBASE=$2
MODELBASE=$3
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

        MODELPATH=$MODELBASE/$FOLDNUM
        RESULTPATH=$RESULTBASE/$FOLDNUM

        echo $MODELPATH

        TEST_POSITIVE_FEATURE=$FEATUREBASE/${FOLDNUM}_test_postive/features/feature.mat
        TEST_NEGATIVE_FEATURE=$FEATUREBASE/${FOLDNUM}_test_negative/features/feature.mat

        echo $TEST_POSITIVE_FEATURE
        echo $TEST_NEGATIVE_FEATURE
 
        mkdir -p $MODELPATH
        mkdir -p $RESULTPATH

        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchTesting('$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH/model.mat', '$RESULTPATH', 'testing_result', 1, -1)"
 
        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchTesting('$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH/hsv_model.mat', '$RESULTPATH', 'hsv_testing_result', 1, 1893)"
  
        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchTesting('$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH/edge_model.mat', '$RESULTPATH', 'edge_testing_result', 1894, 2189)"
 
        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchTesting('$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH/saliency_model.mat', '$RESULTPATH', 'saliency_testing_result', 2190, 2507)"

        matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchTesting('$TEST_POSITIVE_FEATURE', '$TEST_NEGATIVE_FEATURE', '$MODELPATH/texture_model.mat', '$RESULTPATH', 'texture_testing_result', 2508, 2566)"
 
        COUNT=$(($COUNT+1))
    fi
done

