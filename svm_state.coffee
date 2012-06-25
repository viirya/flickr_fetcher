
cli = require('cli')
App = require('./lib/stats').App
StatisticSourceDir = require('./lib/stats').StatisticSourceDir

options = cli.parse
    resultdir: ['r', 'The classification results path', 'string'],
    groundtruth: ['g', 'The ground truth of data label: 1 or -1', 'string']

if (options.groundtruth == 'positive')
    options.groundtruth = '1'
else
    options.groundtruth = '-1'

app = new App(options)
app.init(() ->
    app.run(new StatisticSourceDir(options))
)

