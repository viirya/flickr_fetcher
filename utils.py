
import sys
import argparse
import re
import os

from numpy import array, zeros, mean, std, sort, add, subtract, divide, dot, sqrt, arange, random
from numpy import linalg as la
from scipy.cluster.vq import vq, kmeans, whiten


def get_files_in_dir(dirname, random_flag = False):

    files = []
    fullpath_files = []
    filelist = os.listdir(dirname)
    for filename in filelist:

        full_filename = dirname + '/' + filename
        files.append(filename)
        fullpath_files.append(full_filename)

    if random_flag == True:
        random.shuffle(files)
        random.shuffle(fullpath_files)

    return (array(files), array(fullpath_files))


