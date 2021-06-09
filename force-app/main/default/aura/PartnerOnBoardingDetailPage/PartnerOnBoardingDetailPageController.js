({
    doInit : function(component, event, helper) {   
        var contactName = $A.get("{!$Label.c.POContactName}");
        var firstName = $A.get("{!$Label.c.POFirstName}");
        var lastName = $A.get("{!$Label.c.POLastName}");
        var email=$A.get("{!$Label.c.PoEmail}");
        var phone=$A.get("{!$Label.c.PoPhone}");
        var primaryRole=$A.get("{!$Label.c.POPrimaryRole}");
        var urlPrefix = $A.get("{!$Label.c.POCommunityPrefix}");
        component.set('v.customActions', [
            //{ label: 'Edit', name: 'edit' }
            { label: 'Custom action', name: 'custom_action' }
        ]);  
        component.set('v.contactColumns', [
            { label: contactName, fieldName: 'Name', type: 'text'/*, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}*/ },
            { label: firstName, fieldName: 'First_Name__c', type: 'text'},
            { label: lastName, fieldName: 'Last_Name__c', type:"text" }, 
            { label: email, fieldName: 'Email__c', type: 'email'},
            { label: phone, fieldName: 'Phone__c', type: 'phone'},
            { label: primaryRole, fieldName: 'Primary_Role__c', type: 'picklist'}
        ]);
        
        //var value = sessionStorage.getItem("applicationId");
        //
        var parsedUrl = new URL(window.location.href);
        var applicationId=parsedUrl.searchParams.get("applicationId");
        var language = parsedUrl.searchParams.get("language");
        // component.set("v.accessCode",accessCode);
        if(!$A.util.isUndefinedOrNull(applicationId) || !$A.util.isEmpty(applicationId)){
            /*   console.log('un'+accessCode);
            var action = component.get('c.getRecordId');
            action.setParams({
                "accessCode":accessCode
            }); 
            action.setCallback(this, function(response){
                var recordId = response.getReturnValue();
                console.log('deatails'+recordId);
                var state = response.getState();
                if(state === 'SUCCESS'){
                    console.log('success');
                    if(!$A.util.isUndefinedOrNull(recordId) || !$A.util.isEmpty(recordId)){  
                        console.log('success inside');
                        component.set("v.applicationId",recordId);
                        if(!$A.util.isUndefinedOrNull(recordId) || !$A.util.isEmpty(recordId)){
                            component.set("v.loadData",true);
                        }
                    }
                }            
            });
            $A.enqueueAction(action);*/
            component.set("v.applicationId",applicationId);
            component.set("v.loadData",true);
        }
        console.log("test"+language);
        window.history.pushState({}, document.title, urlPrefix+"partneronboarding-detail-page?language="+language);
    },
    customHandler: function(component, event, helper) {
        console.log('test');
    },
    handleComponentEvent: function(component, event, helper) {
        console.log('inside event');
        var submittedValue = event.getParam("isSubmitted"); 
        console.log('test value-->'+submittedValue);
        component.set("v.isSubmitted", false);
        component.set("v.isSubmittedDefault",false);
        component.set("v.isSubmitted", submittedValue);
    },
    handleApproval : function(component, event, helper) {
        var poSubmitErrorMsg = $A.get("{!$Label.c.OpportunityResubmitErrorMessage}");
        var poSubmitSuccessMsg = $A.get("{!$Label.c.POSubmitForApprovalMsg}");
        var poError = $A.get("{!$Label.c.POErrorMsg}");
        var poSuccess = $A.get("{!$Label.c.POSuccessMsg}");
        component.set('v.isSubmitted',false);
        var state = event.getParam("state");
        var response = event.getParam("response");
        if(state === 'SUCCESS' && response === 'success'){
            helper.showToast(component, event, {
                "title"  : poSuccess,
                "type"   : "Success",
                "message": poSubmitSuccessMsg
            });
        }else{
            helper.showToast(component, event, {
                "title"  : poError,
                "type"   : "Error",
                "message": poSubmitErrorMsg
            });
        }
        component.set("v.openPopUp",false); 
    },
     navigateToPartner: function(component,event,helper){
        var parsedUrl = new URL(window.location.href);
        var language=parsedUrl.searchParams.get("language");
        if(!$A.util.isUndefinedOrNull(language) || !$A.util.isEmpty(language)){
            var result=language.toLowerCase();
            console.log(result);
            if(result=='ko'){
                result="ko_kr";
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://www.motorolasolutions.com/"+result+"/partners/power-partner/selecting-channel-partner.html"
                });
                urlEvent.fire();  
            }else if(result=='ja'){
                result="ja_jp";
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://www.motorolasolutions.com/"+result+"/partners/power-partner/selecting-channel-partner.html"
                });
                urlEvent.fire();  
            }else{
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://www.motorolasolutions.com/"+result+"/partners/power-partner/selecting-channel-partner.html"
                });
                urlEvent.fire();  
            }
        }else{
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://www.motorolasolutions.com/en_us/partners/power-partner/selecting-channel-partner.html"
            });
            urlEvent.fire();
        }
        
    },
    navigateToContact: function(component,event,helper){
        var parsedUrl = new URL(window.location.href);
        var language=parsedUrl.searchParams.get("language");
        if(!$A.util.isUndefinedOrNull(language) || !$A.util.isEmpty(language)){
            var result=language.toLowerCase();
            
            if(result=='ko'){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://www.motorolasolutions.com/ko_kr/partners/partner-interaction-center.html"
                });
                urlEvent.fire();  
            }else if(result=='ja'){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://www.motorolasolutions.com/ja_jp/partners/partner-interaction-center.html"
                });
                urlEvent.fire();  
            }else if(result=='zh_cn'){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://www.motorolasolutions.com/zh_cn/partners/partner-interaction-center.html"
                });
                urlEvent.fire();  
            }else if(result=='en_xp'){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": " https://www.motorolasolutions.com/en_xp/partners/partner-interaction-center.html"
                });
                urlEvent.fire();
                
            }else{
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "https://www.motorolasolutions.com/en_us/partners/partner-interaction-center.html"
                });
                urlEvent.fire();
            }
            
        }else{
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://www.motorolasolutions.com/en_us/partners/partner-interaction-center.html"
            });
            urlEvent.fire();
        }
    }
    
    
})