
import sys
import argparse
import re

from numpy import array, random

import utils
import mtk_utils

def main():
    parser = argparse.ArgumentParser(description = 'Assign qualification to specific worker or workers of specific HIT.')
    parser.add_argument('-w', help = 'The Turk worker id.')
    parser.add_argument('-d', help = 'The HIT id')
    parser.add_argument('-q', help = 'The qualification id.')
    parser.add_argument('-t', default = 'sandbox', help = 'The type of Mechanical Turk.')
    parser.add_argument('-s', default = 'Approved', help = 'The status of assignments.')

    args = parser.parse_args()

    workers = []
    if (args.w != None):
        workers.append(args.w)
    elif (args.d != None):
        workers = mtk_utils.get_workers(args.t, args.d, args.s)
    else:
        print('Please give Turk worker id and qualification id.')

    assign_qua(args.t, args.q, workers)

    sys.exit(0)


def assign_qua(mtc_type, args_qua__id, workers):

    mtc = mtk_utils.get_mtc(mtc_type) 

    for worker in workers:
        mtc.assign_qualification(qualification_type_id = args_qua__id, worker_id = worker)
 

if __name__ == "__main__":
    main()

