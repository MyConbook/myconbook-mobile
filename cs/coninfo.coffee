# MyConbook Mobile
# mobile.myconbook.net

# Models
class myConbook.model.ConInfo extends Backbone.Model
	getJson: ->
		return @toJSON()

# Collections
class myConbook.model.ConInfoList extends Backbone.Collection
	model: myConbook.model.ConInfo

# Controllers
myConbook.controller.ConInfoList = (type, match, ui) ->
	return if not match
	model = myConbook.data.coninfo
	
	view = new myConbook.view.ConInfoListView
		model: model
		el: jQuery("#con-info-list-items").get(0)

	view.render() if view.model

# Views
class myConbook.view.ConInfoListView extends Backbone.View
	initialize: ->
		@model.bind "reset", @render, @
		return @
	render: ->
		return if not @model? or @model.length is 0

		# Get our DOM playground and clear it out
		@$el.empty()

		# Add the static hotels link
		jQuery("<li>").attr("data-icon", "grid").append(jQuery("<a>").attr("href", "#hotels").text("Hotels")).appendTo(@$el)

		# Iterate through each item
		for item in @model.models
			view = new myConbook.view.ConInfoListItemView model: item

			# Add each schedule item
			@$el.append view.render().el
		
		# Refresh our newly updated listview
		@$el.listview("refresh")
		return @

class myConbook.view.ConInfoListItemView extends Backbone.View
	tagName: "li"
	initialize: ->
		@template = myConbook.templates.ConInfoListItem
	render: ->
		return if not @model?
		@$el.html(@template(@model.getJson()))
		return @
