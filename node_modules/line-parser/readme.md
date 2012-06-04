# this is pre-release, alpha. just saying.

## Installation

- npm install line-parser

## Overview

line-parser takes a stream of "chunks" and outputs full lines (as delimited by \n) as events.

## Usage
<pre>
var LineParser = require("line-parser")

var myParser = new LineParser()

myParser.on("line", function(line){
  console.log(line);
});

myParser.chunk("This is not a ");
myParser.chunk("line until we see a newline.\nSo we will only get two lines emitted");
myParser.chunk(" from this excercise.");

#will output
#This is not a line until we se a newline.
#So we will only get two lines emitted from this excercise.
</pre>

## Global dependancies for building/testing

- jasmine-node (npm install jasmine-node -g)
- coffee-script (npm install coffee-script -g)

## To run tests

- cake build && cake test

## To build javascript library

- cake build