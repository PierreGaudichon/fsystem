

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





parent = (pth) ->
	pth = _.compact pth.split "/"
	if pth.length == 0
		"/"
	else
		pth.length -= 1
		"/" + pth.join "/"



class ItemView

	el: "jQuery"
	path: "/"
	item: {}


	constructor: (@el) ->
		@list = @el.find ".list"
		@content = @el.find ".content"
		@title = $ "head title"
		@header = $ "h1"


	open: (@path)->
		$.getJSON "open", {@path}
			.done (data) =>
				@item = data
				@template()
			.fail =>
				@header.text "Server Error."
				console.log "fail loading : #{@path}."
		return null


	template: ->
		@title.text @item.name
		@header.text "fsystem - #{@item.name}"
		switch @item.item
			when "folder" then @templateFolder()
			when "file" then @templateFile()


	templateFolder: ->
		@templateEmpty()
		for item in @item.inside
			do (item) =>
				el = $ "<li />"
					.text item.name
					.click =>
						@open item.path
				@list.append el
		return null


	templateFile: ->
		@templateEmpty()
		p = parent @item.path
		@content.find(".parent")
			.text p
			.click =>
				@open p
		@content.find("h2").text @item.name
		@content.find("pre").text @item.content || "Not a text file."


	templateEmpty: ->
		@list.empty()
		@content.children().empty()


	initialize: ->
		$.getJSON "root"
			.done (data) =>
				@open data.root
			.fail ->
				console.log "root : failed"





$ ->
	view = new ItemView $ ".view"
	view.initialize()

	$(".test div").sideburns "folderView", {a: "e"}


