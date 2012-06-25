#!/bin/bash

# Usage: sh create_dataset.sh <dataset path> <dataset name>

DIR=$1
DATASET=$2

mkdir $DIR/$DATASET
mkdir $DIR/$DATASET/images
mkdir $DIR/$DATASET/features
mkdir $DIR/$DATASET/tmp
mkdir $DIR/$DATASET/apc
mkdir $DIR/$DATASET/matrix
mkdir $DIR/$DATASET/vlad
mkdir $DIR/$DATASET/classification
 
