(function() {
  var FlickrAPI, Flickr_Fetcher, assert, mongo;

  FlickrAPI = require('flickrnode').FlickrAPI;

  mongo = require('mongodb');

  assert = require('assert');

  Flickr_Fetcher = (function() {

    function Flickr_Fetcher(api_key) {
      this.api_key = api_key;
    }

    Flickr_Fetcher.prototype.init = function(options) {
      this.options = options;
      this.flickr = new FlickrAPI(this.api_key);
      this.server = mongo.Server;
      return this.db = mongo.Db;
    };

    Flickr_Fetcher.prototype.search = function(callback) {
      return this.flickr.photos.search({
        tags: this.options.keyword,
        extras: 'url_m,description,geo,tags,date_upload,date_taken'
      }, function(error, results) {
        return callback(results);
      });
    };

    return Flickr_Fetcher;

  })();

  exports.Flickr_Fetcher = Flickr_Fetcher;

}).call(this);
