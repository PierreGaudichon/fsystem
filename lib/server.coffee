express = require "express"
path = require "path"
fs = require "fs"
async = require "async"
mime = require "mime"

{server, commander} = require "./app"


folder =
	path: "/home/pierre"
	name: "pierre"
	size: 15
	inside: []

file =
	path: "/home/pierre/test"
	name: "test"
	type: "ASCII text"
	content: {} # if size < 10kb



resolve = (pth) ->
	if typeof pth is "string"
		path.resolve path.join commander.root, pth
	else
		path.resolve commander.root



# http://stackoverflow.com/a/24977085
# to coffeescript
# with modification
streamContent = (req, res, file) ->
	range = req.headers.range || "bytes=0-" # the or contiditon is not tested enought
	positions = range.replace(/bytes=/, "").split "-"
	start = parseInt positions[0], 10

	fs.stat file, (err, stats) ->
		if err
			res.status(404).send()
		else
			total = stats.size
			end = if positions[1] then parseInt(positions[1], 10) else total - 1
			chunksize = (end - start) + 1

			res.writeHead 206,
				"Content-Range": "bytes #{start}-#{end}/#{total}",
				"Accept-Ranges": "bytes",
				"Content-Length": chunksize,
				"Content-Type": mime.lookup file

			stream = fs.createReadStream file, {start, end}
				.on "open", () ->
					stream.pipe res
				.on "error", (err) ->
					res.end err



augmentPath = (pth, callback) ->
	fs.lstat pth, (err, stat) ->
		if err
			callback err,
				path: pth
				item: "unknown"

		if stat.isFile()
			item = "file"
		else if stat.isDirectory()
			item = "folder"

		callback null,
			path: pth
			item: item
			type: mime.lookup pth



readDir = (pth, stats, callback) ->
	r =
		item: "folder"
		path: pth
		inside: []

	fs.readdir pth, (err, files=[]) ->
		r.size = files.length
		async.map files,
			(i, callback) ->
				augmentPath path.join(pth, i), callback
			(err, result) ->
				r.inside = result
				callback err, r



readFile = (pth, stats, callback) ->
	r =
		item: "file"
		path: pth
		name: path.basename pth
		type: mime.lookup pth
		size: stats.size

	callback null, r



server.use express.static path.join __dirname, "../public"
server.use express.static path.join __dirname, "../bower_components"
server.use express.static path.join __dirname, "../node_modules"



server.get "/open", (req, res) ->
	pth = resolve req.query.path
	console.log "/open : #{pth}"

	fs.lstat pth, (err, stats) ->
		if err then res.status(500).send "error-stats"

		if stats.isDirectory()
			readDir pth, stats, (err, data) ->
				if err then res.status(500).send "error-folder"
				res.send JSON.stringify data

		else if stats.isFile()
			readFile pth, stats, (err, data) ->
				if err then res.status(500).send "error-file"
				res.send JSON.stringify data

		else
			if err then res.status(500).send "error-fileType"



# Tests files
# /home/pierre/dev/fsystem/test-files/MF2.pdf
# /home/pierre/dev/fsystem/test-files/MF2.pdf
# http://127.0.0.1:1337/file?path=/home/pierre/dev/fsystem/test-files/movie.pdf
# http://127.0.0.1:1337/file?path=/home/pierre/dev/fsystem/test-files/MF2.pdf
server.get "/file", (req, res) ->
	pth = resolve req.param "path"
	console.log "/file : #{pth}"
	streamContent req, res, pth



server.listen commander.port