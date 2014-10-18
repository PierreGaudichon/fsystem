express = require "express"
path = require "path"
fs = require "fs"
_ = require "lodash"
#istextorbinary = require "istextorbinary"
app = express()




folder =
	path: "/home/pierre"
	name: "pierre"
	size: 15
	inside: []


file =
	path: "/home/pierre/test"
	name: "test"
	type: "ASCII text"
	content: {} # to be requested



removeHidden = (files) ->
	_.filter files, (f) -> f[0] != "."



parent = (pth) ->
	pth = _.compact pth.split "/"
	if pth.length == 0
		"/"
	else
		pth.length -= 1
		"/" + pth.join "/"


readDir = (pth, stats, callback) ->
	r =
		item: "folder"
		path: pth
		name: path.basename pth
		inside: []

	r.inside.push
		path: parent pth
		name: ".."

	fs.readdir pth, (err, files) ->
		r.size = files.length
		for f in removeHidden files
			r.inside.push
				path: path.join pth, f
				name: f

		callback err, r



readFile = (pth, stats, callback) ->
	r =
		item: "file"
		path: pth
		name: path.basename pth
		type: "unknown"
		size: stats.size

	if r.size < 10**5 # 10 ko
		fs.readFile r.path, {encoding: "utf-8"}, (err, data) ->
			r.content = data
			callback err, r

	else
		callback null, r



app.use express.static path.join __dirname, "public"
app.use express.static path.join __dirname, "bower_components"
app.use express.static path.join __dirname, "node_modules"



app.get "/root", (req, res) ->
	res.send JSON.stringify {root: __dirname}


app.get "/open", (req, res) ->
	pth = req.query.path
	console.log "/open : #{pth}"

	fs.lstat pth, (err, stats) ->

		if stats.isDirectory()
			readDir pth, stats, (err, data) ->
				res.send JSON.stringify data

		else if stats.isFile()
			readFile pth, stats, (err, data) ->
				res.send JSON.stringify data

		else
			res.send ""



app.listen 1337