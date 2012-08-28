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

