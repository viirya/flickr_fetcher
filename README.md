# The tools used to fetch flickr photos

## Install

    npm install

Since `flickrnode` module can not be installed by npm, you shoule git clone it into node_modules directory.

    cd node_modules
    git clone git://github.com/ciaranj/flickrnode.git

## Usage

### Search Flickr photos

	coffee query.coffee -t <query term> -i <image download path> -f <feature storing path> -m <image processing path> -l <geolocation> -c <database collection>  -n <from datetime> -a <to datetime> -p <starting page> -o <total pages> -s <sorting option> -u <flickr user NSID>

For example:

	coffee query.coffee -t paris -i ./test -f ./feature -m ./tmp -l 'Paris, France' -c paris -n "2012/4/1" -a "2012/4/5" -p 1 -o 2 -s interestingness-desc

### Sample photos from fetched Flickr photos

	sample.coffee -c <database collection> -f <feature storing path> -d <output file> -s <sample number>
	
For example:

	sample.coffee -c paris -f ./features -d test.clu -s 1000
	
### Clustering of sampled photos

	python cluster.py -f <sampled photo features> -o <output file> -k <number of clusters>
	
In addition to "output file", another file "output file" + ".meta" will be created that contains mean and std feature vector of sampled features.
	
For example:

	python cluster.py -f test.clu -o sample.kmean -k 64

### Encoding raw image features as VLAD (vector of locally aggregated descriptors) feature

	python vlad_encoder.py -c <codebook filename> -n <codebook metadata filename> -f <raw feature filename> -o <output filename>
	
For example:

	python vlad_encoder.py -c flickr_sample_500.k_16 -n flickr_sample_500.k_16.meta -f features.hes -o features.vlad

### Encoding all images in database collection as VLAD features

	coffee vlad.coffee -c <database collection> -f <raw feature path> -v <vlad path> -b <codebook filename> -m <codebook metadata filename>

For example:

	coffee vlad.coffee -c paris -f ./features -v ./vlad -b flickr_sample_500.k_16 -m flickr_sample_500.k_16.meta

### Encoding all images in a specified list as VLAD features

	coffee vlad_from_filelist.coffee -l <image list file> -f <raw feature path> -v <vlad storing path> -b <codebook> -m <codebook metadata filename>

For example:

	coffee vlad_from_filelist.coffee -l image_list.txt -f ./features -v ./vlad -b flickr_sample_500.k_16 -m flickr_sample_500.k_16.meta
	
### Validating VLAD feature performance

	python vlad_validate_distance.py -d <vlad feature path> -q <query list file> -g <groundtruth filename>

For example:

	python vlad_validate_distance.py -d ./vlad -q query.txt -g ground_truth.txt

### Generating pairwise distance matrix for images

	python vlad_pairwise_distance.py -d <vlad feature path> -o <output filename>

For example:

	python vlad_pairwise_distance.py -d ./vlad -o paris_7910.distance

### Generating vlad feature matrix for images

	python vlad_data_matrix.py -d <vlad feature path> -o <outout filename> -s <optional sample number> -f <optional output format> -l <optional data label>

The output format could be 'libsvm'. If not given, the output format is simply the arraies of vlad features.
The sample number could be set to generate specified numbers of parts of the data.
The data label could be set to generate '1' or '-1' label in output file of libsvm format.

For example:

	python vlad_data_matrix.py -d ./vlad -o paris_7910.data -f libsvm -l positive

### Clustering flickr images using Affinity Propagation algorithm

	# Running R interaction envrionment
	> source("apc_cluster.R")
	> data_cluster("paris_7910.data") # given the vlad feature matrix

	# Or under command line
	R --slave --args paris_7910 < apc_cluster.R

4 files will be generated under current path. Use "paris_7910.data" as example:

* paris_7910.apc: Binary stored APResult object of APCluster package.
* paris_7910.apc.clusters: Text-format cluster list.
* paris_7910.apc.exemplars: Text-format exemplar list.
* paris_7910.apc.similarity: Negative squared distances (Euclidean) matrix.

