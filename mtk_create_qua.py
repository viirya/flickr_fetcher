
import sys
import argparse
import re

from numpy import array, random

import utils
import amazon_config

def main():
    parser = argparse.ArgumentParser(description = 'Create qualification.')
    parser.add_argument('-n', help = 'The name of qualification')
    parser.add_argument('-d', help = 'The description of qualification.')

    args = parser.parse_args()
    if (args.n != None and args.d != None):
        create_qua(args)
    else:
        print('Please assign qualification type name and description.')

    sys.exit(0)


def create_qua(args):

    from boto.mturk.connection import MTurkConnection
    from boto.mturk.question import QuestionContent, Question, QuestionForm, Overview, AnswerSpecification, SelectionAnswer, FormattedContent, FreeTextAnswer
    from boto.mturk.qualification import PercentAssignmentsApprovedRequirement, Qualifications
 
    ACCESS_ID = amazon_config.ACCESS_ID
    SECRET_KEY = amazon_config.SECRET_KEY
    HOST = 'mechanicalturk.sandbox.amazonaws.com'
 
    mtc = MTurkConnection(aws_access_key_id=ACCESS_ID,
                          aws_secret_access_key=SECRET_KEY,
                          host=HOST)
 
    mtc.create_qualification_type(name = args.n, description = args.d, status = 'Active')
 

if __name__ == "__main__":
    main()

