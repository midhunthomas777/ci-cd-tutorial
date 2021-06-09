({
    openPopup : function(component) {
        $A.createComponent("c:RMARequestForm",{},
                           function(content, status) 
                           {
                               if (status === "SUCCESS") {
                                   component.find('overlayLib').showCustomModal(
                                       {
                                           header: "RMA request",
                                           body: content, 
                                           showCloseButton: true
                                       })
                               }
                           });
    },
    
    downloadForm : function(component) {        
        var urlEvent = $A.get("e.force:navigateToURL");
        var fileUrl = "/contentdocument/" + $A.get("$Label.c.RMADocumentId");
        console.log(fileUrl);
        urlEvent.setParams({
            "url": fileUrl
        });
        urlEvent.fire();
    }
})