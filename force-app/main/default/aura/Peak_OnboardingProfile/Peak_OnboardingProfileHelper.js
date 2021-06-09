/*
 * Copyright (c) 2019. 7Summits Inc. All rights reserved.
 *
 */

({
    getRegionPicklist: function(component, event) {
        var action = component.get("c.getPicklistFromUser");
        action.setParams({
            "ObjectApi_name": 'User',
            "Field_name": 'Region__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.regionList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getIndustryPicklist: function(component, event) {
        var action = component.get("c.getPicklistFromUser");
        action.setParams({
            "ObjectApi_name": 'User',
            "Field_name": 'Industry__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.industryList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getUpdatedUserRecord : function(component, event, helper){
        //update user record so we do not lose any changes from previous step
        var action = component.get("c.getUserRecord");
        console.log(action);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var user = response.getReturnValue();
                component.set("v.user", user);
                component.set("v.recordId", user.Id);
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    setPhoto : function(component, event, helper, documentId, fileName) {
        var action = component.get("c.uploadUserPhoto");
        action.setParams({
            "documentId": documentId,
            "filename": fileName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log("successfull with state: " + state);
            }
            else {
                console.log("Failed with state: " + state);

            }
        });
        $A.enqueueAction(action);

    },
    updateName : function(component, event, helper) {
        var action = component.get("c.updateUserNames");
        action.setParams({
            "currentUser": component.get("v.user")
        });
        console.log(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //   this.goToNext();
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

    },
    goToNext : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        if ((component.get("v.user.FirstName") == null || component.get("v.user.FirstName") == '') ||
            (component.get("v.user.LastName") == null || component.get("v.user.LastName") == '')
        ) {
            component.set("v.error", "Values are required for First Name, Last Name");
        }else if(component.get("v.user.Email") == null || component.get("v.user.Email") == '') {
            component.set("v.error", "Values are required for Email");
        }else
        {
            compEvent.setParams({"message" : "3", "slide" : "Profile"});
            compEvent.fire();
        }

    },
    goBack : function(component, event, helper) {
        var compEvent = component.getEvent("pageChange");
        compEvent.setParams({"message" : "1", "slide" : ""});
        compEvent.fire();
    }
})