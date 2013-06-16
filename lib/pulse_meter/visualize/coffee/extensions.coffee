String::capitalize = ->
	@charAt(0).toUpperCase() + @slice(1)
String::strip = ->
	if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

Number::humanize = ->
	interval = this
	res = ""
	s = interval % 60
	res = "#{s} s" if s > 0
	interval = (interval - s) / 60
	return res unless interval > 0

	m = interval % 60
	res = "#{m} m #{res}".strip() if m > 0
	interval = (interval - m) / 60
	return res unless interval > 0

	h = interval % 24
	res = "#{h} h #{res}".strip() if h > 0
	d = (interval - h) / 24
	if d > 0
		"#{d} d #{res}".strip()
	else
		res

