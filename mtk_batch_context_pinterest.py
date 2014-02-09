
import sys
import argparse
import re

from numpy import array, random

import utils
import amazon_config
import mtk_utils
import hit

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

    db_collections = hit.setup_mongodb()
    data_metainfo = hit.regex_datasource(data_sources)
    images_metainfo = hit.query_imagedata_from_db(db_collections, data_metainfo)

    # data_labels: flickr high interesting 1, flickr low interesting 2, pinterest [3, 4, 5]
    data_labels = data_metainfo[0]
    # data_ids: (flickr, pinterest) image id
    data_ids = data_metainfo[1]


    data_count_limit = 100

    for begin_index in range(0, len(data_sources), data_count_limit):
        print("index: " + str(begin_index))
        generate_hits(args.t, data_sources[begin_index:begin_index + data_count_limit], begin_index, args, data_ids[begin_index:begin_index + data_count_limit], images_metainfo)

    sys.exit(0)


def generate_hits(mtc_type, subset, begin_index, args, data_ids, images_metainfo):

    from boto.mturk.connection import MTurkConnection
    from boto.mturk.question import QuestionContent, Question, QuestionForm, Overview, AnswerSpecification, SelectionAnswer, FormattedContent, FreeTextAnswer
    from boto.mturk.qualification import PercentAssignmentsApprovedRequirement, Qualifications, Requirement


    mtc = mtk_utils.get_mtc(mtc_type)

    title = 'Tell us if you like those images or not'
    description = ('View following images and tell us if you like them or not.')
    keywords = 'image, like, interesting, rating, opinions'

    ratings =[('Very hate it','-2'),
             ('Hate it','-1'),
             ('Neutral','0'),
             ('Like it','1'),
             ('Very like it.','2')]

    #---------------  BUILD OVERVIEW -------------------

    overview = Overview()
    overview.append_field('Title', 'Tell us if you like those images or not.')

    #---------------  BUILD QUESTIONs -------------------

    questions = []

    subset_with_pinterest = []

    index = 0
    for image_url in subset:

        image_id = data_ids[index]
        image = images_metainfo[image_id]
        interestingness = 0

        index = index + 1

        if ('repin_count' in image):
            interestingness = int(image['repin_count']) + int(image['like_count'])
            subset_with_pinterest.append(image_url)
        else:
            continue
            # interestingness = int(image['interestingness'])


        qc = QuestionContent()

        context = ''
        if (interestingness > 0):
            context = ' (shared by ' + str(interestingness) + ' people)'

        qc.append_field('Title', str(interestingness) + ' people said they like following image, would you like it too?')
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
     

    if (len(questions) == 0):
        return

    if (args.m != 'qua'):
        utils.write_file(subset_with_pinterest, args.o + '.index_' + str(begin_index) + '.txt')

    if (args.m == 'qua_init' and begin_index > 0):
        return
 
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
                   duration = 60 * 30 * 4,
                   reward = 0.2 * 2)

    if (args.m == 'qua_init'):
        print("Create qualification type for HIT id: " + hit[0].HITId)
        quatype = mtc.create_qualification_type(name = hit[0].HITId, description = "Temporary qualification for HIT " + hit[0].HITId, status = 'Active')
        print("Qualification type id: " + quatype[0].QualificationTypeId)


if __name__ == "__main__":
    main()

