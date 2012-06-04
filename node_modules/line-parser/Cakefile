exec = require("child_process").exec

run = (command) ->
  cmd = exec command, ->

  cmd.stdout.on "data", (data) -> process.stdout.write data
  cmd.stderr.on "data", (data) -> process.stderr.write data

task 'build', 'build the coffescript version into javascript', (option) ->
  run "coffee --compile line-parser"

task 'test', 'run the jasmine specs', (option) ->
  run "jasmine-node --coffee ./spec"