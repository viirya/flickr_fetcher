
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils

def main():
    parser = argparse.ArgumentParser(description = 'Aggregating multiple files into a sinagle file.')
    parser.add_argument('-f', action = 'append', help = 'The CSV files.')
    parser.add_argument('-e', help = 'The flag to keep common header of files.')
    parser.add_argument('-s', help = 'The flag to pad a space line between the content of files')
    parser.add_argument('-o', help = 'The output file.')

    args = parser.parse_args()
    output = read_data(args)

    if (args.o != None):
        utils.write_file(output, args.o)


def read_data(args):

    data_sources = []
    header = ''
    if (args.f != None):
        if not isinstance(args.f, basestring):
            parts = []
            for afile in args.f:
                part_of_data = utils.load_file(afile)

                if args.e != None and args.e == 'y':
                    if header == '':
                        header = part_of_data[0]
                    part_of_data = part_of_data[1:len(part_of_data)]
                    
                parts.append(part_of_data.tolist())
                if args.s != None and args.s == 'y':
                    parts.append("\n")

            parts = [item for sublist in parts for item in sublist]
            data_sources = array(parts)
        else:
            data_sources = utils.load_file(args.f)


    output = []
    if header != '':
        output.append(header)
    for item in data_sources:
        output.append(item)

    return output


if __name__ == "__main__":
    main()

