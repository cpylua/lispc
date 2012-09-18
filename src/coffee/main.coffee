util = require 'util'

parseOpts = ->
  process.stdout.write "in"
  usage()

usage = ->
  file = process.argv[1]
  pmsg "Usage: node %s SOURCE [TARGET]", file

pmsg = (fmt, args...) ->
  val = util.format fmt, args...
  process.stdout.write val

perror = (fmt, args...) ->
  val = util.format fmt, args...
  process.stderr.write val
