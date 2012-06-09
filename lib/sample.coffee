
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

class Sampler

    constructor: (@options, @db_config) ->

    sample: (callback) ->
            if (@options.collection?)
                @db_config.collection = @options.collection

            if (@db_config?)
                console.log("Connecting database")
                mongodb = new MongoDatabase(@db_config)
                mongodb.init()
                mongodb.operate((collection) =>

                    console.log("Begin to sample data from database")

                    
                    sample_rate = 0.2
                    stream = collection.find({random: {$lte: sample_rate}}, {id: true}).limit(@options.samplenum).streamRecords();

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

        load_features_cb = (results, next_cb) =>

            console.log("Start to load image features")

            photos = results.slice(0)

            load_feature = =>
                photo = photos.pop()
                
                if (@options.sampleoutfile?)
                    @matrix = []

                unless(@matrix?)
                    @matrix = []
 
                if (photo?)
                    console.log("photo id: #{photo.id}")

                    readStream = fs.createReadStream("#{@options.feadir}/#{photo.id}.hes")
                    readStream.on('error', (err) =>
                        console.log(err)
                        load_feature()
                    )
                
                    new lazy(readStream)
                        .lines
                        .forEach((line) =>
                        
                            save = (match) =>
                                vector = match[6].split(" ")

                                num_vector = []

                                for element in vector
                                    num_vector.push(parseFloat(element))

                                @matrix.push(num_vector)
                        
                            line = line.toString()
                        
                            regex = /(.*?)\s(.*?)\s(.*?)\s(.*?)\s(.*?)\s(.*)/
                            match = regex.exec(line)
                        
                            if (match?)
                                save(match)
                        
                        ).on('end', =>
                            if (@options.sampleoutfile?)
                                write_output = =>
                                    vector = @matrix.pop()
                                    if (vector?)
                                        fs.createWriteStream(@options.sampleoutfile, {flags: 'a'}).on('open', (fd) ->
                                            this.write(vector.join(' ') + "\n")
                                            this.end()
                                            write_output()
                                        )
                                    else
                                        load_feature()
                                
                                write_output()
                            else
                                load_feature()
                        )
                else
                    next_cb()

            load_feature()

        last_cb = (results, next_cb) =>

        norm_cb = (results, next_cb) =>
            console.log("Normailizing")

            
            count = 0
            norm = =>
                vector = @matrix.pop()
                if (vector?)
                    for dim in [0..127]
                        vector[dim] = (vector[dim] - @mean_vector[dim]) / @std_vector[dim]
                    console.log("vector #{count}")

                    write_output = =>
                        fs.createWriteStream(@options.outfile, {flags: 'a'}).on('open', (fd) ->
                            this.write(vector.join(' ') + "\n")
                            this.end()
                            norm()
                        )

                    count++
                    write_output()

                else
                    next_cb()

            norm()

        std_cb = (results, next_cb) =>
            console.log("Calculating std value")

            @std_vector = []
            for dim in [0..127]
                @std_vector[dim] = 0
                count = 0
                for vector in @matrix
                    @std_vector[dim] += Math.pow(vector[dim] - @mean_vector[dim], 2)
                    count++
                @std_vector[dim] = Math.sqrt(@std_vector[dim] / count)
                console.log("Dimension #{dim}")

            next_cb()
 

        mean_cb = (results, next_cb) =>
            console.log("Calculating mean value")

            @mean_vector = []
            for dim in [0..127]
                @mean_vector[dim] = 0
                count = 0
                for vector in @matrix
                    @mean_vector[dim] += vector[dim]
                    count++
                console.log("Dimension #{dim}")
                @mean_vector[dim] /= count

            next_cb()

        @last = new Callback(last_cb)
        @norm = new Callback(norm_cb, @last)
        @std = new Callback(std_cb, @norm)
        @mean = new Callback(mean_cb, @std)

        @sampler = new Sampler(@options, @db_config)

        if (@options.sampleoutfile?)
            @jobs = new Callback(load_features_cb, @last)
        else
            @jobs = new Callback(load_features_cb, @mean)

        @sampler.sample(@jobs.expose_cb())

exports.App = App

