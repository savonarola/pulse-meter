PageTitle = Backbone.Model.extend {
	defaults: ->
		{ title: "" }
	initialize: ->
		if !@get('title')
			@set {
				'title': @defaults.title
			}
	clear: ->
		@destroy()
}

PageTitleList = Backbone.Collection.extend {
	model: PageTitle
	url: ROOT + 'page_titles'
}

PageTitles = new PageTitleList

PageTitleView = Backbone.View.extend {
	tagName: 'li'
	
	template: _.template('<%= title %>')
		
	events: {
		'click': 'doAlert'
	}

	initialize: ->
		@model.bind 'change', @render, this
		@model.bind 'destroy', @remove, this

	render: ->
		@$el.html @template(@model.toJSON())

	doAlert: ->
		alert "HI!"
}

AppView = Backbone.View.extend {
	el: $('#pulse-app')
	initialize: ->
		PageTitles.bind 'add', @addOne, this
		PageTitles.bind 'reset', @addAll, this
		PageTitles.bind 'all', @render, this

		PageTitles.fetch()

	render: ->
		# Nothing to do here!

	addOne: (page_title) ->
		view = new PageTitleView {
			model: page_title
		}
		view.render()
		console.log(page_title, view, view.el)
		@$('#page-titles').append(view.el)

	addAll: ->
		PageTitles.each(@addOne)

}

App = new AppView
