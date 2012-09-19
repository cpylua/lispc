path = require 'path'
fs = require 'fs'

main = ->
  opts = parseOpts()
  fs.readFile opts.source, 'utf8', (err, content) ->
    xperror err if err
    ast = read content
    js = compile ast
    fs.writeFile opts.target, js, 'utf8', (err) -> xperror err if err

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

main()