
express = require('express')
stylus = require('stylus')
nib = require('nib')

lazy = require('lazy')
fs = require('fs')
cli = require('cli')

ImageLoader = require('./lib/images').ImageLoader

options = cli.parse
    imgdir: ['i', 'The image path', 'string'],
    photoset: ['c', 'The photo set', 'string']

console.log(options)

image_loader = new ImageLoader()

app = express.createServer()
compile = (str, path) ->
    return stylus(str).set('filename', path).use(nib())

app.set('views', __dirname + '/views')
app.set('view engine', 'jade')
app.set('view options', { layout: false })
app.use(express.logger())
app.use(express.bodyParser())
app.use(express.cookieParser())
app.use(express.session(secret: "clusters"))
app.use(stylus.middleware { src: __dirname + '/public', compile: compile})
app.use(express.static(__dirname + '/public'))

app.get('/', (req, res) ->
    console.log(req.session)

    unless (req.session.images?)
        image_loader.load_images(options, (images) ->
            console.log(images)
            req.session.images = images
            res.render('images', { title : 'Home', images: images, imgpath: options.imgdir, photoset: options.photoset })
        )
    else
        res.render('images', { title : 'Home', images: req.session.images, imgpath: options.imgdir, photoset: options.photoset})
)
app.listen(3000)

