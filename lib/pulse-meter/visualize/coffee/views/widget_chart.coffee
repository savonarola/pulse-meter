WidgetChartView = Backbone.View.extend {
	tagName: 'div'

	initialize: (options) ->
		@pageInfos = options['pageInfos']
		@model.bind 'destroy', @remove, this

	updateData: (min, max) ->
		@presenter.draw(min, max)

	render: ->
		@presenter = WidgetPresenter.create(@pageInfos, @model, @el)
}
