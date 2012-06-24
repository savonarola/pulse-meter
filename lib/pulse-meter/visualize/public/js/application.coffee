$ ->
	globalOptions = gon.options

	PageInfo = Backbone.Model.extend {
	}

	PageInfoList = Backbone.Collection.extend {
		model: PageInfo
		selected: ->
			@find (m) ->
				m.get 'selected'
			

		selectFirst: ->
			@at(0).set('selected', true) if @length > 0

		selectPage: (id) ->
			@each (m) ->
				m.set 'selected', m.id == id
	}

	pageInfos = new PageInfoList

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
			pageInfos.bind 'reset', @render, this

		addOne: (pageInfo) ->
			view = new PageTitleView {
				model: pageInfo
			}
			view.render()
			$('#page-titles').append(view.el)

		render: ->
			$('#page-titles').empty()
			pageInfos.each(@addOne)
	}

	pageTitlesApp = new PageTitlesView

	pageInfos.reset gon.pageInfos

	Widget = Backbone.Model.extend {
		initialize: ->
			@needRefresh = true
			@setNextFetch()
			@timespanInc = 0

		increaseTimespan: (inc) ->
			@timespanInc = @timespanInc + inc
			@forceUpdate()

		resetTimespan: ->
			@timespanInc = 0
			@forceUpdate()

		url: ->
			"#{@collection.url()}/#{@get('id')}?timespan=#{@get('timespan') + @timespanInc}"

		time: -> (new Date()).getTime()

		setNextFetch: ->
			@nextFetch = @time() + @get('interval') * 1000

		setRefresh: (needRefresh) ->
			@needRefresh = needRefresh

		needFetch: ->
			interval = @get('interval')
			@time() > @nextFetch && @needRefresh && interval? && interval > 0

		refetch: ->
			if @needFetch()
				@forceUpdate()
				@setNextFetch()

		cutoffValue: (v, min, max) ->
			if v?
				if min? && v < min
					min
				else if max? && v > max
					max
				else
					v
			else
				0

		cutoff: (min, max) ->
			_.each(@get('series').rows, (row) ->
				for i in [1 .. row.length - 1]
					value = row[i]
					value = 0 unless value?
					row[i] = @cutoffValue(value, min, max)
			, this)

		forceUpdate: ->
			@fetch {
				success: (model, response) ->
					model.trigger('redraw')
			}

		pieData: ->
			data = new google.visualization.DataTable()
			data.addColumn('string', 'Title')
			data.addColumn('number', @get('valuesTitle'))
			data.addRows(@get('series').data)
			data

		dateOffset: ->
			if globalOptions.useUtc
				(new Date).getTimezoneOffset() * 60000
			else
				0

		lineData: ->
			title = @get('title')
			data = new google.visualization.DataTable()
			data.addColumn('datetime', 'Time')
			dateOffset = @dateOffset()
			series = @get('series')
			_.each series.titles, (t) ->
				data.addColumn('number', t)

			_.each series.rows, (row) ->
				row[0] = new Date(row[0] + dateOffset)
				data.addRow(row)
			data

		options: ->
			{
				title: @get('title')
				lineWidth: 1
				chartArea: {
					left: 40
					width: '100%'
				}
				height: 300
				legend: {
					position: 'bottom'
				}
				vAxis: {
					title: @get('valuesTitle')
				}
				axisTitlesPosition: 'in'
			}

		pieOptions: ->
			$.extend true, @options(), {
				slices: @get('series').options
			}

		lineOptions: ->
			$.extend true, @options(), {
				hAxis: {
					format: 'yyyy.MM.dd HH:mm:ss'
				}
				series: @get('series').options
			}

		tableOptions: ->
			$.extend true, @lineOptions(), {
				sortColumn: 0
				sortAscending: false
			}

		chartOptions: ->
			opts = if @get('type') == 'pie'
				@pieOptions()
			else if @get('type') == 'table'
				@tableOptions()
			else
				@lineOptions()
			$.extend true, opts, globalOptions.gchartOptions, pageInfos.selected().get('gchartOptions')

		chartData: ->
			if @get('type') == 'pie'
				@pieData()
			else
				@lineData()

		chartClass: ->
			if @get('type') == 'pie'
				google.visualization.PieChart
			else if @get('type') == 'area'
				google.visualization.AreaChart
			else if @get('type') == 'table'
				google.visualization.Table
			else
				google.visualization.LineChart

	}

	WidgetList = Backbone.Collection.extend {
		model: Widget
		url: ->
			ROOT + 'pages/' + pageInfos.selected().id + '/widgets'
	}

	WidgetChartView = Backbone.View.extend {
		tagName: 'div'

		initialize: ->
			@model.bind 'destroy', @remove, this

		updateData: (min, max) ->
			@model.cutoff(min, max)
			@chart.draw(@model.chartData(), @model.chartOptions())

		render: ->
			chartClass = @model.chartClass()
			@chart = new chartClass(@el)
			@updateData()

	}

	WidgetView = Backbone.View.extend {
		tagName: 'div'

		template: ->
			_.template($(".widget-template[data-widget-type=\"#{@model.get('type')}\"]").html())

		initialize: ->
			@model.bind('destroy', @remove, this)
			@model.bind('redraw', @updateChart, this)

		events: {
			"click #refresh": 'refresh'
			"click #need-refresh": 'setRefresh'
			"click #extend-timespan": 'extendTimespan'
			"click #reset-timespan": 'resetTimespan'
		}

		refresh: ->
			@model.forceUpdate()

		setRefresh: ->
			needRefresh = @$el.find('#need-refresh').is(":checked")
			@model.setRefresh(needRefresh)
			true

		extendTimespan: ->
			select = @$el.find("#extend-timespan-val")
			val = select.first().val()
			@model.increaseTimespan(parseInt(val))

		resetTimespan: ->
			@model.resetTimespan()

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
			pageInfos.selectPage(id)
			widgetList.fetch()
		defaultRoute: (actions) ->
			@navigate('//pages/1') if pageInfos.length > 0
	}

	appRouter = new AppRouter

	Backbone.history.start()

