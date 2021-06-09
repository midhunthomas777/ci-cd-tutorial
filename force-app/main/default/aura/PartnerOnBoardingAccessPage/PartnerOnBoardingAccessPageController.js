({
    handleSave : function(component, event, helper) {
        component.set('v.errorMsg',null);
        var urlPrefix = $A.get("{!$Label.c.POCommunityPrefix}");
        var inputValue=component.find("accessCode").get("v.value");
        if($A.util.isEmpty(inputValue)){
            component.set('v.errorMsg','No Record Found. Please Enter Valid Access Code');
        }else{
            console.log('inside');
            var action = component.get('c.getRecordId');
            action.setParams({
                "accessCode":inputValue
            }); 
            action.setCallback(this, function(response){                
                var recordId = response.getReturnValue();
                var state = response.getState();
                if(state === 'SUCCESS'){
                    if($A.util.isUndefinedOrNull(recordId) || $A.util.isEmpty(recordId)){
                        component.set('v.errorMsg','No Record Found. Please Enter Valid Access Code');
                    }else{
                       /* var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId":recordId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();*/
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": urlPrefix+"partneronboarding-detail-page?applicationId="+recordId
                        });
                        urlEvent.fire();
                    }
                }else{
                    component.set('v.errorMsg','No Record Found. Please Enter Valid Access Code');
                }
            });
            $A.enqueueAction(action);  
        }
    }
})