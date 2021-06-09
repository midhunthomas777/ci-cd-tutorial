({
    doInit: function(component, event, helper) {
        // Create the action
        var action = component.get("c.getPartnerLevelLogo");
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnData = response.getReturnValue();
                if(returnData != null && returnData != undefined && returnData['docId'] != 'NO_DATA') {
                    component.set("v.canShowImage",true);
                    var imageUrl = '/servlet/servlet.FileDownload?file=';
                	imageUrl =  returnData['siteBaseUrl'] + imageUrl + returnData['docId'];
                	component.set("v.imageUrl",imageUrl);
                }else {
                    component.set("v.canShowImage",false);
                }
            }
            else {
                console.log("No level set");
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
    }
})