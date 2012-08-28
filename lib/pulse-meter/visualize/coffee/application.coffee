#= require extensions
#= require models/page_info
#= require models/widget
#= require models/dinamic_widget
#= require models/sensor_info
#= require collections/page_info_list
#= require collections/sensor_info_list
#= require collections/widget_list
#= require views/page_title
#= require views/page_titles

document.startApp = ->
	pageInfos = new PageInfoList
	pageTitlesApp = new PageTitlesView(pageInfos)
	pageInfos.reset gon.pageInfos

	class WidgetPresenter
		constructor: (@pageInfos, @model, el) ->
			chartClass = @chartClass()
			@chart = new chartClass(el)
			@draw()

		get: (arg) -> @model.get(arg)

		globalOptions: -> gon.options
	
		dateOffset: ->
			if @globalOptions.useUtc
				(new Date).getTimezoneOffset() * 60000
			else
				0
		
		options: ->
			{
				title: @get('title')
				height: 300
			}

		mergedOptions: ->
			pageOptions = if @pageInfos.selected()
				@pageInfos.selected().get('gchartOptions')
			else
				{}

			$.extend(true,
				@options(),
				@globalOptions.gchartOptions,
				pageOptions,
				@get('gchartOptions')
			)

		data: -> new google.visualization.DataTable

		chartClass: -> google.visualization[@visualization]

		cutoff: ->
		
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

		draw: (min, max) ->
			@cutoff(min, max)
			@chart.draw(@data(), @mergedOptions())

	WidgetPresenter.create = (pageInfos, model, el) ->
		type = model.get('type')
		if type? && type.match(/^\w+$/)
			presenterClass = eval("#{type.capitalize()}Presenter")
			new presenterClass(pageInfos, model, el)
		else
			null

	class PiePresenter extends WidgetPresenter
		visualization: 'PieChart'

		cutoff: ->
		
		data: ->
			data = super()
			data.addColumn('string', 'Title')
			data.addColumn('number', @get('valuesTitle'))
			data.addRows(@get('series').data)
			data

		options: ->
			$.extend true, super(), {
				slices: @get('series').options
				legend: {
					position: 'bottom'
				}
			}

	class TimelinePresenter extends WidgetPresenter
		data: ->
			data = super()
			data.addColumn('datetime', 'Time')
			dateOffset = @dateOffset() + @get('interval') * 1000
			series = @get('series')
			_.each series.titles, (t) ->
				data.addColumn('number', t)

			_.each series.rows, (row) ->
				row[0] = new Date(row[0] + dateOffset)
				data.addRow(row)
			data

	class SeriesPresenter extends TimelinePresenter
		options: ->
			secondPart = if @get('interval') % 60 == 0 then '' else ':ss'
			format = if @model.timespan() > 24 * 60 * 60
				"yyyy.MM.dd HH:mm#{secondPart}"
			else
				"HH:mm#{secondPart}"

			$.extend true, super(), {
				lineWidth: 1
				chartArea: {
					width: '100%'
				}
				legend: {
					position: 'bottom'
				}
				vAxis: {
					title: @valuesTitle()
					textPosition: 'in'
				}
				hAxis: {
					format: format
				}
				series: @get('series').options
				axisTitlesPosition: 'in'
			}

		valuesTitle: ->
			if @get('valuesTitle')
				"#{@get('valuesTitle')} / #{@humanizedInterval()}"
			else
				@humanizedInterval()


		humanizedInterval: ->
			@get('interval').humanize()
		
		cutoff: (min, max) ->
			_.each(@get('series').rows, (row) ->
				for i in [1 .. row.length - 1]
					value = row[i]
					value = 0 unless value?
					row[i] = @cutoffValue(value, min, max)
			, this)


	class LinePresenter extends SeriesPresenter
		visualization: 'LineChart'

	class AreaPresenter extends SeriesPresenter
		visualization: 'AreaChart'

	class TablePresenter extends TimelinePresenter
		visualization: 'Table'

		cutoff: ->

		options: ->
			$.extend true, super(), {
				sortColumn: 0
				sortAscending: false
			}

	class GaugePresenter extends WidgetPresenter
		visualization: 'Gauge'

		cutoff: ->

		data: ->
			data = super()
			data.addColumn('string', 'Label')
			data.addColumn('number', @get('valuesTitle'))
			data.addRows(@get('series'))
			data

	SensorInfoListView = Backbone.View.extend {
		tagName: 'div'

		template: ->
			_.template($("#sensor-list").html())

		initialize: (sensorInfo) ->
			@sensorInfo = sensorInfo
			@sensorInfo.bind 'reset', @render, this

		render: ->
			@$el.html @template()({sensors: @sensorInfo.toJSON()})

		selectedSensors: ->
			checked = _.filter @$el.find('.sensor-box'), (el) -> $(el).is(':checked')
			ids = {}
			_.each checked, (box) -> ids[box.id] = true
			selected = @sensorInfo.filter (sensor) -> ids[sensor.id]
			
	}

	DynamicChartView = Backbone.View.extend {
		initialize: ->
			@sensors = []
			@type = 'Area'
			@widget = new DynamicWidget
			
			@widget.bind('destroy', @remove, this)
			@widget.bind('redraw', @redrawChart, this)

		tagName: 'div'

		events: {
			"click #refresh-chart": 'update'
			"click #extend-timespan": 'extendTimespan'
			"click #reset-timespan": 'resetTimespan'
		}

		template: -> _.template($("#dynamic-widget-plotarea").html())

		render: ->
			@$el.html(@template()())

		extendTimespan: ->
			select = @$el.find("#extend-timespan-val")
			val = select.first().val()
			@widget.increaseTimespan(parseInt(val))
			@update()

		resetTimespan: ->
			@widget.resetTimespan()
			@update()

		sensorIds: -> _.map(@sensors, (s) -> s.id)

		redrawChart: ->
			if @presenter
				@presenter.draw()
			else
				@presenter = WidgetPresenter.create(pageInfos, @widget, @chartContainer())


		chartContainer: ->
			@$el.find('#chart')[0]

		update: ->
			@widget.forceUpdate() if @sensors.length > 0

		draw: (sensors, type) ->
			@sensors = sensors
			@type = type

			@widget.set('sensorIds', @sensorIds())
			@widget.set('type', @type)
			
			@presenter = null
			$(@chartContainer()).empty()
			@widget.forceUpdate()
	}

	DynamicWidgetView = Backbone.View.extend {
		tagName: 'div'

		initialize: ->
			@sensorInfo = new SensorInfoList

			@sensorListView = new SensorInfoListView(@sensorInfo)
			@chartView = new DynamicChartView
		
			@$el.html(@template()())

			@$el.find('#sensor-list-area').append(@sensorListView.el)
			
			@chartView.render()
			@$el.find('#dynamic-plotarea').append(@chartView.el)

		events: {
			"click #sensor-controls #refresh": 'refresh'
			"click #sensor-controls #draw": 'drawChart'
		}

		template: ->
			_.template($("#dynamic-widget").html())

		errorTemplate: -> _.template($("#dynamic-widget-error").html())

		error: (error)->
			@$el.find('#errors').append(@errorTemplate()(error: error))


		refresh: ->
			@sensorInfo.fetch()

		intervalsEqual: (sensors) ->
			interval = sensors[0].get('interval')
			badIntervals = _.filter(sensors, (s) ->
				s.get('interval') != interval
			)
			badIntervals.length == 0

		drawChart: ->
			selectedSensors = @sensorListView.selectedSensors()
			return unless selectedSensors.length > 0
	
			unless @intervalsEqual(selectedSensors)
				@error('Selected sensors have different intervals')
				return

			type = @$el.find('#chart-type').val()
			@chartView.draw(selectedSensors, type)
			
		render: (container) ->
			container.empty()
			container.append(@$el)
			@sensorInfo.fetch()
			@chartView.update()
			
	}


	WidgetChartView = Backbone.View.extend {
		tagName: 'div'

		initialize: ->
			@model.bind 'destroy', @remove, this

		updateData: (min, max) ->
			@presenter.draw(min, max)

		render: ->
			@presenter = WidgetPresenter.create(pageInfos, @model, @el)
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
			@$el.addClass("span#{@model.get('width')}")

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
	widgetList.setContext(pageInfos)
	widgetList.startPolling()

	WidgetListView = Backbone.View.extend {
		initialize: ->
			widgetList.bind 'reset', @render, this
			
		render: ->
			container = $('#widgets')
			container.empty()
			widgetList.each (w) ->
				view = new WidgetView { model: w }
				view.render()
				container.append(view.el)
				view.renderChart()
	}

	widgetListApp = new WidgetListView

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
			dynamicWidget = new DynamicWidgetView
			dynamicWidget.render($('#widgets'))
		defaultRoute: (actions) ->
			if @pageInfos.length > 0
				@navigate('//pages/1')
			else
				@navigate('//custom')
	}
	appRouter = new AppRouter(pageInfos, widgetList)

	Backbone.history.start()

