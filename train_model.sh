#!/bin/bash

# Usage: sh train_model.sh <training data path> <model path>

DIR=$1
FILES=$(find $DIR -type f)
for f in $FILES
do
    ./libsvm-3.12/svm-train -s 2 -g 0.0000001 -n 0.5 $f $f.model
    mv $f.model $2/.
done

