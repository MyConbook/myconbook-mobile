# MyConbook Mobile
# mobile.myconbook.net

# Models
class myConbook.model.BuildingMap extends Backbone.Model
	getJson: ->
		return @toJSON()

# Collections
class myConbook.model.BuildingMaps extends Backbone.Collection
	model: myConbook.model.BuildingMap

# Controllers
myConbook.controller.BuildingMapList = (type, match, ui) ->
	return if not match
	model = myConbook.data.buildingmaps
	
	view = new myConbook.view.BuildingMapListView
		model: model
		el: jQuery("#building-maps-list-items").get(0)

	view.render() if view.model

# Views
class myConbook.view.BuildingMapListView extends Backbone.View
	initialize: ->
		@model.bind "reset", @render, @
		return @
	render: ->
		return if not @model? or @model.length is 0

		# Get our DOM playground and clear it out
		@$el.empty()

		# Iterate through each item
		for item in @model.models
			view = new myConbook.view.BuildingMapListItemView model: item

			# Add each schedule item
			@$el.append view.render().el
		
		# Refresh our newly updated listview
		@$el.listview("refresh")
		return @

class myConbook.view.BuildingMapListItemView extends Backbone.View
	tagName: "li"
	initialize: ->
		@template = myConbook.templates.BuildingMapListItem
	render: ->
		return if not @model?
		@$el.html(@template(@model.getJson()))
		return @