express = require "express"
path = require "path"
fs = require "fs"
async = require "async"
mime = require "mime"

{server, commander} = require "./app"
File = require "./File"


display = (str) ->
	if commander.verbose
		console.log str



server.use express.static path.join __dirname, "../public"
server.use express.static path.join __dirname, "../bower_components"
server.use express.static path.join __dirname, "../node_modules"



server.get "/open", (req, res) ->
	new File req.query.path, false, (f) ->
		display "/open : #{f.requestedPath}"
		f.send req, res



# Tests files
# /home/pierre/dev/fsystem/test-files/MF2.pdf
# /home/pierre/dev/fsystem/test-files/MF2.pdf
# http://127.0.0.1:1337/file?path=/home/pierre/dev/fsystem/test-files/movie.pdf
# http://127.0.0.1:1337/file?path=/home/pierre/dev/fsystem/test-files/MF2.pdf

server.get "/file", (req, res) ->
	new File req.param("path"), false, (f) ->
		display "/file : #{f.requestedPath}"
		f.stream req, res



server.listen commander.port
display "Server started on port #{commander.port} and serving files from #{path.resolve commander.root}."
