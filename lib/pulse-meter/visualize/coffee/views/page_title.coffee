PageTitleView = Backbone.View.extend {
	tagName: 'li'

	template: _.template('<a href="#/pages/<%= id  %>"><%= title %></a>')
		
	initialize: ->
		@model.bind 'change', @render, this
		@model.bind 'destroy', @remove, this

	render: ->
		@$el.html @template(@model.toJSON())
		if @model.get('selected')
			@$el.addClass('active')
		else
			@$el.removeClass('active')
}

