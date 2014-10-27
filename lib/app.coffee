express = require "express"
commander = require "commander"



module.exports =
	commander: commander
	server: express()



require "./cli"
require "./server"