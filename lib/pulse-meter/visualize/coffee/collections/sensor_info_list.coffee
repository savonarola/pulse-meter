SensorInfoList = Backbone.Collection.extend {
	model: SensorInfo
	url: -> ROOT + 'sensors'
}
