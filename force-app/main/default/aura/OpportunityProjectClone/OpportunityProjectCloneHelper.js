({  
    fetchOpportunityAccess:function(component){
        var action = component.get('c.fetchOpportunityAccess');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                if(resp === ""){
                    component.set("v.isCreatable",true);
                }else{
                    component.set("v.isCreatable",false);
                    component.set("v.displayMessage",resp);
                }
            }else {
                console.log('Error retrieving Metadata');
            }
        });
        $A.enqueueAction(action);
    },
    fetchOrignalOpportunity : function(component, helper){
        var recordId = component.get("v.recordId"); 
        var action = component.get('c.fetchOriginalClone');
        action.setParams({
            "originalRecId"	: recordId,
            "functionality" : "Opportunity_Clone"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var resp = response.getReturnValue();
                component.set("v.originalOpportunity", resp);                
            }
            component.set("v.loadSpinner", false);
        });
        $A.enqueueAction(action); 
    },
    childSelectionScreen : function(component, helper){
        var recordId = component.get("v.recordId"); 
        console.log(recordId);
        var action = component.get('c.sObjectChildSelectionFunc');
        action.setParams({
            "originalRecId": recordId,
            "functionality" : "Opportunity_Clone"
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                component.set("v.childSelectionsOptions", resp.options);
                component.set("v.finalSelectionOptions", resp.options);
                component.set("v.heading", resp.heading.Heading__c);
            }
            component.set("v.loadSpinner", false);
            component.set("v.showChildSelection", true);
        });
        $A.enqueueAction(action);
    },
    getUserThemeJS :function(component, helper){
        var action = component.get('c.getUserTheme');
        action.setCallback(this, function(response){
            component.set("v.loadSpinner", false);
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var userTheme= response.getReturnValue();
                component.set("v.userTheme", userTheme);
            }
        });
        $A.enqueueAction(action);
    },  
    redirectToSobject : function(component, event, helper, recId){
        var userTheme = component.get("v.userTheme");
        var executionOrigin = component.get("v.executionOrigin");
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