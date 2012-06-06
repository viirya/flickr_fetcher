
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

        search_args =
            tags: @options.keyword
            extras: 'url_m,description,geo,tags,date_upload,date_taken'

        if (@options.page?)
            search_args.page = @options.page
        if (@options.bbox?)
            search_args.bbox = @options.bbox

        console.log(search_args)

        @flickr.photos.search(search_args, (error, results) ->
            callback(results)
        )

exports.Flickr_Fetcher = Flickr_Fetcher

