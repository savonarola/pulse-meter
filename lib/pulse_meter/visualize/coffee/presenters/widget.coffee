class WidgetPresenter
	constructor: (@pageInfos, @model, el) ->
		chartClass = @chartClass()
		@chart = new chartClass(el)
		@draw()

	get: (arg) -> @model.get(arg)

	globalOptions: -> gon.options

	dateOffset: ->
		if @globalOptions.useUtc
			(new Date).getTimezoneOffset() * 60000
		else
			0
	
	options: ->
		{
			title: @get('title')
			height: 300
			chartArea:
				left: 10
		}

	mergedOptions: ->
		pageOptions = if @pageInfos.selected()
			@pageInfos.selected().get('gchartOptions')
		else
			{}

		$.extend(true,
			@options(),
			@globalOptions.gchartOptions,
			pageOptions,
			@get('gchartOptions')
		)

	data: -> new google.visualization.DataTable

	chartClass: -> google.visualization[@visualization]

	cutoff: ->
	
	cutoffValue: (v, min, max) ->
		if v?
			if min? && v < min
				min
			else if max? && v > max
				max
			else
				v
		else
			0

	draw: (min, max) ->
		@cutoff(min, max)
		@chart.draw(@data(), @mergedOptions())

WidgetPresenter.create = (pageInfos, model, el) ->
	type = model.get('type')
	if type? && type.match(/^\w+$/)
		presenterClass = eval("#{type.capitalize()}Presenter")
		new presenterClass(pageInfos, model, el)
	else
		null
