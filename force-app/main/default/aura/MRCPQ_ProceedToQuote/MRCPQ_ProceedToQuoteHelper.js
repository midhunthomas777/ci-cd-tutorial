({
    getAccountDetails : function(component) {
        console.log('---------- getAccountDetails ------------');
        component.set("v.calculatorRecordProcessing",true);
        var action = component.get('c.getAccountDetails');   
        console.log('ProceedtoQuote - MCN####'+ component.get("v.motorolaCustomerNumber"));
        console.log('ProceedtoQuote - AccountId####'+ component.get("v.accountId"));
        console.log('ProceedtoQuote - partnerAccountId####'+ component.get("v.partnerAccountId"));
        
        action.setParams({
            motoCustNum :  component.get("v.motorolaCustomerNumber"),
            accountId : component.get("v.accountId"), 
            partnerAccountID: component.get("v.partnerAccountId")
        });
        var self = this;
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            console.log('state is for getaccount'+state);
            
            // this.getPartnerCommissionInfo(component);
            if( state === "SUCCESS"){
                component.set('v.detailWrap', actionResult.getReturnValue());
                this.getPartnerCommissionInfo(component);
                console.log('ProceedtoQuote - detailWrap####'+ component.get("v.detailWrap.mrCommunityType"));
                //alert('user type'+component.get("v.isPartnerUser"));
                component.set("v.calculatorRecordProcessing",false);                
            }   
            else{
                component.set("v.calculatorRecordProcessing",false);
            }
        });
        $A.enqueueAction(action);
        
    },
    getSitePrefix : function(component){       
        console.log('---------- getSitePrefix ------------');
        var action = component.get("c.fetchSitePrefix");       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state is for getSitePrefix'+state);
            if (state === "SUCCESS") {
                component.set("v.getURL",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);  
    },
    getCPQSiteId : function(component){      
        console.log('---------- getCPQSiteId ------------');
        var action = component.get("c.fetchCPQSiteId");       
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state is for getCPQSiteId'+state);
            if (state === "SUCCESS") {
                component.set("v.cpqSiteId",response.getReturnValue());
                console.log('Response CPQSITEID - ' + component.get("v.cpqSiteId"));  
            }
        });
        $A.enqueueAction(action);  
    },
    getOrderType : function(component){
        console.log('---------- getOrderType ------------');
        var action = component.get("c.fetchOrderType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state is for getaccount'+state);
            if (state === "SUCCESS") {
                //component.set("v.orderTypes",response.getReturnValue());
                var orderTypes = response.getReturnValue();
                orderTypes.sort();
                component.set("v.orderTypes",orderTypes);
            }
        });
        $A.enqueueAction(action);  
    },
    launchCPQ : function(component){      
        console.log('---------- launchCPQ ------------');
        var accountID =component.get("v.accountId"); 
        var partnerAccountId =component.get("v.partnerAccountId");
        var baseURL =component.get("v.getURL"); 
        console.log('baseURL'+baseURL);
        var cpqSiteId =component.get("v.cpqSiteId"); 
        var selectedMCN =component.get("v.motorolaCustomerNumber"); 
        var selectedMCNId =component.get("v.mcnId"); 
        //added for storing percentage in CPQ session
        var selectedEligiblePer=component.get("v.commissionDetails");
        component.set("v.cpqMRID", component.get("v.detailWrap.mrId"));
        var cpqMRId= component.get("v.cpqMRID"); 
        var cpqOrderType =  component.get("v.selectedOrderType");
        var isAccount ="True";      
        var action = component.get('c.createCPQSession');
        var isPartnerUser = component.get('v.isPartnerUser');
        var userTheme = component.get('v.userTheme');
        var oppId = component.get('v.oppId');
        console.log('ProceedtoQuote===>'+oppId);
        console.log('selectedMCNId===>'+selectedMCNId);
        console.log('selectedMCN===>'+selectedMCN);
        action.setParams({ "custId": accountID,
                          "MCNId": selectedMCNId,
                          "eligiblePer": selectedEligiblePer,
                          "MRId":cpqMRId,
                          "orderType":cpqOrderType,
                          "oppoId" : oppId
                         });      
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state is for launchCPQ'+state);
            console.log('state==>' + state);
            if(component.isValid() && state==="SUCCESS"){
                console.log("Response SUCCESS" );
                if($A.util.isUndefinedOrNull(oppId) || $A.util.isEmpty(oppId)){
                    var strURL = baseURL + "/apex/BigMachines__QuoteEdit?actId=" + accountID + "&siteId=" + cpqSiteId;
                }else{
                    var strURL = baseURL + "/apex/BigMachines__QuoteEdit?oppId=" + oppId + "&siteId=" + cpqSiteId + "&actId=" + accountID;                    
                }          
                console.log('strURL - ' + strURL)
                if(isPartnerUser) {
                    window.open(strURL,"_blank");
                    window.location.reload();
                } else if(userTheme != 'classic' && !isPartnerUser){
                    window.open(strURL,"_blank");
                } else {
                    window.open(strURL,"_self");
                }
                this.updateMCNonOpp(component);
            }         
        });
        $A.enqueueAction(action); 
    },
    getPartnerCommissionInfo : function(component){ 
        console.log('---------- getPartnerCommissionInfo ------------');
        var actionCommissionDetail = component.get("c.getPartnerCommissionDetails");
        console.log('Response orderType ######' + component.get("v.selectedOrderType"));
        console.log('Response techSpecLevel ######' + component.get("v.detailWrap.mrTierLevel"));
        console.log('Response communityType ######' + component.get("v.detailWrap.mrCommunityType"));
        actionCommissionDetail.setParams({
            orderType: component.get("v.selectedOrderType"), 
            techSpecLevel : component.get("v.detailWrap.mrTierLevel"),
            communityType : component.get("v.detailWrap.mrCommunityType")
        });
        actionCommissionDetail.setCallback(this, function(response){
            var state = response.getState();
            console.log('state is for getPartnerCommissionInfo'+state);
            if (state === "SUCCESS") {
                component.set("v.commissionDetails", response.getReturnValue());
                console.log('Response commissionDetails - ' + component.get("v.commissionDetails"));
            }
        });
        $A.enqueueAction(actionCommissionDetail);
    },
    updateMCNonOpp : function(component){  
        console.log('---------- updateMCNonOpp ------------');
        var selectedMCN =component.get("v.motorolaCustomerNumber"); 
        var selectedMCNId =component.get("v.mcnId");
        var oppId = component.get('v.oppId');
        var action = component.get('c.updateOppMCN');      
        console.log('updateMCNonOpp oppId===>'+oppId);
        console.log('updateMCNonOpp selectedMCNId===>'+selectedMCNId);
        action.setParams({"oppId" : oppId,
                          "mcnID": selectedMCNId         				                         
                         });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state is for updateMCNonOpp'+state);
            if(component.isValid() && state==="SUCCESS"){
                console.log("Response SUCCESS" );                
            }         
        });
        $A.enqueueAction(action); 
    },
})