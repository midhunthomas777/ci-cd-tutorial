({
    handlePageChange : function(component,event,helper){
        var pageReference = component.get("v.pageReference");
        alert('PageReference..'+pageReference);
        var recordTypeID = pageReference.state.recordTypeId;
        console.log('Record Type ID is..'+recordTypeID);
    },
    getCPQSiteId : function(component,event,helper){
        component.set("v.loadSpinner", true);
        var action = component.get("c.fetchCPQSiteId");       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.cpqSiteId",response.getReturnValue());
                console.log('Response CPQSITEID - ' + component.get("v.cpqSiteId"));  
            }
            console.log('entered this section')
            this.getAccounts(component, helper);
        });
        $A.enqueueAction(action);  
    },
    getAccounts : function(component, helper){
        var accountId = component.get("v.recordId"); 
        console.log('Account id..'+accountId);
        var action = component.get('c.getMCN');
        action.setParams({"recId": accountId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                var resp= response.getReturnValue();
                if(!($A.util.isUndefinedOrNull(resp) || $A.util.isEmpty(resp))){                    
                    if(resp.length == 0){
                        component.set("v.showError", true);
                        component.set("v.errorMessage", "Quotes can be created on Opportunity associated with a Customer Account with an Active MCN or a Prospect account");
                        component.set("v.loadSpinner", false);
                        return false;
                    } else if(resp.length == 1) {
                        if(accountId.startsWith('006')){ //SF-2509         
                            /*      if(resp[0].Parent.RecordType.DeveloperName !== 'Prospect' && $A.util.isEmpty(resp[0].CDH_Account__c)){ 
                                    component.set("v.showError", true);
                                    component.set("v.errorMessage", "Please populate Motorola Customer Number field on the opportunity.");
                                    component.set("v.loadSpinner", false);
                                    return false;
                            }
                            else*/                            
                            if($A.util.isEmpty(resp[0].CDH_Account__c)){ 
                                if(resp[0].RecordType.DeveloperName=='Prospect'){
                                    component.set("v.mcnId", null);
                                }else{
                                    component.set("v.mcnId", resp[0].Id);
                                }                                
                                component.set("v.oppMCN", false);
                                //component.set("v.oppAccId", resp[0].parent.Id);                                
                            }else{
                                component.set("v.mcnId", resp[0].CDH_Account__c);
                                component.set("v.oppMCN", true);
                                component.set("v.oppAccId", resp[0].AccountId);
                            }                         
                        } else if(accountId.startsWith('001')){
                            component.set("v.mcnId", resp[0].Id);
                        } else {
                            component.set("v.oppAccId", resp[0].Account__c);
                            // This is to pass the selected Parnter MCN from  the Opportunity Partner Recrod
                            // Defect - VESTA_SPILLMAN_INT-1239
                            component.set("v.mcnId", resp[0].Partner_MCN__c);
                            component.set("v.pOppoId", resp[0].Opportunity__c);
                        }
                        component.set("v.singleMCN", true);
                        console.log('Single MCN oppAccId==>'+component.get("v.oppAccId"));
                        console.log('MCNId==>'+component.get("v.mcnId"));
                        this.launchCPQ(component);
                    } else {                       
                        component.set("v.multipleMCN", true);
                        component.set("v.loadSpinner", false);
                    }
                } else {
                    component.set("v.showError", true);
                    component.set("v.errorMessage", "Quotes can only be created for active Motorola Customer Numbers.");
                    component.set("v.loadSpinner", false);
                }
            }
            component.set("v.loadSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    launchCPQ : function(component){    
        var accID;
        var recordID = component.get("v.recordId");
        var singleMCN = component.get("v.singleMCN");
        var cpqSiteId = component.get("v.cpqSiteId"); 
        var oppAccId = component.get("v.oppAccId");
        var selectedMCNId = component.get("v.mcnId");
        var action = component.get('c.createCPQSession');
        var theme = component.get("v.userTheme");
        var oppoId = component.get("v.pOppoId");
        var oppMCN = component.get("v.oppMCN");
        var oppoAccId = component.get("v.oppoAccId");
        var partnerQuote;
        console.log('Before recordID==>'+recordID);
        console.log('oppMCN==>'+oppMCN);        
        console.log('oppoAccId==>'+oppoAccId);
        console.log('selectedMCNId==>'+selectedMCNId);
        console.log('recordID==>'+recordID);
        console.log('accID==>'+accID);
        if(recordID.startsWith('006')){
            if(oppMCN){
                selectedMCNId = null;
                accID = oppoAccId; //has to be set otherwise we get this https://motorolasolutions--uat--bigmachines.visualforce.com/apex/QuoteEdit?actId=undefined&siteId=a5Q340000001M5hEAE&oppId=0061F00000AqnupQAB
            }else{
                oppoId = recordID;
                accID = oppoAccId;
            }            
        }else if(recordID.startsWith('001')){
            accID = recordID;
        }        
        console.log('After oppoId==>'+oppoId);
        console.log('After accID==>'+accID);
        // this is for creating quote from Partner2__c related list on Opportunity
        if(recordID.startsWith('a09')){
            accID = oppAccId;
            partnerQuote = 'Software';
            console.log('##In partners2##')
            console.log('##In partners2#accID#'+accID)
            console.log('##In partners2#recordID#'+recordID)
            console.log('##In partners2#oppoId#'+oppoId)
        }
        action.setParams({"custId": accID,"MCNId": selectedMCNId,
                          "eligiblePer": null,"MRId":null,"orderType":null,
                          "oppoId" : oppoId,"partnerSoftwareQuote" : partnerQuote, "recordId" : component.get("v.recordId")
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state==="SUCCESS"){
                console.log('NewQuote SingleMCN');
                var strURL;
                if(recordID.startsWith('006')){
                    strURL = "/apex/BigMachines__QuoteEdit?oppId=" + recordID + "&siteId=" + cpqSiteId + "&actId=" + accID;
                } else {
                    strURL = "/apex/BigMachines__QuoteEdit?actId=" + accID + "&siteId=" + cpqSiteId;
                }
                if(singleMCN && theme !='classic') {
                    window.open(strURL,"_blank");   
                } else {
                    window.open(strURL,"_self");
                }
                if(theme !='classic'){
                    $A.get("e.force:closeQuickAction").fire();
                }
                if(!oppMCN && selectedMCNId !=null){
                    console.log('oppMCN==>'+oppMCN);
                    this.updateMCNonOpp(component);
                }
            }         
        });
        $A.enqueueAction(action); 
    },
    
    checkOppValidility : function(component,event){ 
        var recordId = component.get("v.recordId");
        var action = component.get('c.isValidOpp');
        var userTheme = component.get("v.userTheme");
        //Getting current userId
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({
            "recordId": recordId,
            "userId" : userId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === 'SUCCESS'){
                if(!($A.util.isUndefinedOrNull(resp) || $A.util.isEmpty(resp))){
                    this.showToast(component,resp,'Error');
                    /*if(userTheme != "classic"){

                    }*/
                }
                else {
                    this.getCPQSiteId(component,event);
                }
            } else{
                this.showToast(component,'Some unexpected error occured','Error');
            }
        });
        
        $A.enqueueAction(action);  
    },
    
    isCreateQuoteFromAccTrue : function(component,event){
        var action = component.get('c.canCreateQuoteFromAcc');
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            console.log('###IN create account method in the lightnign component###');
            if(state === 'SUCCESS'){
                if(!($A.util.isUndefinedOrNull(resp) || $A.util.isEmpty(resp))) {
                    this.showToast(component,resp,'Error');
                    //$A.get("e.force:closeQuickAction").fire();
                } else{
                    this.getCPQSiteId(component,event);   
                }
            }if(state === 'ERROR') {
                this.showToast(component,'Some unexpected error occured','Error');   
            }
        });
        $A.enqueueAction(action); 
    },
    
    showToast : function(component,message,messageType){
        var userTheme = component.get('v.userTheme');
        if(userTheme == "classic"){
            component.set("v.showError",true);
            component.set("v.errorMessage", message);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: message,
                type : messageType
            });
            toastEvent.fire(); 
            $A.get("e.force:closeQuickAction").fire();
        }
    },   
    
    updateMCNonOpp : function(component){  
        var selectedMCN =component.get("v.motorolaCustomerNumber"); 
        var selectedMCNId =component.get("v.mcnId");
        var oppId = component.get("v.recordId");
        var action = component.get('c.updateOppMCN');      
        console.log('updateMCNonOpp oppId===>'+oppId);
        console.log('updateMCNonOpp selectedMCNId===>'+selectedMCNId);
        action.setParams({"oppId" : oppId,
                          "mcnID": selectedMCNId         				                         
                         });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state==="SUCCESS"){
                console.log("Response SUCCESS" );                
            }         
        });
        $A.enqueueAction(action); 
    },
})