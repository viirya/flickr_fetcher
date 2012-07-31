
conf = require('./config')

cli = require('cli')
App = require('./lib/app').App

options = cli.parse
    imgdir: ['i', 'The image store path', 'string'],
    feadir: ['f', 'The image feature store path', 'string'],
    tmpdir: ['m', 'The tmporary path', 'string'],
    keyword: ['t', 'The keywords to search for flickr', 'string'],
    collection: ['c', 'The database collection', 'string'],
    mindate: ['n', 'The min_taken_date of flickr search parameter', 'string'],
    maxdate: ['a', 'The max_taken_date of flickr search parameter', 'string'],
    location: ['l', 'The location to search photos from', 'string'],
    page: ['p', 'The starting page', 'number', 1],
    totalpage: ['o', 'The total pages to download', 'number'],
    sort: ['s', 'The order of returned photos.', 'string'],
    userid: ['u', 'The Flickr user NSID.', 'string']

app = new App(conf.flickr_apikey, conf.mongodb)
app.init(options, () ->
    app.run()
)

