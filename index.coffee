express = require "express"
path = require "path"
fs = require "fs"
async = require "async"
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



app.listen 1337