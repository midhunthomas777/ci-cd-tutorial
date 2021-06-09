/* Developed as part of SF-1954 - APAC Communities: 
APAC Deal Registration - Displaying Message for Submitted Opportunity  */
({
    handleRecordUpdated : function(component, event, helper) {
        console.log('InSubmitforApprovalCon====>');
        console.log('Region is'+component.get("v.OppFields.Region__c"));
        var eventParams = event.getParams();
        console.log('InsideParams'+eventParams.changeType);
        if(eventParams.changeType === "LOADED"){
            var region = component.get("v.OppFields.Region__c");
            var oppStatus = component.get("v.OppFields.Approval_Status__c");
            component.set('v.oppStatus',oppStatus);
            var alreadyApproved = $A.get("{!$Label.c.OppRecordApproved}");
            var closeQuickAction = $A.get("e.force:closeQuickAction");
			console.log('oppStatus'+oppStatus);
            if(oppStatus === 'Approved'){
                helper.showToast({
                    "title"   :"Error!",
                    "type"    :"Error",
                    "message" :alreadyApproved
                });  
                closeQuickAction.fire();
            }
            console.log(' Region is======>'+region);
            if(region =='AP'){
                component.set("v.functionality",'APAC Opportunity Submission'); 
            }
        }
        else if(eventParams.changeType === "CHANGED"){
            
        }else if(eventParams.changeType === "REMOVED"){
            
        }else if(eventParams.changeType === "ERROR"){
            console.log('Error: ' + component.get("v.recordError"));
        }
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    handleApproval : function(component,event,helper){
        var state = event.getParam("state");
        var response = event.getParam("response");
        console.log('state'+state);
        console.log('response'+response);
        
        helper.handlerApprovalProcessRespose(component,event,state,response);
    }
    })