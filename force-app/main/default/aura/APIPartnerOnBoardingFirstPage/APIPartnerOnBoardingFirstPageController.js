({
    handleFieldSetEvent:function(component, event, helper) {
        var fieldSetData=event.getParam("fieldSetResult");
        component.set("v.fieldSetFinalResultFirst",fieldSetData); 
        console.log('test fields-->'+JSON.stringify(fieldSetData));
    },
    handleSubmit : function(component, event, helper) { 
        component.set("v.showSpinner", true);
    },
    handleSuccess : function(component, event, helper) {  
        var payload =event.getParams().response;
        console.log('record Id>>>'+payload.id);
        helper.navigateToObject(payload.id, event, helper);
        console.log('test out');
        component.set("v.showSpinner", false);
    },
    handleError :function(component, event, helper) {
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));
        component.set("v.showSpinner", false);        
    },
    navigateToApplicationInfo: function(component,event,helper){
        var parsedUrl = new URL(window.location.href);
        var language=parsedUrl.searchParams.get("language");
        var website = $A.get("$Label.c.Motorola_Website_Link");
        var appURL = $A.get("$Label.c.Command_Central_Partner_Program_Information_URL");
        var lang = 'en_us';
        var urlEvent = $A.get("e.force:navigateToURL");            
        var url = website+"/"+lang+"/"+appURL;
        console.log('URL>>'+url);
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    navigateToTermOfUse: function(component,event,helper){
        
        var urlEvent = $A.get("e.force:navigateToURL");
        var url = $A.get("$Label.c.Program_Terms_of_Use_URL");
        console.log('URL>>'+url);
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})