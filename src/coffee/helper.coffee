util = require 'util'

root = global

root.pmsg = (fmt, args...) ->
  val = util.format fmt, args...
  process.stdout.write val

root.perror = (fmt, args...) ->
  val = util.format fmt, args...
  process.stderr.write val

root.plog = (fmt, args...) ->
  val = util.format fmt, args...
  util.log val

root.xperror = (fmt, args...) ->
  perror(fmt, args...)
  process.exit()
