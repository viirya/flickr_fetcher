
import sys
import argparse
import re
import pymongo

from numpy import array, random

import utils
import hit
import mongodb_config

def main():
    parser = argparse.ArgumentParser(description = 'Analyze HIT results submitted by Amazon Mechnical Turk workers.')
    parser.add_argument('-f', help = 'The mtk data source file.')
    parser.add_argument('-d', help = 'The image path')

    args = parser.parse_args()

    if (args.f != None):
        file_urls = utils.load_file(args.f)

        data_metainfo = hit.regex_datasource(file_urls)

        # data_labels: flickr high interesting 1, flickr low interesting 2, pinterest [3, 4, 5]
        data_labels = data_metainfo[0]
        # data_ids: (flickr, pinterest) image id
        data_ids = data_metainfo[1]

        count = 0
        for url in file_urls:
            utils.crawl_image_from_url(url, args.d + '/' + data_ids[count] + '.jpg')
            count += 1

if __name__ == "__main__":
    main()

