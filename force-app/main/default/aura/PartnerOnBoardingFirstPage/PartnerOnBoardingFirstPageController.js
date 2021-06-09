({
    handleFieldSetEvent:function(component, event, helper) {
        var fieldSetData=event.getParam("fieldSetResult");
        var sectionfieldSetName = event.getParam("sectionfieldSetName");
       if(sectionfieldSetName === 'PartnerEmpowerFieldSetFirstPage'){
            component.set("v.fieldSetFinalResultFirst",fieldSetData);
        }else if(sectionfieldSetName === 'PartnerEmpowerFieldSetSecondPage'){
            component.set("v.fieldSetFinalResultSecond",fieldSetData);
            console.log('test fields-->'+JSON.stringify(fieldSetData));
        }else if(sectionfieldSetName === 'PartnerEmpowerFieldSetSignatory'){
            component.set("v.fieldSetFinalResultSignatory",fieldSetData);
            console.log('test fields sign-->'+JSON.stringify(component.get("v.fieldSetFinalResultSignatory")));
        }
    },
    handleEvent:function(component, event, helper) {
        var showThirdPage = event.getParam("showThirdPage");
        var secondPageRec = event.getParam("applnRecSecondPage");
        if(showThirdPage){
            document.getElementById("partnerOnboardingSecondPage").style.display = "none";        
            component.set("v.loadThirdPage",true);
            document.getElementById("partnerOnboardingThirdPage").style.display = "block";
        }
        
    },
    handleSubmit : function(component, event, helper) { 
        var emailError = $A.get("{!$Label.c.POEmailMsg}");
        var parentCompanyError= $A.get("{!$Label.c.POParentComapnyName}");
        component.set("v.errorMsg",null);
        event.preventDefault();
        var eventFields = event.getParam("fields"); 
        var secondPage=false;
        if(eventFields['Are_You_Authorized_to_Sign_Legal_Agmt__c']=="No"){
            secondPage=component.get("v.loadSecondPage");
        }else{
            secondPage=component.get("v.loadSignatoryPage");
        }
        var emailField= eventFields['Applicant_Email_Address__c'];             
        var regExpEmailformat= /^[a-zA-Z0-9._-]+@(?!gmail.com)(?!gmail)(?!yahoo.com)(?!yahoo)(?!hotmail.com)(?!hotmail)(?!naver.com)(?!naver)(?!hanmail.net)(?!hanmail)(?!daum.net)(?!daum)(?!nate.com)(?!nate)(?!qq.com)(?!qq)(?!163.com)(?!163)(?!126.com)(?!126)(?!live.com)(?!live)(?!outlook.com)(?!outlook)(?!sina.com)(?!sina)(?!rediffmail.com)(?!rediffmail)(?!t-online.de)(?!t-online)(?!gmx.de)(?!gmx)(?!onet.pl)(?!onet)(?!orange.fr)(?!orange)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,9}$/;
        var LAregExpEmailformat= /^[a-zA-Z0-9._-]+@(?!naver.com)(?!naver)(?!hanmail.net)(?!hanmail)(?!daum.net)(?!daum)(?!nate.com)(?!nate)(?!qq.com)(?!qq)(?!163.com)(?!163)(?!126.com)(?!126)(?!outlook.com)(?!outlook)(?!sina.com)(?!sina)(?!rediffmail.com)(?!rediffmail)(?!t-online.de)(?!t-online)(?!gmx.de)(?!gmx)(?!onet.pl)(?!onet)(?!orange.fr)(?!orange)[a-zA-Z0-9.-]+\.[a-zA-Z]{2,9}$/;
        var region = eventFields['Partner_Region__c'];	
        
        //var thirdPage=component.get("v.loadThirdPage");
        if(!secondPage){
            
            if(!$A.util.isEmpty(emailField)){   
                if(emailField.match(regExpEmailformat) || (region === 'LA' && emailField.match(LAregExpEmailformat))){
                    component.set("v.errorMsg",null); 
                    if((eventFields['Divison_of_or_Owned_by_Another_Company__c']=="Yes" && !$A.util.isEmpty(eventFields['Divison_of_or_Owned_by_Another_Company__c'])) && $A.util.isEmpty(eventFields['Parent_Company_Name__c'])){
                        component.set("v.errorMsg",parentCompanyError); 
                        document.getElementById("partnerOnboardingAlertMsg").scrollIntoView(true);
                        document.getElementById("partnerOnboardingFirstPage").style.display = "block"; 
                        document.getElementById("partnerOnboardingSecondPage").style.display = "none";
                        document.getElementById("partnerOnboardingSignatoryPage").style.display = "none";
                    }else{
                        component.set("v.errorMsg",null); 
                        if(eventFields['Are_You_Authorized_to_Sign_Legal_Agmt__c']=="No"){
                            component.set("v.loadSecondPage",true);
                            component.set("v.loadSignatoryPage",false);
                            document.getElementById("partnerOnboardingFirstPage").style.display = "none";
                            document.getElementById("partnerOnboardingSecondPage").style.display = "block";
                            document.getElementById("partnerOnboardingSignatoryPage").style.display = "none";
                        }else{
                            component.set("v.loadSignatoryPage",true);
                            component.set("v.loadSecondPage",false);
                            document.getElementById("partnerOnboardingFirstPage").style.display = "none";
                            document.getElementById("partnerOnboardingSecondPage").style.display = "none";
                            document.getElementById("partnerOnboardingSignatoryPage").style.display = "block";
                            
                        }
                    }
                    //document.getElementById("partnerOnboardingFirstPage").style.display = "none"; 
                }else{
                    component.set("v.errorMsg",emailError);  
                    document.getElementById("partnerOnboardingAlertMsg").scrollIntoView(true);
                }
            } 
        }else{
            if(!$A.util.isEmpty(emailField)){  
                if(emailField.match(regExpEmailformat)  || (region === 'LA' && emailField.match(LAregExpEmailformat))){
                    component.set("v.errorMsg",null);
                    if((eventFields['Divison_of_or_Owned_by_Another_Company__c']=="Yes" && !$A.util.isEmpty(eventFields['Divison_of_or_Owned_by_Another_Company__c'])) && $A.util.isEmpty(eventFields['Parent_Company_Name__c'])){
                        component.set("v.errorMsg",parentCompanyError); 
                        document.getElementById("partnerOnboardingAlertMsg").scrollIntoView(true);
                        document.getElementById("partnerOnboardingFirstPage").style.display = "block"; 
                        document.getElementById("partnerOnboardingSecondPage").style.display = "none";
                        document.getElementById("partnerOnboardingSignatoryPage").style.display = "none";
                    }else{
                        component.set("v.errorMsg",null); 
                        if(eventFields['Are_You_Authorized_to_Sign_Legal_Agmt__c']=="No"){
                            document.getElementById("partnerOnboardingSecondPage").style.display = "block";
                            document.getElementById("partnerOnboardingFirstPage").style.display = "none";
                            document.getElementById("partnerOnboardingSignatoryPage").style.display = "none";
                        }else{
                            document.getElementById("partnerOnboardingSignatoryPage").style.display = "block";                
                            document.getElementById("partnerOnboardingSecondPage").style.display = "none";
                            document.getElementById("partnerOnboardingFirstPage").style.display = "none";
                        }
                    } 
                }else{
                    component.set("v.errorMsg",emailError);  
                    document.getElementById("partnerOnboardingAlertMsg").scrollIntoView(true);
                }
            }
        }
        component.set("v.firstPageResult",eventFields);
        component.set("v.showSpinner", false); 
    },
    handleSuccess : function(component, event, helper) {  
        var payload =event.getParams().response;
        console.log('test'+JSON.stringify(payload));
        component.set("v.showSpinner", false);      
    },
    
    handleError :function(component, event, helper) {
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));
        component.set("v.showSpinner", false);
        
    },
    
    handleLoad : function(component,event,helper){
        component.set("v.showSpinner", false);
        console.log('on first page');
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