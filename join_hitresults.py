
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils
import mongodb_config

def main():
    parser = argparse.ArgumentParser(description = 'Analyze HIT results submitted by Amazon Mechnical Turk workers.')
    parser.add_argument('-m', action = 'append', help = 'The MTurk HIT result file.')
    parser.add_argument('-o', help = 'The output file of used data.')
    parser.add_argument('-f', default = 'hit', help = 'The output file format {hit, r}.')
    parser.add_argument('-r', default = 'n', help = 'The flag of row header.')

    args = parser.parse_args()

    all_hits = []
    if (args.m != None):
        hits = []
        if not isinstance(args.m, basestring):
            for afile in args.m:
                all_hits = add_hits(afile, all_hits)
        else:
            all_hits = add_hits(args.m, all_hits)

    print(all_hits)


    if (args.f == 'hit'):
        print_all_hits(all_hits, args.o)
    else:
        output = print_all_hits(all_hits, args.o, ' ', 8, False)
        if (args.r == 'y'):
            append_row_header(output, all_hits[0], args.o, 4)

    #print_hit_with_data_labels(hits, data_labels, args.o)
    #print_summary(data_sources, hits, data_labels, data_ids, images_metainfo, data_type, args.s)


def add_hits(filename, all_hits):

    hits = utils.load_file(filename)
    hits = hits[0:len(hits)]
    all_hits.append(hits)

    return all_hits

def reformat_hit(hit, sep = ',' , begin_index = 8):

    org_hit = hit
    hit = hit.rsplit(',')
    if (len(hit) <= 1):
        hit = org_hit.rsplit("\t")

    hit = hit[begin_index:len(hit)]
    hit_row = sep.join(hit)

    return (hit, hit_row, org_hit)

def append_row_header(output, hits, filename, field_index = 4):

    count = 0
    for line in output:

        (hit, hit_row, org_hit) = reformat_hit(hits[count + 1], ',', 0)
        header = hit[field_index]

        output[count] = header + "\t" + output[count]
        count += 1

    
    if (filename != None):
        utils.write_file(output, filename)


def print_all_hits(all_hits, filename, sep = ',', field_index = 0, with_header = True):

    output = []

    count = 0
    for hit in all_hits[0]:

        (first_hit, first_hit_row, org_first_hit) = reformat_hit(hit, sep, 0)

        for hits in all_hits[1:len(all_hits)]:
            for hit in hits[0:len(hits)]:
                (hit, hit_row, org_hit) = reformat_hit(hit, sep, 0)
                
                if (first_hit[4] == hit[4]):
                    (hit, hit_row, org_hit) = reformat_hit(org_hit, sep)

                    if (field_index != 0):
                        (first_hit, first_hit_row, org_first_hit) = reformat_hit(org_first_hit, sep, field_index)

                    if (first_hit[len(first_hit) - 1] == ''):
                        first_hit_row += hit_row
                    else:
                        first_hit_row += sep + hit_row

        if (count == 0 and with_header == False):
            count += 1
            continue

        output.append(first_hit_row)

    if (filename != None):
        utils.write_file(output, filename)

    return output

if __name__ == "__main__":
    main()


