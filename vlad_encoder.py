
import sys
import argparse
import re

from numpy import array, zeros, mean, std, add, subtract, divide, dot, sqrt
from scipy.cluster.vq import vq, kmeans, whiten


parser = argparse.ArgumentParser(description = 'K-means clustering util for image feature processing.')
parser.add_argument('-f', help = 'The file of observations (image features).')
parser.add_argument('-o', help = 'The output file.')
parser.add_argument('-c', help = 'The codebook of visual words.')
parser.add_argument('-n', help = 'The codebook meta info.')
 
 

args = parser.parse_args()

def load_meta(filename):
    f = open(filename, 'r')
    content = []
    for line in f:
        vec = map(float, line.split())
        content.append(vec)

    f.close()

    return (array(content[0]), array(content[1])) # return (meta, std)

def load_codebook(filename):
    f = open(filename, 'r')
    content = []
    for line in f:
        vec = map(float, line.split())
        content.append(vec)

    f.close()

    return array(content)

def load_features(filename):
    f = open(filename, 'r')
    content = []
    for line in f:
        m = re.search('(.*?)\s(.*?)\s(.*?)\s(.*?)\s(.*?)\s(.*)', line)
        if (m != None):
            vec = map(float, m.group(6).split())
            norm_vec = sqrt(dot(vec, vec)) 
            content.append(divide(vec, norm_vec))

    f.close()

    return array(content)

def normalize(features, mean_vec, std_vec):

    norm_array = []
    for vec in features:
        diff = subtract(vec, mean_vec)
        norm_vec = divide(diff, std_vec)
        norm_array.append(norm_vec)

    return array(norm_array)


def vlad_encoding(features, codebook):

    (codes, dist) = vq(features, codebook)
   
    vlad = zeros(codebook.shape)
    for idx in range(codes.size):
        diff = subtract(features[idx], codebook[codes[idx]])
        vlad[codes[idx]] = add(diff, codes[idx])


    return vlad

def write_file(vlad, filename):

    f = open(filename, 'w')
    for vec in vlad:
        vec.tofile(f, sep = " ")
        f.write("\n")
    f.close()


(mean, std) = load_meta(args.n)
codebook = load_codebook(args.c)
features = load_features(args.f)
features = normalize(features, mean, std)
vlad = vlad_encoding(features, codebook)
write_file(vlad, args.o)

