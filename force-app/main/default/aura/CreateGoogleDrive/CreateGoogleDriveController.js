({
    doInit: function (component, event, helper) {
        //helper.checkAccess(component, event, helper);
    },
    createDrive : function(component, event, helper) {
       helper.createGoogleDrive(component, event, helper);
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            component.set("v.loadSpinner",false);
            var recordId = component.get("v.recordId");//component.get("v.currentUser.Profile.Name");
            var recordCreatedDate = component.get("v.recordCreatedDate.CreatedDate");
            var JSrecordCreatedDate = new Date(recordCreatedDate);
            var today = new Date();
            //console.log('recordCreatedDate*******'+JSrecordCreatedDate);
            //console.log('today date time*******'+today);
            var timeDiff = today.getTime() - JSrecordCreatedDate.getTime(); 
            var minutesDiff = Math.floor(timeDiff / 60000);
            console.log('timeDiff is ************'+minutesDiff);
            if(minutesDiff < 15 ){
                component.set("v.hideButton",true); 
                component.set("v.displayMessage","Record is just created . please come back after 15 mintues");
            }else{
                helper.checkAccess(component, event, helper);
            }
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }

})