document.startApp = ->
	globalOptions = gon.options
	
	String::capitalize = ->
		@charAt(0).toUpperCase() + @slice(1)
	String::strip = ->
		if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""

	Number::humanize = ->
		interval = this
		res = ""
		s = interval % 60
		res = "#{s} s" if s > 0
		interval = (interval - s) / 60
		return res unless interval > 0

		m = interval % 60
		res = "#{m} m #{res}".strip() if m > 0
		interval = (interval - m) / 60
		return res unless interval > 0

		h = interval % 24
		res = "#{h} h #{res}".strip() if h > 0
		d = (interval - h) / 24
		if d > 0
			"#{d} d #{res}".strip()
		else
			res

	PageInfo = Backbone.Model.extend {
	}

	PageInfoList = Backbone.Collection.extend {
		model: PageInfo
		selected: ->
			@find (m) ->
				m.get 'selected'

		selectFirst: ->
			@at(0).set('selected', true) if @length > 0
		
		selectNone: ->
			@each (m) ->
				m.set 'selected', false

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


	class WidgetPresenter
		constructor: (model, el) ->
			@model = model
			chartClass = @chartClass()
			@chart = new chartClass(el)
			@draw()

		get: (arg) -> @model.get(arg)
	
		dateOffset: ->
			if globalOptions.useUtc
				(new Date).getTimezoneOffset() * 60000
			else
				0
		
		options: ->
			{
				title: @get('title')
				height: 300
			}

		mergedOptions: ->
			pageOptions = if pageInfos.selected()
				pageInfos.selected().get('gchartOptions')
			else
				{}

			$.extend(true,
				@options(),
				globalOptions.gchartOptions,
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

	WidgetPresenter.create = (model, el) ->
		type = model.get('type')
		if type? && type.match(/^\w+$/)
			presenterClass = eval("#{type.capitalize()}Presenter")
			new presenterClass(model, el)
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

		timespan: -> @get('timespan') + @timespanInc

		url: ->
			timespan = @timespan()
			if _.isNaN(timespan)
				"#{@collection.url()}/#{@get('id')}"
			else
				"#{@collection.url()}/#{@get('id')}?timespan=#{timespan}"

		time: -> (new Date()).getTime()

		setNextFetch: ->
			@nextFetch = @time() + @get('redrawInterval') * 1000

		setRefresh: (needRefresh) ->
			@needRefresh = needRefresh

		needFetch: ->
			interval = @get('redrawInterval')
			@time() > @nextFetch && @needRefresh && interval? && interval > 0

		refetch: ->
			if @needFetch()
				@forceUpdate()
				@setNextFetch()

		forceUpdate: ->
			@fetch {
				success: (model, response) ->
					model.trigger('redraw')
			}

	}

	DynamicWidget = Backbone.Model.extend {

		increaseTimespan: (inc) ->
			@set('timespan', @timespan() + inc)

		resetTimespan: ->
			@set('timespan', null)

		timespan: -> @get('timespan')

		sensorArgs: ->
			_.map(@get('sensorIds'), (name) -> "sensor[]=#{name}").join('&')

		url: ->
			url = "#{ROOT}dynamic_widget?#{@sensorArgs()}&type=#{@get('type')}"
			
			timespan = @timespan()
			url = "#{url}&timespan=#{timespan}" if timespan? && !_.isNaN(timespan)

			url

		forceUpdate: ->
			@fetch {
				success: (model, response) ->
					model.trigger('redraw')
			}
	}

	WidgetList = Backbone.Collection.extend {
		model: Widget
		url: ->
			ROOT + 'pages/' + pageInfos.selected().id + '/widgets'
	}

	SensorInfo = Backbone.Model.extend {

	}

	SensorInfoList = Backbone.Collection.extend {
		model: SensorInfo
		url: ->
			ROOT + 'sensors'
	}


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
				@presenter = WidgetPresenter.create(@widget, @chartContainer())


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
			@presenter = WidgetPresenter.create(@model, @el)
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
	setInterval( ->
		if pageInfos.selected()
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
				view = new WidgetView { model: w }
				view.render()
				container.append(view.el)
				view.renderChart()
	}

	widgetListApp = new WidgetListView

	AppRouter = Backbone.Router.extend {
		routes: {
			'pages/:id': 'getPage'
			'custom': 'custom'
			'*actions': 'defaultRoute'
		}
		getPage: (ids) ->
			id = parseInt(ids)
			pageInfos.selectPage(id)
			widgetList.fetch()
		custom: ->
			pageInfos.selectNone()
			dynamicWidget = new DynamicWidgetView
			dynamicWidget.render($('#widgets'))
		defaultRoute: (actions) ->
			if pageInfos.length > 0
				@navigate('//pages/1')
			else
				@navigate('//custom')
	}

	appRouter = new AppRouter

	Backbone.history.start()

