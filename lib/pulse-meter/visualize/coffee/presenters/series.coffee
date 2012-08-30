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
		_.each(@get('series').rows, (row) =>
			for i in [1 .. row.length - 1]
				value = row[i]
				value = 0 unless value?
				row[i] = @cutoffValue(value, min, max)
		)
