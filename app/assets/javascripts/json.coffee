
@getJsonProgrammesURL = (time, length, broadcast, ch) ->
	retURL = "/json/programmes"
	retURL = retURL + "/" + time.getFullYear()
	retURL = retURL + "/" + ("0"+(time.getMonth() + 1)).slice(-2)
	retURL = retURL + "/" + ("0"+time.getDate()).slice(-2)
	retURL = retURL + "/" + ("0"+time.getHours()).slice(-2)
	retURL = retURL + "/" + ("0"+time.getMinutes()).slice(-2)
	retURL = retURL + "/" + ("0"+length).slice(-3)
	retURL = retURL + "/" + broadcast
	retURL = retURL + "/" + ch

@getJsonDisplayAreaURL = (time, length) ->
	retURL = "/json/displayarea"
	retURL = retURL + "/" + time.getFullYear()
	retURL = retURL + "/" + ("0"+(time.getMonth() + 1)).slice(-2)
	retURL = retURL + "/" + ("0"+time.getDate()).slice(-2)
	retURL = retURL + "/" + ("0"+time.getHours()).slice(-2)
	retURL = retURL + "/" + ("0"+time.getMinutes()).slice(-2)
	retURL = retURL + "/" + ("0"+length).slice(-3)

@getJsonChannelNameURL = (ch) ->
	retURL = "/json/name"
	retURL = retURL + "/" + ch
