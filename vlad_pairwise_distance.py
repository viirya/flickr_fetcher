
import sys
import argparse
import re
import os

from numpy import array, zeros, mean, std, sort, add, subtract, divide, dot, sqrt
from numpy import linalg as la
from scipy.cluster.vq import vq, kmeans, whiten

import vlad

parser = argparse.ArgumentParser(description = 'K-means clustering util for image feature processing.')
parser.add_argument('-d', help = 'The directory of vlad feature files.')
parser.add_argument('-o', help = 'The output file.')
 
args = parser.parse_args()


photos = vlad.list_files(args.d)
dist = vlad.do_query(photos, photos.keys())
vlad.write_out_distance(dist, args.o)

