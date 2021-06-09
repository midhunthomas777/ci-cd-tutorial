/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
    inLexMode: function () {
        let lexMode = new RegExp('.*?\/s\/','g').exec(window.location.href) != null;
        return !lexMode;
    },

    getMapLocators: function (component, event, helper) {
        // getting values from attribute.
        const action = component.get("c.recordData");

        const streetApi = component.get('v.streetApi');
        const cityApi = component.get('v.cityApi');
        const stateApi = component.get('v.stateApi');
        const countryApi = component.get('v.countryApi');
        const postalApi = component.get('v.postalApi');
        const objectName = component.get('v.objectName');
        const limitSize = component.get('v.limit');
        const sortByApi = component.get('v.sortByField');
        const ascending = component.get('v.ascending');
        const geoLocationApi = component.get('v.geoLocation');
        const latitudeValue = component.get('v.userlatitude');
        const longitudeValue = component.get('v.userlongitude');
        const filterFieldApiName = component.get('v.filterFieldName');
        let filterFieldValue = component.get('v.filterFieldValue');
        const locationNameAPI = component.get('v.locationNameAPI');
        const recordId = component.get("v.recordId");
        const sortPreference = component.get("v.sortPreference");
        let recordIdValue;
        if (recordId) {
            recordIdValue = recordId;
        }

        if (filterFieldValue === '{userId}') {
            filterFieldValue = $A.get("$SObjectType.CurrentUser.Id");
        }
        
        //passing parameters to controller method.
        action.setParams({
            'parentId': recordIdValue,
            'objectName': objectName,
            'parentApi': component.get('v.parentApi'),
            'streetApi': streetApi,
            'cityApi': cityApi,
            'stateApi': stateApi,
            'countryApi': countryApi,
            'postalApi': postalApi,
            'geoLocationApi': geoLocationApi,
            'latitudeValue': latitudeValue,
            'longitudeValue': longitudeValue,
            'sortByApi': sortByApi,
            'ascending': ascending,
            'filterFieldApiName': filterFieldApiName,
            'filterFieldValue': filterFieldValue,
            'locationNameAPI': locationNameAPI,
            'limitSize': limitSize,
            'sortPreference' :sortPreference
            
            
        });
        
        action.setCallback(this, function (response) {
            const state = response.getState();
            console.log('state::'+state);
            component.set("v.Spinner", false);
            if (state === 'SUCCESS') {
                if(response.getReturnValue() === 'No Records'){
                    component.set("v.noRecords", true);
                } else {
                const resultant = JSON.parse(response.getReturnValue());
                const iconname = component.get("v.iconname");
                let str = component.get("v.recordDetailLink");
                let result =window.location.hostname;
                let records
                if(resultant != null){
                records = resultant.records;
                }
                if (records != null) {
                    if(records.length != 0){
                  	component.set("v.fromLocation", resultant.fromLocation);
                    let locations = [];
                        let recorddirection = '_parent';
                        if(component.get("v.openRecordInNewTab")){
                            recorddirection = '_blank';
                        }
                    for (let i = 0; i < records.length; i++) {
                        let latitude;
                        let longitude;
                        let address = '';
                        let recordName = records[i][component.get("v.locationNameAPI")];
                        if (!this.inLexMode()){
                            let detail = '/s/detail/';
                            let pathName = window.location.pathname;
                            let prefix = pathName.indexOf('/s/');
                            if (prefix !== -1) {
                                detail = pathName.substr(0, prefix) + detail;
                            }
                            let url = window.location.protocol+'//'+window.location.hostname+detail+records[i]["Id"];
                            result = '<a href="' + url + '" target="'+ recorddirection +'">' + str + '</a>'
                        }
                        else {
                            let url = window.location.protocol+'//'+window.location.hostname+'/'+records[i]["Id"];
                            result = '<a href="' + url + '" target="'+ recorddirection +'">' + str + '</a>' 
                        }
                        
                        if (records[i][streetApi]) {
                            address += records[i][streetApi] + '<br/> ';
                        }
                        if (records[i][cityApi]) {
                            address += records[i][cityApi] + '<br/> ';
                        }
                        if (records[i][stateApi]) {
                            address += records[i][stateApi] + '<br/> ';
                        }
                        if (records[i][countryApi]) {
                            address += records[i][countryApi];
                        }
                        if (records[i][geoLocationApi]) {
                            latitude = records[i][geoLocationApi].latitude;
                            longitude = records[i][geoLocationApi].longitude;
                        }
                        
                        locations.push({
                            location: {
                                Street: records[i][component.get("v.streetApi")],
                                City: records[i][component.get("v.cityApi")],
                                State: records[i][component.get("v.stateApi")],
                                Country: records[i][component.get("v.countryApi")],
                                PostalCode: records[i][component.get("v.postalApi")],
                                Longitude: longitude,
                                Latitude: latitude
                                
                            },
                            
                            title: records[i][component.get("v.locationNameAPI")],
                            description: address+'</br> </br> '+result,
                            icon: iconname
                        });
                    }
                    
                    
                    component.set('v.mapMarkers', locations);
                    if (component.get("v.showListView") === false) {
                        component.set('v.listView', "hidden");
                    }
                }
                    else{
                        component.set("v.noAddress", true);
                    }
                } else {
                     component.set("v.invalidfields", true);
                }
            }
            }
            else{
                alert('Something went wrong. Please contact your System Administrator.');
            }
            
        });
        $A.enqueueAction(action);
    }
    
});