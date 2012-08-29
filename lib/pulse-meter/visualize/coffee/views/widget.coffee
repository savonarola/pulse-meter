WidgetView = Backbone.View.extend {
	tagName: 'div'

	template: ->
		_.template($(".widget-template[data-widget-type=\"#{@model.get('type')}\"]").html())

	initialize: (options) ->
		@pageInfos = options['pageInfos']
		@model.bind('destroy', @remove, this)
		@model.bind('redraw', @updateChart, this)

	events: {
		"click #refresh": 'refresh'
		"click #need-refresh": 'setRefresh'
		"click #extend-timespan": 'extendTimespan'
		"click #reset-timespan": 'resetTimespan'
	}

	refresh: ->
		@model.forceUpdate()

	setRefresh: ->
		needRefresh = @$el.find('#need-refresh').is(":checked")
		@model.setRefresh(needRefresh)
		true

	extendTimespan: ->
		select = @$el.find("#extend-timespan-val")
		val = select.first().val()
		@model.increaseTimespan(parseInt(val))

	resetTimespan: ->
		@model.resetTimespan()

	renderChart: ->
		@chartView.render()

	updateChart: ->
		@chartView.updateData(@cutoffMin(), @cutoffMax())

	render: ->
		@$el.html @template(@model.toJSON())
		@chartView = new WidgetChartView {
			pageInfos: @pageInfos
			model: @model
		}
		@$el.find("#plotarea").append(@chartView.el)
		@$el.addClass("span#{@model.get('width')}")

	cutoffMin: ->
		val = parseFloat(@controlValue('#cutoff-min'))
		if _.isNaN(val) then null else val

	cutoffMax: ->
		val = parseFloat(@controlValue('#cutoff-max'))
		if _.isNaN(val) then null else val

	controlValue: (id) ->
		val = @$el.find(id).first().val()


}
