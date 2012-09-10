#= require extensions
#= require models/page_info
#= require models/widget
#= require models/dinamic_widget
#= require models/sensor_info
#= require collections/page_info_list
#= require collections/sensor_info_list
#= require collections/widget_list
#= require presenters/widget
#= require presenters/pie
#= require presenters/timeline
#= require presenters/series
#= require presenters/line
#= require presenters/area
#= require presenters/table
#= require presenters/gauge
#= require views/page_title
#= require views/page_titles
#= require views/sensor_info_list
#= require views/dynamic_chart
#= require views/dynamic_widget
#= require views/widget_chart
#= require views/widget
#= require views/widget_list
#= require router

document.startApp = ->
	pageInfos = new PageInfoList
	pageTitlesApp = new PageTitlesView(pageInfos)
	pageInfos.reset gon.pageInfos

	widgetList = new WidgetList
	widgetList.setContext(pageInfos)
	widgetList.startPolling()

	widgetListApp = new WidgetListView {widgetList: widgetList, pageInfos: pageInfos}

	appRouter = new AppRouter(pageInfos, widgetList)

	Backbone.history.start()
