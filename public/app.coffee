

class ItemView

	el: "jQuery"
	path: "/"
	item: {}


	constructor: (@el) ->


	open: (@path)->
		$.getJSON "open", {@path}
			.done (data) =>
				@item = data
				@template()
			.fail -> console.log "fail loading : #{@path}."
		return null


	template: ->
		switch @item.item
			when "folder" then @templateFolder()
			when "file" then @templateFile()


	templateFolder: ->
		@el.empty()
		for item in @item.inside
			do (item) =>
				el = $ "<li />"
					.text item.name
					.click =>
						@open item.path
				@el.append el
		return null


	initialize: ->
		$.getJSON "root"
			.done (data) =>
				@open data.root
			.fail ->
				console.log "root : failed"


	templateFile: ->
		#@el.empty()



$ ->
	view = new ItemView $ ".list"
	view.initialize()



