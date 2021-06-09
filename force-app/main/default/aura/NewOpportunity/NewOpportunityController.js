({
    doInit : function(component, event, helper) {
        helper.getOppRegionTerritoryMapping(component, event,helper);//SF-2699
        component.set("v.motorolaCustomerNumber","");        
        component.set("v.loadSpinner", true);
        var userTheme= component.get("v.userTheme");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.secondaryOwner",userId);
        var isClone = component.get("v.clone");
        console.log("isClone :="+isClone);
        var navigateAttributes = component.get("v.pageReference");
        
        /*Added by Martina*/
        var device = $A.get("$Browser.formFactor");
        if(device != 'PHONE' && !(isClone)){
                       
            var state = navigateAttributes.state;
            var base64Context = state.inContextOfRef;	        
            console.log('base64Context = '+base64Context);	        
            if (base64Context.startsWith("1\.")) {	            
                base64Context = base64Context.substring(2);	            
                console.log('base64Context = '+base64Context);	        
            }	        
            var addressableContext = JSON.parse(window.atob(base64Context));	        
            component.set("v.isNewOpp",true);
            component.set("v.recordTypeId",navigateAttributes.state.recordTypeId);
            component.set("v.customerAccId",addressableContext.attributes.recordId);
            
        }
        
        /* Added by sagar for getting attribute values in mobile */
        else{
        if (!($A.util.isUndefinedOrNull(navigateAttributes) || $A.util.isEmpty(navigateAttributes))){
            
            component.set("v.isNewOpp",navigateAttributes.state.c__isNewOpp);
            component.set("v.recordTypeId",navigateAttributes.state.c__recordTypeId);
            component.set("v.customerAccId",navigateAttributes.state.c__customerAccId);
        }
        }
        if(component.get("v.clone")){
            component.set("v.saveOrCloneBtn", "Clone Opportunity");    
        }
        if($A.util.isUndefinedOrNull(userTheme) || $A.util.isEmpty(userTheme)){
            helper.getUserThemeJS(component, helper);
        } 
       
		//helper.getAccRegionTerritory(component, event,helper);//SF-2699
		helper.getFieldsetsJS(component, helper);
        helper.fetchOpportunityAccess(component);
        helper.getAccounts(component, event,helper);
        //helper.prePopulateOppDetails(component,event, helper);
        helper.fetchMetaMessages(component, helper);
        //helper.checkOppRecordType(component, helper);  
    },
    recordUpdated: function(component, event, helper) {
 		//console.log('in userRecordLoader recordUpdated ');
        var recID = component.get("v.recordId");
        var isClone = component.get("v.clone");
        var changeType = event.getParams().changeType;
     	//console.log('User changeType==>'+changeType);
        if (changeType === "ERROR") {  }
        else if (changeType === "LOADED") { 
            if(!$A.util.isUndefinedOrNull(recID) && !$A.util.isEmpty(recID) && recID.startsWith('001')){//SF-2733
                //alert('in loading');
				helper.getAccRegionTerritory(component, event,helper);//SF-2699
                helper.prePopulateOppDetails(component,event, helper);
            }else if(isClone){
                helper.prePopulateOppDetails(component,event, helper);
            }
        }
        else if (changeType === "REMOVED") {}
        else if (changeType === "CHANGED") {  
            if(!$A.util.isUndefinedOrNull(recID) && !$A.util.isEmpty(recID) && recID.startsWith('001')){//SF-2733 
                //alert('in changed');
                helper.getAccRegionTerritory(component, event,helper);//SF-2699
                helper.prePopulateOppDetails(component,event, helper);
            }
        }
    },   
    handleSuccess : function(component, event, helper) {
        //console.log("--In handleSuccess--");
        component.set("v.loadSpinner", false);
        var isClone = component.get("v.clone");
        if(!isClone){
            var payload = event.getParams().response;
            var oppId = payload.id;
            helper.redirectToSobject(component,event,oppId);
        }
    },
    handleLoad : function(component, event, helper) {
        //console.log("--In handleLoad--");       
        component.set("v.loadSpinner", false);   
    },
    handleSubmit : function(component, event, helper) {
        //console.log("--In handleSubmit--");
        component.set("v.errorMsg", null);
        component.set("v.loadSpinner", true);
        var isClone = component.get("v.clone");
        var numberOfMCNs = component.get("v.noOfMCNs");
        var isProspect = component.get("v.isProspect");
        var isPartnerAsEndUser = component.get("v.isPartnerAsEndUser")
        var metaMessages = component.get("v.metaMessages");
        var currentUserProfile = component.get("v.currentUser.Profile.Name");
        var NASWprofile = $A.get("$Label.c.NA_Software_Enterprise_Profile");
        event.preventDefault();
        var eventFields = event.getParam("fields");
        eventFields['CDH_Account__c'] = component.get("v.mcnId");
        eventFields['Secondary_Owner__c'] = component.get("v.secondaryOwner");
        if(isClone){ 
            eventFields['RecordTypeId'] = component.get("v.recordTypeId"); /* Added by Sagar */
        }     
        eventFields['AccountId'] = component.get("v.customerAccId");
        if(eventFields['StageName'] != 'Secure' && eventFields['StageName'] != 'Verbal' && !isClone) { // Added by Harish to handle forecast category on Clone
            eventFields['ForecastCategoryName'] = 'Non Commit';
        } else if((eventFields['StageName'] == 'Secure' || eventFields['StageName'] == 'Verbal') && !isClone){
            eventFields['ForecastCategoryName'] = 'Commit';
        }
        //console.log('Compelte Result='+JSON.stringify(eventFields));  
        var isValidated = true;
        document.getElementById("stdError").style.display = "none";
        if($A.util.isUndefinedOrNull(eventFields['Region__c']) || $A.util.isEmpty(eventFields['Region__c'])){
            isValidated = false;
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg", metaMessages['Region_Not_Blank'].Message__c);
        }/**Added by Harish*/
        else if(eventFields['Region__c'] != 'AP' && ($A.util.isEmpty(eventFields['Territory__c']) || $A.util.isEmpty(eventFields['Territory__c']))){
            isValidated = false;    
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg",  metaMessages['Territory_Check'].Message__c ); 
        }else if($A.util.isEmpty(eventFields['Country__c']) || $A.util.isEmpty(eventFields['Country__c'])){
            isValidated = false;    
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg",  metaMessages['Country_Check'].Message__c ); 
        }else if((eventFields['Country__c'] == 'United States' || eventFields['Country__c'] == 'Canada') && ($A.util.isEmpty(eventFields['State__c']) || $A.util.isEmpty(eventFields['State__c']))){
            isValidated = false;    
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg",  metaMessages['State_Check'].Message__c ); 
        }else if($A.util.isUndefinedOrNull(eventFields['Channel_Opportunity__c']) || $A.util.isEmpty(eventFields['Channel_Opportunity__c'])){
            isValidated = false;    
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg",  metaMessages['Route_To_Market_Validation'].Message__c ); 
        }else if($A.util.isEmpty(eventFields['CurrencyIsoCode']) || $A.util.isEmpty(eventFields['CurrencyIsoCode'])){
            isValidated = false;    
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg",  metaMessages['Currency_Check'].Message__c ); 
        }else if(isClone && ($A.util.isEmpty(eventFields['ForecastCategoryName']) || $A.util.isEmpty(eventFields['ForecastCategoryName']))){
            isValidated = false;    
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg", metaMessages['Forecast_Category_Check'].Message__c);
        }else if(eventFields['StageName'] === 'Lost' || eventFields['StageName'] === 'No Pursuit' || eventFields['StageName'] === 'Execute & Expand / Won'){
            isValidated = false;
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg", metaMessages['Stage_Validation'].Message__c);
        }else if($A.util.isEmpty(eventFields['Industry__c']) || $A.util.isEmpty(eventFields['Industry__c'])){
            isValidated = false;    
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg",  metaMessages['Industry_Check'].Message__c ); 
        }
        //SF-2509
        /*else if((numberOfMCNs > 1 && ($A.util.isUndefinedOrNull(component.get("v.mcnId")) || $A.util.isEmpty(component.get("v.mcnId")) || $A.util.isUndefinedOrNull(component.get("v.motorolaCustomerNumber")) || $A.util.isEmpty(component.get("v.motorolaCustomerNumber")))) && isProspect !=true){
            isValidated = false;
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg", metaMessages['Multiple_MCN_Validation'].Message__c); 
        }else if(($A.util.isUndefinedOrNull(component.get("v.mcnId")) || $A.util.isEmpty(component.get("v.mcnId")) || $A.util.isUndefinedOrNull(component.get("v.motorolaCustomerNumber")) || $A.util.isEmpty(component.get("v.motorolaCustomerNumber"))) && isProspect !=true){
            isValidated = false;
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg", metaMessages['Single_MCN_Validation'].Message__c); 
        }*/
        else if(currentUserProfile == NASWprofile && ($A.util.isEmpty(eventFields['Sales_Process__c']))){
            isValidated = false;
            component.set("v.loadSpinner", false);
            component.set("v.errorMsg", metaMessages['Sales_Process_is_Mandatory_for_SE_Users'].Message__c); 
        }
        
        if(isValidated){
            var requiredField = component.find('reqField');
            var numberOfRequiredFields = requiredField.length;
            for (var i = 0; i < numberOfRequiredFields; i++) {
                var valueOfRequiredField = requiredField[i].get("v.value");
                if($A.util.isUndefinedOrNull(valueOfRequiredField) || $A.util.isEmpty(valueOfRequiredField)){
                    isValidated = false;
                    component.set("v.loadSpinner", false);
                    component.set("v.errorMsg", 'Please fill all the required fields'); 
                }
            }
        }
        if(!isClone && isValidated){
            component.find("oppEditForm").submit(eventFields);
        }else if(isClone && isValidated){
            helper.cloneOpportunity(component, event, helper, eventFields);
        } 
    },
    
    handleError :function(component, event, helper) {
        console.log("--In handleError--");
        var errors = event.getParams();
        var errorMsg = JSON.stringify(errors);
        document.getElementById("stdError").style.display = "block";
        component.set("v.loadSpinner", false);
    },
    changeMCN :function(component, event, helper) {
        console.log("--In changeMCN--");
        component.set("v.changeMCN",true);
        document.getElementById("newOppForm").style.display = "none";
    },
    getMCNDetails : function(component, event, helper) {
        console.log("--In getMCNDetails--");
        component.set("v.loadSpinner", false);
        var motorolacustomernumber = event.getParam("motorolaCustomerNumber");
        var mcnId = event.getParam("mcnId");
        component.set("v.motorolaCustomerNumber",motorolacustomernumber);
        component.set("v.mcnId",mcnId);
        component.set("v.linkText","[Change MCN]");
        document.getElementById("newOppForm").style.display = "block";
        component.set("v.changeMCN",false);
    },
    cancel : function(component, event, helper) {
        console.log("--In cancel--");
        var isClone = component.get("v.clone");
        var recId=component.get("v.customerAccId"); 
        if(isClone){
            recId = component.get("v.originalOpportunityId");
        }
        /* using window.open as cancel button would only available in classic */
        if($A.util.isUndefinedOrNull(recId) || $A.util.isEmpty(recId)){
            window.open("/006/o", "_self");
        }else{
            window.open("/"+recId, "_self");
        }
    },
    changeAccount :  function(component, event, helper) {
        //alert('accId'+accId);
        console.log("--In changeAccount--");
        var accId=component.get("v.customerAccId");  
        //alert('accId'+accId);
        if(!$A.util.isUndefinedOrNull(accId)  && !$A.util.isEmpty(accId)){ 
            component.set("v.customerAccId",accId.toString());            
            helper.getAccounts(component, event ,helper);            
            helper.prePopulateOppDetails(component,event,helper);
        }
    },
    getUpdatedLookupValues : function(component, event, helper) {
        console.log("--In getUpdatedLookupValues--");
        var updatedFieldValue = event.getParam("lookupFieldValues");
        var accRecId = component.get("v.AccRecordId");
        if (!$A.util.isUndefinedOrNull(updatedFieldValue) && !$A.util.isEmpty(updatedFieldValue)){
            var customerAccId =  updatedFieldValue.split(";");
            component.set("v.customerAccId",customerAccId[1]);            
            console.log('After accRecId==>'+accRecId);
            helper.getAccounts(component, event ,accRecId);
            //alert('is it executing');
            //alert('customerAccId'+customerAccId);
            var recId = component.get('v.recordId');
            if (!$A.util.isUndefinedOrNull(recId) && !$A.util.isEmpty(recId) && recId.startsWith('001')){
                helper.getAccRegionTerritory(component, event,helper);//SF-2699
                helper.prePopulateOppDetails(component,event,helper);
            }
            
        } 
    },
    showRequiredFields: function(component, event, helper){
        console.log("--In showRequiredFields--");
        $A.util.removeClass(component.find("reqField"), "none");
    },
})