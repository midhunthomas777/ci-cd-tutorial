({
    redirectToSobject : function(component, event, helper, recId){
        var executionOrigin = component.get("v.executionOrigin");
        var userTheme = component.get("v.userTheme");
        if(userTheme === 'Theme3'){
            window.open("/"+recId,"_self");
        }else if(executionOrigin != 'component'){
            sforce.one.navigateToSObject(recId);
        }else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": recId,
                "slideDevName": "related"
            });
            navEvt.fire();
        }
    }
    
})