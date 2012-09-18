fs     = require 'fs'
{exec} = require 'child_process'
util   = require 'util'
uglify = require './node_modules/uglify-js'

prodSrcCoffeeDir     = 'src/coffee'
testSrcCoffeeDir     = 'test/coffee'

prodTargetJsDir      = 'src/js'
testTargetJsDir      = 'test/js'

prodTargetFileName   = 'lispc'
prodTargetCoffeeFile = "#{prodSrcCoffeeDir}/#{prodTargetFileName}.coffee"
prodTargetJsFile     = "#{prodTargetJsDir}/#{prodTargetFileName}.js"
prodTargetJsMinFile  = "#{prodTargetJsDir}/#{prodTargetFileName}.min.js"

prodCoffeeOpts = "--output #{prodTargetJsDir} --compile"
testCoffeeOpts = "--output #{testTargetJsDir}"

prodCoffeeFiles = [
    'compiler'
    'main'
]

pegjsFile = 'src/reader.pegjs'

task 'watch:all', 'Watch production and test CoffeeScript', ->
    invoke 'watch:test'
    invoke 'watch'
    
task 'build:all', 'Build production and test CoffeeScript', ->
    invoke 'build:test'
    invoke 'build'    

task 'watch', 'Watch prod source files and build changes', ->
    invoke 'build'
    util.log "Watching for changes in #{prodSrcCoffeeDir}"

    for file in prodCoffeeFiles then do (file) ->
        fs.watchFile "#{prodSrcCoffeeDir}/#{file}.coffee", (curr, prev) ->
            if +curr.mtime isnt +prev.mtime
                util.log "Saw change in #{prodSrcCoffeeDir}/#{file}.coffee"
                invoke 'build'

task 'build', 'Build a single JavaScript file from prod files', ->
    util.log "Building #{prodTargetJsFile}"
    remaining = prodCoffeeFiles.length
    appContents = []

    # compile separate coffee files first
    for file in prodCoffeeFiles then do (file) ->
        exec "coffee #{prodCoffeeOpts} #{prodSrcCoffeeDir}/#{file}.coffee", (err, stdout, stderr) ->
            if err then handleError err else read file

    # compile parser
    exec "pegjs --track-line-and-column #{pegjsFile} #{prodTargetJsDir}/reader.js", (err, stdout, stderr) ->
        if err then handleError err else util.log "  Compiled #{pegjsFile}"

    read = (file) ->
        fs.readFile "#{prodTargetJsDir}/#{file}.js"
                  , 'utf8'
                  , (err, fileContents) ->
            handleError(err) if err
            appContents.push fileContents
            util.log "  Compiled #{file}.js"
            process() if --remaining == 0

    process = ->
        fs.writeFile prodTargetJsFile
                   , appContents.join('\n\n')
                   , 'utf8'
                   , (err) ->
            handleError(err) if err
            message = "Written #{prodTargetJsFile}"
            util.log message

            for file in prodCoffeeFiles then do (file) ->
                fs.unlink "#{prodTargetJsDir}/#{file}.js", (err) -> handleError(err) if err

task 'watch:test', 'Watch test specs and build changes', ->
    invoke 'build:test'
    util.log "Watching for changes in #{testSrcCoffeeDir}"
    
    fs.readdir testSrcCoffeeDir, (err, files) ->
        handleError(err) if err
        for file in files then do (file) ->
            fs.watchFile "#{testSrcCoffeeDir}/#{file}", (curr, prev) ->
                if +curr.mtime isnt +prev.mtime
                    coffee testCoffeeOpts, "#{testSrcCoffeeDir}/#{file}"

task 'build:test', 'Build individual test specs', ->
    util.log 'Building test specs'
    fs.readdir testSrcCoffeeDir, (err, files) ->
        handleError(err) if err
        for file in files then do (file) -> 
            coffee testCoffeeOpts, "#{testSrcCoffeeDir}/#{file}"

task 'uglify', 'Minify and obfuscate', ->
    jsp = uglify.parser
    pro = uglify.uglify

    fs.readFile prodTargetJsFile, 'utf8', (err, fileContents) ->
        ast = jsp.parse fileContents  # parse code and get the initial AST
        ast = pro.ast_mangle ast # get a new AST with mangled names
        ast = pro.ast_squeeze ast # get an AST with compression optimizations
        final_code = pro.gen_code ast # compressed code here
    
        fs.writeFile prodTargetJsMinFile, final_code
        # fs.unlink prodTargetJsFile, (err) -> handleError(err) if err
        
        message = "Uglified #{prodTargetJsMinFile}"
        util.log message
    
coffee = (options = "", file) ->
    util.log "Compiling #{file}"
    exec "coffee #{options} --compile #{file}", (err, stdout, stderr) -> 
        handleError(err) if err

handleError = (error) -> 
    util.log error
