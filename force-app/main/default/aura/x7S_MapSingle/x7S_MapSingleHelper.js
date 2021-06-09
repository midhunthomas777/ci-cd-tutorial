/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
    recordInfo: function (cmp, event, helper) {
        let action = cmp.get('c.recordData');
        const recordID = cmp.get('v.recordId');

        const streetAddress = cmp.get("v.street_Api");
        const cityAddress = cmp.get("v.city_Api");
        const stateAddress = cmp.get("v.state_Api");
        const countryAddress = cmp.get("v.country_Api");
        const postalAddress = cmp.get("v.postalCode_Api");
        const longitude = cmp.get("v.longitude_Api");
        const latitude = cmp.get("v.latitude_Api");

        // set action params
        action.setParams({
            'recId': recordID,
            'streetApi': streetAddress,
            'cityApi': cityAddress,
            'stateApi': stateAddress,
            'countryApi': countryAddress,
            'postalApi': postalAddress,
            'longitudeApi': longitude,
            'latitudeApi': latitude,

        });
        // callback to process action results
        action.setCallback(this, function (response) {
            let state = response.getState();
            let address;
            let recordName;
            if (state === 'SUCCESS') {

                const item = JSON.parse(response.getReturnValue());
                if (item) {
                    if (item[streetAddress] === undefined && item[cityAddress] === undefined && item[stateAddress] === undefined){
                        cmp.set("v.invalidAddress", true);
                        cmp.set("v.mapDisplay", false);
                    } else {
                    
                    if (item['Name'] !== undefined) {
                        recordName = item['Name'];
                    }
                    if (item[streetAddress] !== undefined) {
                        cmp.set('v.streetValue', item[streetAddress]);
                        address = item[streetAddress];
                    }
                    if (item[cityAddress] !== undefined) {
                        cmp.set('v.cityValue', item[cityAddress]);
                        if (address) {
                            address = address + '<br/>' + item[cityAddress];
                        }
                        else {
                            address = item[cityAddress];
                        }
                    }
                    if (item[stateAddress] !== undefined) {
                        cmp.set('v.stateValue', item[stateAddress]);
                        if (address) {
                            address = address + ', ' + item[stateAddress];
                        }
                        else {
                            address = item[stateAddress];
                        }
                    }
                    if (item[postalAddress] !== undefined) {
                        cmp.set('v.postalCodeValue', item[postalAddress]);
                        if (address) {
                            address = address + ', ' + item[postalAddress];
                        }
                        else {
                            address = item[postalAddress];
                        }
                    }
                    if (item[countryAddress] !== undefined) {
                        cmp.set('v.countryValue', item[countryAddress]);
                        if (address) {
                            address = address + '<br/>' + item[countryAddress];
                        }
                        else {
                            address = item[countryAddress];
                        }
                    }
                    if (item[longitude] !== undefined) {
                        cmp.set('v.longitudeValue', item[longitude]);
                    }
                    if (item[latitude] !== undefined) {
                        cmp.set('v.latitudeValue', item[latitude]);
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
                            title: recordName,
                            description: address
                        }
                    ]);
                }
                }

                else {
                    cmp.set("v.invalidfields", true);
                    cmp.set("v.mapDisplay", false);
                }
            }

        });
        // invoke action
        $A.enqueueAction(action);
    },

});