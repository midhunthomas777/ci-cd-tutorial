({
    goToWizard :function(component, event, helper) {
        component.set("v.stepNumber",0);
        helper.showSpinner(component);
    },
    createRecords : function(component, event, helper) {
        helper.showSpinner(component);
        var fields = {};
        fields["Name"] = component.find("nameField").get("v.value");
        fields["Industry"] = component.find("industryField").get("v.value");
        fields["AnnualRevenue"] = component.find("revenueField").get("v.value");
        fields["NumberOfEmployees"] = component.find("noEmployeeField").get("v.value");
        //fields = fields.concat(component.find("addressField").get("v.value"));
        var address  = component.find("addressField").get("v.value");
        for (var key in address) {
          fields[key] = address[key];
         }
        component.find("accountForm").submit(fields);
    },
    handleContactOnload : function(component, event, helper) {
        helper.hideSpinner(component);
    },
    createContact : function(component, event, helper) {
        var response = event.getParams().response;
        
        //when account is created, get its id and set as accountId of contact
        //also set value of contact id in parameter
        component.find("contactAccountId").set("v.value",response.id);
        component.set("v.accountId",response.id);
        component.find("contactForm").submit();
    },
    
    handleContactSuccess : function(component, event, helper) {
        //change to next screen (file uploader)
        helper.hideSpinner(component);
        component.set("v.stepNumber",1);
    },
    handleinsuranceUploadFinished : function(component, event, helper) {
        //when insurance is uploaded , set its id to attribute so that it can be 
        //previewed in fild card
        component.set("v.insuranceId",event.getParam("files")[0].documentId );
    },
    handlelicenceUploadFinished : function(component, event, helper) {
        //when licence is uploaded , set its id to attribute so that it can be 
        //previewed in fild card
        component.set("v.licenceId",event.getParam("files")[0].documentId );
    },
    goToConsentPage : function(component, event, helper) {
        //change to next screen (Consent)
        component.set("v.stepNumber",2);
    },
    handleSubmitForm : function(component, event, helper) {
        helper.showSpinner(component);
        //set Partner_Registration_Status__c = submitted on account
        event.preventDefault();
        var eventFields = event.getParam("fields");
        eventFields["Partner_Registration_Status__c"] = "Submitted";
        component.find('consentUpdateForm').submit(eventFields);
    },
    handleSubmitFormSuccess : function(component, event, helper) {
        //change to next screen (Success message)
        helper.hideSpinner(component);
        component.set("v.stepNumber",3);
    }
})