
express = require('express')
stylus = require('stylus')
nib = require('nib')

lazy = require('lazy')
fs = require('fs')
cli = require('cli')

APCluster = require('./lib/cluster').APCluster

options = cli.parse
    imgdir: ['i', 'The image path', 'string'],
    apcdir: ['a', 'The APC cluster pathname', 'string'],
    photoset: ['c', 'The photo set', 'string'],
    mappingfile: ['m', 'The image id mapping file', 'string'],
    clustersize: ['s', 'The threshold of cluster size', 'number']

console.log(options)

apc_cluster = new APCluster()

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
        apc_cluster.load_clusers(options.apcdir, options.mappingfile, (clusters) ->
            req.session.clusters = clusters
            res.render('index', { title : 'Home', clusters: clusters, imgpath: options.imgdir, photoset: options.photoset, size_limit: options.clustersize })
        )
    else
        res.render('index', { title : 'Home', clusters: req.session.clusters, imgpath: options.imgdir, photoset: options.photoset, size_limit: options.clustersize })
)
app.listen(3000)