### Browsing clustering results

	coffee app.coffee -i <image base path> -a <apc cluster list filename> -c <image set sub-path under image base path>

For example:

	coffee app.coffee -i /images -a ./paris_7910.apc.clusters -c paris

A node.js application will be running at port 3000. Open browser to see the clustering results at a URL such as http://localhost:3000/

### Browsing MapReduce clustering results

	coffee apc_mapreduce.coffee -i <image base path> -a <apc cluster result pathname> -c <image set sub-path under image base path> -s <the threshold of cluster size>

For example:

	coffee apc_mapreduce.coffee -i /images -a ./output -c paris -s 20

### Generating vlad features for each APC cluster in libsvm format.

	python vlad_data_matrix_for_clusters.py -d <vlad feature path> -c <apc cluster list filename> -o <output path and filename prefix> -t <threshold for cluster size>

For example:

	python vlad_data_matrix_for_clusters.py -d ./vlad -c paris_7910.apc.clusters -o ./clusters_vlad/cluster_data -t 5
	
The files ./clusters_vlad/cluster_data.cluster.[0 ~ (clusters_number -1)] will be generated. Each file contains vlad features for photos in the corresponding APC cluster.

### The bash script used to train models and test data

	./train_model.sh <training data path> <model output path>
	./test_model.sh <model path> <test data> <classification result output path>

### The bash script used to create the directionary structure for dataset

	./create_dataset.sh <base path> <dataset name>

### 

	coffee svm_state.coffee -r <svm testing result path> -g <calculating statistics for positive or negative>

For example:

	coffee svm_state.coffee -r ./classification -g positive

### Broswing fetched photos

	coffee image.coffee -i <image base path under public> -c <image relative path under image base path>
	
For example:

	coffee image.coffee -i images -c test

### Generate crowdsourcing dataset file

	python crowdsourcing.py -d <image path> -o <output file> -n <number of sampled images> -u <image prefix> -m <file output mode {w|a}>
	
For example:

	python crowdsourcing.py -d ./images -o crowd.txt -n 10 -u "http://testurl/images/" -m w
	
### Crawling Pinterest images

	coffee pinterest.coffee -i <image download path> -f <feature storing path> -m <image processing path> -c <database collection> -p <starting page> -o <total pages>
	
For example:

	coffee pinterest.coffee -i ./images -f ./features -m ./tmp -c pinterest -p 1 -o 2
	
### Creating HITs for Amazon Mechanical Turk                                                                              

	python mtk.py -f <data source file> -o <output file for keeping sampled data>

For example:

	python mtk.py -f mtk_datasource.txt -o mtk_datasource_subset_s50_a10_r0.3.txt

### Creating HITs for Amazon Mechanical Turk in batch

	python mtk_batch.py -f <data source file> -o <output file prefix for keeping sampled data> -m <running mode in normal, qua_init, qua> -q <qualification type id, required when in 'qua' mode>

For example:

	python mtk_batch.py -f mtk_datasource.txt -o mtk_datasource_subset_s50_a10_r0.3 

This script iterates for every pre-defined number of items in data source file and submits as multiple HITs.

It supports few running modes. 'normal' is default and submits all items as multiple HITs. 'qua init' is the initial run of the mode that wants all questions to be answered by the same workers. Because the QuestionXML length limit of Turk, we can not submit all questions in a single HIT. So in this mode, we submit first part of questions and create a qualification for the HIT. Then the workers of the HIT can be assigned with the qualification by using mtk_assign_qua.py. Next we run mtk_batch.py again in 'qua' mode that requires an -q parameter that is qualification type id to limit the qulified workers to the workers of previous HIT.
 
### Analyzing submitted HIT results

	python analyze_hitresult.py -f <data source file> -m <HIT result csv file> -o <output csv file> -s <summary output file> -t <optional data type> -r <optional, the times of random split> -d <optional output path>

