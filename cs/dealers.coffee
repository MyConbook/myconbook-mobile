# MyConbook Mobile
# mobile.myconbook.net

# Models
class myConbook.model.Dealer extends Backbone.Model
	idAttribute: "ID"
	getJson: ->
		json = @toJSON()
		return json

# Collections
class myConbook.model.Dealers extends Backbone.Collection
	model: myConbook.model.Dealer

# Controllers
myConbook.controller.DealerList = (type, match, ui) ->
	return if not match
	params = myConbook.router.getParams(match[0])
	model = myConbook.data.dealers
	
	view = new myConbook.view.DealerListView
		model: model
		el: jQuery("#dealers-list-items").get(0)

	view.render() if view.model

myConbook.controller.DealerDetails = (type, match, ui) ->
	return if not match
	params = myConbook.router.getParams(match[0])
	model = myConbook.data.dealers

	view = new myConbook.view.DealerDetailView
		model: model
		el: jQuery("#dealer-list-detail").get(0)

	view.viewId = params.id
	view.render() if view.model

# Views
class myConbook.view.DealerListView extends Backbone.View
	initialize: ->
		@model.bind "reset", @render, @
		return @
	render: ->
		return if not @model? or @model.length is 0

		# Group our model contents by first character
		groups = @model.groupBy (model) =>
			return model.get("Name").substr(0, 1) ? ""
		
		# Organize our object {a: b} into an array of [a1, a2, a3]
		groupTitles = new Array()
		
		for groupTitle, items of groups
			groupTitles.push groupTitle
		
		# Sort our array
		groupTitles.sort()
		
		# Get our DOM playground and clear it out
		@$el.empty()
		
		# Iterate through each group
		for groupTitle in groupTitles
			# Get items in the group
			items = groups[groupTitle]
			
			# Iterate through each item in group
			for item in items
				dividerTitle = null

				# Handle divider text
				if groupTitle isnt prevTitle
					prevTitle = dividerTitle = groupTitle
				
				view = new myConbook.view.DealerListItemView model: item
				view.dividerTitle = dividerTitle

				# Add each schedule item
				@$el.append view.render().$el.children()
		
		# Refresh our newly updated listview
		@$el.listview("refresh")
		return @

class myConbook.view.DealerListItemView extends Backbone.View
	initialize: ->
		@template = myConbook.templates.DealerListItem
	render: ->
		return if not @model?
		json = @model.getJson()
		json.DividerTitle = @dividerTitle
		@$el.html(@template(json))
		return @

class myConbook.view.DealerDetailView extends Backbone.View
	initialize: ->
		@template = myConbook.templates.DealerDetail
		@model.bind "reset", @render, @
		return @
	render: ->
		return if not @model?
		
		# Get the item we want from the model
		item = @model.get @viewId
		return if not item?
		
		# Get our rendering page
		page = jQuery("#dealer-details")
		
		# Set the dynamic subpage header to the display name
		jQuery(".subpageHeader", page).text item.get("Name")
		
		# Set the rest of the page template
		@$el.html(@template(item.getJson()))
		
		page.trigger("create")
		return @
