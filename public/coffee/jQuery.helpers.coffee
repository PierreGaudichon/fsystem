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



window.creates = (el, txt) -> $("<#{el} />").text(txt)