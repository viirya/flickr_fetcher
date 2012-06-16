
import sys
import argparse
import re
import os

from numpy import array, zeros, mean, std, sort, add, subtract, divide, dot, sqrt
from numpy import linalg as la
from scipy.cluster.vq import vq, kmeans, whiten


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

def load_list(filename):
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

def validate(distance, query, groundtruth):

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
            if photo_id in groundtruth:
                hit = hit + 1
                query_ap += (hit / count)
            count = count + 1
        if hit > 0:
            query_ap = query_ap / hit
        ap[query_photo] = query_ap
        map_value += query_ap

    map_value /= query.size

    return (ap, map_value)

def write_out_vlad_matrix(photos, filename):

    f = open(filename, 'w')
 
    for photo_id, feature in photos.iteritems():
        f.write(photo_id + "\t")
        feature.tofile(f, sep = " ")
        f.write("\n")

    f.close() 

def write_out_distance(distance, filename):

    f = open(filename, 'w')
    for photo_from_id, dist_vec in distance.iteritems():
        for (photo_to_id, dist) in dist_vec:
            f.write(photo_from_id + "\t" + photo_to_id + "\t" + str(dist) + "\n")
    f.close()

 
def write_file(vlad, filename):

    f = open(filename, 'w')
    for vec in vlad:
        vec.tofile(f, sep = " ")
        f.write("\n")
    f.close()

