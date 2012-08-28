class GaugePresenter extends WidgetPresenter
	visualization: 'Gauge'

	cutoff: ->

	data: ->
		data = super()
		data.addColumn('string', 'Label')
		data.addColumn('number', @get('valuesTitle'))
		data.addRows(@get('series'))
		data
