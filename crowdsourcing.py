
import sys
import argparse
import re

from numpy import array, zeros, mean, std, add, subtract, divide, dot, sqrt
from scipy.cluster.vq import vq, kmeans, whiten

import utils

parser = argparse.ArgumentParser(description = 'Collect randomply sampling photos as dataset used for CrowdFlower.')
parser.add_argument('-d', help = 'The image data path.')
parser.add_argument('-o', help = 'The output file.')
parser.add_argument('-n', help = 'The number of sampled photos.')
parser.add_argument('-m', help = 'The output mode.')
parser.add_argument('-u', help = 'The URL prefix.')
 

args = parser.parse_args()

def write_file(filename, files, prefix, mode = 'a'):

    f = open(filename, mode)
    if mode == 'a':
        f.write("\n" + prefix)
    if mode == 'w':
        f.write(prefix)
    files.tofile(f, sep = "\n" + prefix)
    f.close()

(files, fullpath_files) = utils.get_files_in_dir(args.d, True)
if args.n != None:
    files = files[0:min(len(files), int(args.n))]
if args.m == None:
    args.m = 'a'
write_file(args.o, files, args.u, args.m)

