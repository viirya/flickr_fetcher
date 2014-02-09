
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils
import mongodb_config

def main():
    parser = argparse.ArgumentParser(description = 'Analyze HIT results submitted by Amazon Mechnical Turk workers.')
    parser.add_argument('-f', help = 'The mtk data source file.')
    parser.add_argument('-m', help = 'The MTurk HIT result file.')
    parser.add_argument('-o', help = 'The output file of used data.')
    parser.add_argument('-s', help = 'The summary output file.')
    parser.add_argument('-t', help = 'The data type.')
    parser.add_argument('-r', help = 'The times of random splits.')
    parser.add_argument('-d', help = 'The output path.')

    args = parser.parse_args()

    output_prefix = ''
    output_postfix = ''

    if (args.m != None):
        m = re.search('(.*)\/(.*)', args.m)
        if (m != None):
            output_prefix = m.group(1)
            output_postfix = m.group(2)

    if (args.d != None):
        output_prefix = args.d

    if (args.o == None):
        args.o = output_prefix + "/mtk_label_" + output_postfix

    if (args.s == None):
        args.s = output_prefix + "/mtk_label_summary_" + output_postfix

    db_collections = setup_mongodb()

    data_sources = []
    if (args.f != None):
        data_sources = utils.load_file(args.f)

    hits = []
    if (args.m != None):
        hits = utils.load_file(args.m)
        hits = hits[1:len(hits)]

    #print(data_sources)
    #print(hits)

    data_metainfo = regex_datasource(data_sources)

    # data_labels: flickr high interesting 1, flickr low interesting 2, pinterest [3, 4, 5]
    data_labels = data_metainfo[0]
    # data_ids: (flickr, pinterest) image id
    data_ids = data_metainfo[1]

    images_metainfo = query_imagedata_from_db(db_collections, data_metainfo)

    data_type = None
    if (args.t != None):
        args.s = args.s + ".type." + args.t
        data_type = args.t.rsplit(',')

    if (args.r == None):
        print_hit_with_data_labels(hits, data_labels, args.o)
        print_summary(data_sources, hits, data_labels, data_ids, images_metainfo, data_type, args.s)
    else:
        output = []
        for iter_i in range(0, int(args.r)):
            random.shuffle(hits) 
            part1 = hits[:len(hits) / 2]
            part2 = hits[len(hits) / 2:]
 
            part_output = print_summary(data_sources, part1, data_labels, data_ids, images_metainfo, data_type, None)

            if len(output) == 0:
                output.append(part_output)
            else:
                output.append(part_output[1:len(part_output)])

            output.append("\n")
            part_output = print_summary(data_sources, part2, data_labels, data_ids, images_metainfo, data_type, None) 
            output.append(part_output[1:len(part_output)])
            output.append("\n")
            output.append("\n")
  

        output = [item for sublist in output for item in sublist]
        if (args.s != None):
            utils.write_file(output, args.s)

 
def query_imagedata_from_db(db_collections, data_metainfo):

    data_labels = data_metainfo[0]
    data_ids = data_metainfo[1]

    data_ids_by_label = {}
    count = 0
    for label in data_labels:
        if not label in data_ids_by_label:
            data_ids_by_label[label] = []

        data_ids_by_label[label].append(data_ids[count])
        count += 1


    images = {}

    for label, ids in data_ids_by_label.iteritems():
        col = db_collections[int(label) - 1]
        field = 'id'

        if (int(label) > 2):
            field = 'pin_id'

        for image in col.find({field: {'$in': ids } }):
            images[image[field]] = image

    return images    


def setup_mongodb():

    connection = pymongo.Connection(mongodb_config.HOST)

    db = connection['flickr_geo']

    flickr_high_interesting_2011 = db['high_interestingness_2011']
    flickr_low_interesting_2011 = db['low_interestingness_2011']

    pinterest_20120708 = db['pinterest_20120708']
    pinterest_20120709 = db['pinterest_20120709']
    pinterest_20120710 = db['pinterest_20120710']
    pinterest_20121012 = db['pinterest_20121012']
    pinterest_20121013 = db['pinterest_20121013']
    pinterest_20121014 = db['pinterest_20121014']
    pinterest_20121015 = db['pinterest_20121015']
 
    return [flickr_high_interesting_2011, flickr_low_interesting_2011, pinterest_20120708, pinterest_20120709, pinterest_20120710, pinterest_20121012, pinterest_20121013, pinterest_20121014, pinterest_20121015]

 
def print_summary(data_sources, hits, data_labels, data_ids, images_metainfo, data_type, filename):


    output = []

    positive_labels = []
    for label in data_labels:
        if label == '2':
            positive_labels.append('N')
        else:
            positive_labels.append('P')

    labels = ', '.join(positive_labels)

    print(labels + ' : ' + str(len(positive_labels)))

    interesting_labels = {}
    for hit in hits:
        org_hit = hit
        hit = hit.rsplit(',')
        if (len(hit) <= 1):
            hit = org_hit.rsplit("\t")

        hit = hit[8:len(hit)]

        index = 0
        for hit_item in hit:
            
            if hit_item == '':
                continue

            if index not in interesting_labels:
                interesting_labels[index] = {'P': 0, 'N': 0, 'NN': 0}
 
            if int(hit_item) > 0:
                interesting_labels[index]['P'] += 1
            elif int(hit_item) < 0:
                interesting_labels[index]['N'] += 1
            else:
                interesting_labels[index]['NN'] += 1

            index += 1

    interestingness = {}
    index = 0
    for image_id in data_ids:
        image = images_metainfo[image_id]
        # print("index: " + str(index))
        if (not 'repin_count' in image):
            #print(image)
            #print(image['interestingness'])
            interestingness[index] = int(image['interestingness'])
        else:
            #print(image)
            #print(int(image['repin_count']) + int(image['like_count']))
            interestingness[index] = int(image['repin_count']) + int(image['like_count'])
        index += 1

    print(interestingness)
    print('len : ' + str(len(interestingness)))

    output.append("image,ground_truth,interesting,not interesting,neutral,interestingness")
    index = 0
    for label in positive_labels:
        if (data_type == None or data_labels[index] in data_type):
            output.append(data_sources[index] + ',' + label + ',' + str(interesting_labels[index]['P']) + ',' + str(interesting_labels[index]['N']) + ',' + str(interesting_labels[index]['NN']) + ',' + str(interestingness[index]))
        index += 1

    if (filename != None):
        utils.write_file(output, filename)

    return output
 
def print_hit_with_data_labels(hits, data_labels, filename):


    output = []

    print("data label: #" + str(len(data_labels)))

    labels = ', '.join(data_labels)

    print(labels)

    output.append(labels)

    for hit in hits:
        org_hit = hit
        hit = hit.rsplit(',')
        if (len(hit) <= 1):
            hit = org_hit.rsplit("\t")
        hit = hit[8:len(hit)]
        print("hit row: #" + str(len(hit)))
        hit_row = ', '.join(hit)
        print(hit_row)
        output.append(hit_row)

    if (filename != None):
        utils.write_file(output, filename)


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


