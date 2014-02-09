
import sys
import argparse
import re

from numpy import array, random

import utils
import amazon_config

def main():
    parser = argparse.ArgumentParser(description = 'Generate HITs for Amazon Mechnical Turk workers.')
    parser.add_argument('-f', help = 'The mtk data source file.')
    parser.add_argument('-o', help = 'The output file of used data.')

    args = parser.parse_args()

    data_sources = []
    if (args.f != None):
        data_sources = utils.load_file(args.f)
        random.shuffle(data_sources)

    generate_hits(data_sources, args)

    sys.exit(0)


def generate_hits(data_sources, args):

    from boto.mturk.connection import MTurkConnection
    from boto.mturk.question import QuestionContent, Question, QuestionForm, Overview, AnswerSpecification, SelectionAnswer, FormattedContent, FreeTextAnswer
    from boto.mturk.qualification import PercentAssignmentsApprovedRequirement, Qualifications
 
    ACCESS_ID = amazon_config.ACCESS_ID
    SECRET_KEY = amazon_config.SECRET_KEY
    HOST = 'mechanicalturk.sandbox.amazonaws.com'
 
    mtc = MTurkConnection(aws_access_key_id=ACCESS_ID,
                          aws_secret_access_key=SECRET_KEY,
                          host=HOST)
 
    title = 'Give your opinion of interestingness level about images'
    description = ('Watch images and give us your opinion of interestingness level about the images')
    keywords = 'image, interestingness, interesting, rating, opinions'
 
    ratings =[('Very boring','-2'),
             ('Boring','-1'),
             ('Neutral','0'),
             ('Interesting','1'),
             ('Very interesting, I would like to share it with my friends.','2')]
 
    #---------------  BUILD OVERVIEW -------------------
 
    overview = Overview()
    overview.append_field('Title', 'Give your opinion about interestingness level on those images')
 
    #---------------  BUILD QUESTIONs -------------------

    questions = []

    subset = data_sources[0:50]

    utils.write_file(subset, args.o)

    for image_url in subset:
     
        qc = QuestionContent()
        qc.append_field('Title','How interesting the image to you?')
        qc.append(FormattedContent('<img src="' + image_url + '" alt="image" />'))
        
        
        fta = SelectionAnswer(min=1, max=1,style='dropdown',
                              selections=ratings,
                              type='text',
                              other=False)
        
        q = Question(identifier='interestingness',
                      content=qc,
                      answer_spec=AnswerSpecification(fta),
                      is_required=True)
        
        questions.append(q)

 
    #--------------- BUILD THE QUESTION FORM -------------------
 
    question_form = QuestionForm()
    question_form.append(overview)

    for question in questions:
        question_form.append(question)


    # BUILD QUALIFICATION

    qualifications = Qualifications()
    req = PercentAssignmentsApprovedRequirement(comparator = "GreaterThan", integer_value = "95")
    qualifications.add(req)
 
    #--------------- CREATE THE HIT -------------------
 
    mtc.create_hit(questions = question_form,
                   qualifications = qualifications,
                   max_assignments = 10,
                   title = title,
                   description = description,
                   keywords = keywords,
                   duration = 60 * 30,
                   reward = 0.3)


if __name__ == "__main__":
    main()

