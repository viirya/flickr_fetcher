
import sys
import argparse
import re
import os

from numpy import array, zeros, mean, std, sort, add, subtract, divide, dot, sqrt
from numpy import linalg as la
from scipy.cluster.vq import vq, kmeans, whiten


parser = argparse.ArgumentParser(description = 'K-means clustering util for image feature processing.')
parser.add_argument('-d', help = 'The directory of vlad feature files.')
parser.add_argument('-q', help = 'The filename of query photo id list.')
parser.add_argument('-o', help = 'The output file.')
#parser.add_argument('-c', help = 'The codebook of visual words.')
#parser.add_argument('-n', help = 'The codebook meta info.')
 
 
args = parser.parse_args()


def list_files(dirname):

    photos = {}
    filelist = os.listdir(dirname)
    for filename in filelist:

        file_id = ''
        m = re.search('(.*?)\..*', filename)
        if (m != None):
            file_id = m.group(1)

        #print("Reading " + filename)
        f = open(dirname + '/' + filename, 'r')
        content = []
        for line in f:
            vec = map(float, line.split())
            content.append(vec)
        content = array(content).flatten()
        photos[file_id] = content
        f.close() 

    return photos

def load_query(filename):
    f = open(filename, 'r')
    content = []
    for line in f:
        content.append(line.rstrip())

    f.close()

    return array(content)

def do_query(photos, query):

    distance = {}

    for query_photo in query:
        if query_photo in photos:
            print("Querying with " + query_photo)
            query_feature = photos[query_photo]
            distance_for_query = []
            for photo_id, feature in photos.iteritems():
                if photo_id != query_photo:
                    dist = la.norm(subtract(query_feature, feature))
                    distance_for_query.append((photo_id, dist))

            distance_for_query = array(distance_for_query, dtype = [('id', 'S20'), ('distance', float)])
            distance_for_query.sort(order = 'distance')
            distance[query_photo] = distance_for_query

                                
    return distance

def validate(distance, query):

    ap = {}
    map_value = 0.0
    for query_photo in query:
        dist_vec = distance[query_photo]

        count = 1.0
        hit = 0.0
        query_ap = 0.0
        for (photo_id, dist) in dist_vec:
            if count > 10:
                break
            if photo_id in query:
                hit = hit + 1
                query_ap += (hit / count)
            count = count + 1
        if hit > 0:
            query_ap = query_ap / hit
        ap[query_photo] = query_ap
        map_value += query_ap

    map_value /= query.size

    return (ap, map_value)

 
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
        vlad[codes[idx]] = add(diff, vlad[codes[idx]])


    return vlad

def write_file(vlad, filename):

    f = open(filename, 'w')
    for vec in vlad:
        vec.tofile(f, sep = " ")
        f.write("\n")
    f.close()


photos = list_files(args.d)
query = load_query(args.q)
dist = do_query(photos, query)
(ap, map_value) = validate(dist, query)
print("AP: ")
print(ap)
print("MAP: ")
print(map_value)

