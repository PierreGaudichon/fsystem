
# Params
# ------------------------------------------------------------------------------

param =
	defaultHtm: "none"



# IO
# ------------------------------------------------------------------------------


send = (str = "", htm) ->
	if isSocket
		emitSocket str, htm

	display str, htm


display = (str, htm) ->
	h = process str, htm, "html"
	c = process str, htm, "console"

	if console? and console.log?
		console.log c

	if isHTML
		emitHTML h

	log.push {str, htm, time: new Date()}

log = []



# Helpers
# ------------------------------------------------------------------------------


process = (str, htm, env) ->
	if htm == ""
		return str

	if matching[htm]?
		m = matching[htm]
	else if matching[param.defaultHtm]?
		m = matching[param.defaultHtm]
	else
		return str

	if m == "json"
		return JSON.stringify str
	else if m == "pjson"
		return JSON.stringify str, null, "\t"

	sementics[env][m] str


times = (str, n) ->
	r = ""
	for i in [0...n] by 1
		r += str
	return r



# Semantics
# ------------------------------------------------------------------------------


matching =
	"n": "none"
	"none": "none"
	"no": "none"
	"json": "json"
	"j": "json"
	"pjson": "pjson"
	"pj": "pjson"
	"pretty-json": "pjson"
	"h1": "h1"
	"h2": "h2"
	"h3": "h3"
	"h4": "h4"
	"h5": "h5"
	"h6": "h6"
	"#": "h1"
	"##": "h2"
	"###": "h3"
	"####": "h4"
	"#####": "h5"
	"######": "h6"
	"*": "em"
	"_": "em"
	"em": "em"
	"**": "strong"
	"__": "strong"
	"strong": "strong"
	"-": "li"
	"+": "li"
	"li": "li"
	"go": "go"


sementics =
	console:
		"h1": (s) -> "\n" + s + "\n" + times("=", s.length) + "\n"
		"h2": (s) -> "\n" + s + "\n" + times("-", s.length) + "\n"
		"h3": (s) -> "\n" + "### " + s + "\n"
		"h4": (s) -> "\n" + "#### " + s + "\n"
		"h5": (s) -> "\n" + "##### " + s + "\n"
		"h6": (s) -> "\n" + "###### " + s + "\n"
		"em": (s) -> "	" + s
		"strong": (s) -> "!	" + s
		"li": (s) -> " \u2022 " + s
		"go": (s) -> "\u25B6 " + s
		"none": (s) -> s

	html:
		"h1": (s) -> "<h1>#{s}</h1>"
		"h2": (s) -> "<h2>#{s}</h2>"
		"h3": (s) -> "<h3>#{s}</h3>"
		"h4": (s) -> "<h4>#{s}</h4>"
		"h5": (s) -> "<h5>#{s}</h5>"
		"h6": (s) -> "<h6>#{s}</h6>"
		"em": (s) -> "<em>#{s}</em>"
		"strong": (s) -> "<strong>#{s}</strong>"
		"li": (s) -> "&bull; #{s}"
		"go": (s) -> "&#9654; #{s}"
		"none": (s) -> s


# Socket Management
# ------------------------------------------------------------------------------


socket = null

isSocket = false

setSocket = (soc) ->
	socket = soc
	isSocket = true
	socket.on "cl-message", ({str, htm}) ->
		display str, htm

emitSocket = (str, htm) ->
	socket.emit "cl-message", {str, htm}



# HTML Management
# ------------------------------------------------------------------------------


contener = null
isHTML = false

setHTML = (elem) ->
	if window? and document?
		contener = elem
		isHTML = true


emitHTML = (str) ->
	li = document.createElement "li"
	li.innerHTML = str
	contener.appendChild li



# Fun
# ------------------------------------------------------------------------------


# http://stackoverflow.com/a/9924463
STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg
ARGUMENT_NAMES = /([^\s,]+)/g
getParamNames = (func) ->
	fnStr = func.toString().replace STRIP_COMMENTS, ""
	result = fnStr.slice(fnStr.indexOf('(')+1, fnStr.indexOf(')')).match(ARGUMENT_NAMES)
	if !result?
		 result = []
	return result


mergeArrs = (a, b) ->
	r = {}
	for i, k in a
		r[i] = b[k]
	return r


fun = (t, f) -> ->
	r = f.apply t, arguments
	send
		fun: f
		args: mergeArrs getParamNames(f), arguments
		ret: r
		time: new Date()
	return r



# Exports
# ------------------------------------------------------------------------------


out = send
out.socket = setSocket
out.html = setHTML
out.param = param
out.log = log
out.fun = fun


if module? and module.exports?
	module.exports = out
else if window?
	window.cl = out