DynamicChartView = Backbone.View.extend {
	initialize: (options) ->
		@pageInfos = options['pageInfos']
		@sensors = []
		@type = 'Area'
		@widget = new DynamicWidget
		
		@widget.bind('destroy', @remove, this)
		@widget.bind('redraw', @redrawChart, this)

	tagName: 'div'

	events: {
		"click #refresh-chart": 'update'
		"click #extend-timespan": 'extendTimespan'
		"click #reset-timespan": 'resetTimespan'
	}

	template: -> _.template($("#dynamic-widget-plotarea").html())

	render: ->
		@$el.html(@template()())

	extendTimespan: ->
		select = @$el.find("#extend-timespan-val")
		val = select.first().val()
		@widget.increaseTimespan(parseInt(val))
		@update()

	resetTimespan: ->
		@widget.resetTimespan()
		@update()

	sensorIds: -> _.map(@sensors, (s) -> s.id)

	redrawChart: ->
		if @presenter
			@presenter.draw()
		else
			@presenter = WidgetPresenter.create(@pageInfos, @widget, @chartContainer())


	chartContainer: ->
		@$el.find('#chart')[0]

	update: ->
		@widget.forceUpdate() if @sensors.length > 0

	draw: (sensors, type) ->
		@sensors = sensors
		@type = type

		@widget.set('sensorIds', @sensorIds())
		@widget.set('type', @type)
		
		@presenter = null
		$(@chartContainer()).empty()
		@widget.forceUpdate()
}

