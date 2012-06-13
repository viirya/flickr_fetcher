
conf = require('./config')

cli = require('cli')
App = require('./lib/vlad').App
VladEncoderSourceList = require('./lib/vlad').VladEncoderSourceList

options = cli.parse
    feadir: ['f', 'The image feature store path', 'string'],
    listfile: ['l', 'The photo id list filename', 'string'],
    vladdir: ['v', 'The vlad feature path', 'string'],
    codebook: ['b', 'The codebook filename', 'string'],
    metafile: ['m', 'The codebook meta filename', 'string']

app = new App(conf.mongodb, options)
app.init(() ->
    app.run(new VladEncoderSourceList(options, conf.mongodb))
)

