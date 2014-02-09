
import sys
import argparse
import re

from numpy import array, random

import utils
import amazon_config
 
def get_mtc(mtc_type = 'sandbox'):

    from boto.mturk.connection import MTurkConnection
    from boto.mturk.question import QuestionContent, Question, QuestionForm, Overview, AnswerSpecification, SelectionAnswer, FormattedContent, FreeTextAnswer
    from boto.mturk.qualification import PercentAssignmentsApprovedRequirement, Qualifications

 
    ACCESS_ID = amazon_config.ACCESS_ID
    SECRET_KEY = amazon_config.SECRET_KEY

    HOST = 'mechanicalturk.sandbox.amazonaws.com'

    if (mtc_type == 'normal'):
        HOST = 'mechanicalturk.amazonaws.com'

    mtc = MTurkConnection(aws_access_key_id=ACCESS_ID,
                          aws_secret_access_key=SECRET_KEY,
                          host=HOST)

    return mtc

def get_workers(mtc_type, hit_id, status):

    mtc = get_mtc(mtc_type)
    assignments = get_assignments(mtc, hit_id, status)

    workers = []
    for assignment in assignments:
        workers.append(assignment.WorkerId)

    return workers

def get_assignments(mtc, arg_hit_id, arg_status):

    assignments = mtc.get_assignments(hit_id = arg_hit_id, status = arg_status, page_size = 100, page_number = 1) 

    return assignments
 

