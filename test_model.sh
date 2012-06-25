#!/bin/bash

# Usage: sh test_model.sh <model path> <test data> <output path>

DIR=$1

FILES=$(find $DIR -type f | sort -n -t . -k 3)
COUNT=0
for f in $FILES  # model files
do
    echo $f
    if [[ "$f" =~ .*[0-9]\.model ]]
    then
        FILENUM=$(echo "$f" | sed 's/.*\.\([0-9]*\)\.model/\1/')
        echo $FILENUM
        ./libsvm-3.12/svm-predict $2 $f $2.output.$FILENUM  
        mv $2.output.$FILENUM $3/.
        COUNT=$(($COUNT+1))
    fi
done

