({
	getCPQPageURL : function(component) {
        console.log('recordId = '+component.get('v.recordId'));
        var action = component.get("c.getPageUrl");
        var recId = component.get("v.recordId");
        action.setParams({
            "parentAccID" : recId                     
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state in getCPQPageURL - '+state);
            if (state === "SUCCESS") {
                component.set("v.getPageURL",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getSitePrefix : function(component){        
        var action = component.get("c.fetchSitePrefix");       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.getURL",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    
    getCPQSiteId : function(component) {
        var action = component.get("c.fetchCPQSiteId");       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state in getCPQSiteId - '+state);
            if (state === "SUCCESS") {
                component.set("v.cpqSiteId",response.getReturnValue());
                console.log('Response CPQSITEID - ' + component.get("v.cpqSiteId"));                                   			
            }
        });
        $A.enqueueAction(action);
    },
    
    launchCPQ : function(component){
        console.log('-- In MRCPQ_ProceedEditQuote launchCPQ --');
        var accId = component.get('v.accountId');
        var mcnId= component.get('v.mcnId');
        var mcnNumber= component.get('v.mcnNumber');
        var quoteId = component.get("v.recordId");     
        var oppId = component.get('v.oppId');
        var baseURL = component.get("v.getURL");
        var getPageUrl = component.get("v.getPageURL"); 
        var cpqSiteId =component.get("v.cpqSiteId"); 
        var editCPQURL = getPageUrl + "&siteId=" + cpqSiteId + "&Id=" + quoteId;
        console.log('editCPQURL = '+editCPQURL);
        console.log('baseURL = '+baseURL);
        console.log('getPageUrl = '+getPageUrl);
        
        var action = component.get('c.createCPQSession');
        action.setParams({ "custId": accId,
                          "MCNId" : mcnId,
                          "recordId" : quoteId
                         });   
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state==>' + state);
            if(state==="SUCCESS"){
                console.log("Response SUCCESS" );
                if($A.util.isUndefinedOrNull(oppId) || $A.util.isEmpty(oppId)){
                    var strURL = baseURL + "/apex/BigMachines__QuoteEdit?actId=" + accId + "&siteId=" + cpqSiteId;
                }else{
                    var strURL = baseURL + "/apex/BigMachines__QuoteEdit?oppId=" + oppId + "&siteId=" + cpqSiteId + "&actId=" + accId;                    
                } 
                console.log('strURL = '+strURL);
                //window.open(strURL,"_blank"); 
        		window.open(editCPQURL,"_blank"); 
                
                this.updateMCNonQuote(component);
            }
        });
        $A.enqueueAction(action); 
    	},
    
    updateMCNonQuote : function(component){  
        console.log('---- updateMCNonQuote ----');
        var selectedMCN =component.get("v.mcnNumber"); 
        var selectedMCNId =component.get("v.mcnId");
        var quoteId = component.get('v.recordId');
        var theme = component.get('v.userTheme'); 
        var action = component.get('c.updateQuote'); 
        
        console.log('selectedMCN == '+selectedMCN);
        console.log('selectedMCNId == '+selectedMCNId);
        console.log('quoteId == '+quoteId);
        action.setParams({"quoteId" : quoteId,
                          "mcnNumber": selectedMCN         				                         
                         });        
        /*action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state==="SUCCESS"){
                console.log("Response SUCCESS" );   
                
                // code for updating quote in SF
            }         
        });*/
        action.setCallback(this, function(response) {
            //component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            var recordId= component.get('v.recordId');
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse === 'Ok'){
                    console.log('Operation Completed Successfully!');
                    if(theme!='Classic'){
                        window.location.reload();
                    }else{
                        window.open('/'+quoteId,'_self');
                    }
                }else{
                    if(theme!='Classic'){
                        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                        dismissActionPanel.fire(); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message: "Record can not be updated due to error encountered in API",
                            duration:' 30000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire(); 
                    }else{
                        component.set("v.Message", true);
                        component.set("v.errorMessage","Record can not be updated due to error encountered in API");
                    }
                }
            } else {
                alert('Unknown error while updating the Quote');
            }
        });
        
        $A.enqueueAction(action); 
    }
    
})