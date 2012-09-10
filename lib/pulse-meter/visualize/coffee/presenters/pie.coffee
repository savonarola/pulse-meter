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

