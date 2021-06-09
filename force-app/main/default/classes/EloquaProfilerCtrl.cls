public class EloquaProfilerCtrl {
    public String eloquaFrameUrl{get;set;}
    public boolean engageBoolean{get;set;}
    
    public EloquaProfilerCtrl(ApexPages.StandardController stdController){
        
        String incomingRecId = stdController.getId();
        String isEngageStr = ApexPages.currentPage().getParameters().get('isEngage');
        if(String.isNotBlank(isEngageStr)){
            engageBoolean=TRUE;
        }else{
            engageBoolean =FALSE;
        }
        
        eloquaFrameUrl = getdynamicURL(incomingRecId,isEngageStr);
        
    }
    @AuraEnabled
    public static String getdynamicURL(Id incomingRecId,String isEngageStr){
        String eloquaFrameUrlFinal;
        Lead currentLeadRecord;
        Contact currentContactRecord;
        List<Eloqua__mdt> eloquas = new List<Eloqua__mdt>();
        
        Id currentUserProfileId = userinfo.getProfileId();
        Boolean singleSignEnabledForCurrentUser = false;
        
        System.debug('userinfo.getUserId()###'+userinfo.getUserId());
        User currentUser = [SELECT Id,Single_Sign_On_for_Eloqua__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        
        if(currentUser.Single_Sign_On_for_Eloqua__c){
            singleSignEnabledForCurrentUser = true;
        }
        
        System.debug('singleSignEnabledForCurrentUser###'+singleSignEnabledForCurrentUser);
        
        if(String.valueOf(incomingRecId).substring(0,3) == '00Q') {
            currentLeadRecord = [Select Id, Email, Region__c from Lead where Id =: incomingRecId LIMIT 1];
            if(GlobalUtility.runningInASandbox()) {
                if(!singleSignEnabledForCurrentUser){
                    eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c from Eloqua__mdt 
                               where Instance__c = 'Sandbox' AND Region__c =: currentLeadRecord.Region__c];
                }else{
                    eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c from Eloqua__mdt 
                               where Instance__c = 'Sandbox' AND Is_Signle_Sign_On_Enabled__c=true AND Object_Type__c='Lead'];
                }
                
            } else {
                if(!singleSignEnabledForCurrentUser){
                    eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c from Eloqua__mdt 
                               where Instance__c = 'Production' AND Region__c =: currentLeadRecord.Region__c];
                }else{
                    eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c from Eloqua__mdt 
                               where Instance__c = 'Production' AND Is_Signle_Sign_On_Enabled__c=true AND Object_Type__c='Lead'];
                }
            }
        } else if(String.valueOf(incomingRecId).substring(0,3) == '003') {
            currentContactRecord = [Select Id, Email, Region__c from Contact where Id =: incomingRecId LIMIT 1];
            if(GlobalUtility.runningInASandbox()) {
                if(!singleSignEnabledForCurrentUser){
                    eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c from Eloqua__mdt 
                               where Instance__c = 'Sandbox' AND Region__c =: currentContactRecord.Region__c];
                }else{
                    eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c from Eloqua__mdt 
                               where Instance__c = 'Sandbox' AND Is_Signle_Sign_On_Enabled__c=true AND Object_Type__c='Lead'];
                }
                
            } else {
                if(!singleSignEnabledForCurrentUser){
                    eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c from Eloqua__mdt 
                               where Instance__c = 'Production' AND Region__c =: currentContactRecord.Region__c];
                }else{
                    eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c from Eloqua__mdt 
                               where Instance__c = 'Production' AND Is_Signle_Sign_On_Enabled__c=true AND Object_Type__c='Lead'];
                }
            }
        }else if(String.valueOf(incomingRecId).substring(0,3) == '006'){
            if(GlobalUtility.runningInASandbox()) {
                eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c,Is_Signle_Sign_On_Enabled__c from Eloqua__mdt 
                           where Instance__c = 'Sandbox' AND Object_Type__c='Opportunity'];
            } else {
                eloquas = [Select Eloqua_URL__c,LoginPrefix__c,Password__c,Region__c,Resource_URL__c,Username__c,Engage_Resource_URL__c,Is_Signle_Sign_On_Enabled__c from Eloqua__mdt 
                           where Instance__c = 'Production' AND Object_Type__c='Opportunity'];
            }
        }
        
        if(!eloquas.isEmpty()) {
            Eloqua__mdt eloqua = eloquas.get(0);
            if(String.valueOf(incomingRecId).substring(0,3) == '00Q') {
                if(String.isNotBlank(isEngageStr)) {
                    if(!singleSignEnabledForCurrentUser) {
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c + '&Username=' + eloqua.Username__c
                            + '&Password=' + eloqua.Password__c + '&Url=' + eloqua.Engage_Resource_URL__c + currentLeadRecord.Email;
                    }else {
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c +'&ReturnUrl=' + eloqua.Engage_Resource_URL__c + currentLeadRecord.Email;
                    }
                } else {
                    if(!singleSignEnabledForCurrentUser){
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c + '&Username=' + eloqua.Username__c
                            + '&Password=' + eloqua.Password__c + '&Url=' + eloqua.Resource_URL__c + currentLeadRecord.Email;
                    }else{
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c +'&ReturnUrl=' + eloqua.Resource_URL__c + currentLeadRecord.Email;
                    }
                }
            } else if(String.valueOf(incomingRecId).substring(0,3) == '003') {
                if(String.isNotBlank(isEngageStr)) {
                    if(!singleSignEnabledForCurrentUser){
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c + '&Username=' + eloqua.Username__c
                            + '&Password=' + eloqua.Password__c + '&Url=' + eloqua.Engage_Resource_URL__c + currentContactRecord.Email;
                    }else{
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c +'&ReturnUrl=' + eloqua.Engage_Resource_URL__c + currentContactRecord.Email;
                    }
                } else {
                    if(!singleSignEnabledForCurrentUser){
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c + '&Username=' + eloqua.Username__c
                            + '&Password=' + eloqua.Password__c + '&Url=' + eloqua.Resource_URL__c + currentContactRecord.Email;
                    }else{
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c +'&ReturnUrl=' + eloqua.Resource_URL__c + currentContactRecord.Email;
                    }
                }
            } else if(String.valueOf(incomingRecId).substring(0,3) == '006') {
                if(String.isNotBlank(isEngageStr)){
                    if(!singleSignEnabledForCurrentUser){
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c + '&Username=' + eloqua.Username__c
                            + '&Password=' + eloqua.Password__c + '&Url=' + eloqua.Engage_Resource_URL__c;
                    }else{
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c +'&ReturnUrl=' + eloqua.Engage_Resource_URL__c;
                    }
                }else{
                    if(!singleSignEnabledForCurrentUser){
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c + '&Username=' + eloqua.Username__c
                            + '&Password=' + eloqua.Password__c + '&Url=' + eloqua.Resource_URL__c;
                    }else{
                        eloquaFrameUrlFinal = eloqua.Eloqua_URL__c + '?LoginPrefix=' + eloqua.LoginPrefix__c +'&ReturnUrl=' + eloqua.Resource_URL__c;
                    }
                }                
            }
            System.debug('#######eloquaFrameUrlFinal####### => ' + eloquaFrameUrlFinal);
        }
        
        return eloquaFrameUrlFinal;
    }  
}