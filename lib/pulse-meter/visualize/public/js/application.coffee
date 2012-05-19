$ ->
	globalOptions = gon.options

	Highcharts.setOptions {
		global: {
			useUTC: globalOptions.useUtc
		}
	}

	PageTitle = Backbone.Model.extend {
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
			@needRefresh = true
			@setNextFetch()

		time: -> (new Date()).getTime()

		setNextFetch: ->
			@nextFetch = @time() + @get('interval') * 1000

		setRefresh: (needRefresh) ->
			@needRefresh = needRefresh

		refetch: ->
			if @time() > @nextFetch && @needRefresh
				@fetch()
				@setNextFetch()

		cutoffValue: (v, min, max) ->
			if min isnt null && v.y < min
				v.y = min
				v.color = globalOptions.outlierColor
			if max isnt null && v.y > max
				v.y = max
				v.color = globalOptions.outlierColor

		cutoff: (min, max) ->
			_.each(@get('series'), (s) ->
				_.each( s.data, (v) ->
					@cutoffValue(v, min, max)
				, this)
			, this)
	}

	WidgetList = Backbone.Collection.extend {
		model: Widget
		url: ->
			ROOT + 'pages/' + pageTitles.selected().id + '/widgets'
	}

	WidgetChartView = Backbone.View.extend {
		tagName: 'div'

		initialize: ->
			@model.bind 'destroy', @remove, this

		updateData: (min, max) ->
			@model.cutoff(min, max)
			chartSeries = @chart.series
			newSeries = @model.get('series')
			for i in [0 .. chartSeries.length - 1]
				if newSeries[i]?
					chartSeries[i].setData(newSeries[i].data, false)
			@chart.redraw()

		render: ->
			@chart = new Highcharts.Chart {
				chart: {
					renderTo: @el
					plotBorderWidth: 1
					spacingLeft: 0
					spacingRight: 0
					type: @model.get('type')
					zoomType: 'x'
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

	WidgetView = Backbone.View.extend {
		tagName: 'div'

		template: _.template($('#widget-template').html())

		initialize: ->
			@model.bind('destroy', @remove, this)
			@model.bind('change', @updateChart, this)

		events: {
			"click #refresh": 'refresh'
			"click #need-refresh": 'setRefresh'
		}

		refresh: ->
			@model.fetch()

		setRefresh: ->
			needRefresh = @$el.find('#need-refresh').is(":checked")
			@model.setRefresh(needRefresh)
			true

		renderChart: ->
			@chartView.render()

		updateChart: ->
			@chartView.updateData(@cutoffMin(), @cutoffMax())

		render: ->
			@$el.html @template(@model.toJSON())
			@chartView = new WidgetChartView {
        model: @model
      }
      @$el.find("#plotarea").append(@chartView.el)
      @$el.addClass "span#{@model.get('width')}"

		cutoffMin: ->
			val = parseFloat(@controlValue('#cutoff-min'))
			if _.isNaN(val) then null else val

		cutoffMax: ->
			val = parseFloat(@controlValue('#cutoff-max'))
			if _.isNaN(val) then null else val

		controlValue: (id) ->
			val = @$el.find(id).first().val()


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

