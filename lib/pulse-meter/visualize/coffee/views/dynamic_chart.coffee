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
		"change #start-time input": 'maybeEnableStopTime'
		"click #set-interval": 'setTimelineInterval'
	}

	template: -> _.template($("#dynamic-widget-plotarea").html())

	render: ->
		@$el.html(@template()())
		@initDatePickers()

	initDatePickers: ->
		@$el.find(".datepicker").each (i) ->
			$(this).datetimepicker
				showOtherMonths: true
				selectOtherMonths: true
		@$el.find("#end-time input").prop("disabled", true)

	setTimelineInterval: ->
		start = @unixtimeFromDatepicker("#start-time input")
		end = @unixtimeFromDatepicker("#end-time input")
		@widget.setStartTime(start)
		@widget.setEndTime(end)
		@update()

	dateFromDatepicker: (id) ->
		@$el.find(id).datetimepicker("getDate")

	unixtimeFromDatepicker: (id) ->
		date = @dateFromDatepicker(id)
		if date
			date.getTime() / 1000
		else
			null

	maybeEnableStopTime: ->
		date = @dateFromDatepicker("#start-time input")
		disabled = if date then false else true
		@$el.find("#end-time input").prop("disabled", disabled)

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
