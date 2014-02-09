#!/bin/bash

# Usage: sh crawl_n_fold_images.sh <n-fold file path> <output path>

DIR=$1
OUTPUTBASE=$2
FILES=$(find $DIR -type f | sort -n -t . -k 3)
COUNT=0
for f in $FILES  # fold files
do
    echo $f
    if [[ "$f" =~ fold_[0-9]*_.*\.txt ]]
    then
        FILETITLE=$(echo "$f" | sed 's/.*\/\(.*\)\.txt/\1/')

        OUTPATH=$OUTPUTBASE/$FILETITLE/images
        mkdir -p $OUTPATH
        python crawl_images.py -f $f -d $OUTPATH
        COUNT=$(($COUNT+1))
    fi
done

