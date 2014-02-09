
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils

def main():
    parser = argparse.ArgumentParser(description = 'Randomly split HIT results for analyzing consistency.')
    parser.add_argument('-f', action = 'append', help = 'The mtk data source files.')
    parser.add_argument('-m', action = 'append', help = 'The MTurk HIT result files.')
    parser.add_argument('-o', help = 'The output file of used data.')
    parser.add_argument('-s', help = 'The summary output file.')
    parser.add_argument('-t', help = 'The data type.')

    args = parser.parse_args()
    (data_sources, hits, head_of_hits) = read_data(args)


def read_data(args):

    data_sources = []
    if (args.f != None):
        if not isinstance(args.f, basestring):
            parts = []
            for afile in args.f:
                part_of_data = utils.load_file(afile)
                parts.append(part_of_data.tolist())

            parts = [item for sublist in parts for item in sublist]
            data_sources = array(parts)
        else:
            data_sources = utils.load_file(args.f)


    hits = []
    head_of_hits = ''
    if (args.m != None):
        if not isinstance(args.f, basestring):
            parts = []
            for afile in args.m:
                part_of_data = utils.load_file(afile)
                if head_of_hits == '':
                    head_of_hits = part_of_data[0]
                part_of_data = part_of_data[1:len(part_of_data)]
                parts.append(part_of_data.tolist())
 
            parts = [item for sublist in parts for item in sublist]
            hits = array(parts)
 
        else:
            hits = utils.load_file(args.m)
            hits = hits[0]
            hits = hits[1:len(hits)]

    return (data_sources, hits, head_of_hits)


if __name__ == "__main__":
    main()

