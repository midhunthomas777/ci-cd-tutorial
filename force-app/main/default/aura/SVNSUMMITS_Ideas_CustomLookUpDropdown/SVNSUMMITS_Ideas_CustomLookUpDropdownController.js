/**
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    selectRecord : function(component, event, helper){
        // get the selected record from list
        let getSelectRecord = component.get("v.oRecord");

        // call the event
        let compEvent = component.getEvent("oSelectedRecordEvent");

        // set the Selected sObject Record to the event attribute.
        compEvent.setParams({selectedUser : getSelectRecord});

        // fire the event
        compEvent.fire();
    },
})