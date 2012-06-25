
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
parser.add_argument('-c', help = 'The apc clustering result file.')
parser.add_argument('-o', help = 'The output file.')
parser.add_argument('-t', help = 'The threshold for cluster size, optionally.')
 
args = parser.parse_args()


photos = vlad.list_files(args.d)
clusters = vlad.load_clustering(args.c)
for idx, cluster in enumerate(clusters):
    if args.t == None or len(cluster['member']) >= int(args.t): 
        vlad.write_out_vlad_matrix_libsvm_format(photos, args.o + ".cluster." + str(idx), cluster)

