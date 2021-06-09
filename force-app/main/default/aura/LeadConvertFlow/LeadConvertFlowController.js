({
    init : function (component) {
        var action = component.get("c.checkLeadStatus");
        var recordId = component.get("v.recordId");
        action.setParams({ leadRecId : recordId});
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue()  === "Success") {
                    component.set("v.isValidLead", true);
                    //If validation is succeded firing lead conversion flow
                    let flow = component.find("LeadConversionFlow");
                    let flowInputVars = [{
                        name: 'recordId',
                        type: 'String',
                        value: component.get("v.recordId")
                    }];
                    flow.startFlow("Inside_Sales_Lead_Conversion",flowInputVars);
                    //flow.startFlow("Inside_sales_lead_conversion1",flowInputVars);
                } else {
                    component.set("v.isValidLead", false);  
                    component.set("v.displayMessage",response.getReturnValue());
                } 
            } else {
                console.log('Error in lead validating function');
            }
        });
        component.set("v.loadSpinner", false);
        $A.enqueueAction(action);
    }
})