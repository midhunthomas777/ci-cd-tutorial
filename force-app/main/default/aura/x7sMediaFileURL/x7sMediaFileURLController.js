({
    doInit : function(component, event, helper){
        let titleSize = component.get("v.titleSize");
        component.set("v.titleSize", titleSize.toLowerCase());
        let titleAlignment = component.get("v.titleAlignment");
        component.set("v.titleAlignment", titleAlignment.toLowerCase());
    	helper.getLatestVersion(component, event, helper);
	},
	copyValue : function(component, event, helper) {
        var versionId = component.get("v.versionId");
        var text = window.location.protocol+'//'+window.location.hostname+'/sfc/servlet.shepherd/version/download/'+versionId;
        // calling common helper class to copy selected text value
        helper.copyTextHelper(component,event,text);
    },
	
})