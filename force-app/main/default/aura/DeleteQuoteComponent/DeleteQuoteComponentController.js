//Developed as part of SF-2059 - Partners get redirected to wrong place after quote deletion
({
    doinit: function(component, event, helper) {
        var recordid=component.get("v.recordId");
        var orderNumberQuotemessage = $A.get("{!$Label.c.OrderNumberNotEmpty}"); 
        console.log('RecordIdIs====>'+recordid);
        var action=component.get("c.deleteRecord");
        action.setParams({"rec":recordid});
        action.setCallback(this,function(response){
            var state=response.getState();
            console.log('state is========'+state);
            console.log('response is======'+response);
            if(state==="SUCCESS")
            {
                var accountId=response.getReturnValue();
                console.log('AccountId Is====>'+accountId);
                console.log('success test');     
                console.log('closed');
                helper.handleRecordUpdated(component, event, helper,accountId);
            }
            else if(state==="ERROR"){
                /*console.log('InsideError===>');
                var errors = response.getError();
                component.set("v.showErrors",true);
               component.set("v.errorMessage",errors[0].message);
               console.log('Errors are'+errors); */               
               var errorToast = $A.get("e.force:showToast");
               errorToast.setParams({  
                   "title": "Error",
                   "message": orderNumberQuotemessage
               });
               errorToast.fire();
               var closeQuickAction = $A.get("e.force:closeQuickAction");    
               closeQuickAction.fire();               
           }
          });
        $A.enqueueAction(action);       
    }    
})