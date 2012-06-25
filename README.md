# The tools used to fetch flickr photos

## Install

    npm install

Since `flickrnode` module can not be installed by npm, you shoule git clone it into node_modules directory.

    cd node_modules
    git clone git://github.com/ciaranj/flickrnode.git

## Usage

### Search Flickr photos

	coffee query.coffee -t <query term> -i <image download path> -f <feature storing path> -m <image processing path> -l <geolocation> -c <database collection>  -n <from datetime> -a <to datetime>

For example:
	coffee query.coffee -t paris -i ./test -f ./feature -m ./tmp -l 'Paris, France' -c paris -n "2012/4/1" -a "2012/4/5"

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

### Generating vlad features for each APC cluster in libsvm format.

	python vlad_data_matrix_for_clusters.py -d <vlad feature path> -c <apc cluster list filename> -o <output path and filename prefix>

For example:

	python vlad_data_matrix_for_clusters.py -d ./vlad -c paris_7910.apc.clusters -o ./clusters_vlad/cluster_data
	
The files ./clusters_vlad/cluster_data.cluster.[0 ~ (clusters_number -1)] will be generated. Each file contains vlad features for photos in the corresponding APC cluster.

### The bash script used to train models and test data

	sh train_model.sh <training data path> <model output path>
	sh test_model.sh <model path> <test data> <classification result output path>

### The bash script used to create the directionary structure for dataset

	sh create_dataset.sh <base path> <dataset name>



