WidgetList = Backbone.Collection.extend {
	model: Widget
	setContext: (@pageInfos) ->
	url: -> ROOT + 'pages/' + @pageInfos.selected().id + '/widgets'
}
