
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
		r = []
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



augmentData = (data) ->
	pth = new AbsolutePath(data.path)
	data.parent =  pth.parent().str()
	data.hidden = pth.isHidden()
	data.name = pth.name()
	if data.inside
		data.inside = _.map data.inside, (i) ->
			pth = new AbsolutePath i.path
			r =
				item: i.item
				path: pth.path()
				name: pth.name()
				hidden: pth.isHidden()
				isFolder: i.item == "folder"
				isFile: i.item == "file"
			return r
	return data



class ItemView

	view: "jQuery"
	breadcrumb: "jQuery"
	path: "/"
	item: {}


	constructor: (view) ->
		@view = $ view
		@breadcrumb = creates("div").attr("<cl></cl>ass", "breadcrumb").appendTo @view
		@list = creates("div").attr("class", "list").appendTo @view

		at = @
		@view.on "click", "[data-open]", ->
			at.open $(@).data("open")




	open: (@path)->
		$.getJSON "open", {@path}
			.done (data) =>
				@item = augmentData data
				console.log @item
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


	templateBreadcrunb: ->
		breadcrumb = new AbsolutePath(@path).breadcrumb()
		@breadcrumb.sideburns "breadcrumb", {breadcrumb}


	initialize: -> @open()



$ ->
	view = new ItemView "#mainView"
	view.initialize()
	view.open("/home/pierre/dev/fsystem")
