DynamicWidget = Backbone.Model.extend {

	increaseTimespan: (inc) ->
		@set('timespan', @timespan() + inc)

	resetTimespan: ->
		@set('timespan', null)

	timespan: -> @get('timespan')

	sensorArgs: ->
		_.map(@get('sensorIds'), (name) -> "sensor[]=#{name}").join('&')

	url: ->
		url = "#{ROOT}dynamic_widget?#{@sensorArgs()}&type=#{@get('type')}"
		
		timespan = @timespan()
		url = "#{url}&timespan=#{timespan}" if timespan? && !_.isNaN(timespan)

		url

	forceUpdate: ->
		@fetch {
			success: (model, response) ->
				model.trigger('redraw')
		}
}
