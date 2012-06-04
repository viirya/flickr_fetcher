
conf = require('./config')

cli = require('cli')
App = require('./lib/app').App

options = cli.parse
    imgdir: ['p', 'image store path', 'string'],
    keyword: ['t', 'The keywords to search for flickr', 'string'],
    collection: ['c', 'The database collection', 'string']

app = new App(conf.flickr_apikey)
app.init(options)
app.run()

