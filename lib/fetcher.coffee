
FlickrAPI = require('flickrnode').FlickrAPI

mongo = require('mongodb')
assert = require('assert')

class Flickr_Fetcher
    constructor: (@api_key) ->
 
    init: (@options)->

        @flickr = new FlickrAPI(@api_key)
        @server = mongo.Server
        @db = mongo.Db

    search: (callback) ->

        @flickr.photos.search({tags: @options.keyword, extras: 'url_m,description,geo,tags,date_upload,date_taken'}, (error, results) ->
            callback(results)
        )

exports.Flickr_Fetcher = Flickr_Fetcher