For example:

	python analyze_hitresult.py -f mtk_datasource_subset.txt -m HITResultsFor.csv -o mtk_label_HITResultsFor.csv -s mtk_label_summary_HITResultsFor.csv -t "3,4,5"

The option of the times of random split causes the script to randomly split the HIT results with specified times and aggregately output random splits.

### Aggregating mutiple files into a singal file 

	python aggregate_csv.py -f <mutiple data source files> -f <.....> -o <output file> -e <flag to output common header of files, could be 'y' or 'n'>

For example:

	python aggregate_csv.py -f mtk/20120815_s200/mtk_label_summary_HITResultsFor1.csv -f mtk/20120815_s200/mtk_label_summary_HITResultsFor2.csv -f mtk/20120815_s200/mtk_label_summary_HITResultsFor3.csv -f mtk/20120815_s200/mtk_label_summary_HITResultsFor4.csv -o aggregated.csv -e 'y'

### Juxtaposing two aggregated results

    python aggregate_csv_comparator.py -f <aggregated file one> -f <aggregated file two> -o <output file>

For example:

    python aggregate_csv_comparator.py -f mtk/20120815_s200/pinterest/aggregated.csv -f mtk/20120815_s200/aesthetics/flickr_pinterest/aggregated.csv -o test.csv
	
### Create qualification type for Mechanical Turk

    python mtk_create_qua.py -n <qualification name> -d <qualification type description>

For example:

    python mtk_create_qua.py -n test2 -d 'test 2 qualification'

### Assign qualification to specific Turk worker or workers of specific HIT

    python mtk_assign_qua.py -w <worker id> -q <qualification type id> -d <HIT id> -t <Turk service type, default is 'sandbox'> -s <status of assignments, default is 'Approved'>

When assign qualification to specific worker, worker id is required parameter. When assign to workers of specific HIT, HIT id is required.

For example:

    python mtk_assign_qua.py -w AV83DIG34WE86 -q 246D2AC9KSSZOQ8JH7WUXKQOYII0I8

### Joining two or more HIT result files

    python join_hitresults.py -m <"last" HIT result file> -m <second or more HIT result files> -o <output filename> -f <output file format {hit, r | default = hit}> -r <output row header {y, n | default = n}>

When sumbitting splitted questions to multiple HITs for same workers to complete those HITs, we may need to join those HIT results back to a single HIT result file. In this case, join_hitresults.py can do this favor. Those anwsers given from same workers will be concatenated in same rows.

For example:

    python join_hitresults.py -m mtk/20120815_s200/200_images_20_workers/HITResultsFor2KXDEY5COW0L9KAKZFIFTC6VP7KV46.csv -m mtk/20120815_s200/200_images_20_workers/HITResultsFor29QSV7WGKCCVEEET16UMPAPQ6PUS22.csv -o test.csv

### Performing SVD analysis on HIT result and plot the vector of singular values

    # Under command line
    R --slave --args datafile colorfile colordimension colorlabel < hit_svd.R

Few arguments are needed. datafile is raw data file. For now datafile is generated by join_hitresults.py that includes raw scores provided by HIT workers. colorfile is a CSV-format file in that each column represents a dimension (such interestingness) for data. colorlabel is a description used in generated plot filename. colordimension is the dimension (column index) of the values used to colorize points in plot.

For example:

    R --slave --args mtk/20120815_s200/200_images_20_workers/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/interestingness_socialinterestingness_flickr.data 1 visualinterestingness_flickr < hit_svd.R

5 files will be generated under the same path of datafile. Using "datafile" as example:

* datafile.u: the left singular vectors.
* datafile.v: the right singular vectors.
* datafile.v.png: the plot of the right singular vectors.
* datafile.v_id.png: the plot of the right singular vectors with sequence ids of datapoints.
* datafile.v_\{colorlabel\}.png: the plot same with datafile.v.png but with color to indicate another dimension (such interestingness) of data.
* datafile.d: the vector of singular values. 
* datafile.d.png: the plot of the vector of singular values.

