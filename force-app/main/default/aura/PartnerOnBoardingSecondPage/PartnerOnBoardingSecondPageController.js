({
    
    handleApplnEvent:function(component, event, helper) {
        var applnSecondPage = event.getParam("showThirdPage");
        component.set("v.applnSecondPage",applnSecondPage);
    },
    handleSubmit : function(component, event, helper) { 
        event.preventDefault();
        var eventFields = event.getParam("fields"); 
        var firstPageData=component.get("v.firstPageData");
        component.set("v.partnerRegion",firstPageData['Partner_Region__c']);
        var signatoryData=[];
        if(firstPageData['Partner_Region__c']=='NA'){
            eventFields['RecordTypeId']='0122H00000048B8';
        }else if(firstPageData['Partner_Region__c']=='APAC'){
            eventFields['RecordTypeId']='0122H00000048B5';
        }else if(firstPageData['Partner_Region__c']=='EMEA'){
            eventFields['RecordTypeId']='0122H00000048B6';
        }else{
            eventFields['RecordTypeId']='0122H00000048B7';
        }
        if(firstPageData['Are_You_Authorized_to_Sign_Legal_Agmt__c']=='Yes'){
            signatoryData.push({
                'sobjectType': 'Empower_Application__c',
                'Company_Signature_Authority_Phone_Number__c': '',
                'Company_Signature_Authority_First_Name__c': '',
                'Company_Signature_Authority_Last_Name__c': '',
                'Company_Signature_Authority_Primary_Role__c':'',            
                'Company_Signature_Authority_Primary__c': '',
                'Company_Signature_Authority_Salutation__c': '',
                'Company_Signature_Authority_Email__c': '',
                'Company_Signature_Authority_Mobile__c':''
            });
            signatoryData.Company_Signature_Authority_Phone_Number__c=firstPageData['Applicant_Phone_Number__c'];
            signatoryData.Company_Signature_Authority_First_Name__c=firstPageData['Applicant_First_Name__c'];
            signatoryData.Company_Signature_Authority_Last_Name__c=firstPageData['Applicant_Last_Name__c'];
            signatoryData.Company_Signature_Authority_Primary_Role__c=firstPageData['Applicant_Primary_Role__c'];
            signatoryData.Company_Signature_Authority_Primary__c=firstPageData['Applicant_Primary_Language__c'];
            signatoryData.Company_Signature_Authority_Salutation__c=firstPageData['Applicant_Salutation__c'];
            signatoryData.Company_Signature_Authority_Email__c=firstPageData['Applicant_Email_Address__c'];
            signatoryData.Company_Signature_Authority_Mobile__c=firstPageData['Applicant_Mobile_Number__c'];
            
            const finalResult =Object.assign({},firstPageData,signatoryData,eventFields);
            component.find("inputForm").submit(finalResult);  
            component.set("v.showSpinner", true);
        }else{
            const finalResult = Object.assign({},firstPageData,eventFields);
            component.find("inputForm").submit(finalResult);  
            component.set("v.showSpinner", true);
        }      
    },
    handleSuccess : function(component, event, helper) { 
        var payload = event.getParams().response;
        var region =  component.get("v.partnerRegion");
        console.log('payload-->'+JSON.stringify(payload));       
        helper.callForApprovalSubmission(component,event, helper,payload.id,payload.recordTypeId,region);
        helper.navigateToObject(component,event, helper,payload.id);
        component.set("v.showSpinner", false);
        
    },
    handleError :function(component, event, helper) {
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));
        component.set("v.showSpinner", false);
        
    },
    backOperation : function(component, event, helper) {
        component.set("v.showSpinner", false);
        document.getElementById("partnerOnboardingSecondPage").style.display = "none";
        document.getElementById("partnerOnboardingSignatoryPage").style.display = "none";
        document.getElementById("partnerOnboardingFirstPage").style.display = "block";
    },
    handleLoad : function(component,event,helper){
        component.set("v.showSpinner", false); 
        var payload = event.getParams();    
        console.log('inside load');
    },
})