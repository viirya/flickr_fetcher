
sys = require('sys')
cli = require('cli')
prompt = require('prompt')
mongo = require('mongodb')
assert = require('assert')
http = require('http')
fs = require('fs')

Flickr_Fetcher = require('./fetcher').Flickr_Fetcher
Callback = require('./callback').Callback

class App

    constructor: (@flickr_apikey) ->

    init: (@options) ->

    run: ->

        simple_cb = (results) ->
            sys.puts(sys.inspect(results))
        
        parse_cb = (results) ->

            regex = /http:\/\/(.*?)\/(.*)/

            download_cb = =>
                
                photo = results.photo.pop()
                
                if (photo?)
                    console.log("downloading #{photo.url_m}")
                    
                    match = regex.exec(photo.url_m)
                    hostname = match[1]
                    path = '/' + match[2]
                    
                    download_img(photo.id, hostname, path, download_cb)

            download_cb()

        download_img = (photo_id, hostname, img_path, cb) =>
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
                    fs.writeFile("#{@options.imgdir}/#{photo_id}.jpg", imagedata, 'binary', (err) ->
                        if (err)
                            throw err
                        console.log('File saved.')
                        cb()
                    )
                )

            )


        parse = new Callback(parse_cb)
        show = new Callback(simple_cb, parse)   
 
        fetcher = new Flickr_Fetcher(@flickr_apikey)
        fetcher.init(@options)
        fetcher.search(show.expose_cb())

exports.App = App

