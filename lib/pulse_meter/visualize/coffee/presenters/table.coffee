class TablePresenter extends TimelinePresenter
	visualization: 'Table'

	cutoff: ->

	options: ->
		$.extend true, super(), {
			sortColumn: 0
			sortAscending: false
		}
