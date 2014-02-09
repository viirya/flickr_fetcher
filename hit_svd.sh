#!/bin/bash

# social interestingness to mean hue figure

R --slave --args mtk/20121015_pinterest_1000/hsv_model.data 3 2 3 "mean hue" "social interestingness" social_interestingness_mean_hue_pinterest y < draw_plot_for_cvs.R

# social/visual interestingness to face detection figure

nice R --slave --args mtk/20121015_pinterest_1000/facedetection_model.data 3 2 3 "face detection" "social interestingness" social_interestingness_face_detection_pinterest y < draw_plot_for_facedetection.R

nice R --slave --args mtk/20121015_pinterest_1000/facedetection_model.data 3 1 3 "face detection" "visual interestingness" visual_interestingness_face_detection_pinterest < draw_plot_for_facedetection_visualinterestingness.R

# visual interestingness of visual interestingness survey

R --slave --args mtk/20120815_s200/200_images_20_workers/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/interestingness_socialinterestingness.data 1 visual_interestingness < hit_svd.R

R --slave --args mtk/20120815_s200/200_images_20_workers/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/interestingness_socialinterestingness_flickr.data 1 visual_interestingness_flickr < hit_svd.R

R --slave --args mtk/20120815_s200/200_images_20_workers/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/interestingness_socialinterestingness_pinterest.data 1 visual_interestingness_pinterest < hit_svd.R

# social interestingness of visual interestingness survey

R --slave --args mtk/20120815_s200/200_images_20_workers/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/interestingness_socialinterestingness.data 2 social_interestingness < hit_svd.R

R --slave --args mtk/20120815_s200/200_images_20_workers/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/interestingness_socialinterestingness_flickr.data 2 social_interestingness_flickr < hit_svd.R

R --slave --args mtk/20120815_s200/200_images_20_workers/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/interestingness_socialinterestingness_pinterest.data 2 social_interestingness_pinterest < hit_svd.R



# image aesthetics of aesthetics survey

R --slave --args mtk/20120815_s200/200_images_20_workers/aesthetics/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/aesthetics/interestingness_socialinterestingness.data 1 aesthetics < hit_svd.R 

R --slave --args mtk/20120815_s200/200_images_20_workers/aesthetics/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/aesthetics/interestingness_socialinterestingness_flickr.data 1 aesthetics_flickr < hit_svd.R 

R --slave --args mtk/20120815_s200/200_images_20_workers/aesthetics/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/aesthetics/interestingness_socialinterestingness_pinterest.data 1 aesthetics_pinterest < hit_svd.R 

# visual interestingness of aesthetics survey

R --slave --args mtk/20120815_s200/200_images_20_workers/aesthetics/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/aesthetics/interestingness_socialinterestingness_interestingness.data 1 visual_interestingness < hit_svd.R

# social interestingness of aesthetics survey

R --slave --args mtk/20120815_s200/200_images_20_workers/aesthetics/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/aesthetics/interestingness_socialinterestingness.data 2 social_interestingness < hit_svd.R

R --slave --args mtk/20120815_s200/200_images_20_workers/aesthetics/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/aesthetics/interestingness_socialinterestingness_flickr.data 2 social_interestingness_flickr < hit_svd.R

R --slave --args mtk/20120815_s200/200_images_20_workers/aesthetics/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/aesthetics/interestingness_socialinterestingness_pinterest.data 2 social_interestingness_pinterest < hit_svd.R
 
# visual interestingness of visual interestingness with context survey

R --slave --args mtk/20120815_s200/200_images_20_workers/context_pinterest/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/context_pinterest/interestingness_socialinterestingness.data 1 visual_interestingness_context < hit_svd.R


# visual interestingness without context of visual interestingness with context survey

R --slave --args mtk/20120815_s200/200_images_20_workers/context_pinterest/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/context_pinterest/interestingness_socialinterestingness_interestingnesswithoutcontext.data 1 visual_interestingness_without_context < hit_svd.R

# aesthetics without context of visual interestingness with context survey

R --slave --args mtk/20120815_s200/200_images_20_workers/context_pinterest/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/context_pinterest/interestingness_socialinterestingness_aestheticswithoutcontext.data 1 aesthetics_without_context < hit_svd.R

# social interestingness of visual interestingness with context survey

R --slave --args mtk/20120815_s200/200_images_20_workers/context_pinterest/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/context_pinterest/interestingness_socialinterestingness.data 2 social_interestingness_context < hit_svd.R

