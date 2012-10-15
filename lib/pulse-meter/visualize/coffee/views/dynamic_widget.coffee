DynamicWidgetView = Backbone.View.extend {
	tagName: 'div'

	initialize: (options) ->
		@pageInfos = options['pageInfos']
		@sensorInfo = new SensorInfoList

		@sensorListView = new SensorInfoListView(@sensorInfo)
		@chartView = new DynamicChartView {pageInfos: @pageInfos}
	
		@$el.html(@template()())

		@$el.find('#sensor-list-area').append(@sensorListView.el)
		
		@chartView.render()
		@$el.find('#dynamic-plotarea').append(@chartView.el)

	events: {
		"click #sensor-controls #refresh": 'refresh'
		"click #sensor-controls #draw": 'drawChart'
	}

	template: ->
		_.template($("#dynamic-widget").html())

	errorTemplate: -> _.template($("#dynamic-widget-error").html())

	error: (error)->
		@$el.find('#errors').append(@errorTemplate()(error: error))

	refresh: ->
		@sensorInfo.fetch()

	intervalsEqual: (sensors) ->
		interval = sensors[0].get('interval')
		badIntervals = _.filter(sensors, (s) ->
			s.get('interval') != interval
		)
		badIntervals.length == 0

	drawChart: ->
		selectedSensors = @sensorListView.selectedSensors()
		return unless selectedSensors.length > 0

		unless @intervalsEqual(selectedSensors)
			@error('Selected sensors have different intervals')
			return

		type = @$el.find('#chart-type').val()
		@chartView.draw(selectedSensors, type)
		
	render: (container) ->
		container.empty()
		container.append(@$el)
		@sensorInfo.fetch()
		@chartView.update()
		
}
