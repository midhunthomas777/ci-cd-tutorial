({
	handlerApprovalProcessRespose : function(component,event,state,response) {
        var closeQuickAction = $A.get("e.force:closeQuickAction");
        var productvalidationerror =  $A.get("{!$Label.c.Validation_Error_Product_Family}");
        var productsuccesssubmission = $A.get("{!$Label.c.OpportunitySubmitMessage}");
        var oppresubmiterrormessage = $A.get("{!$Label.c.OpportunityResubmitErrorMessage}");  
        var inApprovalProcess = $A.get("{!$Label.c.RecordApprovalProcess}");  
        var alreadyApproved = $A.get("{!$Label.c.OppRecordApproved}");
        if(state === "SUCCESS"){
            if(response.includes(productvalidationerror)){                   
                this.showToast({
                    "title"   :"Error!",
                    "type"    :"Error",
                    "message" :productvalidationerror
                });  
                if(closeQuickAction){
                    closeQuickAction.fire();
                } 
                
                /* If the user clicks submit for approval again. This is standard message so custom 
                      label not required  */
                
            } else if(response.includes(inApprovalProcess)){                   
                this.showToast({
                    "title"   :"Error!",
                    "type"    :"Error",
                    "message" :oppresubmiterrormessage
                });  
                if(closeQuickAction){
                    closeQuickAction.fire();
                } 
            }              
                else if(response.includes(alreadyApproved)){     //              
                    this.showToast({
                        "title"   :"Error!",
                        "type"    :"Error",
                        "message" :oppresubmiterrormessage
                    });  
                    if(closeQuickAction){
                        closeQuickAction.fire();
                    } 
                }              
                    else if(closeQuickAction){
                    this.showToast({
                        "title"  : "Success!",
                        "type"   : "Success" ,
                        "message" : productsuccesssubmission                       
                    });                    
                    closeQuickAction.fire();
                }
        }else if(state === "ERROR"){
            this.showToast({
                "title"   :"Error!",
                "type"    :"Error",
                "message" :"Record has already been sent for Approval"
            });
            if(closeQuickAction){
                closeQuickAction.fire();
            }
        }else{
            if(closeQuickAction){
                closeQuickAction.fire();
            }
        }
        
    },
    showToast : function(param){
        var toastEvent = $A.get("e.force:showToast");
        if($A.util.isUndefinedOrNull(toastEvent)){
            console.log('unable to run toast message.');            
        }else{
            toastEvent.setParams(param);
            toastEvent.fire();            
        }        
    }

})