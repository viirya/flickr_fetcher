
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils

def main():
    parser = argparse.ArgumentParser(description = 'Exporting data matrix from HIT summary result.')
    parser.add_argument('-f', action = 'append', help = 'The CSV files.')
    parser.add_argument('-c', help = 'The exporting columns separated with comma.')
    parser.add_argument('-o', help = 'The output file.')
    parser.add_argument('-t', help = 'The types used to filter out data row.')
    parser.add_argument('-p', default = '0', help = 'The padding for filtered rows.')
    parser.add_argument('-d', help = 'The data source file.')

    args = parser.parse_args()

    data_sources = []
    data_labels = []
    data_ids = []
    if (args.d != None):
        data_sources = utils.load_file(args.d)

        data_metainfo = regex_datasource(data_sources)

        # data_labels: flickr high interesting 1, flickr low interesting 2, pinterest [3, 4, 5]
        data_labels = data_metainfo[0]
        # data_ids: (flickr, pinterest) image id
        data_ids = data_metainfo[1]

    output = read_data(args, data_sources, data_labels)

    if (args.o != None):
        utils.write_file(output, args.o)

def read_file(afile, fields, filters, data_sources, data_labels, padding = None):

    part_of_data = utils.load_file(afile)
    part_of_data = part_of_data[1:len(part_of_data)]

    content = {}
    count = 0
    for line in part_of_data:
        line_fields = line.rsplit(',')
        if (len(line_fields) == 1):
            line_fields = line.rsplit("\t")

        selected_line = ''

        if (len(filters) == 0 or data_labels[count] in filters):
            selected_line = [line_fields[int(index)] for index in fields]
        else:
            if padding != None:
                selected_line = padding
            else:
                selected_line = ['0' for index in fields]

        #content.append(','.join(selected_line))
        content[line_fields[0]] = ','.join(selected_line)

        count += 1

    output_content = []
    for item in data_sources:
        if (item in content):
            output_content.append(content[item]) 
        else:
            print("key " + item + " is not in input file.")
        
    return "\n".join(output_content)
 

def read_data(args, data_sources, data_labels):

    fields = args.c.rsplit(',')

    filters = []
    if (args.t != None):
        filters = args.t.rsplit(',')

    output = []
    if (args.f != None):
        if not isinstance(args.f, basestring):
            parts = []
            for afile in args.f:
                part_of_data = read_file(afile, fields, filters, data_sources, data_labels, args.p.rsplit(','))
                output.append(part_of_data)
        else:
            output.append(read_file(args.f, fields, filters, data_sources, data_labels))

    return output


def regex_datasource(data_sources):

    data_labels = []
    data_ids = []
    for data in data_sources:
        m = re.search('.*\/(.*?)\/(.*?)\.(.*)', data)
        if (m != None):
            data_labels.append(m.group(1))
            data_ids.append(m.group(2))

    return [data_labels, data_ids]


if __name__ == "__main__":
    main()

