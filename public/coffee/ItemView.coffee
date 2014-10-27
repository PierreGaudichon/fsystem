class window.ItemView

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
		{ hidden: true, isFolder: true }
		{ hidden: false, isFolder: true }
		{ hidden: true, isFile: true }
		{ hidden: false, isFile: true }
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
		#@list.sideburns "file", @item
		window.location.replace "file?path=#{@path}"


	templateBreadcrunb: ->
		breadcrumb = new AbsolutePath(@path).breadcrumb()
		@breadcrumb.sideburns "breadcrumb", {breadcrumb}


	initialize: -> @open "/"


	previous: ->
		if @history.length == 0
			@path
		else
			@history[@history.length-1]