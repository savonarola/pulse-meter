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
