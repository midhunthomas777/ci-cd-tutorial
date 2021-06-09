/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
    init: function (cmp, event, helper) {
        const streetAddress = cmp.get("v.street");
        const cityAddress = cmp.get("v.city");
        const stateAddress = cmp.get("v.state");
        const countryAddress = cmp.get("v.country");
        const postalAddress = cmp.get("v.postalCode");
        const longitude = cmp.get("v.longitude");
        const latitude = cmp.get("v.latitude");

        const streetApi = cmp.get('v.street_Api');
        const cityApi = cmp.get('v.city_Api');
        const stateApi = cmp.get("v.state_Api");
        const postalApi = cmp.get("v.postalCode_Api");
        const countryApi = cmp.get('v.country_Api');
        const longitudeApi = cmp.get("v.longitude_Api");
        const latitudeApi = cmp.get("v.latitude_Api");

        let address;
        let allignment = cmp.get("v.titleAlignment");
        cmp.set("v.titleAlignment", allignment.toLowerCase());

        let sizeofTitle = cmp.get("v.titleSize");
        cmp.set("v.titleSize", sizeofTitle.toLowerCase());

        if ((streetAddress == null || streetAddress === '') && (cityAddress == null || cityAddress === '') && (countryAddress == null || countryAddress === '') &&
            (stateAddress == null || stateAddress === '') && (longitude == null || longitude === '') && (latitude == null || latitude === '') &&
            (streetApi == null || streetApi === '') && (cityApi == null || cityApi === '') && (countryApi == null || countryApi === '') &&
            (stateApi == null || stateApi === '') && (longitudeApi == null || longitudeApi === '') && (latitudeApi == null || latitudeApi === '')) {
            cmp.set('v.mapDisplay', false);
        }
        else {
            cmp.set('v.mapDisplay', true);
        }
        if (streetApi || cityApi || stateApi || countryApi || postalApi || longitudeApi || latitudeApi) {

            helper.recordInfo(cmp, event, helper);

        }
        else {

            if (streetAddress != null) {
                cmp.set('v.streetValue', streetAddress);
                address = streetAddress;
            }
            if (cityAddress != null) {
                cmp.set('v.cityValue', cityAddress);
                if (address) {
                    address = address + '<br/>' + cityAddress;
                }
                else {
                    address = cityAddress;
                }
            }
            if (stateAddress != null) {
                cmp.set('v.stateValue', stateAddress);
                if (address) {
                    address = address + ', ' + stateAddress;
                }
                else {
                    address = stateAddress;
                }
            }
            if (postalAddress != null) {
                cmp.set('v.postalCodeValue', postalAddress);
                if (address) {
                    address = address + ', ' + postalAddress;
                }
                else {
                    address = postalAddress;
                }
            }
            if (countryAddress != null) {
                cmp.set('v.countryValue', countryAddress);
                if (address) {
                    address = address + '<br/>' + countryAddress;
                }
                else {
                    address = countryAddress;
                }
            }
            if (longitude != null) {
                cmp.set('v.longitudeValue', longitude);
            }
            if (latitude != null) {
                cmp.set('v.latitudeValue', latitude)
            }


        }

        cmp.set('v.mapMarkers', [
            {
                location: {
                    Street: cmp.get('v.streetValue'),
                    City: cmp.get('v.cityValue'),
                    State: cmp.get('v.stateValue'),
                    Country: cmp.get('v.countryValue'),
                    PostalCode: cmp.get('v.postalCodeValue'),
                    Latitude: cmp.get('v.latitudeValue'),
                    Longitude: cmp.get('v.longitudeValue'),

                },
                title: cmp.get('v.addressName'),
                description: address
            }
        ]);
    }
});