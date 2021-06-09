({
    doInit : function(component, event, helper) {
        component.set("v.loadSpinner", true); 
        /* Start - Edited Sheetal */
        var cloneRenewalOptions = [{'label': 'Clone Opportunity', 'value': 'Clone'},
                                   {'label': 'Create Service/Subscription Renewal Opportunity', 'value': 'Renew'}]
        component.set("v.oppTypeSelectionOptions", cloneRenewalOptions); 
        /* End - Edited Sheetal */
        helper.fetchOpportunityAccess(component);
        helper.getUserThemeJS(component, helper);
        helper.childSelectionScreen(component, helper);
        helper.fetchOrignalOpportunity(component, helper);
    },
    /* Added - Sheetal to handle the change on clone/Renew */
    handleChangeRadionButton : function (component, event) {
        var childSelectionsOptions 	= component.get("v.childSelectionsOptions"); 
        var originalOpportunity 	= component.get("v.originalOpportunity");
        var inputCmp    = component.find("radioGrp");
        var checkboxGrp = component.find("checkboxGrp");
        var proceedBtn  = component.find("proceedBtn");
        if(component.get("v.selectedOppType") == 'Renew') {  
            /* start : sheetal-jira-284 */
            if(!$A.util.isUndefinedOrNull(originalOpportunity)){
                if(!originalOpportunity.HasOpportunityLineItem || originalOpportunity.Product_Line_Item_Count__c <= 0){
                    checkboxGrp.set("v.disabled","true");
                    proceedBtn.set("v.disabled","true");
                    inputCmp.setCustomValidity("Error: No associated products found, can not create Renewal Opportunity");
                }else{
                    component.set("v.isRenew", true);
                    component.set("v.finalSelectionOptions", childSelectionsOptions.filter(item => item.value !== 'OpportunityLineItem'));   
                } 
            }           
        }else{
            if(checkboxGrp.set("v.disabled")|| proceedBtn.set("v.disabled")){
                checkboxGrp.set("v.disabled","false");
                proceedBtn.set("v.disabled","false");
            }
            inputCmp.setCustomValidity("");  
            component.set("v.isRenew", false);
            component.set("v.finalSelectionOptions", childSelectionsOptions);
        }
        inputCmp.reportValidity(); 
        /* End : sheetal-jira-284 */
    },
    clone : function (component, event) {
        component.set("v.showNewOpportunity", true);
        component.set("v.showChildSelection", false);
    },
    cancel : function(component, event, helper) {
        var recId = component.get("v.recordId");
        helper.redirectToSobject(component, event, helper,recId);
    }
})