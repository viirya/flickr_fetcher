
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils
import mongodb_config

def main():
    parser = argparse.ArgumentParser(description = 'Analyze HIT results submitted by Amazon Mechnical Turk workers.')
    parser.add_argument('-f', action = 'append', help = 'The mtk data source file.')
    parser.add_argument('-o', help = 'The output file of used data.')

    args = parser.parse_args()

    (header, data) = load_multi_data(args)

    if (args.o != None):
        output_comparator_file(header, data, args.o)

def output_comparator_file(header, data, filename):

    output = []

    output.append(', '.join(header))

    for map_key, content in data.iteritems():
        output.append(map_key + ', ' + ', '.join(content))

    utils.write_file(output, filename)
 


def load_multi_data(args):

    header = []
    data = {}
    if (args.f != None):
        if not isinstance(args.f, basestring):

            for afile in args.f:
                file_lines = utils.load_file(afile)
                
                count = 0
                for line in file_lines:
                    org_line = line
                    line = line.rsplit(',')
                    if (len(line) <= 1):
                        line = org_line.rsplit("\t")

                    if (count == 0):
                        if (len(header) > 0):
                            header.append(', '.join(line[1:len(line)]))
                        else:
                            header.append(', '.join(line))
 
                        count = count + 1
                        continue

                    if (line[0] not in data):
                        data[line[0]] = []

                    data[line[0]].append(', '.join(line[1:len(line)]))

    return (header, data)
                                        

if __name__ == "__main__":
    main()


