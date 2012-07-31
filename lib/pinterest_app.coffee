
sys = require('util')
cli = require('cli')
prompt = require('prompt')
assert = require('assert')
http = require('http')
fs = require('fs')
exec = require('child_process').exec

Pinterest = require('./pinterest').Pinterest
Callback = require('./callback').Callback
MongoDatabase = require('./mongo').MongoDatabase

class App

    constructor: (@db_config) ->

    init: (@options, cb) ->
        unless (@options.page?)
            @options.page = 1
        cb()

    run: ->

        simple_cb = (results, next_cb) =>
            @cur_page = @options.page
            console.log(results)
            next_cb()

        parse_cb = (results, next_cb) =>

            regex = /http:\/\/(.*?)\/(.*)/

            photos = results.slice(0)

            download = =>
                
                photo = photos.pop()
                
                if (photo?)
                    console.log("downloading #{photo.image_url}")
                    
                    match = regex.exec(photo.image_url)

                    if (match?)

                        hostname = match[1]
                        path = '/' + match[2]
                        
                        download_cb = (photo) =>
                            command = "convert #{@options.imgdir}/#{photo.pin_id}.jpg #{@options.tmpdir}/#{photo.pin_id}.pgm"
                            exec(command, {timeout: 10000}, (error, stdout, stderr) =>
                                if (error?)
                                    console.log('exec error: ' + error)
                        
                                command = "./bin/extract_features_64bit.ln -hesaff -sift -i #{@options.tmpdir}/#{photo.pin_id}.pgm -o1 #{@options.feadir}/#{photo.pin_id}.hes"
                            
                                exec(command, {timeout: 10000}, (error, stdout, stderr) =>
                                    if (error?) 
                                        console.log('exec error: ' + error);
                                    download()
                                )
                            )
                        
                        download_img(photo, hostname, path, download_cb)
                    else
                        download()
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
                    fs.writeFile("#{@options.imgdir}/#{photo.pin_id}.jpg", imagedata, 'binary', (err) =>
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
                mongodb.operate((collection) =>

                    console.log("Begin to store photo information into database")

                    photos = results.slice(0)
                    count = 0
                    push_photo = =>
                        photo = photos.pop()
                        if (photo?)
                            photo.random = Math.random()

                            collection.update({pin_id: photo.pin_id}, photo, {safe:true, upsert: true}, (err, result) =>
                                assert.equal(null, err)
                                count++
                                push_photo()
                            )
                        else
                            console.log("Total #{count} photos inserted")
                            next_cb()

                    push_photo()
                )

        last_cb = (results, next_cb) =>
            if (!@options.org_page?)
                if (@options.page?)
                    @options.org_page = @options.page
                else
                    @options.org_page = @cur_page

            if (@options.totalpage?)
                if ((@cur_page - @options.org_page + 1) >= @options.totalpage)
                    process.exit()
                else
                    @options.page++
                    @pinterest.set(@options)
                    @pinterest.request(@show.expose_cb())
            else
                process.exit()

        @last = new Callback(last_cb)
        @store = new Callback(store_cb, @last)
        @parse = new Callback(parse_cb, @store)
        @show = new Callback(simple_cb, @parse)   

        @pinterest = new Pinterest()
        @pinterest.set(@options)
        @pinterest.request(@show.expose_cb())

exports.App = App

