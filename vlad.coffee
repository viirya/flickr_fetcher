
conf = require('./config')

cli = require('cli')
App = require('./lib/vlad').App

options = cli.parse
    feadir: ['f', 'The image feature store path', 'string'],
    collection: ['c', 'The database collection', 'string'],
    vladdir: ['v', 'The vlad feature path', 'string'],
    codebook: ['b', 'The codebook filename', 'string'],
    metafile: ['m', 'The codebook meta filename', 'string']

app = new App(conf.mongodb, options)
app.init(() ->
    app.run()
)

