({
    ModelToastMsg : function(component, event, helper) {
        try
        {
            var displayDecisionFieldValue;
            var action = component.get("c.toastShowDone");
            var recordId = component.get("v.recordId");
            var fieldAPIName = component.get("v.objectField");
            var toastTypeField = component.get('v.toastType');
            var toastModeField = component.get('v.toastMode');
            var messageField = component.get('v.message');
            var displayToastValue = component.get('v.displayToast');
            var displayDecisionFieldAPIName = component.get('v.displayDecisionField');
            console.log('**displayDecisionFieldAPIName**'+displayDecisionFieldAPIName);
            console.log('**displayToastValue**'+displayToastValue);
            console.log('**fieldAPIName**'+fieldAPIName);
            console.log('**messageField**'+messageField);
            console.log('**toastTypeField**'+toastTypeField);
            if((displayToastValue && !$A.util.isUndefinedOrNull(displayDecisionFieldAPIName) && 
                 (($A.util.isUndefinedOrNull(fieldAPIName) && !$A.util.isUndefinedOrNull(messageField))|| !$A.util.isUndefinedOrNull(fieldAPIName)))||
                (!displayToastValue && !$A.util.isUndefinedOrNull(fieldAPIName))){
                
                console.log('#Checkpoint 1');
                //Call class to fetch field values
                action.setParams({"objId":recordId,"fieldName":fieldAPIName,"displayToast":displayToastValue,"displayDecisionFieldAPI":displayDecisionFieldAPIName,"message":messageField});
                action.setCallback(this,function(result){
                    console.log('#component.isValid()#'+component.isValid());
                    console.log('#result.getState()#'+result.getState());
                    if (component.isValid() && result.getState() == 'SUCCESS'){
                        var sobjectrecord = action.getReturnValue();
                        var type = "success";
                        var message;
                        console.log('**sobjectrecord**'+sobjectrecord);
                        if(sobjectrecord != 'NotValid'){
                            console.log('**fieldAPIName**'+fieldAPIName);
                            console.log('**sobjectrecord**'+sobjectrecord);
                            console.log('**messageField**'+messageField);
                            if(sobjectrecord!=''){
                                console.log('#Checkpoint 2nd');
                                message = sobjectrecord;  
                                helper.showToast(component, event, helper, type, message,toastTypeField,toastModeField,messageField);
                            }
                            else if(fieldAPIName=='' && sobjectrecord=='' && messageField!=''){
                                console.log('#Checkpoint 3rd');
                                helper.showToast(component, event, helper, type, messageField,toastTypeField,toastModeField,message);
                            }
                        }
                    }
                    else
                    {
                        console.log('#Checkpoint 4tg');
                        var type = "error";
                        var message = result.getError()[0].message;
                        messageField = messageField + " ERROR";
                        //helper.showToast(component, event, helper, type, message,toastTypeField,toastModeField,messageField);
                    }
                });
                $A.enqueueAction(action);
            }
            else if(!displayToastValue && messageField!=''){
                console.log('#Checkpoint 5th');
                var type = "success";
                helper.showToast(component, event, helper, type, messageField,toastTypeField,toastModeField,"");
            }
        }
        catch(e){
            console.log('Catch Exception: '+e);
        }
    },
    showToast : function(component, event, helper, type, message,toastTypeField,toastModeField,messageField) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastModeField === 'Sticky'){
            toastEvent.setParams({
                title : messageField,
                message: message,
                type: toastTypeField,
                mode: toastModeField
            });
        }else if(toastModeField === 'Dismissible'){
            toastEvent.setParams({
                title : messageField,
                message: message,
                duration:' 5000',
                type: toastTypeField,
                mode: toastModeField
            });
        }else{
            toastEvent.setParams({
                title : messageField,
                message: message,
                duration:' 5000',
                type: toastTypeField,
                mode: toastModeField
            });
        }
        toastEvent.fire();
    }
})