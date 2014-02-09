#!/bin/bash

# Usage: sh average_testing_error.sh <model basepath> <result path>

MODELBASE=$1
RESULTPATH=$2

MATLAB_LIBPATH="~/project/Aesthetics/PhotoAssessment"

echo $MODELPATH

mkdir -p $RESULTPATH

matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchAverageTextingError('$MODELBASE', 'model_testing_error.mat', '$RESULTPATH', 'average_testing_error')"

matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchAverageTextingError('$MODELBASE', 'hsv_model_testing_error.mat', '$RESULTPATH', 'hsv_average_testing_error')"

matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchAverageTextingError('$MODELBASE', 'edge_model_testing_error.mat', '$RESULTPATH', 'edge_average_testing_error')"

matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchAverageTextingError('$MODELBASE', 'texture_model_testing_error.mat', '$RESULTPATH', 'texture_average_testing_error')"

matlab -nosplash -r "addpath('$MATLAB_LIBPATH'); batchAverageTextingError('$MODELBASE', 'saliency_model_testing_error.mat', '$RESULTPATH', 'saliency_average_testing_error')"
 

