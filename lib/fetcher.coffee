
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
            extras: 'url_m,url_o,url_l,url_z,url_n,url_q,url_c,description,geo,tags,date_upload,date_taken,views'

        if (@options.userid?)
            search_args.user_id = @options.userid
        if (@options.keyword?)
            search_args.tags = @options.keyword
        if (@options.page?)
            search_args.page = @options.page
        if (@options.bbox?)
            search_args.bbox = @options.bbox
        if (@options.sort?)
            search_args.sort = @options.sort
        if (@options.mindate)
            search_args.min_taken_date = Math.round(new Date(@options.mindate).getTime() / 1000)
        if (@options.maxdate)
            search_args.max_taken_date = Math.round(new Date(@options.maxdate).getTime() / 1000)

        search_args.tag_mode = 'all'

        console.log(search_args)

        @flickr.photos.search(search_args, (error, results) ->
            callback(results)
        )

exports.Flickr_Fetcher = Flickr_Fetcher

