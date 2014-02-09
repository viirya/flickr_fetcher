
import sys
import argparse
import re

from numpy import array, random

import utils
import amazon_config
import hit

def main():
    parser = argparse.ArgumentParser(description = 'Generate HITs for Amazon Mechnical Turk workers.')
    parser.add_argument('-f', help = 'The mtk data source file.')
    parser.add_argument('-o', help = 'The output file of used data.')

    args = parser.parse_args()

    data_sources = []
    if (args.f != None):
        data_sources = utils.load_file(args.f)
        random.shuffle(data_sources)

    db_collections = hit.setup_mongodb()
    data_metainfo = hit.regex_datasource(data_sources)
    images_metainfo = hit.query_imagedata_from_db(db_collections, data_metainfo)

    # data_labels: flickr high interesting 1, flickr low interesting 2, pinterest [3, 4, 5]
    data_labels = data_metainfo[0]
    # data_ids: (flickr, pinterest) image id
    data_ids = data_metainfo[1]

    data_count_limit = 50

    for begin_index in range(0, len(data_sources), data_count_limit):
        print("index: " + str(begin_index))
        generate_hits(data_sources[begin_index:begin_index + data_count_limit], begin_index, args, data_ids[begin_index:begin_index + data_count_limit], images_metainfo)

    sys.exit(0)


def generate_hits(subset, begin_index, args, data_ids, images_metainfo):

    from boto.mturk.connection import MTurkConnection
    from boto.mturk.question import QuestionContent, Question, QuestionForm, Overview, AnswerSpecification, SelectionAnswer, FormattedContent, FreeTextAnswer
    from boto.mturk.qualification import PercentAssignmentsApprovedRequirement, Qualifications
 
    ACCESS_ID = amazon_config.ACCESS_ID
    SECRET_KEY = amazon_config.SECRET_KEY
    HOST = 'mechanicalturk.amazonaws.com'
 
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

    utils.write_file(subset, args.o + '.index_' + str(begin_index) + '.txt')

    index = 0
    for image_url in subset:

        image_id = data_ids[index]
        image = images_metainfo[image_id]
        interestingness = 0

        if ('repin_count' in image):
            interestingness = int(image['repin_count']) + int(image['like_count'])
        #else:
            # interestingness = int(image['interestingness'])

        index = index + 1
     
        qc = QuestionContent()

        context = ''
        if (interestingness > 0):
            context = ' (shared by ' + str(interestingness) + ' people)'

        qc.append_field('Title','How interesting the image' + context + ' to you?')
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
                   reward = 0.2)


if __name__ == "__main__":
    main()

