util = require 'util'
path = require 'path'
reader = require './reader'

main = ->
  opts = parseOpts()
  pmsg "%j", reader.parse "(a . b)"

parseOpts = ->
  args = process.argv
  if args.length != 3 and args.length != 4
    usage()
    process.exit()

  opts = {
    source: args[2]
    target: replaceExt args[2], 'js'
  }
  opts.target = args[3] if args.length == 4
  opts

replaceExt = (file, ext) ->
  "#{file}.#{ext}"

usage = ->
  file = path.basename process.argv[1]
  pmsg "Usage: node %s SOURCE [TARGET]", file

pmsg = (fmt, args...) ->
  val = util.format fmt, args...
  process.stdout.write val

perror = (fmt, args...) ->
  val = util.format fmt, args...
  process.stderr.write val

plog = (fmt, args...) ->
  val = util.format fmt, args...
  util.log val

main()