### Performing SVD analysis on HIT result and plot the vector of singular values with HSV model

    # Under command line
    R --slave --args datafile colorfile colordimension colorlabel < hit_svd_hsv.R

For example:
 
    R --slave --args mtk/20120815_s200/200_images_20_workers/r_data/image200_interestingness_with_workerid.data mtk/20120815_s200/200_images_20_workers/hsv_model.data 1 hsv_pinterest < hit_svd_hsv.R


### Drawing distribution plot for data matrix (2 column for x, y coordinates)

    # Under command line
    R --slave --args datafile < correlation_data_plot.R

    # Plot multiple data in same plot; Generate reasonable plot when the coordinations of data are located at similar range.
    R --slave --args datafile1 datafile2 outputfile < correlation_join_data_plot.R
 
    # Plot multiple data in same plot with log scale; Generate reasonable plot when the coordinations of data are located at similar range.
    R --slave --args datafile1 datafile2 outputfile < correlation_join_log_data_plot.R
 
For example:

    R --slave --args mtk/20120815_s200/200_images_20_workers/flickr_low/interestingness_socialinterestingness.data < correlation_data_plot.R

    R --slave --args mtk/20120815_s200/200_images_20_workers/flickr_high/interestingness_socialinterestingness.data mtk/20120815_s200/200_images_20_workers/flickr_low/interestingness_socialinterestingness.data test..data < correlation_join_data_plot.R

* datafile.png will be generated.

### Exporting data matrix from HIT summary file

    python export_datamatrix_from_summary.py -f <HIT summary file> -c <exporting columns separated by comma> -o <output file> -d <optional, the data source file used to filter out rows in HIT summary file or used to re-order the data rows in HIT summary file> -t <the data types for output separated by comma> -p <optional padding value>

For example:

    python export_datamatrix_from_summary.py -f mtk/20120815_s200/200_images_20_workers/flickr_low/mtk_label_summary_HIT_aggregated.csv.type.2.csv -c "2,5" -o mtk/20120815_s200/200_images_20_workers/flickr_low/interestingness_socialinterestingness.data -d mtk/20120815_s200/200_images_20_workers/datasource.txt -t "1,2"
    
    python export_datamatrix_from_summary.py -f mtk/20120815_s200/200_images_20_workers/mtk_label_summary_HIT_aggregated_mean_hsv.csv -c "2,5,6,7,8" -o mtk/20120815_s200/200_images_20_workers/hsv_model.data -t '3,4,5' -d mtk/20120815_s200/200_images_20_workers/datasource.txt -p '0,0,0,0,1'

### Crawling images in image URL list

    python crawl_images.py -f <image URL list file> -d <image path>


For example:

    python crawl_images.py -f pinterest_1000.txt -d /project/project-mira3/flickr_geo_photos/pinterest_interestingness/test

### Generating n-fold files

    python n_fold_sampling.py -p <positive sample file> -n <negtive sample file> -f <the number of folds> -o <output path>


For example:

    python n_fold_sampling.py -p mtk/20121015_pinterest_1000/HIT_summary_aggregated_morethan_5.csv -n mtk/20121015_pinterest_1000/HIT_summary_aggregated_lessthan_6.csv -f 10 -o mtk/20121015_pinterest_1000/10_fold

### Crawling images of n-fold sampling

    crawl_n_fold_images.sh <the path of n-fold files> <image base path>    

For example:

    crawl_n_fold_images.sh mtk/20121015_pinterest_1000/10_fold /project/project-mira3/flickr_geo_photos/pinterest_interestingness

### Extracting image features for n-fold sampled images

    extract_image_features_n_fold.sh <the path of n-fold files> <feature base path>

For example:

    extract_image_features_n_fold.sh mtk/20121015_pinterest_1000/10_fold /project/project-mira3/flickr_geo_photos/pinterest_interestingness

### Training and testing image interestingness model


    train_and_test_interesting_model.sh <the path of n-fold files> <feature base path> <model base path>   
 
