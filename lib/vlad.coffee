
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

class VladEncoder

    constructor: (@options, @db_config) ->

    sample: (callback) ->
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
                        callback(photos)
                    )

                )

class App

    constructor: (@db_config, @options) ->

    init: (cb) ->
        cb()

    run: ->

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

        @last = new Callback(last_cb)
        @jobs = new Callback(invoke_vlad_encoder_cb, @last)
 
        @sampler = new VladEncoder(@options, @db_config)
        @sampler.sample(@jobs.expose_cb())

exports.App = App

