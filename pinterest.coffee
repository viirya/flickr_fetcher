
conf = require('./config')

cli = require('cli')
App = require('./lib/pinterest_app').App

options = cli.parse
    imgdir: ['i', 'The image store path', 'string'],
    feadir: ['f', 'The image feature store path', 'string'],
    tmpdir: ['m', 'The tmporary path', 'string'],
    keyword: ['t', 'The keywords to search for flickr', 'string'],
    collection: ['c', 'The database collection', 'string'],
    page: ['p', 'The starting page', 'number', 1],
    totalpage: ['o', 'The total pages to download', 'number']

app = new App(conf.mongodb)
app.init(options, () ->
    app.run()
)

