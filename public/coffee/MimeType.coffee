class window.MimeType

	@correspondence:
		pdf:
			icon: "file-pdf-o"
			type: [ "application/pdf" ]
		music:
			icon: "music"
			type: [ "audio/mpeg" ]
		image:
			icon: "image"
			type: [ "image/jpeg" ]
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