path = require "path"
mkdirp = require "mkdirp"

{commander} = require "./app"



commander
	.version "0.0.1"
	.option "-p, --port [number=1337]", "Set the web server port.", 1337
	.option "-r, --root [path=./root]", "Set the root of the server.", "root"
	.option "-v, --verbose", "Display routing informations."
	.parse process.argv



mkdirp path.resolve commander.root



#root = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE