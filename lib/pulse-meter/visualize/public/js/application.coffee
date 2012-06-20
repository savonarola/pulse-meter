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

		lineData: ->
			title = @get('title')
			data = new google.visualization.DataTable()
			data.addColumn('datetime', 'Time')
			series = @get('series')
			console.log title, series.rows.length
			_.each series.titles, (t) ->
				data.addColumn('number', t)
			_.each series.rows, (row) ->
				row[0] = new Date(row[0])
				data.addRow(row)

			data

		options: ->
			{
				title: @get('title')
				lineWidth: 1
				chartArea: {
					left: 20
					width: '100%'
				}
				height: 300
				legend: {
					position: 'bottom'
				}
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

			if @model.get('type') == 'pie'
				@chart.draw(@model.pieData(), @model.pieOptions())
			else
				@chart.draw(@model.lineData(), @model.lineOptions())

	render: ->
			if @model.get('type') == 'pie'
				@chart = new google.visualization.PieChart(@el)
				@chart.draw(@model.pieData(), @model.pieOptions())
			else
				@chart = new google.visualization.AreaChart(@el)
				@chart.draw(@model.lineData(), @model.lineOptions())
	}

	WidgetView = Backbone.View.extend {
		tagName: 'div'

		template: _.template($('#widget-template').html())

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

