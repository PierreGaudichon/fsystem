express = require "express"
commander = require "commander"



module.exports.server = express()
module.exports.commander = commander



require "./cli"
require "./server"