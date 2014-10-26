
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
		pdf:
			icon: "file-pdf-o"
			type: [ "application/pdf" ]
		video:
			icon: "file-movie-o"
			type: [ "video/mp4", "video/x-matroska" ]
		subtitle:
			icon: "file-text-o"
			type: [ "application/x-subrip" ]
		binary:
			icon: "file-o"
			type: [ "application/octet-stream" ]


	constructor: (@mime) ->


	type: ->
		for t, d of MimeType.correspondence
			for m in d.type
				if @mime is m
					return t
		return "binary"


	icon: (type)->
		if type == "file"
			MimeType.correspondence[@type()].icon
		else if type == "folder"
			"folder-o"
		else
			"file-o"





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
		data.json = JSON.stringify data, null, "\t"
		if data.inside
			data.inside =  ItemView.masterSort _.map data.inside, (i) ->
				pth = new AbsolutePath i.path
				r =
					item: i.item
					type: i.type
					path: pth.path()
					name: pth.name()
					hidden: pth.isHidden()
					isFolder: i.item == "folder"
					isFile: i.item == "file"
					icon: new MimeType(i.type).icon(i.item)
				return r
		return data


	@masterSortParam: [
		{ hidden: false, isFolder: true }
		{ hidden: true, isFolder: true }
		{ hidden: false, isFile: true }
		{ hidden: true, isFile: true }
	]


	@masterSort: (inside) ->
		r = []
		for param in ItemView.masterSortParam
			r.push _.filter inside, (i) ->
				for k, v of param
					if i[k] != v
						return false
				return true
		return _.uniq _.flatten r


	open: (@path, history = true)->
		$.getJSON "open", {@path}
			.done (data) =>
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
