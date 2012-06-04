
sys = require('sys')
conf = require('./config')

cli = require('cli')
prompt = require('prompt')
mongo = require('mongodb')
assert = require('assert')

Flickr_Fetcher = require('./lib/fetcher').Flickr_Fetcher
Callback = require('./lib/callback').Callback

class App
    constructor: () ->

    init: ->
        @options = cli.parse
            imgdir: ['p', 'image store path', 'string'],
            keyword: ['t', 'The keywords to search for flickr', 'string'],
            collection: ['c', 'The database collection', 'string']

    run: ->

        simple_cb = (results) ->
            sys.puts(sys.inspect(results))
        
        parse_cb = (results) ->
            for photo in results.photo
                console.log(photo.description)

        parse = new Callback(parse_cb)
        show = new Callback(simple_cb, parse)   
 
        fetcher = new Flickr_Fetcher(conf.flickr_apikey)
        fetcher.init(@options)
        fetcher.search(show.expose_cb())

app = new App()
app.init()
app.run()

