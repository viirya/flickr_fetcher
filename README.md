# The tools used to fetch flickr photos

## Install

    npm install

Since `flickrnode` module can not be installed by npm, you shoule git clone it into node_modules directory.

    cd node_modules
    git clone git://github.com/ciaranj/flickrnode.git

## Usage

	coffee query.coffee -t <query term> -i <image download path> -f <feature storing path> -m <image processing path> -l <geolocation> -c <database collection>

For example:
	coffee query.coffee -t paris -i ./test -f ./feature -m ./tmp -l 'Paris, France' -c paris

