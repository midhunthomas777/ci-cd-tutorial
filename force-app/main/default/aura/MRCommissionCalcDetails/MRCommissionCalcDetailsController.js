({
    doInit : function(component, event, helper) {    
        console.log('a******accountId is'+ component.get("v.accountId"));
        console.log('a******motorolaCustomerNumber is'+ component.get("v.motorolaCustomerNumber"));
        console.log('a******mcnId is'+ component.get("v.mcnId"));
        console.log('*a*****accountRecType is'+ component.get("v.accountRecType"));
       console.log('*a*****partnerID is'+ component.get("v.partnerId"));

        helper.getAccountDetail(component,helper);
    }
})