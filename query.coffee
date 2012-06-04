
FlickrAPI = require('flickrnode').FlickrAPI
sys = require('sys')
conf = require('./config')
flickr = new FlickrAPI(conf.flickr_apikey)

cli = require('cli')
prompt = require('prompt')
mongo = require('mongodb')
assert = require('assert')


class Flickr_Fetcher
    constructor: () ->

    init: ->
        @options = cli.parse
            imgdir: ['p', 'image store path', 'string'],
            keyword: ['t', 'The keywords to search for flickr', 'string'],
            collection: ['c', 'The database collection', 'string']

        @server = mongo.Server
        @db = mongo.Db

    search: (callback) ->

        flickr.photos.search({tags: @options.keyword, extras: 'url_m,description,geo,tags,date_upload,date_taken'}, (error, results) ->
            callback(results)
        )

class Callback
    constructor: (@fn, @next_cb = null) ->

    expose_cb: ->
        return (results) =>
            @fn(results)
            if (@next_cb?)
                @next_cb.expose_cb()(results)

simple_cb = (results) ->
    sys.puts(sys.inspect(results))

parse_cb = (results) ->
    for photo in results.photo
        console.log(photo.description)

parse = new Callback(parse_cb)
show = new Callback(simple_cb, parse)   

fetcher = new Flickr_Fetcher
fetcher.init()
fetcher.search(show.expose_cb())

