
sys = require('util')
cli = require('cli')
prompt = require('prompt')
assert = require('assert')
http = require('http')
fs = require('fs')
lazy = require('lazy')
clusterfck = require("clusterfck")
exec = require('child_process').exec

Callback = require('./callback').Callback
MongoDatabase = require('./mongo').MongoDatabase

class VladEncoderSource

    constructor: (@options)

    sample: () ->
 

class VladEncoderSourceList extends VladEncoderSource

    constructor: (@options) ->

    sample: (cb) ->

        readStream = fs.createReadStream("#{@options.listfile}")
        readStream.on('error', (err) =>
            console.log(err)
        )
        photos = []
        count = 0
        new lazy(readStream)
            .lines
            .forEach((line) =>

                line = line.toString()
                photos.push({id: line})
                count++

            ).on('end', =>
                console.log("Total #{count} photos")
                cb(photos)
            )
        
 

class VladEncoderSourceDir extends VladEncoderSource

    constructor: (@options, @db_config) ->

    sample: (cb) ->

        fs.readdir(@options.feadir, (err, files) ->

        ) 

class VladEncoderSourceDB extends VladEncoderSource
 
    constructor: (@options, @db_config) ->

    sample: (cb) ->
            if (@options.collection?)
                @db_config.collection = @options.collection

            if (@db_config?)
                console.log("Connecting database")
                mongodb = new MongoDatabase(@db_config)
                mongodb.init()
                mongodb.operate((collection) =>

                    console.log("Begin to collect photo data from database")

                    stream = collection.find({}, {id: true}).streamRecords();

                    photos = []
                    count = 0
                    stream.on("data", (item) ->
                        # console.log(item)
                        count++
                        photos.push(item)
                    )

                    stream.on("end", ->
                        console.log("Total: #{count} photos")
                        cb(photos)
                    )

                )
 

 
class VladEncoder

    constructor: () ->

    sample: (source, callback) ->
        results = source.sample(callback)

class App

    constructor: (@db_config, @options) ->

    init: (cb) ->
        cb()

    run: (source) ->

        invoke_vlad_encoder_cb = (results, next_cb) =>

            console.log("Start to encode photo raw feature in vlad feature")

            photos = results.slice(0)

            invoke_encoder = =>
                photo = photos.pop()
                
                if (photo?)
                    console.log("photo id: #{photo.id}")

                    feature_filename = "#{@options.feadir}/#{photo.id}.hes"
                    vlad_filename = "#{@options.vladdir}/#{photo.id}.vlad"

                    command = "python vlad_encoder.py -c #{@options.codebook} -n #{@options.metafile} -f #{feature_filename} -o #{vlad_filename}"
                    exec(command, (error, stdout, stderr) =>
                        if (error?)
                            console.log('exec error: ' + error)

                        invoke_encoder()
                    )

                else
                    next_cb()

            invoke_encoder()

        last_cb = (results, next_cb) =>
            process.exit()

        @last = new Callback(last_cb)
        @jobs = new Callback(invoke_vlad_encoder_cb, @last)
 
        @sampler = new VladEncoder()
        @sampler.sample(source, @jobs.expose_cb())

exports.App = App
exports.VladEncoderSource = VladEncoderSource
exports.VladEncoderSourceDB = VladEncoderSourceDB
exports.VladEncoderSourceList = VladEncoderSourceList


