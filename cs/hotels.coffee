# MyConbook Mobile
# mobile.myconbook.net

# Models
class myConbook.model.Hotel extends Backbone.Model
	idAttribute: "ID"
	getJson: ->
		json = @toJSON()
		return json

# Collections
class myConbook.model.Hotels extends Backbone.Collection
	model: myConbook.model.Hotel

# Controllers
myConbook.controller.HotelList = (type, match, ui) ->
	return if not match
	model = myConbook.data.hotels
	
	view = new myConbook.view.HotelListView
		model: model
		el: jQuery("#hotel-list-items").get(0)

	view.render() if view.model

myConbook.controller.HotelDetails = (type, match, ui) ->
	return if not match
	params = myConbook.router.getParams(match[0])
	model = myConbook.data.hotels

	view = new myConbook.view.HotelDetailView
		model: model
		el: jQuery("#hotel-list-detail").get(0)

	view.viewId = params.id
	view.render() if view.model

# Views
class myConbook.view.HotelListView extends Backbone.View
	initialize: ->
		@model.bind "reset", @render, @
		return @
	render: ->
		return if not @model? or @model.length is 0

		# Get our DOM playground and clear it out
		@$el.empty()

		# Iterate through each item
		for item in @model.models
			view = new myConbook.view.HotelListItemView model: item

			# Add each schedule item
			@$el.append view.render().el
		
		# Refresh our newly updated listview
		@$el.listview("refresh")
		return @

class myConbook.view.HotelListItemView extends Backbone.View
	tagName: "li"
	initialize: ->
		@template = myConbook.templates.HotelListItem
	render: ->
		return if not @model?
		@$el.html(@template(@model.getJson()))
		return @

class myConbook.view.HotelDetailView extends Backbone.View
	initialize: ->
		@template = myConbook.templates.HotelDetail
		@model.bind "reset", @render, @
		return @
	render: ->
		return if not @model?
		
		# Get the item we want from the model
		item = @model.get @viewId
		return if not item?
		
		# Get our rendering page
		page = jQuery("#hotel-details")
		
		# Set the dynamic subpage header to the display name
		jQuery(".subpageHeader", page).text item.get("Name")
		
		# Set the rest of the page template
		@$el.html(@template(item.getJson()))
		
		page.trigger("create")
		return @
