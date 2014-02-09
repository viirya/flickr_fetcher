
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils

def main():
    parser = argparse.ArgumentParser(description = 'Filtering HIT result summary file.')
    parser.add_argument('-f', help = 'The CSV summary file.')
    parser.add_argument('-e', help = 'The flag to keep common header of files.')
    parser.add_argument('-t', help = 'The comparing field index and threshold separated by a comma.')
    parser.add_argument('-o', help = 'The output file.')

    args = parser.parse_args()
    output = read_data(args)

    if (args.o != None):
        utils.write_file(output, args.o)


def filter_content(part_of_data, operator, comparing_field_index, threshold):

    content = []
    for line in part_of_data:
        line_fields = line.rsplit(',')
        if (len(line_fields) == 1):
            line_fields = line.rsplit("\t")

        if (operator == 'more'):
            if (int(line_fields[int(comparing_field_index)]) > int(threshold)):
                content.append(line)
        elif (operator == 'less'):
            if (int(line_fields[int(comparing_field_index)]) < int(threshold)):
                content.append(line)
 

    return content


def read_data(args):

    [operator, comparing_field_index, threshold] = args.t.rsplit(',')

    data_sources = []
    header = ''
    if (args.f != None):

        parts = []
        afile = args.f

        part_of_data = utils.load_file(afile)
        
        if args.e != None and args.e == 'y':
            if header == '':
                header = part_of_data[0]
            part_of_data = part_of_data[1:len(part_of_data)]
        
        
        part_of_data = filter_content(part_of_data, operator, comparing_field_index, threshold)
            
        parts.append(part_of_data)
        
        parts = [item for sublist in parts for item in sublist]
        data_sources = array(parts)

    output = []
    if header != '':
        output.append(header)
    for item in data_sources:
        output.append(item)

    return output


if __name__ == "__main__":
    main()

