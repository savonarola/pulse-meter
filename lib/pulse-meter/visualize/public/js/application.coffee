$ ->
	PageTitle = Backbone.Model.extend {
		defaults: -> {
			title: ""
			selected: false
		}
		initialize: ->
			if !@get('title')
				@set {
					'title': @defaults.title
				}
			@set('selected', @defaults.selected)
		clear: ->
			@destroy()
	}

	PageTitleList = Backbone.Collection.extend {
		model: PageTitle

		selectFirst: ->
			@at(0).set('selected', true) if @length > 0

		selectPage: (id) ->
			@each (m) ->
				m.set 'selected', m.id == id
	}

	pageTitles = new PageTitleList

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

	PageTitlesView = Backbone.View.extend {
		initialize: ->
			pageTitles.bind 'reset', @render, this

		addOne: (page_title) ->
			view = new PageTitleView {
				model: page_title
			}
			view.render()
			$('#page-titles').append(view.el)

		render: ->
			$('#page-titles').empty()
			pageTitles.each(@addOne)
	}

	pageTitlesApp = new PageTitlesView

	pageTitles.reset gon.pageTitles


	AppRouter = Backbone.Router.extend {
		routes: {
			'help' : 'help'
			'pages/:id': 'getPage'
			'*actions': 'defaultRoute'
		}
		getPage: (id) ->
			pageTitles.selectPage(parseInt(id))
		defaultRoute: (actions) ->
			AppRouter.navigate('//pages/1') if pageTitles.length > 0
	}

	appRouter = new AppRouter
	Backbone.history.start()

