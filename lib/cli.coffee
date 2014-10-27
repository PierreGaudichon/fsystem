path = require "path"
mkdirp = require "mkdirp"

{commander} = require "./app"



commander
	.version "0.0.1"
	.option "-p, --port [number]", "Web server port.", 1337
	.option "-r, --root [path]", "Root of the server.", "root"
	.parse process.argv



mkdirp path.resolve commander.root



#root = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE