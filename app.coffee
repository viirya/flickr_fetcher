
express = require('express')
stylus = require('stylus')
nib = require('nib')

lazy = require('lazy')
fs = require('fs')
cli = require('cli')

options = cli.parse
    imgdir: ['i', 'The image path', 'string'],
    apcfile: ['a', 'The APC cluster filename', 'string'],
    photoset: ['c', 'The photo set', 'string']

console.log(options)

load_clusers = (options, cb) ->

    readStream = fs.createReadStream("#{options.apcfile}")
    readStream.on('error', (err) =>
        console.log(err)
    ) 

    clusters = []
    cur_cluster = {}
    new lazy(readStream)
        .lines
        .forEach((line) =>
        
            add_cluster_member = (match) =>
                member = match[1]
        
                if (cur_cluster.exemplar?)
                    unless (cur_cluster.member?)
                        cur_cluster.member = []
                    cur_cluster.member.push(member)
                else 
                    cur_cluster.exemplar = member
                    cur_cluster.member = []
        
            line = line.toString()
        
            regex = /\"x\"/
            match = regex.exec(line)

            if (match?)
                if (cur_cluster.exemplar?)
                    clusters.push(cur_cluster)
                cur_cluster = {}

            regex = /\"(.*?)\"\s.*/
            match = regex.exec(line)
        
            if (match?)
                add_cluster_member(match)

        ).on('end', =>
            #console.log(clusters)
            console.log("Cluster file parsed.")
            cb(clusters)
        )
                        


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
        load_clusers(options, (clusters) ->
            req.session.clusters = clusters
            res.render('index', { title : 'Home', clusters: clusters, imgpath: options.imgdir, photoset: options.photoset })
        )
    else
        res.render('index', { title : 'Home', clusters: req.session.clusters, imgpath: options.imgdir, photoset: options.photoset})
)
app.listen(3000)

