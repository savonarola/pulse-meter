PageTitlesView = Backbone.View.extend {
	initialize: (@pageInfos) ->
		@pageInfos.bind 'reset', @render, this

	addOne: (pageInfo) ->
		view = new PageTitleView {
			model: pageInfo
		}
		view.render()
		$('#page-titles').append(view.el)

	render: ->
		$('#page-titles').empty()
		@pageInfos.each(@addOne)
}
