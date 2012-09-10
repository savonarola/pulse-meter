Widget = Backbone.Model.extend {
	initialize: ->
		@needRefresh = true
		@setNextFetch()
		@timespanInc = 0

	increaseTimespan: (inc) ->
		@timespanInc = @timespanInc + inc
		@forceUpdate()

	resetTimespan: ->
		@timespanInc = 0
		@forceUpdate()

	timespan: -> @get('timespan') + @timespanInc

	url: ->
		timespan = @timespan()
		if _.isNaN(timespan)
			"#{@collection.url()}/#{@get('id')}"
		else
			"#{@collection.url()}/#{@get('id')}?timespan=#{timespan}"

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
