
express = require('express')
stylus = require('stylus')
nib = require('nib')

lazy = require('lazy')
fs = require('fs')
cli = require('cli')

VladCluster = require('./lib/cluster').VladCluster

options = cli.parse
    imgdir: ['i', 'The image path', 'string'],
    apcfile: ['a', 'The APC cluster filename', 'string'],
    photoset: ['c', 'The photo set', 'string']

console.log(options)

vlad_cluster = new VladCluster()

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

    unless (req.session.clusters?)
        vlad_cluster.load_clusers(options.apcfile, (clusters) ->
            req.session.clusters = clusters
            res.render('index', { title : 'Home', clusters: clusters, imgpath: options.imgdir, photoset: options.photoset })
        )
    else
        res.render('index', { title : 'Home', clusters: req.session.clusters, imgpath: options.imgdir, photoset: options.photoset})
)
app.listen(3000)

