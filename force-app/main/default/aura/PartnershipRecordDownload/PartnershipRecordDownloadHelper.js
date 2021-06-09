({
    downloadGDrive : function (component, event, helper) {
        var action = component.get("c.downloadFile");
        action.setParams({ 
            recId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var serverResponse = response.getReturnValue();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                let downloadLink = document.createElement("a");
                downloadLink.href = serverResponse.contentType + ";content-disposition:attachment;base64,"+serverResponse.blobContent;
                downloadLink.download = serverResponse.fileName + serverResponse.extension;
                downloadLink.click();
            } else if (state === "INCOMPLETE") {
                console.log("State is Incomplete");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})