class window.AbsolutePath

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