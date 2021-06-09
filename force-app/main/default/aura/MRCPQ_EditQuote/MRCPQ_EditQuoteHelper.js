({
	 getCPQPageURL : function(component) {
        let action = component.get("c.getPageUrl");
        action.setParams({
            "parentAccID" : component.get("v.recordId")       
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.getPageURL", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getQuoteInfo : function(component) {
        let action = component.get("c.getQuoteInfo");
        action.setParams({
            "quoteId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state !== "SUCCESS"){
                return;
            }
            let quote = response.getReturnValue();
            if (quote.length === 0 ){
                component.set("v.showError", true);
                component.set("v.errorMessage", "Unable to retrieve Quote information");
                component.set("v.loadSpinner", false);
                return;
            }
            let mcn = quote.Motorola_Customer_Number__c;
            let accRecType = quote.BigMachines__Account__r.RecordType.Name;
            if (!mcn && accRecType === 'Customer'){
                component.set('v.oppoAccId', quote.BigMachines__Account__c);
                component.set('v.accountId', quote.BigMachines__Account__c);
                component.set('v.oppId', quote.BigMachines__Opportunity__c);
                component.set('v.multipleMCN', true);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCPQSiteId : function(component) {
        let action = component.get("c.fetchCPQSiteId");       
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.cpqSiteId", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
   /* updateQuoteWithMCN : function(component) {
        console.log('-----------------In updateQuoteWithMCN------------------');
        var quoteID = component.get("v.recordId");  
        var mcnNumber = component.get("v.MCNselected");  
        var action = component.get("c.updateQuote");   
        action.setParams({
            "quoteId" : quoteID,
            "mcnNumber" : mcnNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state in updateQuoteWithMCN ---'+state);
            if (state === "SUCCESS") {
                component.set("v.cpqSiteId",response.getReturnValue());
                console.log('Response CPQSITEID - ' + component.get("v.cpqSiteId"));                                   			
            }
        });
        $A.enqueueAction(action);
    }*/
})