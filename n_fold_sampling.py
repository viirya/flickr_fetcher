
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils

def main():
    parser = argparse.ArgumentParser(description = 'Generating n-fold cross validation sample file.')
    parser.add_argument('-p', help = 'The CSV summary file for positive samples.')
    parser.add_argument('-n', help = 'The CSV summary file for negative samples.')
    parser.add_argument('-f', help = 'The number of folds.')
    parser.add_argument('-o', help = 'The output path.')

    args = parser.parse_args()
    output = read_data(args)


def filter_content(part_of_data):

    content = []
    for line in part_of_data:
        line_fields = line.rsplit(',')
        if (len(line_fields) == 1):
            line_fields = line.rsplit("\t")

        content.append(line_fields[0])
 

    return content

def read_file(filename, n_fold):
 
    data_sources = []
    parts = []
    
    part_of_data = utils.load_file(filename)
    part_of_data = part_of_data[1:len(part_of_data)]
    part_of_data = filter_content(part_of_data)
        
    parts.append(part_of_data)
    
    parts = [item for sublist in parts for item in sublist]
    data_sources = array(parts)

    random.shuffle(data_sources)

    data_count_limit = len(data_sources) / n_fold
    folds = []
    count = 0
    for begin_index in range(0, len(data_sources), data_count_limit):
        end_index = begin_index + data_count_limit

        if (count == n_fold - 1):
            end_index = len(data_sources)

        print("begin: " + str(begin_index))
        print("end: " + str(end_index))

        folds.append(data_sources[begin_index:end_index])

        count += 1

    return folds


def read_data(args):

    n_fold = 0
    if (args.f != None):
        n_fold = int(args.f)
    else:
        print("The number of folds can not be zero.")
        sys.exit(0)

    pos_folds = []
    if (args.p != None):
        pos_folds = read_file(args.p, n_fold)

    neg_folds = []    
    if (args.n != None):
        neg_folds = read_file(args.n, n_fold)

    if (len(pos_folds) != 0 and len(neg_folds) != 0):
        for fold_test_index in range(0, n_fold):
 
            filename = "fold_" + str(fold_test_index + 1) + "_test_"
            utils.write_file(pos_folds[fold_test_index], args.o + "/" + filename + "postive.txt") 
            utils.write_file(neg_folds[fold_test_index], args.o + "/" + filename + "negative.txt") 
 
            pos_train_folds = []
            neg_train_folds = []

            for fold_index in range(0, n_fold):

                if (fold_index != fold_test_index):
                    pos_train_folds.append(pos_folds[fold_index])
                    neg_train_folds.append(neg_folds[fold_index])

            pos_train_folds = [item for sublist in pos_train_folds for item in sublist]
            neg_train_folds = [item for sublist in neg_train_folds for item in sublist]

            filename = "fold_" + str(fold_test_index + 1) + "_train_"
            utils.write_file(pos_train_folds, args.o + "/" + filename + "postive.txt") 
            utils.write_file(neg_train_folds, args.o + "/" + filename + "negative.txt") 
            


if __name__ == "__main__":
    main()

