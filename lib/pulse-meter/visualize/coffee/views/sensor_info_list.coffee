SensorInfoListView = Backbone.View.extend {
	tagName: 'div'

	template: ->
		_.template($("#sensor-list").html())

	initialize: (sensorInfo) ->
		@sensorInfo = sensorInfo
		@sensorInfo.bind 'reset', @render, this

	render: ->
		@$el.html @template()({sensors: @sensorInfo.toJSON()})

	selectedSensors: ->
		checked = _.filter @$el.find('.sensor-box'), (el) -> $(el).is(':checked')
		ids = {}
		_.each checked, (box) -> ids[box.id] = true
		selected = @sensorInfo.filter (sensor) -> ids[sensor.id]
}
