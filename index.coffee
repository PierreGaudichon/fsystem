express = require "express"
path = require "path"
fs = require "fs"
async = require "async"
mime = require "mime"
#_ = require "lodash"
app = express()



root = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

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
		type: "unknown"
		size: stats.size

	if r.size < 10**5 * 8 # 10 ko
		fs.readFile r.path, {encoding: "utf-8"}, (err, data="") ->
			r.content = data
			callback err, r

	else
		r.isTooBig = true
		callback null, r



app.use express.static path.join __dirname, "public"
app.use express.static path.join __dirname, "bower_components"
app.use express.static path.join __dirname, "node_modules"



app.get "/open", (req, res) ->
	pth = req.query.path || root
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



app.get "/file/:name", (req, res) ->
	streamContent req, res, "test-files/#{req.param 'name'}"




app.listen 1337