# MyConbook Mobile
# mobile.myconbook.net

# Models
class myConbook.model.GuideModel extends Backbone.Model
	idAttribute: "ID"
	displayName: "Guide"
	getItemView: (obj) ->
		new myConbook.view.GuideListItemView obj
	isOpen: ->
	 	# Not supported by default
		false
	getJson: ->
		json = @toJSON()
		json.IsOpen = @isOpen()
		json.CleanedHours = @cleanedHours()
		json.TodaysHours = @todaysHours()
		return json
	cleanedHours: ->
		clean = (val) ->
			return "Closed" if not val
			return val if val isnt "?"
			return "Unknown"
	
		hours =
			"Thursday": clean @get("Thursday")
			"Friday": clean @get("Friday")
			"Saturday": clean @get("Saturday")
			"Sunday": clean @get("Sunday")
			
		return hours
	todaysHours: ->
		cleaned = @cleanedHours()

		if cleaned?
			today = new Date().getDay()
			return cleaned.Thursday if today is 4
			return cleaned.Friday if today is 5
			return cleaned.Saturday if today is 6
			return cleaned.Sunday if today is 0
		
		return "Not available"

# Controllers
myConbook.controller.GuideList = (type, match, ui) ->
	return if not match
	params = myConbook.router.getParams(match[0])
	model = myConbook.helper.getModelFromParams params
	
	# Create view
	view = new myConbook.view.GuideListView
		model: model
		el: jQuery("#guide-list-items").get(0)
	
	# Bind local events
	jQuery("#guide-sort-order a").unbind().bind("tap", _.bind(view.changeGrouping, view))

	view.viewName = params.view
	view.filter = params.filter
	view.render() if view.model

myConbook.controller.GuideDetails = (type, match, ui) ->
	return if not match
	params = myConbook.router.getParams(match[0])
	model = myConbook.helper.getModelFromParams params
	
	view = new myConbook.view.GuideDetailsView
		model: model
		el: jQuery("#guide-list-detail").get(0)
	
	view.viewName = params.view
	view.viewId = params.id
	view.render() if view.model
	
# Views
class myConbook.view.GuideListView extends Backbone.View
	initialize: ->
		@model.bind "reset", @render, @
		return @
	changeGrouping: (event) ->
		# Handle clicking on the sort order buttons
		@grouping = jQuery(event.target).text()

		# For some reason to re-render from here, `this` must be bound or it will lose it in the call
		(_.bind @render, @)()
		return @
	render: ->
		# TODO: Split this into two views (list view and list item view)
		return if not @model? or @model.length is 0
		
		# Check to see if we can show anything
		if @filter is "opennow" and not myConbook.isConDay
			jQuery("#open-now-warning").show()
			return @
		else
			jQuery("#open-now-warning").hide()

		# Grab the group order if we didn't set it from the click event
		@grouping = jQuery("#guide-sort-order a.ui-btn-active").text() if not @grouping?

		# Set the dynamic subpage header to the display name
		jQuery("#guide-list .subpageHeader").text @model.displayName

		# Handle show/hiding the nav bar for certain types		
		navBar = jQuery("#guide-navbar")
		if @viewName is "atms"
			navBar.hide()
			grouping = "Bank"
		else
			navBar.show()

		# Group our model contents by grouping method
		groups = @model.groupBy (model) =>
			if @grouping is "Name"
				return model.get("Name").substr(0, 1) ? ""
			else if @grouping is "Bank"
				return model.get("Name") ? ""
			else # Category
				return model.get("Category") ? ""
		
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
				# Check visibility
				continue if @filter is "opennow" and not item.isOpen()

				dividerTitle = null

				# Handle divider text
				if groupTitle isnt prevTitle
					prevTitle = dividerTitle = groupTitle
				
				view = item.getItemView model: item
				view.dividerTitle = dividerTitle
				view.viewName = @viewName

				if dividerTitle?
					view.dividerInfo =
						Text: dividerTitle
						Count: groups[groupTitle].length

				@$el.append view.render().$el.children()
		
		# Refresh our newly updated listview
		@$el.listview("refresh")
		return @

class myConbook.view.GuideListItemView extends Backbone.View
	initialize: ->
		@template = myConbook.templates.GuideListItem
	render: ->
		return if not @model?
		json = @model.getJson()
		json.DividerInfo = @dividerInfo
		json.ViewName = @viewName
		@$el.html(@template(json))
		return @

class myConbook.view.GuideDetailsView extends Backbone.View
	initialize: ->
		@template = myConbook.templates.GuideDetail
		@model.bind "reset", @render, @
		return @
	render: ->
		return if not @model?
		
		# Get the item we want from the model
		item = @model.get @viewId
		return if not item?
		
		# Get our rendering page
		page = jQuery("#guide-details")
		
		# Set the dynamic subpage header to the display name
		jQuery(".subpageHeader", page).text item.get("Name")
		
		# Set the rest of the page template
		@$el.html(@template(item.getJson()))
		
		page.trigger("create")
		return @
