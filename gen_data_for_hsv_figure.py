
import sys
import argparse
import re
import pymongo
import colorsys

from numpy import array, random, mean

import utils

def main():
    parser = argparse.ArgumentParser(description = 'Reading hsv model data and generating data for hsv figure.')
    parser.add_argument('-f', help = 'The CSV hsv file.')
    parser.add_argument('-x', default = '1', help = 'The x-axis column')
    parser.add_argument('-y', default = '2', help = 'The y-axis column, i.e hue column.')
    parser.add_argument('-t', help = 'The threshold of mean hue.')
    parser.add_argument('-b', default = '100', help = 'The length of bin.')
    parser.add_argument('-d', default = '-1', help = 'The threshold of x-axis.')
    parser.add_argument('-o', help = 'The output file.')

    args = parser.parse_args()
    output = read_data(args)

    if (args.o != None):
        utils.write_file(output, args.o)


def calculat_hsv_figure(part_of_data, x_column, y_column, bin_length, threshold, x_threshold):

    content = []
    table = {} 
    table_for_all = {}
    for line in part_of_data:
        line_fields = line.rsplit(',')
        if (len(line_fields) == 1):
            line_fields = line.rsplit("\t")

        x_value = int(line_fields[x_column])
        y_value = float(line_fields[y_column])

        if (x_threshold > 0 and x_value > x_threshold):
            x_value = x_threshold 

        if (y_value > threshold):
            if ((x_value / bin_length) in table):
                table[x_value / bin_length] += 1
            else:
                table[x_value / bin_length] = 1

        if ((x_value / bin_length) in table_for_all):
            table_for_all[x_value / bin_length] += 1
        else:
            table_for_all[x_value / bin_length] = 1
 
    #content.append(",".join(line_fields))

    print(table)
    print(table_for_all)

    for k in sorted(table_for_all.keys()):
        if k in table:
            aline = str(bin_length * k) + "\t" + str(float(table[k]) / table_for_all[k])  
            content.append(aline)
        else:
            content.append(str(bin_length * k) + "\t" + "0.0")

    return content


def read_data(args):

    x_column = int(args.x)
    y_column = int(args.y)
    bin_length = int(args.b)
    threshold = float(args.t)
    x_threshold = int(args.d)

    data_sources = []
    if (args.f != None):

        parts = []
        afile = args.f

        part_of_data = utils.load_file(afile)
        part_of_data = calculat_hsv_figure(part_of_data, x_column, y_column, bin_length, threshold, x_threshold)
            
        parts.append(part_of_data)
        
        parts = [item for sublist in parts for item in sublist]
        data_sources = array(parts)

    output = []
    for item in data_sources:
        output.append(item)

    return output


if __name__ == "__main__":
    main()

