# MyConbook Mobile
# mobile.myconbook.net

# Models
class myConbook.model.Day extends Backbone.Model
	getJson: ->
		return @toJSON()

class myConbook.model.ScheduleItem extends Backbone.Model
	idAttribute: "ID"
	getJson: ->
		json = @toJSON()
		json.TimeRange = @getTimeRange()
		return json
	getStartDate: ->
		@startDate ?= moment(@get("StartDate"))
		return @startDate
	getEndDate: ->
		@endDate ?= moment(@get("EndDate"))
		return @endDate
	getTimeRange: ->
		@timeRange ?= @getStartDate().format("h:mmA") + " - " + @getEndDate().format("h:mmA")
		return @timeRange

# Collections
class myConbook.model.DayList extends Backbone.Collection
	model: myConbook.model.Day

class myConbook.model.Schedule extends Backbone.Collection
	model: myConbook.model.ScheduleItem

# Controllers
myConbook.controller.ScheduleSelect = (type, match, ui) ->
	return if not match
	params = myConbook.router.getParams(match[0])
	model = myConbook.data.dayList
	
	view = new myConbook.view.ScheduleSelectView
		model: model
		el: jQuery("#schedule-select-list").get(0)
	
	view.render() if view.model

myConbook.controller.ScheduleList = (type, match, ui) ->
	return if not match
	params = myConbook.router.getParams(match[0])
	model = myConbook.data.schedule
	
	view = new myConbook.view.ScheduleListView
		model: model
		el: jQuery("#schedule-items-list").get(0)

	# Bind local events
	jQuery("#schedule-sort-order a").unbind().bind("tap", _.bind(view.changeGrouping, view))

	view.viewDate = myConbook.helper.fixDayClock(params.date)
	view.render() if view.model

myConbook.controller.ScheduleDetails = (type, match, ui) ->
	return if not match
	params = myConbook.router.getParams(match[0])
	model = myConbook.data.schedule

	view = new myConbook.view.ScheduleDetailView
		model: model
		el: jQuery("#schedule-details-area").get(0)

	view.viewId = params.id
	view.render() if view.model

# Views
class myConbook.view.ScheduleSelectView extends Backbone.View
	# Schedule day select list view
	initialize: ->
		@model.bind "reset", @render, @
	render: ->
		return if not @model? or @model.length is 0

		# Get our DOM playground and clear it out
		@$el.empty()

		# Add each schedule item
		for item in @model.models
			view = new myConbook.view.ScheduleSelectItemView model: item
			@$el.append view.render().el
		
		@$el.listview("refresh")

		return @
		
class myConbook.view.ScheduleSelectItemView extends Backbone.View
	# Schedule day select single model view
	tagName: "li"
	initialize: ->
		@template = myConbook.templates.ScheduleSelectItem
		return @
	render: ->
		return if not @model?
		@$el.attr("data-theme", "b") if @model.get("isToday")
		@$el.html(@template(@model.getJson()))
		return @

class myConbook.view.ScheduleListView extends Backbone.View
	# Schedule list view
	initialize: ->
		@model.bind "reset", @render, @
		return @
	changeGrouping: (event) ->
		# Handle clicking on the sort order buttons
		@grouping = jQuery(event.target).text()

		# To re-render from here, `this` must be bound to the view
		(_.bind @render, @)()
		return @
	render: ->
		return if not @model? or @model.length is 0

		# Grab the group order if we didn't set it from the click event
		@grouping = jQuery("#schedule-sort-order a.ui-btn-active").text() if not @grouping?

		# Give a range of 24 hours from the start time
		endOfDate = @viewDate.clone().add
			days: 1
			seconds: -1

		# Filter only the given day's events
		dayEvents = @model.filter (item) =>
			startDate = item.getStartDate()
			return @viewDate < startDate < endOfDate

		dayName = @viewDate.format("dddd")

		# Group our model contents by grouping method
		groups = _.groupBy dayEvents, (model) =>
			if @grouping is "Name"
				return model.get("Title").substr(0, 1) ? "(None)"
			else if @grouping is "Room"
				return model.get("Location") ? "(None)"
			else if @grouping is "Category"
				return model.get("Category") ? "(None)"
			else # Time
				return dayName + " at" + model.getStartDate().format(" h:mmA")#.replace(" 0:", " 12:")
		
		# Organize our object {a: b} into an array of [a1, a2, a3]
		groupTitles = new Array()
		
		for groupTitle, items of groups
			groupTitles.push groupTitle
		
		# Sort our array, unless we're grouping by Time (already sorted)
		groupTitles.sort() if @grouping isnt "Time"
		
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
				
				# Create the view
				view = new myConbook.view.ScheduleListItemView model: item
				
				if dividerTitle?
					view.dividerInfo =
						Text: dividerTitle
						Count: groups[groupTitle].length

				# Add each schedule item
				@$el.append view.render().$el.children()
		
		# Refresh our newly updated listview
		@$el.listview("refresh")
		return @

class myConbook.view.ScheduleListItemView extends Backbone.View
	# Schedule list item single model view
	initialize: ->
		@template = myConbook.templates.ScheduleListItem
	render: ->
		return if not @model?
		json = @model.getJson()
		json.DividerInfo = @dividerInfo
		@$el.html(@template(json))
		return @

class myConbook.view.ScheduleDetailView extends Backbone.View
	initialize: ->
		@template = myConbook.templates.ScheduleDetail
		@model.bind "reset", @render, @
		return @
	render: ->
		return if not @model?
		
		# Get the item we want from the model
		item = @model.get @viewId
		return if not item?
		
		# Set the rest of the page template
		@$el.html(@template(item.getJson()))
		
		@$el.trigger("create")
		return @
