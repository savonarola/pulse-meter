WidgetListView = Backbone.View.extend {
	initialize: (options) ->
		@widgetList = options['widgetList']
		@pageInfos = options['pageInfos']
		@widgetList.bind 'reset', @render, this
		
	render: ->
		container = $('#widgets')
		container.empty()
		@widgetList.each (w) =>
			view = new WidgetView { pageInfos: @pageInfos, model: w }
			view.render()
			container.append(view.el)
			view.renderChart()
}
