LineParser = require("../line-parser.js")

describe "Line parser", ->
  parser = null
  lines = []

  beforeEach ->
    lines = []
    parser = new LineParser()
    parser.on "line", (line) -> lines.push(line)
  
  describe "parsing individual chunks", ->   
    it 'should emit nothing when given an empty string', ->
      parser.chunk ""
      expect(lines.length).toEqual(0)

    it "should emit nothing when given a string without any newlines", ->
      parser.chunk "blah blah blah"
      expect(lines.length).toEqual(0)

    it "should emit one line when given a string ending with a newline", ->
      parser.chunk "line\n"
      expect(lines.length).toEqual(1)
      expect(lines[0]).toEqual("line")

    it "should strip trailing \\r charicters", ->
      parser.chunk "line\r\n"
      expect(lines.length).toEqual(1)
      expect(lines[0]).toEqual("line")
  
    it "should convert a single newline into a single blank line", ->
      parser.chunk "\n"
      expect(lines).toEqual([""])
      
    it "should convert three newlines into three blank lines", ->
      parser.chunk "\n\n\n"
      expect(lines).toEqual(["", "", ""])
      
  describe "parsing multiple lines", ->
    
    verify = (chunks, expectedLines) ->
      console.log chunks
      console.log expectedLines

      for chunk in chunks
        parser.chunk chunk
      
      console.log lines

      expect(lines).toEqual(expectedLines)

    it "should handle a mix of things", ->
      verify [
        "the quick"
        " brown fox\njumped"
        " over the\n"
        "lazy"
        "\ndog"
        "\n"
      ], [
        "the quick brown fox"
        "jumped over the"
        "lazy"
        "dog"
      ]

    it "should emit blank lines for serieses of newlins"

