#!/bin/bash
# Usage: ./copy_classification_images.sh <classification result basepath> <image output basepath>

BASEDIR=$1
IMAGEBASEDIR=$2

for i in $(seq 1 10)
do

    mkdir -p $IMAGEBASEDIR/fold_${i}/correct
    mkdir -p $IMAGEBASEDIR/fold_${i}/wrong

    sed 's/\.\./\./' $BASEDIR/fold_$i/classification_error.txt | xargs -I '{}' cp '{}' $IMAGEBASEDIR/fold_${i}/wrong
    sed 's/\.\./\./' $BASEDIR/fold_$i/classification_correct.txt | xargs -I '{}' cp '{}' $IMAGEBASEDIR/fold_${i}/correct

done

