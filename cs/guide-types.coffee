# MyConbook Mobile
# mobile.myconbook.net

# Helpers
myConbook.helper.getModelFromParams = (params) ->
	switch params.view
		when "restaurants" then return myConbook.data.restaurants
		when "bars" then return myConbook.data.bars
		when "stores" then return myConbook.data.stores
		when "atms" then return myConbook.data.atms
		else return null

# Models
class myConbook.model.Restaurant extends myConbook.model.GuideModel
	isOpen: ->
		now = moment()
		# Check and cache if this restaurant is open
		return @cachedIsOpen ?= _.find @get("Hours"), (hours) ->
			# Find the first matching instance of being open
			startDate = myConbook.helper.fixClock(hours.StartPeriod)
			endDate = myConbook.helper.fixClock(hours.EndPeriod)
			return ((now.diff(startDate) >= 0) and now.diff(endDate) < 0)

class myConbook.model.Bar extends myConbook.model.GuideModel

class myConbook.model.Store extends myConbook.model.GuideModel

class myConbook.model.ATM extends myConbook.model.GuideModel
	getItemView: (obj) ->
		new myConbook.view.ATMListItemView obj
	cleanedHours: ->
		return null

# Collections
class myConbook.model.Restaurants extends Backbone.Collection
	model: myConbook.model.Restaurant
	displayName: "Restaurants"

class myConbook.model.Bars extends Backbone.Collection
	model: myConbook.model.Bar
	displayName: "Bars"

class myConbook.model.Stores extends Backbone.Collection
	model: myConbook.model.Store
	displayName: "Stores"

class myConbook.model.ATMs extends Backbone.Collection
	model: myConbook.model.ATM
	displayName: "Banks/ATMs"

# Views
class myConbook.view.ATMListItemView extends myConbook.view.GuideListItemView
	initialize: ->
		@template = myConbook.templates.AtmListItem