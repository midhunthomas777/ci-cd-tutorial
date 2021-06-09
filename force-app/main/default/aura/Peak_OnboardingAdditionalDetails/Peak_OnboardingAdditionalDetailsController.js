/**
 * Created by: Dipendra Dadhich
 * Created Date: 19-08-2019. 
 */
 ({
    init: function (component, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.recordId",userId);
    },
    goToNext : function(component, event, helper) {
        helper.handleSubmit(component, event, helper);
        helper.goToNext(component, event, helper);
    },
    goBack : function(component, event, helper) {
        helper.goBack(component, event, helper);
    },
    handleOnSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        var messgae = "Record Saved Sucessfully"
        component.find("notificationsLibrary").showToast({
            "title": "Saved",
            "message": messgae
        });
    },
    handleOnError : function(component, event, helper) {
    }
})