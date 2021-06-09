({
    searchCustPrefHelper : function(component, event, helper) {
        var customerNum = '';
        var siteNum = '';
        var buttonValue = event.getSource().get("v.value");
        component.set("v.loadSpinner", true);
        
        if(buttonValue == 'emailOPTTab'){
            component.set('v.resultList', null);
        	customerNum = component.find("customerNum").get("v.value");
        }else if(buttonValue == 'addDeleteTab'){
            component.set('v.addContactresult', null);
            customerNum = component.find("customerNumTab3").get("v.value");
            siteNum = component.find("siteNum").get("v.value");
        }else if(buttonValue == 'ccEmailTab'){
            customerNum = component.find("customerNumTab4").get("v.value");
        }
        var action = component.get("c.handleCustomerPref");
        action.setParams({
            "customerNum" : customerNum,
            "siteNum" 	  : siteNum,
            "metaName" 	  : 'EInvoice_Customer'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out'];
            if(state === 'SUCCESS' && !errorCodes.includes(response)){
                component.set("v.data", []);
                var newItems = JSON.parse(response);
                console.log(newItems);
                
                if(buttonValue == 'emailOPTTab'){
                    for(var i=0;i<newItems.length;i++){
                        newItems[i].rowId = 'row-'+i;
                    }
                    component.set('v.resultList', newItems);
                	component.set('v.resultListLength', newItems.length);
                    this.createRetainDelData(component,event,helper);
                    component.set('v.customerName', newItems[0].CUSTOMER_NAME + ' | Current Invoice Preference : ' + newItems[0].CUST_INVOICE_PREFERENCE);
                
                }else if(buttonValue == 'addDeleteTab'){
                    component.set('v.addContactresult', newItems);
                	component.set('v.addContactresultLength', newItems.length);
                    component.set('v.addContactCustName', newItems[0].CUSTOMER_NAME + ' | Current Invoice Preference : ' + newItems[0].CUST_INVOICE_PREFERENCE);
                
                }else if(buttonValue == 'ccEmailTab'){
                    var custPreference = newItems[0].CUST_INVOICE_PREFERENCE;
                    this.validatePreferenceNumber(component, event, custPreference);
                }
                
                if(buttonValue != 'ccEmailTab'){
                	this.getSitesANDEmails(component, event, buttonValue);
                    this.resetDecisonSection(component, event, helper);
                }
                                
                component.set("v.loadSpinner", false);
            }else{
                this.displayResponse(component,event,response);
            } 
        });
        $A.enqueueAction(action);
    },
    displayResponse : function(component,event,response) {
      	var selectedTab = component.get("v.selTabId");
        var message = '';
        if(response == 'NOACCESS') {
            message = 'Insufficient Privileges to this Customer Number, please try another one.';
        
        }else if(response == 'APIError'){
        	message = 'Request has not been submitted successfully, please retry after some time.';
        
        }else{
            console.log(response);
            message = response;
        }
        
        this.showToast(component, message,'error');
        component.set("v.loadSpinner", false);
    },
    sendcustomerDetails : function(component, event, requestType) {
        var customerNum = component.find("customerNum").get("v.value");
        var customerDetailsComp = component.find('customerComp');
        customerDetailsComp.getcustomerDetails(customerNum,requestType);
    },
    validateNewContacts : function(component,event,RowItem){
        var error = false;
        if(RowItem['P_EMAIL'] == ''){
            error = true;
        }else if(RowItem['P_CONTACT_FIRST_NAME'] == ''){
            error = true;
        }     
        else if(RowItem['P_CONTACT_LAST_NAME'] == ''){
            error = true;
        }
        
        return error;
    },
    createRetainDelData : function(component,event,helper){
      	var resultList = component.get("v.resultList");
        component.set("v.retainList", []);
        component.set("v.retainListDuplicate", []);
     	var RowItemList = component.get("v.retainList");
        
        for(var i=0;i<resultList.length;i++){
            var contactname = resultList[i].BILL_TO_SITE_CONTACT_NAME;
            var firstName = contactname.substring(0,contactname.indexOf(' '));
            var lastName = contactname.substring(contactname.indexOf(' ')+1);
            RowItemList.push({
                'P_ACTION_TYPE'			   : 'New',
                'P_CUSTOMER_SITE' 	       : resultList[i].BILL_TO_SITE_NUMBER,
                'P_CONTACT_FIRST_NAME'	   : firstName,
                'P_CONTACT_LAST_NAME'	   : lastName,
                'P_EMAIL'				   : resultList[i].CONTACT_EMAIL_ADDRESS,
                'P_CONTACT_ROLE'		   : resultList[i].CONTACT_ROLE,
                'P_CONTACT_REFERENCE'	   : resultList[i].CONTACT_REFERENCE,
                'BILL_TO_SITE_CONTACT_NAME': resultList[i].BILL_TO_SITE_CONTACT_NAME,
                'rowId' 				   : resultList[i].rowId
            });
        }
        component.set("v.retainList", RowItemList);
        component.set('v.retainListDuplicate', RowItemList);
        component.set("v.retainListLength", RowItemList.length);
    },
    validateSearch : function(component,event,helper) {
        var btnVal = event.getSource().get("v.value");
        if(btnVal == 'emailOPTTab'){
            var customerNumber = component.find("customerNum");
            customerNumber.showHelpMessageIfInvalid();
            if(customerNumber.checkValidity() == true){
                this.searchCustPrefHelper(component, event, helper);
            }
        }
        else if(btnVal == 'addDeleteTab'){
            var customerNumber = component.find("customerNumTab3");
            customerNumber.showHelpMessageIfInvalid();
            if(customerNumber.checkValidity() == true){
                this.searchCustPrefHelper(component, event, helper);
            }
        }
        else if(btnVal == 'ccEmailTab'){
            var customerNumber = component.find("customerNumTab4");
            customerNumber.showHelpMessageIfInvalid();
            if(customerNumber.checkValidity() == true){
                this.searchCustPrefHelper(component, event, helper);
            }
        }
    },
    validatePreferenceNumber : function(component,event,custPreference) {
        if(custPreference.includes('EMAIL')){
            this.ccEmailReset(component, event);
        	component.set('v.ccErrorMsg',false);
        }else{
            var message = 'This customer is not setup for email so we can not display email.';
            this.showToast(component,message,'error');
            component.set('v.ccErrorMsg',true);
        }
    },
    isPartnerUser : function(component,event,helper) {
        var action = component.get("c.isLoggedinPartnerUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS' && response.getReturnValue()){
                component.set('v.isPartner',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    currentLoggedInUser : function(component,event,helper) {
        var action = component.get("c.fetchLoggedinUserDetails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS' && response.getReturnValue() != 'InvoiceUser'){
                var result = JSON.parse(response.getReturnValue());
                component.set("v.userEmail", result.Email);
                component.set("v.userCoreId", result.FederationIdentifier);
                
            } else {
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    genericSectionData : function(component,event){
        var fistName = component.find("confirstname").get("v.value");
        var lastName = component.find("conlastname").get("v.value");
        component.set("v.genericSectionData", []);
        var email = component.get("v.GenericAPEmail");
    	var RowItemList = component.get("v.genericSectionData");
        var allRows = component.get("v.uniqueSiteList");
        var roles = component.get("v.roles");
        for(var i=0;i<allRows.length;i++){
            RowItemList.push({
                'P_ACTION_TYPE'			   : 'New',
                'P_CUSTOMER_SITE' 	       : allRows[i].BILL_TO_SITE_NUMBER,
                'P_CONTACT_FIRST_NAME'	   : fistName,
                'P_CONTACT_LAST_NAME'	   : lastName,
                'P_EMAIL'				   : email,
                'P_CONTACT_ROLE'		   : roles[0],
                'P_CONTACT_REFERENCE'	   : '',
                'BILL_TO_SITE_CONTACT_NAME': fistName+' '+lastName,
            });
        }
        component.set("v.genericSectionData", RowItemList);
        component.set("v.genericAPLength", RowItemList.length);
    },
    getExistingBillToSites : function(component,event) { 
        component.set("v.genericAPBillToSite", []);
    	var RowItemList = component.get("v.genericAPBillToSite");
        var allRows = component.get("v.uniqueSiteList");
        var roles = component.get("v.roles");
        var data = component.get("v.resultList");  
        
        var siteAddressMap = component.get("v.siteAddressMap");
        for(var i=0;i<data.length;i++){
        	siteAddressMap[data[i].BILL_TO_SITE_NUMBER]=data[i].ADDRESS1+' '+data[i].CITY+','+data[i].STATE+','+data[i].COUNTRY;
        }
                
        for(var i=0;i<allRows.length;i++){
            //console.log('siteAddressMap = '+siteAddressMap[allRows[i].BILL_TO_SITE_NUMBER]);
            RowItemList.push({
                'P_ACTION_TYPE'			   : 'New',
                'P_CUSTOMER_SITE' 	       : allRows[i].BILL_TO_SITE_NUMBER,
                'P_CONTACT_FIRST_NAME'	   : '',
                'P_CONTACT_LAST_NAME'	   : '',
                'P_EMAIL'				   : '',
                'P_CONTACT_ROLE'		   : roles[0],
                'P_CONTACT_REFERENCE'	   : '',
                'email' 	 	  		   : '',
                'emailInput' 	  		   : '',
                'existing'	 	  		   : '',
                'contactName'	  		   : '',
                'firstName'	 	  	   	   : '',
            	'lastName'	 	  	   	   : '',
                'BILL_TO_SITE_CONTACT_NAME': '',
                'Address'				   : siteAddressMap[allRows[i].BILL_TO_SITE_NUMBER]
            });
        }
        component.set("v.genericAPBillToSite", RowItemList);
        component.set("v.genericAPLength", RowItemList.length);
    },
    createObjectData : function(component,event,helper,identifier,btnVal) {
        var sites;
        var emails;
        var RowItemList;
		var selectedTab = component.get("v.selTabId");
        if(selectedTab == 'tab1'){
            if(identifier){
                component.set("v.emailOptContacts", []);
            }else{
                var existingRows = component.get("v.emailOptContacts");
                for(var i=0; i<existingRows.length;i++){
                    var RowItem = existingRows[i];
                }
            }
            RowItemList = component.get("v.emailOptContacts");
            sites = component.get("v.uniqueSiteList");
            emails = component.get("v.existingEmails");
        }
        else if(selectedTab == 'tab2'){
            if(identifier){
                component.set("v.ContactList", []);
            }else{
                var existingRows = component.get("v.ContactList");
                for(var i=0; i<existingRows.length;i++){
                    var RowItem = existingRows[i];
                }
            }
            RowItemList = component.get("v.ContactList");
        	sites = component.get("v.sitesForContact");
        	emails = component.get("v.emailsForContact");
        }
       
        var roles = component.get("v.roles");
        RowItemList.push({
            'P_ACTION_TYPE'			  	: 'New',
            "P_CUSTOMER_SITE"		  	: sites[0].BILL_TO_SITE_NUMBER,
            "P_CONTACT_FIRST_NAME"	  	: '',
            "P_CONTACT_LAST_NAME"	  	: '',
            "P_EMAIL"				  	: '',
            "P_CONTACT_ROLE"		  	: roles[0],
            "P_CONTACT_REFERENCE"	  	: '',
            'email'		 	   			: '',
            'emailInput' 	   			: '',
            'BILL_TO_SITE_CONTACT_NAME' : ''
        });
        
        if(selectedTab == 'tab1'){
            component.set("v.emailOptContacts", RowItemList);
        }else if(selectedTab == 'tab2'){
            component.set("v.ContactList", RowItemList);
        }
    },
    removeObjectData : function(component,event,helper,tabvalue) {
        var index = event.getParam("indexVar");
        if(tabvalue == 'emailOPTTab'){
            var AllRowsList = component.get("v.emailOptContacts");
            AllRowsList.splice(index, 1);
            component.set("v.emailOptContacts", AllRowsList);
        }else if(tabvalue == 'addDeleteTab'){
            var AllRowsList = component.get("v.ContactList");
            AllRowsList.splice(index, 1);
            component.set("v.ContactList", AllRowsList);
        }
    },
    getRowItemValues : function(component,RowItem) {
        this.resetRowBeforeMerge(component,RowItem);
        for(var item in RowItem){
            if(item == "email" && RowItem[item] != "Other"){
                RowItem.P_EMAIL = RowItem.email;
            }
            if(item == "emailInput" && RowItem[item] != ''){
                RowItem.P_EMAIL = RowItem.emailInput;
            }
            if(item == "contactName" && RowItem[item] != "Other"){
                RowItem.BILL_TO_SITE_CONTACT_NAME = RowItem.contactName;
            }
            
            if(RowItem.contactName == "Other" && (RowItem.firstName != '' || RowItem.lastName != '')){
                RowItem.P_CONTACT_FIRST_NAME = RowItem.firstName;
                RowItem.P_CONTACT_LAST_NAME = RowItem.lastName;
            }
            
            if((item == "P_CONTACT_FIRST_NAME" || item == "P_CONTACT_LAST_NAME") && RowItem[item] != ''){
                if(RowItem.P_CONTACT_LAST_NAME == ''){
                    RowItem.BILL_TO_SITE_CONTACT_NAME = RowItem.P_CONTACT_FIRST_NAME;
                }else{
                    RowItem.BILL_TO_SITE_CONTACT_NAME = RowItem.P_CONTACT_FIRST_NAME+' '+RowItem.P_CONTACT_LAST_NAME;
                }
            }
            
            if((item == "firstName" || item == "lastName") && RowItem[item] != ''){
                if(RowItem.lastName == ''){
                    RowItem.BILL_TO_SITE_CONTACT_NAME = RowItem.firstName;
                }else{
                    RowItem.BILL_TO_SITE_CONTACT_NAME = RowItem.firstName+' '+RowItem.lastName;
                }
            }
            
            if(item == "firstName" && RowItem[item] == '' && RowItem.contactName != "Other"){
                var contact = RowItem.contactName;
                var firstName = contact.substring(0,contact.indexOf(' '));
                RowItem.P_CONTACT_FIRST_NAME = firstName;
            }
            
            if(item == "lastName" && RowItem[item] == '' && RowItem.contactName != "Other"){
                var contact = RowItem.contactName;
                var contName = contact.substring(contact.indexOf(' ')+1);
                if(RowItem.P_CONTACT_FIRST_NAME == ''){
                    RowItem.P_CONTACT_FIRST_NAME = contName;
                }else{
                    RowItem.P_CONTACT_LAST_NAME = contName;
                }                        
                
            }
        }
    },
    resetRowBeforeMerge : function(component,RowItem){
        RowItem.P_EMAIL = '';
        RowItem.BILL_TO_SITE_CONTACT_NAME ='';
    },
    createEInvoiceRecord : function(component,event,type){
        component.set("v.loadSpinner", true);
        var isPartner = component.get("v.isPartner");
        var customerNum;
        var selectedTab = component.get("v.selTabId");
        if(selectedTab == 'tab1'){
            customerNum = component.find("customerNum").get("v.value");
        }else if(selectedTab == 'tab2'){
            customerNum = component.find("customerNumTab3").get("v.value");
        }        
        var requesterEmail = component.get("v.userEmail");
        var coreId     	   = component.get("v.userCoreId");
        if($A.util.isUndefinedOrNull(requesterEmail) && $A.util.isUndefinedOrNull(coreId)){
        	requesterEmail 	= component.find("req").get("v.value");
            coreId 			= component.find("core").get("v.value");
        }
        var action = component.get("c.handleInvoiceRecords");
        if(isPartner && coreId.length > 10){
            coreId = '';
        }
        action.setParams({
            "customerNum" 	 : customerNum,
            "requesterEmail" : requesterEmail,
            "requestType" 	 : type,
            "coreId"		 : coreId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS' && response.getReturnValue() == 'INVOICECREATED'){
                component.set("v.loadSpinner", false);
                this.submitFinalReq(component, event);
            } else if(response.getReturnValue() == 'ERROR') {
                console.log(response.getReturnValue());
                component.set("v.loadSpinner", false);
            } else {
                console.log(response.getReturnValue());
                component.set("v.loadSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    isCommunity : function(component,event){
    	var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            if(state === 'SUCCESS'){
                component.set("v.isCommunity", response);
            }else{
                console.log('Error = '+response);
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component,message,messageType){
        var theme = component.get("v.userTheme");
        var isCommunity = component.get("v.isCommunity");
        if(isCommunity){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title"  : messageType+"!",
                "type"   : messageType,
                "message": message
            });
            toastEvent.fire();
        }else{
            if(theme == 'Theme4d'){
                sforce.one.showToast({
                    "title"  : messageType+"!",
                    "type"   : messageType,
                    "message": message
                });
            }else{
                //alert(message);
                if(messageType == 'Error' || messageType == 'error')
                    component.set("v.errorMsg", message);
                else if(messageType == 'Success' || messageType == 'success')
                    component.set("v.successMsg", message);
            }
        }
        
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.errorMsg", "");
                component.set("v.successMsg", "");
            }), 5000
        );
    },
    getSitesANDEmails : function(component,event,buttonValue){
        var filteredDataArry = [];
        
        if(buttonValue == 'emailOPTTab'){
            component.set("v.uniqueSiteList", []);
            component.set("v.uniqueEmails", []);
            component.set("v.existingEmails", []);
            component.set("v.uniqueNames", []);
            
            var uniqueSites = {};
            var uniqueEmails = {};
            var uniqueNames = {};
            
            var data = component.get("v.resultList");            
            var sites = component.get("v.uniqueSiteList");
            var emails = component.get("v.uniqueEmails");
            var existingEmails = component.get("v.existingEmails");
            var Names = component.get("v.uniqueNames");
            
            existingEmails.push(JSON.parse('{"CONTACT_EMAIL_ADDRESS":""}'));
            Names.push(JSON.parse('{"BILL_TO_SITE_CONTACT_NAME":""}'));
            // get all site numbers
            for(var i=0;i<data.length;i++){
                filteredDataArry.push({
                    "BILL_TO_SITE_NUMBER" : data[i].BILL_TO_SITE_NUMBER,
                    "CONTACT_EMAIL_ADDRESS" : data[i].CONTACT_EMAIL_ADDRESS,
                    "BILL_TO_SITE_CONTACT_NAME" : data[i].BILL_TO_SITE_CONTACT_NAME
                });
            }
            
            filteredDataArry.forEach(function(conItem){
                uniqueSites[conItem.BILL_TO_SITE_NUMBER] = conItem;
                uniqueEmails[conItem.CONTACT_EMAIL_ADDRESS] = conItem;
                uniqueNames[conItem.BILL_TO_SITE_CONTACT_NAME] = conItem;
            });
            
            var sitekeys = Object.keys(uniqueSites);
            var emailkeys = Object.keys(uniqueEmails);
            var Namekeys = Object.keys(uniqueNames);
            
            //fill up sites again
            sitekeys.forEach(function(key){
                sites.push(uniqueSites[key]);
            });
            emailkeys.forEach(function(key){
                emails.push(uniqueEmails[key]);
                existingEmails.push(uniqueEmails[key]);
            });     
            Namekeys.forEach(function(key){
                Names.push(uniqueNames[key]);
            });
            
            emails.push(JSON.parse('{"CONTACT_EMAIL_ADDRESS":"Other"}'));
            existingEmails.push(JSON.parse('{"CONTACT_EMAIL_ADDRESS":"Other"}'));
            Names.push(JSON.parse('{"BILL_TO_SITE_CONTACT_NAME":"Other"}'));
            
            component.set("v.uniqueSiteList", sites);
            component.set("v.uniqueEmails", emails);
            component.set("v.existingEmails", existingEmails);
            component.set("v.uniqueNames", Names);
           
        }
        else if(buttonValue == 'addDeleteTab'){
            component.set("v.sitesForContact", []);
            component.set("v.emailsForContact", []);
            
            var sitesvar = {};
        	var emailsvar = {};
            var sites = component.get("v.sitesForContact");
            var existingEmails = component.get("v.emailsForContact");
            var data = component.get("v.addContactresult");
            existingEmails.push(JSON.parse('{"CONTACT_EMAIL_ADDRESS":""}'));
            
            for(var i=0;i<data.length;i++){
                filteredDataArry.push({
                    "BILL_TO_SITE_NUMBER" : data[i].BILL_TO_SITE_NUMBER,
                    "CONTACT_EMAIL_ADDRESS" : data[i].CONTACT_EMAIL_ADDRESS
                });
            }
            
            filteredDataArry.forEach(function(conItem){
                sitesvar[conItem.BILL_TO_SITE_NUMBER] = conItem;
                emailsvar[conItem.CONTACT_EMAIL_ADDRESS] = conItem;
            });
            
            var sitekeys = Object.keys(sitesvar);
            var emailkeys = Object.keys(emailsvar);
            
            //fill up sites again
            sitekeys.forEach(function(key){
                sites.push(sitesvar[key]);
            });
            emailkeys.forEach(function(key){
                existingEmails.push(emailsvar[key]);
            });     
            
            existingEmails.push(JSON.parse('{"CONTACT_EMAIL_ADDRESS":"Other"}'));
            component.set("v.sitesForContact", sites);
            component.set("v.emailsForContact", existingEmails);
        }
    },
    resetDecisonSection : function(component,event,helper){
        
        var selectedTab = component.get("v.selTabId");
        if(selectedTab == 'tab1'){
            component.find("genericAP").set("v.value", 'Select one');
        	component.find("additionalAP").set("v.value", 'Select one');
           
            $A.util.addClass(component.find("decisionSection"), "slds-hide");
            $A.util.removeClass(component.find("decisionSection"), "slds-show");
            $A.util.addClass(component.find("additionalAP"), "slds-hide");
            $A.util.removeClass(component.find("additionalAP"), "slds-show");
            
            component.set("v.isGenericEmailNo",false);
            component.set("v.showGenericEmailWithSite",false);
            component.set("v.showGenericEmail",false);
        }
        
        this.resetdata(component,event,helper);
         
    },
    resetdata : function(component,event,helper){
        this.createObjectData(component, event, helper,true,'');
    	var selectedTab = component.get("v.selTabId");
        if(selectedTab == 'tab1'){
            component.set("v.flipAccountValue",'Y');
            component.set("v.showExistingData", false);
            component.set("v.isDelDisable",true);
            component.set("v.isDisableValidate",true);
            component.set("v.GenericAPEmail", '');
            component.set("v.finalContacts",[]);
            component.set("v.savedDeletedRows",[]);
            component.set("v.selectedContacts",[]);
            component.set("v.selectedContactsLength",10);
            component.set("v.finalContactsLength",10);
            
        }
        else if(selectedTab == 'tab2'){
            component.set("v.disableDelete",true);
            component.set("v.isDisableFinalize",true);
            
            component.set("v.saveContactsData",[]);
            component.set("v.saveDeletionData",[]);
            component.set("v.selectedRecords",[]);
            component.set("v.saveContactsDataLength",10);
            component.set("v.selectedRecordsLength",10);
        }
    },
    resetRetain : function(component,event,helper){
        this.createRetainDelData(component,event,helper);
    },
    callMuleSoftAPI : function(component, event){
        component.set("v.loadSpinner", true);
        var newItem = component.get("v.CCEmailList");
        var action = component.get("c.callMuleAPI");
        console.log(JSON.stringify(newItem[0]));
        action.setParams({
            "payload" : JSON.stringify(newItem[0]),
            "metaName" : 'EInvoice_CCPOST'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();
            var delayInMilliseconds = 5000;
            var message = '';
            var type = 'Error';
            if(state === 'SUCCESS' && response != 'APIError'){
                //this.ccEmailReset(component, event);
                component.set('v.ccErrorMsg',true);
                console.log('response === '+response);
            	message = 'Your request has been submitted successfully!';
                type = 'Success';
            }else if(response == 'APIError'){
                console.log(response);
				message = 'Request has not been submitted successfully, please retry after some time.';
            }else{
                console.log(response);
				message = JSON.stringify(response.getReturnValue());
            }
            
            this.showToast(component,message,type);
            component.set("v.loadSpinner", false);
            if(type == 'Success'){
                window.setTimeout(
                    $A.getCallback(function() {
                        window.location.reload();
                    }), delayInMilliseconds
                );
            }
            
        });
        $A.enqueueAction(action);
    },
    ccEmailReset : function(component, event){        
        //clear list values
        component.set("v.CCEmailList",[]);
        var CCEmailList = component.get("v.CCEmailList");
        CCEmailList.push({
            'P_SOURCE_SYSTEM'		: 'COF', 
            'P_SOURCE_SYSTEM_REF'	: '',
            'P_CC_EMAIL'		 	: '', 
            'P_REQUESTOR_EMAIL' 	: '',
            'P_REQUESTOR_COREID'	: ''
        });
        component.set("v.CCEmailList", CCEmailList);
    },
    finalizeReqBtn : function(component, event, helper){
        var tabTwoContact = component.get("v.saveContactsData");
        var tabTwoDeleteRows = component.get("v.saveDeletionData");
        
        var selectedTab = component.get("v.selTabId");
        if(selectedTab == 'tab2'){
            if(tabTwoContact.length > 0 || tabTwoDeleteRows.length > 0)
                component.set("v.isDisableFinalize",false);
            else
                component.set("v.isDisableFinalize",true);
        }
        
    },
    displayfinalizeReqData : function(component, event, helper){
        component.set("v.isOpen",true);
        component.set("v.modalHeading","Finalize Saved Data");
        component.set("v.isSaveRequest",false);
        component.set("v.isDeleteBody",false);
        component.set("v.finalizeBody",true);
        component.set("v.buttonlabel","Submit");
        component.set("v.buttonIdentifier", "finalizeRequest");
    },
    createCustomerData : function(component, event){
        component.set("v.customerData", []);
        var isPartner = component.get("v.isPartner");
        var resultList;
        var flipAccountVal = '';
        var customerData = component.get("v.customerData");
        var requesterEmail = component.get("v.userEmail");
        var coreId     	   = component.get("v.userCoreId");
        if($A.util.isUndefinedOrNull(requesterEmail) && $A.util.isUndefinedOrNull(coreId)){
        	requesterEmail 	= component.find("req").get("v.value");
            coreId 			= component.find("core").get("v.value");
        }
        if(isPartner && coreId.length > 10){
            coreId = '';
        }
        var selectedTab = component.get("v.selTabId");
        var newPreference;
        if(selectedTab == 'tab1'){
            flipAccountVal = component.get("v.flipAccountValue");
            resultList = component.get("v.resultList");
            newPreference = 'EMAIL';
        }else if(selectedTab == 'tab2'){
            resultList = component.get("v.addContactresult");
            newPreference = resultList[0].CUST_INVOICE_PREFERENCE;
        }
        customerData.push({
            "P_CURR_INV_PREFERENCE"	: resultList[0].CUST_INVOICE_PREFERENCE,
            "P_NEW_INV_PREFERENCE"	: newPreference,
            "P_SOURCE_SYSTEM"		: "PORTAL",
            "P_SOURCE_SYSTEM_REF"	: "",
            "P_REQUESTOR_EMAIL"		: requesterEmail,
            "P_REQUESTOR_COREID"	: coreId,
            "P_GF_CUSTOMER_NUMBER"	: resultList[0].CUSTOMER_ACCOUNT_NUMBER,
            "P_GF_CUSTOMER_NAME"	: resultList[0].CUSTOMER_NAME,
            "P_FLIP_ALL_ACCTS"		: flipAccountVal
        });
        component.set("v.customerData", customerData);
    },
    submitFinalReq : function(component, event){
        component.set("v.loadSpinner", true);
        var selectedTab = component.get("v.selTabId");
        var dropdownVal = component.get("v.genericAPDropdown");
        if(selectedTab == 'tab1'){
            var RowItemList;
            var tabOneContact = JSON.stringify(component.get("v.finalContacts"));
            var tabOneDeleteRows = JSON.stringify(component.get("v.savedDeletedRows"));
            var retainList =JSON.stringify(component.get("v.retainList"));
            if(dropdownVal == 'No')
                RowItemList = JSON.stringify(component.get("v.genericSectionData"));
            else if(dropdownVal == 'Yes')
                RowItemList = JSON.stringify(component.get("v.genericAPBillToSite"));
            this.sendRequest(component, event,tabOneContact,tabOneDeleteRows,retainList,RowItemList);
        }
        else if(selectedTab == 'tab2'){
            var tabTwoContact = JSON.stringify(component.get("v.saveContactsData"));
            var tabTwoDeleteRows = JSON.stringify(component.get("v.saveDeletionData"));
            this.sendRequest(component,event,tabTwoContact,tabTwoDeleteRows,'[]','[]');
        }
    },
    sendRequest : function(component,event,newContacts,contactsForDelete,retainedConts,RowItemList){
        this.createCustomerData(component, event);
        var selectedTab = component.get("v.selTabId");
        
        var action = component.get("c.serverRequest");
        var customerData = JSON.stringify(component.get("v.customerData"));
		
        action.setParams({
            "contactsForDelete" : contactsForDelete,
            "newContacts" 		: newContacts,
            "retainedContacts"	: retainedConts,
            "genericAPData"		: RowItemList,
            "customerData"		: customerData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var response = response.getReturnValue();                                         
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out'];
            if(state === 'SUCCESS' && !errorCodes.includes(response)){
                console.log(response);
                var delayInMilliseconds = 5000;
                component.set("v.loadSpinner", false);
               	var message = 'Your request has been submitted successfully!';
                this.showToast(component,message,'success');
                window.setTimeout(
                    $A.getCallback(function() {
                        window.location.reload();
                    }), delayInMilliseconds
                );
                
            }else{
                this.displayResponse(component,event,response);
            }
        });
        $A.enqueueAction(action);
        component.set("v.isOpen", false);
    },
})