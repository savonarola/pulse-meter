DynamicWidget = Backbone.Model.extend {

	setStartTime: (@startTime) ->

	setEndTime: (@endTime) ->

	increaseTimespan: (inc) ->
		@set('timespan', @timespan() + inc)

	resetTimespan: ->
		@startTime = null
		@endTime = null
		@set('timespan', null)

	timespan: -> @get('timespan')

	sensorArgs: ->
		_.map(@get('sensorIds'), (name) -> "sensor[]=#{name}").join('&')

	url: ->
		timespan = @timespan()
		url = "#{ROOT}dynamic_widget?#{@sensorArgs()}&type=#{@get('type')}"
		url += "&timespan=#{timespan}" if timespan? && !_.isNaN(timespan)
		url += "&startTime=#{@startTime}" if @startTime
		url += "&endTime=#{@endTime}" if @endTime
		url

		
	forceUpdate: ->
		@fetch {
			success: (model, response) ->
				model.trigger('redraw')
		}
}
