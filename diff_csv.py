
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils

def main():
    parser = argparse.ArgumentParser(description = 'Diff two csv files.')
    parser.add_argument('-p', help = 'First CSV summary file.')
    parser.add_argument('-n', help = 'Second CSV summary file.')

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

def read_file(filename):
 
    data_sources = []
    parts = []
    
    part_of_data = utils.load_file(filename)
    part_of_data = part_of_data[1:len(part_of_data)]
    part_of_data = filter_content(part_of_data)
        
    parts.append(part_of_data)
    
    parts = [item for sublist in parts for item in sublist]

    dictionary = {}
    for item in parts:
        dictionary[item] = 1
    
    return dictionary


def read_data(args):

    content_first_part = {}
    if (args.p != None):
        content_first_part = read_file(args.p)

    content_second_parts = {}    
    if (args.n != None):
        content_second_parts = read_file(args.n)

    print("Diff\n")
    for key in content_first_part.keys():
        if (key not in content_second_parts):
            print(key)    



if __name__ == "__main__":
    main()

