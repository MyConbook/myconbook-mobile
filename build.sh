
coffee --join www/js/myconbook.mobile.js --compile cs/core.coffee cs/buildingmaps.coffee cs/coninfo.coffee cs/dealers.coffee cs/guide.coffee cs/guide-types.coffee cs/hotels.coffee cs/schedule.coffee
uglifyjs www/js/myconbook.mobile.js > www/js/myconbook.mobile.min.js
