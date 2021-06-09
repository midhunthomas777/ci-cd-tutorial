({
    fetchOpportunityAccess:function(component){
        console.log("-- In fetchOpportunityAccess helper --");
        var action = component.get('c.fetchOpportunityAccess');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                if(resp === "" || resp == ""){
                    component.set("v.showOppForm",true);                    
                }else{
                    component.set("v.showOppForm",false);
                    component.set("v.errorMsg",resp);
                }
            }else {
                console.log('Error retrieving Metadata');
            }
        });
        $A.enqueueAction(action);
    },
    getUserThemeJS: function(component, helper) {
        console.log("-- In getUserThemeJS helper --");
        var action = component.get('c.getUserTheme');
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner", false);
            var state = response.getState();
            if (state === 'SUCCESS' && component.isValid()) {
                var userTheme = response.getReturnValue();
                component.set("v.userTheme", userTheme);
            }
        });
        $A.enqueueAction(action);
    },
    getAccounts: function(component, event, accRecId) {
        var accountId = component.get("v.customerAccId");
        console.log('getAccounts accountId==>'+accountId);
        var originalOppId = component.get("v.originalOpportunityId");
        var isClone = component.get("v.clone");
        var action = component.get('c.getMCN');
        if(isClone){
            action.setParams({
                "recId": originalOppId
            });
        }else{
            action.setParams({
                "recId": accountId
            });    
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS' && component.isValid()) {
                var resp = response.getReturnValue();
                console.log('MCN Response..'+JSON.stringify(resp));
                var isProspect;
                if(!isClone){
                    if(!($A.util.isUndefinedOrNull(resp) || $A.util.isEmpty(resp))){
                        //Is_Partner_as_End_User will be true for customers that don't have MCN
                        var accountRec = resp[0];
                        console.log('Partner End user valuee..'+accountRec.Is_Partner_as_End_User__c);
                        if(resp[0].Is_Partner_as_End_User__c == true) {
                            isProspect = true;
                            component.set("v.isProspect", true);
                        }else {
                            ////SF-2509 - Modified below lines
                            //if(!($A.util.isUndefinedOrNull(resp[0].Parent.RecordType.DeveloperName) || $A.util.isEmpty(resp[0].Parent.RecordType.DeveloperName))) {
                            //if(resp[0].Parent.RecordType.DeveloperName == 'Prospect'){
                            if(!($A.util.isUndefinedOrNull(resp[0].RecordType.DeveloperName) || $A.util.isEmpty(resp[0].RecordType.DeveloperName))) {
                                if(resp[0].RecordType.DeveloperName == 'Prospect'){
                                    isProspect = true;
                                    component.set("v.isProspect", true);
                                }else{
                                    component.set("v.isProspect", false);                                    
                                }
                            }
                        }
                       
                    }else{
                        component.set("v.isProspect", false);
                    }
                }else{
                    //component.set("v.selectMCNLink", true); //SF-2509
                    if(!($A.util.isUndefinedOrNull(resp) || $A.util.isEmpty(resp))){
                        //if(resp[0].Account.RecordType.DeveloperName =='Prospect' || resp[0].Account.Is_Partner_as_End_User__c == true){
                        if(resp[0].RecordType.DeveloperName =='Prospect' || resp[0].Is_Partner_as_End_User__c == true){
                            component.set("v.isProspect", true);
                        }else{
                            component.set("v.isProspect", false);
                        }
                    }else{
                        component.set("v.isProspect", false);
                    }
                }
            }
        });
        $A.enqueueAction(action);  
    },
    prePopulateOppDetails: function(component, event, helper) {
        component.set("v.showOppForm", false);
        //console.log("-- In prePopulateOppDetails helper --");
        component.set("v.renderPrePopulatedField", false);
        var accountId = component.get("v.customerAccId");
        var originalOppId = component.get("v.originalOpportunityId");
        var isClone = component.get("v.clone");
        //console.log('originalOppId '+originalOppId);
        //console.log('isClone '+isClone);
        var action = component.get('c.fetchCustomerAccount');  
        if(isClone){
            action.setParams({
                "originalRecId": originalOppId,
                "functionality": "NewOpportunity",
                "isClone": isClone
            });
        }else{
            action.setParams({
                "originalRecId": accountId,
                "functionality": "NewOpportunity",
                "isClone": isClone
            });
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state '+state);
            if (state === 'SUCCESS' && component.isValid()) {
                var resp = response.getReturnValue();
                var accountData = [];
                //SF-2508
                ////SF-2699-Start                
                var currentUserRegion = component.get("v.currentUser.UserTheater__c");
                var currentUserTerritory = component.get("v.currentUser.Default_Territory__c");
                //console.log('currentUserRegion***'+currentUserRegion +'currentUserTerritory**'+currentUserTerritory);
                let oppTerrMap = new Map();
                oppTerrMap = component.get('v.oppTerrMap'); 
                var accRegion = component.get("v.accRegion");
                var accTerr =component.get("v.accTerritory");
                //console.log('accRegion====>'+accRegion);
                //console.log('accTerr====>'+accTerr);
                //SF-2699-End
                for (var key in resp) {
                    //SF-2699-Start
                    if(key === 'Territory__c' && !isClone && ($A.util.isUndefinedOrNull(currentUserTerritory) || $A.util.isEmpty(currentUserTerritory))){
                        console.log('accRegion : '+ accRegion+  ' ;accTerr : '+ accTerr+ ' ;currentUserRegion: ',currentUserRegion);
                        if(!$A.util.isUndefinedOrNull(oppTerrMap) && !$A.util.isEmpty(oppTerrMap)){
                            //console.log('User and Account Region not matching');                             
                            var validoppTerr  = JSON.stringify(oppTerrMap[currentUserRegion]); 
                            console.log('If accTerr==>'+accTerr);
                            if((!$A.util.isUndefinedOrNull(validoppTerr) && !$A.util.isEmpty(validoppTerr)) && validoppTerr.includes(accTerr)){    
                                console.log('Account Territory is Valid');
                                console.log('Region Key'+key);
                                console.log('Acc accTerr'+accTerr);
                                accountData.push({
                                    value: accTerr,
                                    key : key
                                });
                            }else{
                                console.log('Not found any going with blank Terr');
                                accountData.push({
                                    value: null,
                                    key : key
                                });
                            }
                        }
                    }
                    else if(key === 'Territory__c' && !isClone && !$A.util.isUndefinedOrNull(currentUserTerritory) && !$A.util.isEmpty(currentUserTerritory) ){
                        //console.log('UserTerritorynotnull==>'+currentUserTerritory);
                        accountData.push({
                            value: currentUserTerritory,
                            key : key
                        });
                    }
                        else if(key === 'Region__c' && !isClone && !$A.util.isUndefinedOrNull(currentUserRegion) && !$A.util.isEmpty(currentUserRegion) ){
                           //console.log('Region__c found==>'+currentUserTerritory);
                            accountData.push({
                                value: currentUserRegion,
                                key : key
                            });
                        }else{
                            //console.log('Remaining fields found==>'+currentUserTerritory);
                            accountData.push({
                                value: resp[key],
                                key : key
                            });  
                        }
                }
                component.set("v.accountData", accountData);
                //console.log('rerender before'+component.get("v.renderPrePopulatedField"));
                component.set("v.renderPrePopulatedField", true);
                //console.log('rerender After'+component.get("v.renderPrePopulatedField"));
                component.set("v.showOppForm", true);
            }
        });
        $A.enqueueAction(action);
    },
    getFieldsetsJS: function(component, helper) {
        //console.log("-- In getFieldsetsJS helper --");
        var action = component.get('c.getFieldSets');
        action.setParams({
            "objectName": "Opportunity"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var resp = response.getReturnValue();
                Object.keys(resp).forEach(function(key) {
                    if (key === 'NewCloneOpportunityLeftUI') {
                        component.set('v.newCloneOpportunityLeftUI', resp[key]);
                    } else if (key === 'NewCloneOpportunityRightUI') {
                        component.set('v.newCloneOpportunityRightUI', resp[key]);
                    }
                });
            }
        });
        $A.enqueueAction(action);
    },      
    cloneOpportunity: function(component, event, helper, eventFields) {
        //console.log("--In cloneOpportunity helper --");
        var recId = component.get('v.originalOpportunityId');
        var selectedChild = component.get('v.selectedRelationships');
        var metaMessages = component.get("v.metaMessages");
        console.log(selectedChild);
        var action = component.get('c.cloneRecords');
        action.setParams({
            "originalRecId": recId,
            "functionality": "Opportunity_Clone",
            "userSelectedChildAPIs": selectedChild,
            "newRec": eventFields
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.loadSpinner", false);
            if (state === 'SUCCESS' && component.isValid()) {
                var resp = response.getReturnValue();
                if (resp.startsWith('Error')) {
                    var errorMSg = resp.split('Error')[1];
                    if (errorMSg.includes("INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, To add this user to the team")){
                        component.set("v.errorMsg", metaMessages['MNA_No_Opportunity_Team_Access'].Message__c);
                    } else if(errorMSg.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION, Primary Partner is mandatory when the selected Account has 'Is Partner as End User' checked.")) {
                        component.set("v.errorMsg", errorMSg.split(',')[1]);
                    }else{
                        component.set("v.errorMsg", errorMSg);
                    }
                } else {
                    //console.log('Opportunity Id' + resp);
                    component.set("v.newOpportunityId", resp);
                    helper.redirectToSobject(component, event, resp);
                }
            }
        });
        $A.enqueueAction(action);
    },
    redirectToSobject: function(component,event,OppId) {
        console.log("-- In redirectToSobject helper --");
        var userTheme = component.get("v.userTheme");
        var executionOrigin = component.get("v.executionOrigin");
        if (userTheme === 'Theme3') {
            var addProductUrl= 'p/opp/SelectSearch?addTo='+OppId+'&retURL=%2F'+OppId;
            window.open("/"+addProductUrl,"_self");
        } else if (userTheme === 'Theme4d' || userTheme === 'Theme4t' || userTheme === 'Theme4u'){
            if(executionOrigin == 'VF'){
                sforce.one.navigateToURL('/lightning/r/'+OppId+'/related/OpportunityLineItems/view',true);
            } else{
                var relatedListEvent = $A.get("e.force:navigateToRelatedList");
                relatedListEvent.setParams({
                    "relatedListId"  : "OpportunityLineItems",
                    "parentRecordId" : OppId
                });
                relatedListEvent.fire();
            }
        }  
    },
    fetchMetaMessages: function(component, helper) {
        //console.log("-- In fetchMetaMessages helper --");
        var accountId = component.get("v.customerAccId");
        var action = component.get('c.getMetaMessages');
        action.setParams({
            "metaName": 'New_Opportunity'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS' && component.isValid()) {
                var resp = response.getReturnValue();
                component.set("v.metaMessages", resp);
            }
        });
        $A.enqueueAction(action);
    },
    //SF-2699
    getOppRegionTerritoryMapping:function(component,event,helper){
        //console.log("-- In fetchOpportunityAccess helper --");
        component.set("v.loadSpinner", true);
        var action = component.get('c.getOpportunityRegionTerritory');
        action.setParams({
            "objName": "Opportunity",
            "controllingField" :  "Region__c",
            "dependentField" :  "Territory__c",
            "isStd":  true
        });
        action.setCallback(this, function(response){
            component.set("v.loadSpinner", false);
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();  
                var mappingOppRegTerr = [];
                mappingOppRegTerr = resp;
                //console.log('mappingOppRegTerr'+JSON.stringify(mappingOppRegTerr));
                component.set('v.oppTerrMap',mappingOppRegTerr);                
            }else {
                console.log('Error retrieving Data');
            }
        });
        $A.enqueueAction(action);
    },
    //SF-2699
    getAccRegionTerritory:function(component,event,helper){        
        component.set("v.loadSpinner", true);
        var recID = component.get("v.recordId");
        //alert(recID);
        //console.log('getAccRegionTerritory recID==>'+recID);        
        var action = component.get('c.getAccRegionTerritory');
        action.setParams({"recId": recID});
        action.setCallback(this, function(response){            
            var state = response.getState();
            //console.log('state===>' + state);
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue(); 
                component.set("v.accRegion", resp[0].Region__c);
                component.set("v.accTerritory", resp[0].Territory__c);
                console.log('AccRegion1==>'+component.get("v.accRegion"));
                console.log('AccTerritory1==>'+component.get("v.accTerritory"));
            }else {
                console.log('Error retrieving Data');
            }
        });
        $A.enqueueAction(action);
    },
})