
lazy = require('lazy')
fs = require('fs')

class ImageLoader

    constructor: () ->

    load_images: (@options, cb) ->
        console.log(@options)
        fs.readdir("./public/#{@options.imgdir}/#{@options.photoset}", (err, files) =>
            console.log(files)
            cb(files)
        )


exports.ImageLoader = ImageLoader

