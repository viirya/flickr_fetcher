
conf = require('./config')

cli = require('cli')
App = require('./lib/sample').App

options = cli.parse
    numcluter: ['k', 'The number of clusters', 'number', 64],
    feadir: ['f', 'The image feature store path', 'string'],
    collection: ['c', 'The database collection', 'string'],
    outfile: ['o', 'The normalization output file', 'string'],
    sampleoutfile: ['d', 'The direct sample output file', 'string'],
    samplenum: ['s', 'The sample number', 'number', 50]

app = new App(conf.mongodb, options)
app.init(() ->
    app.run()
)

