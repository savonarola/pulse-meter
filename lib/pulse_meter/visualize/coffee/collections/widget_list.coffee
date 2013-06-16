WidgetList = Backbone.Collection.extend {
	model: Widget

	setContext: (@pageInfos) ->

	url: -> ROOT + 'pages/' + @pageInfos.selected().id + '/widgets'

	startPolling: ->
		setInterval( =>
			if @pageInfos.selected()
				@each (w) ->
					w.refetch()
		, 200)
}
