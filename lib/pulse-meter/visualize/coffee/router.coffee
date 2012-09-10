AppRouter = Backbone.Router.extend {
	initialize: (@pageInfos, @widgetList) ->
	routes: {
		'pages/:id': 'getPage'
		'custom': 'custom'
		'*actions': 'defaultRoute'
	}
	getPage: (ids) ->
		id = parseInt(ids)
		@pageInfos.selectPage(id)
		@widgetList.fetch()
	custom: ->
		@pageInfos.selectNone()
		dynamicWidget = new DynamicWidgetView {pageInfos: @pageInfos}
		dynamicWidget.render($('#widgets'))
	defaultRoute: (actions) ->
		if @pageInfos.length > 0
			@navigate('//pages/1')
		else
			@navigate('//custom')
}
