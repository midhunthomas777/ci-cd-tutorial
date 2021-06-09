/*
 * Copyright (c) 2018. 7Summits Inc.
 */

({
	loadWeatherByIP: function (component) {
		let self = this;
		let action;

		if (component.get("v.WeatherAPI") === "WeatherUnderground") {
			action = component.get("c.getWeatherByIP");
			action.setParams({
				WeatherAPI: component.get("v.WeatherAPIKey"),
				IP_API    : component.get("v.IPAPIKey")
			});
		}
		else {
			action = component.get("c.getWeatherByIP2");
			action.setParams({
				isMetric    : component.get("v.units"),
				WeatherAPI  : component.get("v.WeatherAPIKey"),
				languageCode: component.get('v.specifiedLanguage')
			});
		}

		action.setCallback(this, function (response) {
			self.setWeatherData(component, response);
		});

		$A.enqueueAction(action);
	},

	loadWeatherByOrgAddress: function (component) {
		let self = this;
		let action;
		if (component.get("v.WeatherAPI") === "WeatherUnderground") {
			action = component.get("c.getWeatherByOrgAddress");
			action.setParams({
				WeatherAPI: component.get("v.WeatherAPIKey")
			});
		}
		else {
			action = component.get("c.getWeatherByOrgAddress2");
			action.setParams({
				isMetric    : component.get("v.units"),
				WeatherAPI  : component.get("v.WeatherAPIKey"),
				languageCode: component.get('v.specifiedLanguage')
			});
		}

		action.setCallback(this, function (response) {
			self.setWeatherData(component, response);
		});

		$A.enqueueAction(action);
	},

	loadWeatherByUser: function (component) {
		let self = this;
		let action;

		if (component.get("v.WeatherAPI") === "WeatherUnderground") {
			action = component.get("c.getWeatherByUser");
			action.setParams({
				WeatherAPI: component.get("v.WeatherAPIKey")
			});
		}
		else {
			action = component.get("c.getWeatherByUser2");
			action.setParams({
				isMetric    : component.get("v.units"),
				WeatherAPI  : component.get("v.WeatherAPIKey"),
				languageCode: component.get('v.specifiedLanguage')
			});
		}

		action.setCallback(this, function (response) {
			self.setWeatherData(component, response);
		});

		$A.enqueueAction(action);
	},

	loadWeatherByRecord: function (component) {
		let self = this;
		let action;

		console.log(component.get("v.recordId"));
		if (component.get("v.WeatherAPI") === "WeatherUnderground") {
			action = component.get("c.getWeatherByRecord");
			action.setParams({
				WeatherAPI  : component.get("v.WeatherAPIKey"),
				recordId    : component.get("v.recordId"),
				fieldName   : component.get("v.attributeName")
			});
		}
		else {
			action = component.get("c.getWeatherByRecord2");
			action.setParams({
				isMetric    : component.get("v.units"),
				WeatherAPI  : component.get("v.WeatherAPIKey"),
				recordId    : component.get("v.recordId"),
				fieldName   : component.get("v.attributeName"),
				languageCode: component.get('v.specifiedLanguage')
			});
		}

		action.setCallback(this, function (response) {
			self.setWeatherData(component, response);
		});

		$A.enqueueAction(action);
	},

	loadWeatherByLocation: function (component) {
		let self = this;
		let action;

		if (location) {
			if (component.get("v.WeatherAPI") === "WeatherUnderground") {
				action = component.get("c.getWeatherByLocation");
				action.setParams({
					WeatherAPI: component.get("v.WeatherAPIKey"),
					location  : location
				});
			}
			else {
				action = component.get("c.getWeatherByLocation2");
				action.setParams({
					WeatherAPI  : component.get("v.WeatherAPIKey"),
					isMetric    : component.get("v.units"),
					location    : component.get('v.specifiedLocation'),
					languageCode: component.get('v.specifiedLanguage')
				});
			}

			action.setCallback(this, function (response) {
				self.setWeatherData(component, response);
			});

			$A.enqueueAction(action);
		}
	},

	setWeatherData: function (component, response) {
		if (response.getState() === 'SUCCESS') {
			try {
				let data = JSON.parse(response.getReturnValue());
				console.log(data);

				component.set("v.weatherData", data);
				component.set("v.weatherLoaded", true);
			}
			catch(ex) {
				component.set('v.isErrorInAPI', true);
				console.log('JSON parse error: ' + ex.message);
			}
		}
		else {
			component.set("v.isErrorInAPI", true);
		}
	}
});