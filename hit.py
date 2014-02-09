
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils
import mongodb_config

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

    return [flickr_high_interesting_2011, flickr_low_interesting_2011, pinterest_20120708, pinterest_20120709, pinterest_20120710]

 
def regex_datasource(data_sources):

    data_labels = []
    data_ids = []
    for data in data_sources:
        m = re.search('.*\/(.*?)\/(.*?)\.(.*)', data)
        if (m != None):
            data_labels.append(m.group(1))
            data_ids.append(m.group(2))

    return [data_labels, data_ids]


