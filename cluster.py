
import sys
import argparse

from numpy import array, zeros, mean, std, subtract, divide
from scipy.cluster.vq import vq, kmeans, whiten


parser = argparse.ArgumentParser(description = 'K-means clustering util for image feature processing.')
parser.add_argument('-f', help = 'The file of observations (image features).')
parser.add_argument('-n', default = 'y', help = 'The flag for normailzation.')
parser.add_argument('-o', help = 'The output file.')
parser.add_argument('-k', help = 'The number of clusters.')
 
 

args = parser.parse_args()

def load_features(filename):
    f = open(filename, 'r')
    content = []
    for line in f:
        content.append(map(float, line.split()))

    f.close()

    return array(content)

def normalize(output_filename, features):


    mean_vec = mean(features, axis = 0)
    std_vec = std(features, axis = 0)

    f = open(output_filename + ".meta", 'w')
    mean_vec.tofile(f, sep = " ")
    f.write("\n")
    std_vec.tofile(f, sep = " ")
    f.close()

    norm_array = []
    for vec in features:
        diff = subtract(vec, mean_vec)
        norm_vec = divide(diff, std_vec)
        norm_array.append(norm_vec)
    

    return array(norm_array)


def cluster(features, k, output_filename):

    centroids = kmeans(features, k)
    f = open(output_filename, 'w')
    centroids.tofile(f, sep = " ")
    f.close()

    return centroids

 
features = load_features(args.f)
features = normalize(args.o, features)
centroids = cluster(features, args.k, args.o)

