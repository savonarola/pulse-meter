$ ->

	Highcharts.setOptions {
		global: {
			useUTC: gon.options.useUtc
		}
	}

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
		initialize: ->
			@setNextFetch()

		time: -> (new Date()).getTime()

		setNextFetch: ->
			@set('nextFetch', @time() + @get('interval') * 1000)

		refetch: ->
			#console.log @time(), @get('nextFetch'), @get('nextFetch') - @time()
			if @time() > @get('nextFetch')
				@fetch()
				@setNextFetch()
	}

	WidgetList = Backbone.Collection.extend {
		model: Widget
		url: ->
			ROOT + 'pages/' + pageTitles.selected().id + '/widgets'
	}

	WidgetView = Backbone.View.extend {
		tagName: 'div'

		template: _.template($('#widget-template').html())

		initialize: ->
			@model.bind 'change', @reRender, this
			@model.bind 'destroy', @remove, this

		events: {
			"click #refresh": 'refresh'
		}

		refresh: ->
			@model.fetch()
	
		reRender: ->
			@render()
			@renderChart()

		render: ->
			@$el.html @template(@model.toJSON())
			@$el.addClass "span#{@model.get('width')}"

		renderChart: ->
			@chart = new Highcharts.Chart {
				chart: {
					renderTo: @$el.find('#plotarea')[0]
					plotBorderWidth: 1
					spacingLeft: 0
					spacingRight: 0
					type: @model.get('type')
					animation: false
				}
				credits: {
					enabled: false
				}
				title: {
					text: @model.get('title')
				}
				xAxis: {
					type: 'datetime'
				}
				yAxis: {
					title: {
						text: @model.get('valuesTitle')
					}
				}
				series: @model.get('series')
				plotOptions: {
					series: {
						animation: false
					}
				}
			}
	}

	widgetList = new WidgetList
	setInterval( ->
		widgetList.each (w) ->
			w.refetch()
	, 200)

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
				view.renderChart()
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
			@navigate('//pages/1') if pageTitles.length > 0
	}

	appRouter = new AppRouter

	Backbone.history.start()

