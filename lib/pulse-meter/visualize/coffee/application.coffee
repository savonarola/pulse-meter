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
#= require presenters/widget
#= require presenters/pie
#= require presenters/timeline
#= require presenters/series
#= require presenters/line
#= require presenters/area
#= require presenters/table
#= require presenters/gauge

document.startApp = ->
	pageInfos = new PageInfoList
	pageTitlesApp = new PageTitlesView(pageInfos)
	pageInfos.reset gon.pageInfos

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
		initialize: (options) ->
			console.log "DynamicChartView"
			console.log options
			@pageInfos = options['pageInfos']
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
				@presenter = WidgetPresenter.create(@pageInfos, @widget, @chartContainer())


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

		initialize: (options) ->
			@pageInfos = options['pageInfos']
			console.log "DynamicWidgetView: "
			console.log @pageInfos
			@sensorInfo = new SensorInfoList

			@sensorListView = new SensorInfoListView(@sensorInfo)
			@chartView = new DynamicChartView {pageInfos: @pageInfos}
		
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

		initialize: (options) ->
			console.log "WidgetChartView"
			console.log options
			@pageInfos = options['pageInfos']
			@model.bind 'destroy', @remove, this

		updateData: (min, max) ->
			@presenter.draw(min, max)

		render: ->
			@presenter = WidgetPresenter.create(@pageInfos, @model, @el)
	}

	WidgetView = Backbone.View.extend {
		tagName: 'div'

		template: ->
			_.template($(".widget-template[data-widget-type=\"#{@model.get('type')}\"]").html())

		initialize: (options) ->
			console.log "WidgetView"
			console.log options
			@pageInfos = options['pageInfos']
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
				pageInfos: @pageInfos
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
		initialize: (options) ->
			console.log "WidgetListView"
			console.log options
			@widgetList = options['widgetList']
			@pageInfos = options['pageInfos']
			console.log @pageInfos
			@widgetList.bind 'reset', @render, this
			
		render: ->
			container = $('#widgets')
			container.empty()
			@widgetList.each (w) =>
				view = new WidgetView { pageInfos: @pageInfos, model: w }
				view.render()
				container.append(view.el)
				view.renderChart()
	}

	widgetListApp = new WidgetListView {widgetList: widgetList, pageInfos: pageInfos}

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
			dynamicWidget = new DynamicWidgetView {pageInfos: @pageInfos}
			dynamicWidget.render($('#widgets'))
		defaultRoute: (actions) ->
			if @pageInfos.length > 0
				@navigate('//pages/1')
			else
				@navigate('//custom')
	}
	appRouter = new AppRouter(pageInfos, widgetList)

	Backbone.history.start()

