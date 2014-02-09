
import sys
import argparse
import re

from numpy import array, random

import utils
import amazon_config
import mtk_utils

def main():
    parser = argparse.ArgumentParser(description = 'Generate HITs for Amazon Mechnical Turk workers.')
    parser.add_argument('-f', help = 'The mtk data source file.')
    parser.add_argument('-o', help = 'The output file of used data.')
    parser.add_argument('-m', default = 'normal', help = 'The running mode in {normal, qua_init, qua}.')
    parser.add_argument('-q', help = 'The qualification type id.')
    parser.add_argument('-t', default = 'sandbox', help = 'The type of Mechanical Turk.')


    args = parser.parse_args()

    if (args.m == 'qua' and args.q == None):
        print('Please give qualification type id if running in qualification mode.')
        sys.exit(0)

    data_sources = []
    if (args.f != None):
        data_sources = utils.load_file(args.f)
        if (args.m != 'qua'):
            random.shuffle(data_sources)

    data_count_limit = 100

    for begin_index in range(0, len(data_sources), data_count_limit):
        print("index: " + str(begin_index))
        generate_hits(args.t, data_sources[begin_index:begin_index + data_count_limit], begin_index, args)

    sys.exit(0)


def generate_hits(mtc_type, subset, begin_index, args):

    from boto.mturk.connection import MTurkConnection
    from boto.mturk.question import QuestionContent, Question, QuestionForm, Overview, AnswerSpecification, SelectionAnswer, FormattedContent, FreeTextAnswer
    from boto.mturk.qualification import PercentAssignmentsApprovedRequirement, Qualifications, Requirement


    mtc = mtk_utils.get_mtc(mtc_type)
 
    title = 'Give your opinion of aesthetics level about images'
    description = ('View images and give us your opinion of aesthetics level about the images')
    keywords = 'image, aesthetic, aesthetics, rating, opinions'

    ratings =[('Very ugly','-2'),
             ('Ugly','-1'),
             ('Neutral','0'),
             ('Beautiful','1'),
             ('Very beautiful, I would like to take such beautiful photo too.','2')]

    #---------------  BUILD OVERVIEW -------------------

    overview = Overview()
    overview.append_field('Title', 'Give your opinion about aesthetics level on those images')
 
    #---------------  BUILD QUESTIONs -------------------

    questions = []

    if (args.m != 'qua'):
        utils.write_file(subset, args.o + '.index_' + str(begin_index) + '.txt')

    if (args.m == 'qua_init' and begin_index > 0):
        return

    for image_url in subset:
     
        qc = QuestionContent()
        qc.append_field('Title','How beautiful the image to you?')
        qc.append(FormattedContent('<img src="' + image_url + '" alt="image" />'))


        fta = SelectionAnswer(min=1, max=1,style='dropdown',
                              selections=ratings,
                              type='text',
                              other=False)

        q = Question(identifier='aesthetics',
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

    if (args.m == 'qua'):
        if (args.q != None): 
            qua_req = Requirement(qualification_type_id = args.q, comparator = 'EqualTo', integer_value = '1')
            qualifications.add(qua_req)
        else:
            print("Please give qualification type id in 'qua' mode.")
            sys.exit(0)
 
    #--------------- CREATE THE HIT -------------------
 
    hit = mtc.create_hit(questions = question_form,
                   qualifications = qualifications,
                   max_assignments = 10 * 2,
                   title = title,
                   description = description,
                   keywords = keywords,
                   duration = 60 * 30 * 2,
                   reward = 0.2 * 2)

    if (args.m == 'qua_init'):
        print("Create qualification type for HIT id: " + hit[0].HITId)
        quatype = mtc.create_qualification_type(name = hit[0].HITId, description = "Temporary qualification for HIT " + hit[0].HITId, status = 'Active')
        print("Qualification type id: " + quatype[0].QualificationTypeId)


if __name__ == "__main__":
    main()

