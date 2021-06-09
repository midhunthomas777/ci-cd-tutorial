({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Contact Name', fieldName: 'BILL_TO_SITE_CONTACT_NAME', type: 'text', editable: false, initialWidth: 150},
            {label: 'Contact Email Address', fieldName: 'CONTACT_EMAIL_ADDRESS', type: 'email', editable: false, initialWidth: 300},
            {label: 'Contact Role', fieldName: 'CONTACT_ROLE', type: 'text', editable: false},
            {label: 'Site Number', fieldName: 'BILL_TO_SITE_NUMBER', type: 'text', initialWidth: 150},
            {label: 'ADDRESS1', fieldName: 'ADDRESS1', type: 'text'},
            {label: 'ADDRESS2', fieldName: 'ADDRESS2', type: 'text'},
            {label: 'CITY', fieldName: 'CITY', type: 'text', initialWidth: 150},
            {label: 'STATE', fieldName: 'STATE', type: 'text', initialWidth: 100},
            {label: 'ZIP', fieldName: 'POSTAL_CODE', type: 'text', initialWidth: 100},
            {label: 'Status', fieldName: 'CONTACT_STATUS', type: 'text', initialWidth: 80}
        ]);
        component.set('v.contactsColumn', [
            {label: 'Site Number', fieldName: 'P_CUSTOMER_SITE', type: 'text'},
            {label: 'Contact Name', fieldName: 'BILL_TO_SITE_CONTACT_NAME', type: 'text'},
            {label: 'Contact Email', fieldName: 'P_EMAIL', type: 'text', initialWidth: 300},
            {label: 'Roles', fieldName: 'P_CONTACT_ROLE', type: 'text', initialWidth: 300}
        ]);
		
        helper.isCommunity(component, event);
        helper.isPartnerUser(component, event, helper); 
        helper.currentLoggedInUser(component, event, helper);
        helper.ccEmailReset(component, event);     
    },
    searchCustPref : function(component, event, helper) {
        helper.validateSearch(component, event, helper);
    },
    changeFlipAccount : function(component, event, helper) {
		var selectedVal = component.find("flipAcc").get("v.value");  
        component.set("v.flipAccountValue",selectedVal);
    },
    handleSelectedRows : function(component, event, helper) {
        var selectedTab = component.get("v.selTabId");
        if(selectedTab == 'tab1'){
            var selectedRowsId = [];
            var retainRowsId = [];
            var isContactAdded =  false;
            var resultList = component.get("v.resultList");
            var retainList = component.get("v.retainList");
            var selectedRows = event.getParam("selectedRecord");
            //component.set("v.savedDeletedRows",[]);
            //var deleteData = component.get("v.savedDeletedRows");
            var deleteData = [];
            for(var i=0;i<selectedRows.length;i++){
                selectedRowsId.push(selectedRows[i].rowId);
                var contactname = selectedRows[i].BILL_TO_SITE_CONTACT_NAME;
                var firstName = contactname.substring(0,contactname.indexOf(' '));
                var lastName = contactname.substring(contactname.indexOf(' ')+1);
                deleteData.push({
                    'P_ACTION_TYPE'			   : 'Delete',
                    'P_CUSTOMER_SITE' 	       : selectedRows[i].BILL_TO_SITE_NUMBER,
                    'P_CONTACT_FIRST_NAME'	   : firstName,
                    'P_CONTACT_LAST_NAME'	   : lastName,
                    'P_EMAIL'				   : selectedRows[i].CONTACT_EMAIL_ADDRESS,
                    'P_CONTACT_ROLE'		   : selectedRows[i].CONTACT_ROLE,
                    'P_CONTACT_REFERENCE'	   : selectedRows[i].CONTACT_REFERENCE,
                    'BILL_TO_SITE_CONTACT_NAME': selectedRows[i].BILL_TO_SITE_CONTACT_NAME,
                    'rowId' 				   : selectedRows[i].rowId
                });
				                
            }
            for(var i=0;i<retainList.length;i++){
                retainRowsId.push(retainList[i].rowId);
            }
            
            for(var j=0;j<resultList.length;j++){
                var row = resultList[j];
                for(var item in row){
                    if(item == "rowId" && !selectedRowsId.includes(row[item])){  
                        if(!retainRowsId.includes(row[item])){
                            var contactname = resultList[j].BILL_TO_SITE_CONTACT_NAME;
                            var firstName = contactname.substring(0,contactname.indexOf(' '));
                            var lastName = contactname.substring(contactname.indexOf(' ')+1);
                            retainList.push({
                                'P_ACTION_TYPE'			   : 'Retain',
                                'P_CUSTOMER_SITE' 	       : resultList[j].BILL_TO_SITE_NUMBER,
                                'P_CONTACT_FIRST_NAME'	   : firstName,
                                'P_CONTACT_LAST_NAME'	   : lastName,
                                'P_EMAIL'				   : resultList[j].CONTACT_EMAIL_ADDRESS,
                                'P_CONTACT_ROLE'		   : resultList[j].CONTACT_ROLE,
                                'P_CONTACT_REFERENCE'	   : resultList[i].CONTACT_REFERENCE,
                                'BILL_TO_SITE_CONTACT_NAME': resultList[j].BILL_TO_SITE_CONTACT_NAME,
                                'rowId' 				   : resultList[j].rowId
                            });
                            isContactAdded = true;
                        }
                    }
                }
            }
            if(isContactAdded){
                component.set("v.savedDeletedRows",deleteData);
                component.set("v.retainList", retainList);
                component.set("v.retainListDuplicate", retainList);
            }
            
            var selectedRecords = component.get("v.selectedContacts");
            var savedContacts = component.get("v.finalContacts");
            var retainedContacts = component.get("v.retainList");
            if(selectedRows != undefined){
                if(selectedRows.length != 0){
                    selectedRecords = deleteData;
                    component.set("v.isDelDisable",false);
                }else if(selectedRows.length == 0 && selectedRecords.length > 0){
                    selectedRecords.splice(0,selectedRecords.length);
                    component.set("v.isDelDisable",true);
                    component.set("v.savedDeletedRows",[]);
                }
            }
            
            component.set("v.selectedContacts", selectedRecords);
            component.set("v.selectedContactsLength", selectedRecords.length);
            if(savedContacts.length == 0 && selectedRows.length == 0 && retainedContacts.length == 0){
                component.set("v.isFinalReqDisable",true);
            }
        }else if(selectedTab == 'tab2'){
            var selectedRows = event.getParam("selectedRecord");
            var selectedRecords = component.get("v.selectedRecords");
            var savedContacts = component.get("v.saveContactsData");
            
            component.set("v.saveDeletionData",[]);
            var deleteData = component.get("v.saveDeletionData");
            for(var i=0;i<selectedRows.length;i++){
                var contactname = selectedRows[i].BILL_TO_SITE_CONTACT_NAME;
                var firstName = contactname.substring(0,contactname.indexOf(' '));
                var lastName = contactname.substring(contactname.indexOf(' ')+1);
                deleteData.push({
                    'P_ACTION_TYPE'			   : 'Delete',
                    'P_CUSTOMER_SITE' 	       : selectedRows[i].BILL_TO_SITE_NUMBER,
                    'P_CONTACT_FIRST_NAME'	   : firstName,
                    'P_CONTACT_LAST_NAME'	   : lastName,
                    'P_EMAIL'				   : selectedRows[i].CONTACT_EMAIL_ADDRESS,
                    'P_CONTACT_ROLE'		   : selectedRows[i].CONTACT_ROLE,
                    'P_CONTACT_REFERENCE'	   : selectedRows[i].CONTACT_REFERENCE,
                    'BILL_TO_SITE_CONTACT_NAME': selectedRows[i].BILL_TO_SITE_CONTACT_NAME,
                    'rowId' 				   : selectedRows[i].rowId
                });
				                
            }
            
            if(selectedRows != undefined){
                if(selectedRows.length != 0){
                    selectedRecords = deleteData;
                    component.set("v.disableDelete",false);
                }else if(selectedRows.length == 0 && selectedRecords.length > 0){
                    selectedRecords.splice(0,selectedRecords.length);
                    component.set("v.disableDelete",true);
                    component.set("v.saveDeletionData",[]);
                }
            }
            
            component.set("v.selectedRecords", selectedRecords);
            component.set("v.selectedRecordsLength", selectedRecords.length);
            if(savedContacts.length == 0 && selectedRows.length == 0){
                component.set("v.isDisableFinalize",true);
            }
        }        
    },
    deleteConfirmation : function(component, event, helper) {
    	component.set("v.isOpen",true);
        component.set("v.modalHeading","Are you sure you want to delete the records ?");
        component.set("v.finalizeBody",false);
        component.set("v.isDeleteBody",true);
        component.set("v.isSaveRequest",true);
        component.set("v.buttonlabel","Save");
        
        var selectedTab = component.get("v.selTabId");
        if(selectedTab == 'tab1'){
        	component.set("v.buttonIdentifier", "delContactfromEmail");
        }else if(selectedTab == 'tab2'){
            component.set("v.buttonIdentifier", "delContactfromAdd");
        }
    },
    decisionDetails : function(component, event, helper) {
        $A.util.toggleClass(component.find("decisionSection"), "slds-hide");
    },
    changeGenericAP : function(component, event, helper) {
        var selectedVal = component.find("genericAP").get("v.value");
        if(selectedVal == 'Yes'){
            component.find("additionalAP").set("v.value", 'Select one');
            $A.util.removeClass(component.find("additionalAP"), "slds-hide");
            $A.util.addClass(component.find("additionalAP"), "slds-show");
            component.set("v.showGenericEmailWithSite",false);
            component.set("v.isGenericEmailNo",false);
            helper.resetdata(component,event,helper);
            helper.resetRetain(component,event,helper);
        }else if(selectedVal == 'No'){
            component.set("v.showGenericEmail",false);
            component.set("v.isGenericEmailNo",true);
            $A.util.addClass(component.find("additionalAP"), "slds-hide");
            $A.util.removeClass(component.find("additionalAP"), "slds-show");
            component.set("v.showGenericEmailWithSite",false);
            helper.sendcustomerDetails(component,event,'Print');
            helper.resetdata(component,event,helper);
            helper.resetRetain(component,event,helper);
        }
    },
    changeAdditionalAP : function(component, event, helper) {
        var selectedVal = component.find("additionalAP").get("v.value");
        if(selectedVal == 'Yes'){
            component.set("v.showGenericEmail",false);
            component.set("v.showGenericEmailWithSite",true);
            component.set("v.isGenericEmailNo",false);
            helper.getExistingBillToSites(component,event);
            helper.resetdata(component,event,helper);
            helper.resetRetain(component,event,helper);
        }else if(selectedVal == 'No'){
            component.set("v.showGenericEmail",true);
            component.set("v.showGenericEmailWithSite",false);
            component.set("v.isGenericEmailNo",false);
            helper.resetdata(component,event,helper);
            helper.resetRetain(component,event,helper);
        }
    },
    clickCreate: function(component, event, helper) {
        var referenceNumber = component.find("refNum");
        var requesterEmail = component.find("reqEmail");
        var CCEmail = component.find("ccemail");
        var CoreID = component.find("coreid");
        
        referenceNumber.showHelpMessageIfInvalid();
        requesterEmail.showHelpMessageIfInvalid();
        CCEmail.showHelpMessageIfInvalid();
        CoreID.showHelpMessageIfInvalid();
        if(referenceNumber.checkValidity() && requesterEmail.checkValidity() && CCEmail.checkValidity() && CoreID.checkValidity()){
            helper.callMuleSoftAPI(component, event);
        }
        
    },
    addNewContact : function (component, event, helper) {
        var btnVal = event.getSource().get("v.value");
        
        component.set("v.modalHeading","Add New Contacts");
        component.set("v.finalizeBody",false);
        component.set("v.isOpen",true);
        component.set("v.isSaveRequest",true);
        component.set("v.buttonlabel","Save");
        component.set("v.isDeleteBody",false);
        if(btnVal == 'emailOPTTabCont'){
            component.set("v.isEmailOptContact",true);
            component.set("v.buttonIdentifier", "newContactFromEmail");
        }else{
            component.set("v.isEmailOptContact",false);
            component.set("v.buttonIdentifier", "newContactFromAdd");
        }
    },
    removeRow : function (component, event, helper) {
        var identifier = event.getParam("processIdentifier");
        var tabvalue = event.getParam("tabValue");
        if(identifier == 'addNewcontact'){
        	helper.removeObjectData(component, event, helper, tabvalue);
        }
    },
    closeModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    saveModalDetails : function(component, event, helper) {
        var isPartner 	   = component.get("v.isPartner");
        var userEmail 	   = component.get("v.userEmail");
        var userCoreId     = component.get("v.userCoreId");
        var requesterEmail = component.get("v.requesterEmail");
        var requesterCoreId= component.get("v.requesterCoreId");
        var isSaveRequest  = component.get("v.isSaveRequest");
        var requesterInput = component.find("req");
        var coreId 		   = component.find("core");
        var btnName		   = event.getSource().get("v.name");
        var type = '';
        var validationMsg = false;
        var selectedRowsId = [];
        if(btnName == 'newContactFromAdd'){
            var RowItemList = component.get("v.ContactList");
            type = 'Addition';
            for(var i=0; i<RowItemList.length; i++){
                var RowItem = RowItemList[i];
                helper.getRowItemValues(component,RowItem);
                var response = helper.validateNewContacts(component,event,RowItem);
                if(response){
                    validationMsg = true;
                }
            }

            if(validationMsg){
                var message = 'Please input all the emails and contact name.';
                helper.showToast(component,message,'error');
            }else{
                component.set("v.saveContactsData",RowItemList);
                component.set("v.saveContactsDataLength",RowItemList.length);
            }
        }else if(btnName == 'newContactFromEmail'){
            var RowItemList = component.get("v.emailOptContacts");
            type = 'Addition';
            for(var i=0; i<RowItemList.length; i++){
                var RowItem = RowItemList[i];
                helper.getRowItemValues(component,RowItem);
                var response = helper.validateNewContacts(component,event,RowItem);
                if(response){
                    validationMsg = true;
                }
            }
            
            if(validationMsg){
                var message = 'Please input all the emails and contact name.';
                helper.showToast(component,message,'error');
            }else{
                component.set("v.finalContacts",RowItemList);
                component.set("v.finalContactsLength",RowItemList.length);
            }
        }else if(btnName == 'delContactfromAdd'){
            var selectedRecords = component.get("v.selectedRecords");
            type = 'Deletion';
            component.set("v.saveDeletionData",selectedRecords);
        }else if(btnName == 'delContactfromEmail'){
            var selectedRecords = component.get("v.selectedContacts");
            for(var i=0;i<selectedRecords.length;i++){
                selectedRowsId.push(selectedRecords[i].rowId);
            }
            var retainList = component.get("v.retainList");
            var retaindata = component.get("v.retainListDuplicate");
            for(var j=0;j<retaindata.length;j++){
                var retainRow = retaindata[j];
                for(var item in retainRow){
                    if(item == "rowId" && selectedRowsId.includes(retainRow[item])){  
                        var index = retainList.indexOf(retaindata[j]);
                        retainList.splice(index,1);
                    }
                }
            }
            component.set("v.retainList", retainList);
            component.set("v.retainListDuplicate", retainList);
            
            type = 'Deletion';
            component.set("v.savedDeletedRows",selectedRecords);
        }
        
        if(type == 'Addition' || type == 'Deletion')
            helper.finalizeReqBtn(component, event, helper);
        else if(btnName == 'finalizeRequest')
            type = 'NEW, DELETE';
        
        if(isPartner && btnName == 'finalizeRequest'){
            component.set("v.isOpen", false);
            helper.createEInvoiceRecord(component, event, type);
        }else if(isSaveRequest && !validationMsg){
            component.set("v.isOpen", false);
        }else if(btnName == 'finalizeRequest'){
            if($A.util.isUndefinedOrNull(userEmail) || $A.util.isUndefinedOrNull(userCoreId)){
                requesterInput.showHelpMessageIfInvalid();
                coreId.showHelpMessageIfInvalid();
                if(requesterInput.checkValidity() == true && coreId.checkValidity() == true){
                    helper.createEInvoiceRecord(component, event, type);
                }
            }
            else{
                helper.createEInvoiceRecord(component, event, type);
            }
        }
    },
    finalizeRequest : function(component, event, helper){
        helper.displayfinalizeReqData(component, event, helper);
    },
    validateExisting : function(component, event, helper){
        var dropdownVal = component.find("additionalAP").get("v.value");
        if(dropdownVal == 'Yes'){
            var validationMsg = false;
            var retainList = component.get("v.retainList");
            var retaindata = component.get("v.retainListDuplicate");
            
            var isExistingData = component.get("v.showExistingData");
            var UniqueData = component.get("v.genericAPBillToSite");
            for(var i=0; i<UniqueData.length;i++){
                var RowItem = UniqueData[i];
                // reset names value before merge
                RowItem.P_CONTACT_FIRST_NAME = '';
                RowItem.P_CONTACT_LAST_NAME = '';
                helper.getRowItemValues(component,RowItem);
                var response = helper.validateNewContacts(component,event,RowItem);
                if(response)
                    validationMsg = true;
            }
                
			if(!validationMsg){
                component.set("v.genericAPBillToSite", UniqueData);
                helper.resetdata(component,event,helper);
                helper.resetRetain(component,event,helper);
                component.set("v.showExistingData", true);
            }
            else{
                component.set("v.showExistingData", false);
                var message = 'Please inputs all the emails and contact name.';
            	helper.showToast(component, message,'error');
            }
                       
        }else{
            var email = component.find("genericEmail");
            var fistName = component.find("confirstname");
            var lastName = component.find("conlastname");
            
            fistName.showHelpMessageIfInvalid();
            lastName.showHelpMessageIfInvalid();
            email.showHelpMessageIfInvalid();
            if(fistName.checkValidity() == true && lastName.checkValidity() == true && email.checkValidity() == true){
                helper.genericSectionData(component,event);
                component.set("v.showExistingData", true);
            }
            
        }        
    },
    AddContacts : function(component, event, helper){
        var selectedTab = component.get("v.selTabId");
    	helper.createObjectData(component, event, helper,false,'');
    },
})