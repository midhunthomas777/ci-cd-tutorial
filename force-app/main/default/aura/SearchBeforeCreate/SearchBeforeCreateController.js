({
    doInit : function(component, event, helper) {
        helper.getCountries(component, event, helper);
    },
    validateStatePicklist : function(component, event, helper) {
        var countryValue = component.find("country").get("v.value");
        if(countryValue == '--None--'){
            helper.setDefaultDropdowns(component, event, helper, 'state');
            component.set("v.stateDisabled",true);  
        }
        else if(countryValue != '--None--'){
              helper.getProvinceOptions(component, event, helper, countryValue);
        }
    },
    handleLoad: function(component, event, helper) {
        component.set('v.showSpinner', false);
    },
    handleSuccess : function(component, event, helper) {
        console.log('success');
        component.set("v.showSpinner", false);
    },
    handleError :function(component, event, helper) {
        var errors = event.getParams();
        var errorMsg = JSON.stringify(errors);
        console.log("json error", errorMsg);
       // document.getElementById("stdError").style.display = "block";
        component.set("v.showSpinner", false);
    },
    callSearchBeforeCreateTable : function(component, event, helper) {
        console.log("callSearchBeforeCreate");
        var JSAccountName = component.find("name").get("v.value");
        var JScountryCode = component.find("country").get("v.value");
        var JScountry = component.get("v.countryList").reduce( (a, v) => a || (v.value == JScountryCode? v.label: ""), "");
        var JSBillingStateCode = component.find("state").get("v.value");
        var JSBillingState;
        if(!$A.util.isUndefinedOrNull(JSBillingStateCode) && !$A.util.isEmpty(JSBillingStateCode) ){
           JSBillingState = component.get("v.stateList").reduce( (a, v) => a || (v.value == JSBillingStateCode? v.label: ""), "");
        }
        var JSBillingCity = component.find("city").get("v.value");
        var JSBillingStreet = component.find("street").get("v.value");
        var JSPostalCode = component.find("postalCode").get("v.value");
        component.set("v.showSpinner", false);
        event.preventDefault();
        var eventFields = event.getParam("fields");
        var JSTerritory = eventFields['Territory__c'];
        var JSRegion = eventFields['Region__c'];
        var JSRTM = eventFields['Primary_Route_to_Market__c'];
        
        console.log('AccountName'+JSAccountName);
        component.set("v.accountName",JSAccountName);
        component.set("v.countryName",JScountry);
        component.set("v.countryCode",JScountryCode);
        component.set("v.stateName",JSBillingState);
        component.set("v.stateCode",JSBillingStateCode);
        component.set("v.cityName",JSBillingCity);
        component.set("v.streetName",JSBillingStreet);
        component.set("v.postalCode",JSPostalCode);
        component.set("v.territory",JSTerritory);
        component.set("v.region",JSRegion);
        component.set("v.routeToMarket",JSRTM);

        component.set("v.AccountRecordId",component.get("v.recordId"));
        component.set("v.isAccountSearched", false);
        component.set("v.isAccountSearched", true);
    },
    handleChange : function (component, event, helper){
       var rtm = component.find('rtm').get("v.value");
        component.set("v.routeToMarket",rtm);
    }
    
})