
import sys
import argparse
import re

from numpy import array, random

import utils
import mtk_utils

def main():
    parser = argparse.ArgumentParser(description = 'Obtain Turl workers for specific HIT.')
    parser.add_argument('-d', help = 'The HIT id.')
    parser.add_argument('-s', default = 'Approved', help = 'The status of assignments.')
    parser.add_argument('-t', default = 'sandbox', help = 'The type of Mechanical Turk.')

    args = parser.parse_args()
    if (args.d != None):
        workers = mtk_utils.get_workers(args.t, args.d, args.s)
        for worker in workers:
            print(worker)
    else:
        print('Please assign HIT id.')

    sys.exit(0)

if __name__ == "__main__":
    main()

