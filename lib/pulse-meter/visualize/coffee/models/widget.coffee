Widget = Backbone.Model.extend {
	initialize: ->
		@needRefresh = true
		@setNextFetch()
		@timespanInc = 0

	setStartTime: (@startTime) ->

	setEndTime: (@endTime) ->

	increaseTimespan: (inc) ->
		@timespanInc = @timespanInc + inc
		@forceUpdate()

	resetTimespan: ->
		@timespanInc = 0
		@startTime = null
		@endTime = null
		@forceUpdate()

	timespan: -> @get('timespan') + @timespanInc

	url: ->
		timespan = @timespan()
		url = "#{@collection.url()}/#{@get('id')}?foo=1"
		url += "&timespan=#{timespan}" unless _.isNaN(timespan)
		url += "&startTime=#{@startTime}" if @startTime
		url += "&endTime=#{@endTime}" if @endTime
		console.log(url)
		url

	time: -> (new Date()).getTime()

	setNextFetch: ->
		@nextFetch = @time() + @get('redrawInterval') * 1000

	setRefresh: (needRefresh) ->
		@needRefresh = needRefresh

	needFetch: ->
		interval = @get('redrawInterval')
		@time() > @nextFetch && @needRefresh && interval? && interval > 0

	refetch: ->
		if @needFetch()
			@forceUpdate()
			@setNextFetch()

	forceUpdate: ->
		@fetch {
			success: (model, response) ->
				model.trigger('redraw')
		}

}
