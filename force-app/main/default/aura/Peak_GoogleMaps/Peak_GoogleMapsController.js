/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by jasondaluga on 7/17/18.
 */
({
	doInit: function (component, event, helper) {

		component.set('v.hasError', false);

		// encode target and destination
		let location = component.get('v.location');
		if (location && location.length) {
			component.set('v.location', encodeURI(location));
		}

		let destination = component.get('v.destination');
		if (destination && destination.length) {
			component.set('v.destination', encodeURI(destination));
		}

		if (component.get('v.geoLocationName') !== '' ||
			component.get('v.StreetAttributeName') !== '' ||
			component.get('v.CityAttributeName') !== '' ||
			component.get('v.StateAttributeName') !== '' ||
			component.get('v.PostalCodeAttributeName') !== '' ||
			component.get('v.CountryAttributeName') !== '') {

			helper.getAddress(component);
		}
	}
});