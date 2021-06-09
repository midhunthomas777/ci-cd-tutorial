/*
 * Copyright (c) 2018. 7Summits Inc.
 */

({
	doInit: function (component, event, helper) {
		const api = component.get("v.WeatherAPI");

		if (api === "WeatherUnderground") {
			component.set("v.isWeatherUnderground", true);
		}
		else {
			component.set("v.isWeatherUnderground", false);
		}
		switch (component.get("v.LoadOption")) {
			case "IP Location":
				helper.loadWeatherByIP(component);
				break;
			case "Organization Address":
				helper.loadWeatherByOrgAddress(component);
				break;
			case "Record":
				helper.loadWeatherByRecord(component);
				break;
			case "Specified Zip/Postal Code":
				helper.loadWeatherByLocation(component);
				break;
			default:
				helper.loadWeatherByUser(component);
		}
	}
});