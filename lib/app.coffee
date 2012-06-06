
sys = require('sys')
cli = require('cli')
prompt = require('prompt')
assert = require('assert')
http = require('http')
fs = require('fs')
exec = require('child_process').exec

Flickr_Fetcher = require('./fetcher').Flickr_Fetcher
Callback = require('./callback').Callback
MongoDatabase = require('./mongo').MongoDatabase
Geo = require('./geo').Geo

class App

    constructor: (@flickr_apikey, @db_config) ->

    init: (@options, cb) ->
        @decodeLocation(cb)

    decodeLocation: (cb) ->
        if (@options.location?)
            console.log("Decoding the geolocation of #{@options.location}")
            @geo = new Geo
            @geo.decode(@options.location, (data) =>
                if (data.results[0].geometry?)
                    console.log(data.results[0].geometry)

                    @search_bbox =
                        min_lng: data.results[0].geometry.viewport.southwest.lng
                        min_lat: data.results[0].geometry.viewport.southwest.lat
                        max_lng: data.results[0].geometry.viewport.northeast.lng
                        max_lat: data.results[0].geometry.viewport.northeast.lat

                    @search_bbox_string = "#{@search_bbox.min_lng},#{@search_bbox.min_lat},#{@search_bbox.max_lng},#{@search_bbox.max_lat}"

                    console.log("Constructing flickr bbox search argument: #{@search_bbox_string}")
                    @options.bbox = @search_bbox_string
                    cb()
                else
                    console.log("Error in decoding geolocation")
            ) 

    run: ->

        simple_cb = (results, next_cb) =>

            if (results.pages? && !@pages?)
                @pages =  results.pages
        
            @cur_page = results.page

            console.log("Obtain search results at page #{@cur_page} of #{@pages}")
            sys.puts(sys.inspect(results))

            next_cb()

        parse_cb = (results, next_cb) =>

            regex = /http:\/\/(.*?)\/(.*)/

            download = =>
                
                photo = results.photo.pop()
                
                if (photo?)
                    console.log("downloading #{photo.url_m}")
                    
                    match = regex.exec(photo.url_m)
                    hostname = match[1]
                    path = '/' + match[2]
 
                    download_cb = (photo) =>
                    
                        command = "convert #{@options.imgdir}/#{photo.id}.jpg #{@options.tmpdir}/#{photo.id}.pgm"
                        exec(command, (error, stdout, stderr) =>
                            if (error?)
                                console.log('exec error: ' + error)
                            else
                                command = "./bin/extract_features_64bit.ln -hesaff -sift -i #{@options.tmpdir}/#{photo.id}.pgm -o1 #{@options.feadir}/#{photo.id}.hes"
                        
                                exec(command, (error, stdout, stderr) =>
                                    if (error?) 
                                        console.log('exec error: ' + error);
                                    else
                                        download()
                                )
                        )
                    
                    download_img(photo, hostname, path, download_cb)
                else
                    next_cb()

            download()

        download_img = (photo, hostname, img_path, cb) =>
            options = 
                host: hostname
                port: 80
                path: img_path

            request = http.get(options, (res) =>
                imagedata = ''
                res.setEncoding('binary')
                
                res.on('data', (chunk) ->
                    imagedata += chunk
                )
                
                res.on('end', () =>
                    fs.writeFile("#{@options.imgdir}/#{photo.id}.jpg", imagedata, 'binary', (err) =>
                        if (err)
                            throw err
                        console.log('File saved.')

                        cb(photo)
                    )
                )

            )

        store_cb = (results, next_cb) =>
            if (@options.collection?)
                @db_config.collection = @options.collection

            if (@db_config?)
                console.log("Connecting database")
                mongodb = new MongoDatabase(@db_config)
                mongodb.init()
                mongodb.operate((collection) ->

                    console.log("Begin to store photo information into database")

                    push_photo = ->
                        photo = results.photo.pop()
                        if (photo?)
                            collection.insert(photo, {safe:true}, (err, result) ->
                                assert.equal(null, err)
                                push_photo()
                            )
                        else
                            next_cb()

                    push_photo()
                )

        last_cb = (results, next_cb) =>
            if (@cur_page < @pages)
                @options.page = @cur_page + 1

                console.log("Continuing to search for page #{@options.page}")

                @fetcher.init(@options)
                @fetcher.search(@show.expose_cb())

        @last = new Callback(last_cb)
        @store = new Callback(store_cb, @last)
        @parse = new Callback(parse_cb, @store)
        @show = new Callback(simple_cb, @parse)   
 
        @fetcher = new Flickr_Fetcher(@flickr_apikey)
        @fetcher.init(@options)
        @fetcher.search(@show.expose_cb())

exports.App = App

