({
    getCaseRecordType : function(component) {
        // create a empty array for store map keys 
        var arrayOfMapKeys = [];
        var action = component.get("c.getPickListValuesIntoList");
        action.setCallback(this, function(response) {
            var StoreResponse = response.getReturnValue();
            for (var singlekey in StoreResponse) {
                arrayOfMapKeys.push({key:singlekey , value: StoreResponse[singlekey]});
            }
            component.set('v.picklistValues', arrayOfMapKeys);
        })
        $A.enqueueAction(action);
    },getChatTranscriptDetails : function(component) {
        var chatRecordId = component.get("v.recordId");
        var action = component.get("c.getChatTranscriptRecord");
        action.setParams({"chatRecordId":chatRecordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var CaseId = JSON.parse(JSON.stringify(response.getReturnValue())).CaseId;
                var AccountId = JSON.parse(JSON.stringify(response.getReturnValue())).AccountId;
                component.set("v.AccountId",AccountId); 
                if(AccountId != undefined){
                    var RecordTypeName = JSON.parse(JSON.stringify(response.getReturnValue())).Account.RecordType.Name;
                    if(RecordTypeName === 'Customer'){                          
                        this.getAccountRecordType(component);
                    }else{
                        component.set("v.customerNumberFlag","false");
                    }
                }
                //CITIC-478  Added Account and  Contact for autopopulating
                if(CaseId === undefined){ 
                    component.set("v.caseExistFlag",false);
                    if(AccountId != undefined){
                        component.find("accountAuraId").set("v.value",AccountId); 
                    }
                    if(JSON.parse(JSON.stringify(response.getReturnValue())).Contact != undefined){                       
                        var ContactName = JSON.parse(JSON.stringify(response.getReturnValue())).Contact.Name; 
                        component.set("v.searchString",ContactName);                        
                        this.searchRecordsHelper(component);
                    }
                    // CITIC-503 - to auto-populate the subject
                    var ChatName = JSON.parse(JSON.stringify(response.getReturnValue())).Name;
                    var timezone = $A.get("$Locale.timezone");
                    var timeStamp = new Date().toLocaleString("en-US", {timeZone: timezone});
                    var subject = "Case Inbound Chat- "+ChatName+"- "+timeStamp;                    
                    component.set("v.Subject",subject); 

                }else{  
                   // $A.get("e.force:closeQuickAction").fire();
                  //  $A.get('e.force:refreshView').fire();                    
                    component.set("v.caseExistFlag",true);
                    var CaseNumber = JSON.parse(JSON.stringify(response.getReturnValue())).Case.CaseNumber;
                	component.set("v.CaseId",CaseNumber);
                }
                 component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    getTaskDetails : function(component) {
        var taskRecordId = component.get("v.recordId");
        var taskFieldAPI = component.get("v.fieldName");
        var action = component.get("c.getTaskRecord");
        action.setParams({"taskRecordId":taskRecordId,"fieldAPIName":taskFieldAPI});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state*****'+state);
            if (state === "SUCCESS") {
                var taskResult = response.getReturnValue();
                if(taskResult.Status == 'Completed'){                    
                    var relatedRecord = JSON.parse(JSON.stringify(taskResult)).WhatId;
                    if(relatedRecord === undefined){
                        // CITIC-503 - to auto-populate the subject
                       
                        var timezone = $A.get("$Locale.timezone");
                        var timeStamp = new Date().toLocaleString("en-US", {timeZone: timezone});
                        var subject = "Case Inbound Task- "+timeStamp;                    
                        component.set("v.Subject",subject);
                     	component.set("v.showSpinner", false);
                        component.set('v.caseExistFlag',false);   
                    }else if(relatedRecord.startsWith('500')){                       
                        component.set('v.CaseId',relatedRecord);
                        component.set("v.showSpinner", false);
                        component.set('v.caseExistFlag',true); 
                    }
                    component.set('v.taskRecord',taskResult);
                    if(!$A.util.isEmpty(taskResult.WhoId)){
                        var selectedContact = [];
                        selectedContact.push({"label":taskResult.Who.Name,"value":taskResult.WhoId});
                        component.set('v.selectedRecord', selectedContact[0]);
                        $A.util.addClass(component.find('resultDropDown'),'slds-hide');
                    }
                }
                else{
                    this.toasterMessage('','Please change the status to completed on task before creating case','warning','sticky');
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    } ,
    updateTask : function(component, event, helper) {
        var taskRecordId = component.get("v.recordId");
        var action = component.get("c.updateTaskRecord");
        var insertedCaseDetail = event.getParams().response;
        var caseId = insertedCaseDetail.id;
        action.setParams({"taskRecordId":taskRecordId,"caseRecordId":caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 $A.get("e.force:closeQuickAction").fire();
                 $A.get('e.force:refreshView').fire();
                 component.set("v.showSpinner", false);
            }
            else if(state === "ERROR"){
              let errors = response.getError();
              this.errorHandling(errors);
                component.set("v.showSpinner", false);
            }
            
        });
        $A.enqueueAction(action);
    },
    // show the spinner when "Create - Close Case" button is clicked..
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    searchRecordsHelper : function(component, event, helper, value){
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        var casRecordTypeId = component.get("v.recordType");
        var accountId = component.find("accountAuraId").get("v.value");
             
        component.set('v.message', '');
        component.set('v.recordsList', []);
        var action = component.get('c.fetchRecords');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'searchString' : searchString,
            'caseRecordTypeId' : casRecordTypeId,
            'accountId' : String(accountId)
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            if(response.getState() === 'SUCCESS') {
            
                if(result.length > 0) {
                    // To check if value attribute is prepopulated or not
                    if( $A.util.isEmpty(value) && result.length > 1) {
                        component.set('v.recordsList',result);        
                    } else {
                        component.set('v.selectedRecord', result[0]);
                    }
                } else {
                    component.set('v.message', "No Records Found for '" + searchString + "'");
                }
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            $A.util.addClass(component.find("Spinner"), "slds-hide");
            
        })
        $A.enqueueAction(action);        
    },
    updateChatTranscript : function(component, event, helper) {
       
        var chatTrancriptId = component.get("v.recordId");
        var action = component.get("c.updateTranscriptRecord");
        var insertedCaseDetail = event.getParams().response;
        var caseId = insertedCaseDetail.id;
        action.setParams({"transcriptRecordId":chatTrancriptId,"caseRecordId":caseId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }
            else if(state === "ERROR"){
                console.log('update LiveChatTranscript failed');
                console.log(response.getError());
              let errors = response.getError();
              this.errorHandling(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    errorHandling : function(errors) {
        var str = '';
        if(Array.isArray(errors)){
            for(let i=0;i<errors.length;i++){
                if(!$A.util.isEmpty(errors[i].message)){
                    str = errors[i].message +','+str;
                }
            }
        }
        else{
            str = errors;
        }
      
        var er;
        var uiErrorMsg = '';
        if(str.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            er = str.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
            uiErrorMsg = er[1].replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "'");
        }
        else{
            uiErrorMsg = str;
        }
        this.toasterMessage('Case Creation Failed :',uiErrorMsg,'error','sticky');
    },
     toasterMessage :  function(title,message,type,mode) {
        var resultsToast = $A.get("e.force:showToast"); 
        resultsToast.setParams({ 
            "title": title, 
            "message": message,
            "type": type,
            "mode" : mode
        }); 
        resultsToast.fire(); 
    },
    getAccountRecordType: function(component){
        console.log('getAccountRecordType');
        var accountId = component.get("v.AccountId");  
        console.log('--'+accountId);
        var actions = component.get('c.getAccountChildRecords');
        actions.setParams({"AccountId":String(accountId)});
        actions.setCallback(this, function(response) {   
            var state = response.getState();
            if (state === "SUCCESS") {             
               var result = response.getReturnValue();              
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({key: key, value: result[key]});
                }     
                console.log(fieldMap.length);
                component.set("v.AccountChildMap", fieldMap);               
                if(fieldMap.length != 0){
                    component.set("v.customerNumberFlag","true");
                }else{
                    component.set("v.customerNumberFlag","false");
                } 
            }
        });
        $A.enqueueAction(actions);
        ;
       
    
    }
})