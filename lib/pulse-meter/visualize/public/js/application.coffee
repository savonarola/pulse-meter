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
		selected: ->
			@find (m) ->
				m.get 'selected'
			

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

	Widget = Backbone.Model.extend {
		
	}

	WidgetList = Backbone.Collection.extend {
		model: Widget
		url: ->
			ROOT + 'pages/' + pageTitles.selected().id + '/widgets'
	}

	WidgetView = Backbone.View.extend {
		tagName: 'div'
		template: _.template """
			<div class="well">
				Widget: <%= title %> of type <%= type %>
			</div>
		"""

		initialize: ->
			@model.bind 'change', @render, this
			@model.bind 'destroy', @remove, this

		render: ->
			@$el.html @template(@model.toJSON())
	}

	widgetList = new WidgetList

	WidgetListView = Backbone.View.extend {
		initialize: ->
			widgetList.bind 'reset', @render, this
			
		render: ->
			container = $('#widgets')
			container.empty()
			widgetList.each (w) ->
				view = new WidgetView {
					model: w
				}
				view.render()
				container.append(view.el)
	}

	widgetListApp = new WidgetListView

	AppRouter = Backbone.Router.extend {
		routes: {
			'help' : 'help'
			'pages/:id': 'getPage'
			'*actions': 'defaultRoute'
		}
		getPage: (ids) ->
			id = parseInt(ids)
			pageTitles.selectPage(id)
			widgetList.fetch()
		defaultRoute: (actions) ->
			AppRouter.navigate('//pages/1') if pageTitles.length > 0
	}

	appRouter = new AppRouter

	Backbone.history.start()

