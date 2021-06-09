({
    handleLoad : function(component, event, helper) {
        component.set("v.showSpinner", false);
    },
    doInit: function(component, event, helper) {        
        $A.util.addClass(component.find('resultDropDown'),'slds-hide');
        helper.getCaseRecordType(component);
        var hasRecordId = component.get("v.recordId");
        if(!$A.util.isEmpty(hasRecordId) && hasRecordId.startsWith('00T')){
            helper.getTaskDetails(component); 
        }else if(!$A.util.isEmpty(hasRecordId) && hasRecordId.startsWith('570')){     
            helper.getChatTranscriptDetails(component); 
        }
        component.set("v.showSpinner", false);
    },
    handleSubmit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        console.log('submit console ===>');
        event.preventDefault();
        component.set("v.showSpinner", true);
        var taskRecord = component.get("v.taskRecord");
        var contactId = component.get("v.selectedRecord");
        contactId = JSON.parse(JSON.stringify(contactId)).value; 
        
        var contactName = component.find("inputLookup").get("v.value");
        var fields = event.getParam("fields");
        fields["RecordTypeId"] = component.get("v.recordType"); 
        fields["Origin"] = 'Phone';
        fields["ContactId"] = contactId;
        fields["Customer_Account__c"] = component.get("v.CustomerNumber");
        var hasRecordId = component.get("v.recordId");
        if(!$A.util.isEmpty(hasRecordId) && hasRecordId.startsWith('570')){
            fields["Origin"] = 'Chat';
        }
        if(contactName != '' && contactId === ''){
            helper.errorHandling("Please select contact.");
            component.set("v.showSpinner", false);
        }else if(contactId != '' && contactId != undefined)
        { 
            // Validating whether  contact is mapped to the current account               
            var action = component.get("c.validateContact");                
            action.setParams({"ContactId":String(contactId)});
            action.setCallback(this, function(response) {
                var state = response.getState();                   
                if (state === "SUCCESS") {
                    var accountId = component.get("v.AccountId");
                    // if the contact is mapped to the account then submit the form                    
                    if(accountId != response.getReturnValue()){                     
                        helper.errorHandling("Please check the contact as it is not mapped to the current account.");
                        component.set("v.showSpinner", false);
                    }else{
                        var caseRecDetails = component.find('createCaseForm').submit(fields);
                    }
                }
                else if(state === "ERROR"){                      
                    let errors = response.getError();
                    this.errorHandling(errors);
                }
            });
            $A.enqueueAction(action);
            
        }else{         
            var caseRecDetails = component.find('createCaseForm').submit(fields);
        }
                       
        
    },
    handleError:function(component,event,helper){
        var error = event.getParams();
        var errorMessage1 = event.getParam("message");
        //LUCXB-784 used event.getParam('detail') instead of event.getParam('message')
        var errorMessage = event.getParam('detail');        
        helper.errorHandling(errorMessage);
        component.set("v.showSpinner", false);        
    },
    handleSuccess : function(component,event,helper){
        helper.toasterMessage('Case','A related close case record has been created.','success','dismissible');
        var hasRecordId = component.get("v.recordId");
        if(!$A.util.isEmpty(hasRecordId) && hasRecordId.startsWith('00T')){
            helper.updateTask(component,event,helper);
            component.set("v.showSpinner", false);
        }
        else if(!$A.util.isEmpty(hasRecordId)){
            console.log('!=== 2: '+hasRecordId);
           
            helper.updateChatTranscript(component,event,helper);
            component.set("v.showSpinner", false);
        }
    },
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
    showRecords : function( component, event, helper ) {
        if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    // When a keyword is entered in search box
    searchRecords : function( component, event, helper ) {
        var searchString = component.get('v.searchString');
        searchString = searchString.trim().replace(/\*/g, '').toLowerCase();        
        // Ignore search terms that are too small
        if (searchString.length < 2) {
            component.set('v.recordsList', []);
            return;
        }
        if(!$A.util.isEmpty(searchString) && searchString.length >= 2) {
            $A.util.addClass(component.find('resultDropDown'),'slds-is-open');
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            $A.util.removeClass(component.find('resultDropDown'),'slds-hide');
            helper.searchRecordsHelper( component, event, helper);
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    // To remove the selected item.
    removeItem : function( component, event, helper ){
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        $A.util.removeClass(component.find('resultDropDown'),'slds-hide');
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },
    // When an item is selected
    selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    handleRecordUpdated :function(cmp, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            console.log("Record is loaded successfully.");
            console.log(cmp.get("v.transcriptRecord"));
            console.log(cmp.get("v.recordError"));            
        }        
    }, 
    setDepotRefresh:function(component, event, helper){ 
        var varRepair = component.find("CaseType").get("v.value");
        if(varRepair == 'Repair'){
            component.set("v.depotFlag","true");
        }else{
            component.set("v.depotFlag","false");
        }
    },
    setCustomerNumberRefresh:function(component, event, helper){ 
        var accountId = component.get("v.AccountId");
        if(accountId != ''){
            helper.getAccountRecordType(component);
        }
    }
})