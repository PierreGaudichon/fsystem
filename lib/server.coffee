express = require "express"
path = require "path"
fs = require "fs"
async = require "async"
mime = require "mime"

{server, commander} = require "./app"



display = (str) ->
	if commander.verbose
		console.log str



class File

	@create = (r, s, c) -> new File r, s, c


	simple: false
	requestedPath: ""
	resolvedPath: ""
	item: ""
	type: ""
	stat: {}
	err: {}
	inside: []


	constructor: (@requestedPath="/", @simple, callback = ->) ->
		@err = null
		@inside = []

		@resolvedPath = @resolvePath()
		@populate callback


	resolvePath: ->
		if @requestedPath
			path.resolve path.join commander.root, @requestedPath
		else
			path.resolve commander.root


	populate: (callback) ->
		@getStats => @getInside => callback @



	getStats: (callback) ->
		fs.lstat @resolvedPath, (err, stat) =>
			if err
				@err = err
			else
				@stat = stat
				@item =
					if stat.isDirectory() then "folder"
					else if stat.isFile() then "file"
					else "unknown"
				@type = mime.lookup @resolvedPath
			callback()


	getInside: (callback) ->
		if @item is "folder" and not @simple
			fs.readdir @resolvedPath, (err, files) =>
				@inside = []
				if err
					@err = err
					callback()
				else
					for file, k in files
						file = path.join @.requestedPath, file
						cbk2 = if k isnt files.length-1 then -> else callback
						@inside.push new File file, true, cbk2
		else
			callback()


	toJSON: ->
		if @simple
			{path: @requestedPath, @item, @type}
		else if @item is "folder"
			inside = (i.toJSON() for i in @inside)
			{path: @requestedPath, @item, inside}
		else if @item is "file"
			{path: @requestedPath, @item, @type, @size}



	send: (req, res) ->
		if @err
			res.status(500).send @err
		else			res.send JSON.stringify @


	# http://stackoverflow.com/a/24977085
	# to coffeescript
	# with modification
	stream: (req, res) ->
		# the or contiditon is not tested enought
		range = req.headers.range || "bytes=0-"
		positions = range.replace(/bytes=/, "").split "-"
		start = parseInt positions[0], 10

		if @err
			res.status(404).send()
		else
			total = @stat.size
			end = if positions[1] then parseInt(positions[1], 10) else total - 1
			chunksize = (end - start) + 1

			res.writeHead 206,
				"Content-Range": "bytes #{start}-#{end}/#{total}",
				"Accept-Ranges": "bytes",
				"Content-Length": chunksize,
				"Content-Type": @type

			stream = fs.createReadStream @resolvedPath, {start, end}
				.on "open", () ->
					stream.pipe res
				.on "error", (err) ->
					res.end err



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
