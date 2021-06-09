/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by jasondaluga on 7/17/18.
 */
({
	getAddress: function (component) {
		const action = component.get("c.getAddress");

		action.setParams({
			'recordId'      : component.get("v.recordId"),
			'street'        : component.get("v.StreetAttributeName"),
			'city'          : component.get("v.CityAttributeName"),
			'state'         : component.get("v.StateAttributeName"),
			'postalCode'    : component.get("v.PostalCodeAttributeName"),
			'country'       : component.get("v.CountryAttributeName"),
			'geoLocation'   : component.get('v.geoLocationName')
		});

		action.setCallback(this, function (response) {
			const data = response.getReturnValue();
			console.log('getAddress: ' + data);

			component.set('v.hasError', false);

			if (data) {
				// remove nulls from the location string
				let location = data.replace(/\+null|null/g, '');
				console.log('location:' + location);

				if (location) {
					component.set('v.location', location);
				} else {
					component.set('v.hasError', true);
				}
			}
			else {
				component.set('v.hasError', true);
			}
		});

		$A.enqueueAction(action);
	}
});