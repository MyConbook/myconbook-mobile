# MyConbook Mobile site
# mobile.myconbook.net

myConbook =
	# Placeholders
	model: {}
	view: {}
	controller: {}
	helper:
		# Helpful functions
		fixClock: (timestr) ->
			# Trick the browser into thinking relative times are absolute	
			return moment(timestr + "Z").add("minutes", moment().zone())
		fixDayClock: (timestr) ->
			# Day based events 'start' at 4am
			return myConbook.helper.fixClock(timestr + "T04:00:00")
		nl2br: (str) ->
			# Replace both inline and real linebreaks with HTML ones
			return (str + "").replace(/\\n/g, "<br />").replace(/\n/g, "<br />")

	data:
		dayList: null
		schedule: null
		restaurants: null
		bars: null
		stores: null
		atms: null
		coninfo: null
		hotels: null
		dealers: null
		buildingmaps: null
	router: null
	templates: null
	isConDay: false

	# Init functions
	initApp: ->
		@data.dayList = new myConbook.model.DayList
		@data.schedule = new myConbook.model.Schedule
		@data.restaurants = new myConbook.model.Restaurants
		@data.bars = new myConbook.model.Bars
		@data.stores = new myConbook.model.Stores
		@data.atms = new myConbook.model.ATMs
		@data.coninfo = new myConbook.model.ConInfoList
		@data.hotels = new myConbook.model.Hotels
		@data.dealers = new myConbook.model.Dealers
		@data.buildingmaps = new myConbook.model.BuildingMaps
		return @
	initTemplates: ->
		@templates =
			ScheduleSelectItem: Handlebars.compile jQuery("#schedule-select-item-template").html()
			ScheduleListItem: Handlebars.compile jQuery("#schedule-list-items-template").html()
			ScheduleDetail: Handlebars.compile jQuery("#schedule-detail-template").html()
			GuideListItem: Handlebars.compile jQuery("#guide-list-items-template").html()
			AtmListItem: Handlebars.compile jQuery("#atm-list-items-template").html()
			GuideDetail: Handlebars.compile jQuery("#guide-detail-template").html()
			ConInfoListItem: Handlebars.compile jQuery("#con-info-list-items-template").html()
			HotelListItem: Handlebars.compile jQuery("#hotel-list-items-template").html()
			HotelDetail: Handlebars.compile jQuery("#hotel-detail-template").html()
			DealerListItem: Handlebars.compile jQuery("#dealer-list-items-template").html()
			DealerDetail: Handlebars.compile jQuery("#dealer-detail-template").html()
			BuildingMapListItem: Handlebars.compile jQuery("#building-map-list-items-template").html()
	initRouter: ->
		@router = new jQuery.mobile.Router
			"#schedule-select": @controller.ScheduleSelect
			"#schedule-list([?].*)?": @controller.ScheduleList
			"#schedule-details([?].*)?": @controller.ScheduleDetails
			"#guide-list([?].*)?": @controller.GuideList
			"#guide-details([?].*)?": @controller.GuideDetails
			"#con-info": @controller.ConInfoList
			"#hotels": @controller.HotelList
			"#hotel-details([?].*)?": @controller.HotelDetails
			"#dealers": @controller.DealerList
			"#dealer-details([?].*)?": @controller.DealerDetails
			"#building-maps": @controller.BuildingMapList
	prepareData: (inData) ->
		# General data
		jQuery("#convention-name").text(inData.info.Convention)
		jQuery("#about-details").html(myConbook.helper.nl2br(inData.info.ProviderDetails))
		jQuery("#about-dbver").text("Database version: " + inData.info.Version)
		jQuery("#about-dbdate").text("Built: " + myConbook.helper.fixClock(inData.info.BuildDate).toString())

		# Day list data
		dayListArray = new Array()
		now = moment()

		for date in inData.daylist
			today = myConbook.helper.fixDayClock(date)
			isToday = ((now.diff(today) >= 0) and (now.diff(today.clone().endOf("day")) < 0))
			myConbook.isConDay = isToday if myConbook.isConDay is false
			
			dayListArray.push {
				day: today.format("dddd MMM D")
				date: date
				isToday: isToday
			}

		@.data.dayList.reset dayListArray

		# Schedule data
		sortedSchedule = _.sortBy inData.schedule, (schedule) ->
			return schedule.StartDate

		for sched in sortedSchedule
			if sched.Category is "(None)"
				sched.Category = null

		@.data.schedule.reset sortedSchedule

		# Guide data
		if not inData.info.HasGuide
			jQuery("#guides").addClass("ui-disabled");

		groupedHours = _.groupBy inData.restauranthours, (hours) ->
			return hours.RestaurantID
	
		for restaurant in inData.restaurants when groupedHours[restaurant.ID]
			restaurant.Hours = groupedHours[restaurant.ID]
	
		@data.restaurants.reset inData.restaurants

		@data.bars.reset inData.bars
		@data.stores.reset inData.stores
		@data.atms.reset inData.atms

		# Con info
		@data.coninfo.reset inData.coninfo

		# Con info - hotels
		@data.hotels.reset inData.hotels

		# Dealer data
		@data.dealers.reset inData.dealers

		# Hotel map data
		@data.buildingmaps.reset inData.buildingmaps

		# Area map data
		jQuery("#areamap").attr("href", inData.info.AreaMapURL)

		return @

# Prepare data on page load
jQuery(document).bind "mobileinit", ->
	# Change application settings
	jQuery.mobile.page.prototype.options.addBackBtn = true

	# Register template handlers
	Handlebars.registerHelper "nl2br", (str) ->
		return new Handlebars.SafeString myConbook.helper.nl2br str

	# Start MyConbook controls
	myConbook.initApp()
	myConbook.initTemplates()
	myConbook.initRouter()

	# Start JSON data load
	jQuery.getJSON "conbook.json", (data) ->
		myConbook.prepareData data
		jQuery("#master-button-list").show().addClass("ui-state-persist")

	return @