For example:

    train_and_test_interesting_model.sh mtk/20121015_pinterest_1000/10_fold /project/project-mira3/flickr_geo_photos/pinterest_interestingness/data /project/project-mira3/flickr_geo_photos/pinterest_interestingness/model     
 
### Filtering HIT summary file by thresholding specific field

    python filter_hit_summary.py -f <HIT summary file> -e 'y' -t <filtering condition> -o <output file>

The \<filtering condition\> can be set as '\{more \| less\},\<field\>,\<thresholding value\>'.

For example:

    python filter_hit_summary.py -f mtk/20121015_pinterest_1000/HIT_summary_aggregated.csv -e 'y' -t 'less,2,6' -o mtk/20121015_pinterest_1000/HIT_summary_aggregated_lessthan_6.csv

### Drawing plot for data matrix stored in CVS format

    R --slave --args <data matrix file> <x-axis column> <y-axis column> <beginning column of hsv model> <x-axis label> <y-axis label> <output file postfix> <optionally, log-scale axis>< draw_plot_for_cvs.R

For example:

    R --slave --args mtk/20121015_pinterest_1000/hsv_model.data 1 3 3 visual_interestingness mean_hue visual_interestingness_mean_hue_pinterest < draw_plot_for_cvs.R

    R --slave --args mtk/20121015_pinterest_1000/hsv_model.data 1 3 3 visual_interestingness mean_hue visual_interestingness_mean_hue_pinterest x < draw_plot_for_cvs.R

### Generating histogram data for HSV model file

    python gen_data_for_hsv_figure.py -f <hsv model file> -x <x-axis column> -y <y-axis column> -t <mean hue threshold> -b <bin size> -d <boundary of x-axis> -o <output filename>

For example:

    python gen_data_for_hsv_figure.py -f mtk/20121015_pinterest_1000/hsv_model.data -x 1 -y 2 -t 0.3 -b 1000 -d 1000 -o hsv_figure_b_1000_t_0.3_d_1000.data

### Generating classification results

    sh generate_classification_results.sh <n-fold file path> <data path> <classification result diff path> <result path>

For example:

    ./generate_classification_results.sh mtk/20121015_pinterest_1000/10_fold /project/project-mira3/flickr_geo_photos/pinterest_interestingness/data /project/project-mira3/flickr_geo_photos/pinterest_interestingness/testing_result /project/project-mira3/flickr_geo_photos/pinterest_interestingness/classification_result

### Copying classification images

    ./copy_classification_images.sh <classification result basepath> <image output basepath>

For example:

    ./copy_classification_images.sh /project/project-mira3/flickr_geo_photos/pinterest_social_interestingness/classification_result ~/project/image_interestingness/pinterest_social_interestingness_results

### Diff two csv files of image lists

    python diff_csv.py -p <first csv file> -n <second csv file>

For example:

    python diff_csv.py -p mtk/20121015_pinterest_1000/HIT_summary_aggregated_morethan_5.csv -n mtk/20121015_pinterest_1000/HIT_summary_aggregated_morethan_317.csv

### Calculating mean hsv values for images and appending to existing CSV file

    python append_hsv_model.py -f <CSV file> -e <including original header, 'y' for yes> -t <temporary path for downloading image files> -o <output file>

For example:

    python append_hsv_model.py -f mtk/20121015_pinterest_1000/HIT_summary_aggregated.csv -e 'y' -t temp -o HIT_summary_hsv_test.cvs

### Calculating face detection scores for images and appending to existing CSV file

    python append_face_model.py -f <CSV file> -e <including original header, 'y' for yes> -t <temporary path for downloading image files> -o <output file> -c <cascade file>
    
For example:

    python append_face_model.py -f mtk/20121015_pinterest_1000/HIT_summary_aggregated.csv -e 'y' -t temp -o HIT_summary_facedetection.cvs -c ~/repos/opencv/data/haarcascades/haarcascade_frontalface_alt.xml
 
