
conf = require('./config')

cli = require('cli')
App = require('./lib/app').App

options = cli.parse
    imgdir: ['i', 'The image store path', 'string'],
    feadir: ['f', 'The image feature store path', 'string'],
    tmpdir: ['m', 'The tmporary path', 'string'],
    keyword: ['t', 'The keywords to search for flickr', 'string'],
    collection: ['c', 'The database collection', 'string']
    location: ['l', 'The location to search photos from', 'string'],
    page: ['p', 'The starting page', 'number', 1]

app = new App(conf.flickr_apikey, conf.mongodb)
app.init(options, () ->
    app.run()
)

