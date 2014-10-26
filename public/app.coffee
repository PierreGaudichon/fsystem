
do ($ = jQuery) ->

	all = {}

	sideburns = (name, data) ->
		$(@).html Mustache.render all[name], data
		return @

	$ ->
		$("[type='x-tmpl-mustache']").each (k, t) =>
			template = $(t).html()
			name = $(t).attr("id")
			Mustache.parse template
			all[name] = template

	$.fn.sideburns = sideburns



creates = (el, txt) -> $("<#{el} />").text(txt)




class MimeType

	@correspondence:
		pdf: [ "application/pdf" ]
		video: [ "video/mp4", "video/x-matroska" ]
		binary: [ "application/octet-stream" ]


	constructor: (@mime) ->


	type: ->
		for t, ms of @correspondence
			for m in ms
				if @mime is m
					return t
		return "application/octet-stream"







class AbsolutePath

	@fromArray: (arr) ->
		a = new AbsolutePath
		a.arr = arr
		return a

	arr: []

	constructor: (str="/") ->
		@arr = @strToArr str

	strToArr: (str) ->
		_.compact str.split "/"

	path: -> @str()
	str: ->
		"/" + @arr.join "/"

	name: ->
		@arr[@arr.length-1] || "/"

	parent: ->
		if @arr.length == 0
			new AbsolutePath
		else
			arr = _.clone @arr
			arr.length -= 1
			AbsolutePath.fromArray arr

	breadcrumb: ->
		pth = []
		r = [{path: "/", name: "/"}]
		for i in @arr
			pth.push i
			p = AbsolutePath.fromArray pth
			r.push
				path: p.path()
				name: p.name()
		return r

	isHidden: ->
		@name()[0] == "."


cl.param.defaultHtm = "pjson"



removeHidden = (files) ->
	_.filter files, (f) -> f[0] != "."







class ItemView

	view: "jQuery"
	list: "jQuery"
	breadcrumb: "jQuery"
	path: "/"
	item: {}
	history: []


	constructor: (view) ->
		@view = $ view
		@breadcrumb = creates("div").attr("class", "breadcrumb").appendTo @view
		@list = creates("div").attr("class", "list").appendTo @view

		@history = []

		at = @
		@view.on "click", "[data-open]", ->
			at.open $(@).data("open")

		@view.on "click", "[data-previous]", ->
			at.history.pop() if at.history.length > 1
			at.open $(@).data("previous"), false


	augmentData: (data) ->
		pth = new AbsolutePath(data.path)
		data.parent =  pth.parent().str()
		data.hidden = pth.isHidden()
		data.name = pth.name()
		data.previous = @previous()
		if data.inside
			data.inside = _.map data.inside, (i) ->
				pth = new AbsolutePath i.path
				r =
					item: i.item
					type: i.type
					path: pth.path()
					name: pth.name()
					hidden: pth.isHidden()
					isFolder: i.item == "folder"
					isFile: i.item == "file"
				return r
		return data


	open: (@path, history = true)->
		$.getJSON "open", {@path}
			.done (data) =>
				console.log @item
				console.log @history
				@item = @augmentData data
				if history then @history.push @path
				@path = @item.path
				@template()
			.fail =>
				console.log "fail loading : #{@path}."
		return null


	template: ->
		@templateBreadcrunb()
		switch @item.item
			when "folder" then @templateFolder()
			when "file" then @templateFile()


	templateFolder: ->
		@list.sideburns "folder", @item


	templateFile: ->
		@list.sideburns "file", @item
		#window.location.replace "file?path=#{@path}"


	templateBreadcrunb: ->
		breadcrumb = new AbsolutePath(@path).breadcrumb()
		@breadcrumb.sideburns "breadcrumb", {breadcrumb}


	initialize: -> @open()


	previous: ->
		if @history.length == 0
			@path
		else
			@history[@history.length-1]



$ ->
	view = new ItemView "#mainView"
	#view.initialize()
	view.open "/home/pierre/dev/fsystem"
