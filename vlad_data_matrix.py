
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
parser.add_argument('-s', help = 'The number of samples.')
parser.add_argument('-f', help = 'The output format.')
 
args = parser.parse_args()

photos = vlad.list_files(args.d)

if args.s == None:
    if args.f == None:
        vlad.write_out_vlad_matrix(photos, args.o)
    elif args.f == "libsvm":
        vlad.write_out_vlad_matrix_libsvm_format(photos, args.o)
else:
    sampled_sets = vlad.random_sample_photos(photos, int(args.s))
    for idx, photo_set in enumerate(sampled_sets):
        if args.f == None:    
            vlad.write_out_vlad_matrix(photo_set, args.o + "." + str(idx))
        elif args.f == "libsvm":
            vlad.write_out_vlad_matrix_libsvm_format(photo_set, args.o + "." + str(idx))
 



