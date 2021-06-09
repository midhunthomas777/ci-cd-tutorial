/************************************************************************************************
* Description: To fetch customer,Partner,Eligilble percentage,Order Type information when MCN record is selected.
* Author : Adilraza Shaikh
* Date :  28th Aug 2018
**********************************************************************************************/
global class MRCPQ_ProceedToQuoteController { 
    @AuraEnabled
    public static List<Sobject> getMCN (String recId){   
        system.debug('recId##>'+ recId);
        if(recId.startsWith('006')){
            //List<Opportunity> lstOpp = [SELECT Id,CDH_Account__c,CDH_Account__r.Motorola_Customer_Number__c,CDH_Account__r.ERP_Active__c,AccountId,Account.RecordType.DeveloperName,Account.Is_Partner_as_End_User__c,RecordType.DeveloperName FROM Opportunity WHERE (CDH_Account__r.ERP_Active__c = true or Account.RecordType.DeveloperName='Prospect' or Account.Is_Partner_as_End_User__c = true) and Id =: recId];
            //List<Opportunity> lstOpp = [SELECT Id,CDH_Account__c,CDH_Account__r.Motorola_Customer_Number__c,CDH_Account__r.ERP_Active__c,AccountId,Account.RecordType.DeveloperName,Account.Is_Partner_as_End_User__c,RecordType.DeveloperName FROM Opportunity WHERE (CDH_Account__r.ERP_Active__c = true or Account.Is_Partner_as_End_User__c = true) and Id =: recId];
            /*if(!lstOpp.isEmpty()){
//if(lstOpp.get(0).Account.RecordType.DeveloperName=='Prospect' || lstOpp.get(0).Account.Is_Partner_as_End_User__c == true){
//   return lstOpp;
//}else 
if(lstOpp.get(0).CDH_Account__r.ERP_Active__c = true){
return lstOpp;
}
}else{*/
            List<Opportunity> lstOpps = [SELECT Id,AccountId FROM Opportunity WHERE Id =: recId];
            if(!lstOpps.isEmpty()){
                List<Account> checkType = [Select Recordtype.DeveloperName,Is_Partner_as_End_User__c from Account where Id =: lstOpps.get(0).AccountId];
                system.debug('No Opp MCN Loop'+checkType);
                if(!checkType.isEmpty()){
                    if(checkType.get(0).Recordtype.DeveloperName == 'Prospect') {
                        return [SELECT Id,Motorola_Customer_Number__c,Assigned_MR__c,parentId,Parent.RecordType.DeveloperName,RecordType.DeveloperName,Parent.Is_Partner_as_End_User__c,Is_Partner_as_End_User__c FROM Account 
                                WHERE Id=:lstOpps.get(0).AccountId ];
                    } else if(checkType.get(0).Is_Partner_as_End_User__c == true) {
                        return [SELECT Id,Recordtype.DeveloperName,Parent.RecordType.DeveloperName,Motorola_Customer_Number__c,Is_Partner_as_End_User__c FROM Account WHERE Id = :lstOpps.get(0).AccountId];
                    }
                }                
                return [SELECT Id,Motorola_Customer_Number__c,Assigned_MR__c,parentId,RecordType.DeveloperName,Parent.RecordType.DeveloperName,Parent.Is_Partner_as_End_User__c FROM Account 
                        WHERE parentId=:lstOpps.get(0).AccountId AND Recordtype.DeveloperName ='Motorola_Customer_Number' AND ERP_Active__c = true];
            }
            //}
            return null;
        }else if(recId.startsWith('001')){
            List<Account> checkType = [Select Recordtype.DeveloperName,Is_Partner_as_End_User__c from Account where Id =: recId];
            system.debug('checkType'+checkType);
            if(!checkType.isEmpty()){
                if(checkType.get(0).Recordtype.DeveloperName == 'Prospect') {
                    return [SELECT Id,Motorola_Customer_Number__c,Assigned_MR__c,parentId,Parent.RecordType.DeveloperName,RecordType.DeveloperName,Parent.Is_Partner_as_End_User__c,Is_Partner_as_End_User__c FROM Account 
                            WHERE Id=:recId ];
                } else if(checkType.get(0).Is_Partner_as_End_User__c == true) {
                    return [SELECT Id,Recordtype.DeveloperName,Parent.RecordType.DeveloperName,Motorola_Customer_Number__c,Is_Partner_as_End_User__c FROM Account WHERE Id = :recId];
                }
            }
            return [SELECT Id,Motorola_Customer_Number__c,Assigned_MR__c,parentId,RecordType.DeveloperName,Parent.RecordType.DeveloperName,Parent.Is_Partner_as_End_User__c FROM Account 
                    WHERE parentId=:recId AND Recordtype.DeveloperName ='Motorola_Customer_Number' AND ERP_Active__c = true];
        } else {
            return [SELECT Id,Account__c,Opportunity__r.CDH_Account__c,Opportunity__c,Partner_MCN__c FROM Partners2__c WHERE Id=:recId];
        }
        
    }
    @AuraEnabled
    public static String fetchSitePrefix(){
        String partnerAccountID = [SELECT AccountId FROM User WHERE Id =: Userinfo.getUserId()].AccountId;
        if(String.isNotBlank(partnerAccountID)){
            return CPQUtility.fetchSitePrefix();
        }else{
            return URL.getSalesforceBaseUrl().toExternalForm();
        }
    }
    @AuraEnabled
    public static String fetchCPQSiteId(){
        return CPQUtility.fetchCPQSiteId();
    }
    @AuraEnabled
    public static Double getPartnerCommissionDetails(String orderType,String techSpecLevel , String communityType){
        String partnerAccountID = [SELECT AccountId FROM User WHERE Id =: Userinfo.getUserId()].AccountId;
        system.debug('#########partnerAccountID in P2Quote########### => ' + partnerAccountID);
        return CPQUtility.fetchPartnerTerritoryCommission(partnerAccountID,orderType,techSpecLevel,communityType);
    }
    @AuraEnabled
    public static CPQUtility.AccountDetailsWrapper getAccountDetails(String motoCustNum, String accountId , String partnerAccountID){
        if(String.isBlank(partnerAccountID) ){
            partnerAccountID = [SELECT AccountId FROM User WHERE Id =: Userinfo.getUserId()].AccountId;
        }
        return CPQUtility.fetchAccountDetails(motoCustNum,partnerAccountID,accountId); 
    }
    @AuraEnabled      
    public static String createCPQSession(String custId, String MCNId, Decimal eligiblePer, String MRId, String orderType, String oppoId, String partnerSoftwareQuote, String recordId) {
        System.debug('custId===>'+custId);
        System.debug('MCNId===>'+MCNId);
        System.debug('oppoId===>'+oppoId);
        System.debug('recordId===>'+recordId);
        return CPQUtility.createCPQSession(custId,MCNId,eligiblePer,MRId,orderType, oppoId, partnerSoftwareQuote,recordId);
    }
    @AuraEnabled      
    public static List<String> fetchOrderType() {
        String partnerAccountID = [SELECT AccountId FROM User WHERE Id =: Userinfo.getUserId()].AccountId;
        return CPQUtility.fetchOrderType(true, partnerAccountID);
    }
    @AuraEnabled    
    public static boolean fetchQuoteAccess() {        
        boolean quoteAccess =false;
        if(Schema.sObjectType.BigMachines__Quote__c.isCreateable() ){
            quoteAccess = Schema.sObjectType.BigMachines__Quote__c.isCreateable();
        }
        System.debug('quoteAccess===>' + quoteAccess);
        return quoteAccess;
    }
    
    @AuraEnabled
    public static String canCreateQuoteFromAcc(){
        Map<String, Alerts_And_Messages__mdt> alertMessageMap = GlobalUtility.metaMessagesMap(null, 'SpillmanQuoteValidationMessages');
        String quoteAccessMessage;
        if(FeatureManagement.checkPermission('Can_Create_Quotes_from_Accounts')) {
            quoteAccessMessage = '';
        } else {
            quoteAccessMessage = alertMessageMap.get('Create_Quote_Check_From_Account').Message__c;
        }
        return quoteAccessMessage;
    }
    
    @AuraEnabled
    public static String isValidOpp(String recordId,String userId){
        Id oppId;
        if(recordId.startsWith('a09')) {
            List<Partners2__c>  partnerRecord = [SELECT Opportunity__c From Partners2__c WHERE ID =:recordId];
            oppId = partnerRecord[0].Opportunity__c;
        } else{
            oppId = recordId;  
        }
        List<MR_Digitization_Settings__mdt> profilesAllowedToQuote = GlobalUtility.getDigitizationSettings('Profiles_That_Dont_Allow_Direct_Quoting');
        //To Fetch Error Messages
        Map<String, Alerts_And_Messages__mdt> alertMessageMap = GlobalUtility.metaMessagesMap(null, 'SpillmanQuoteValidationMessages');
        Boolean isSpillmanProd,isVestaProd;
        String message = ''; 
        User user = [Select Id,Profile.Name FROM USER WHERE Id = :userId];
        List<Opportunity> opp = [SELECT ID,Purchasing_Entity__c,Account.FTE__c,RecordType.DeveloperName, No_Of_SubAccounts__c,
                                 Account.RecordType.DeveloperName,(SELECT PricebookEntry.Product2.Needs_FTE_for_Quote__c,
                                                                   PricebookEntry.Product2.Site_Required_for_Quoting__c FROM OpportunityLineItems),
                                 (SELECT ID,FTE__c,Billing_Agency__c,End_User_Site__c FROM Opportunity_Agency__r WHERE Create_Quote__c = TRUE) 
                                 FROM Opportunity WHERE ID =:oppId LIMIT 1];                             
        
        if(profilesAllowedToQuote[0].Long_Text_Area__c.contains(user.Profile.Name) || Test.isRunningTest()) {
            for(OpportunityLineItem oppLineItem : opp[0].OpportunityLineItems){
                if(oppLineItem.PricebookEntry.Product2.Site_Required_for_Quoting__c == true){
                    isVestaProd = true;
                } else if(oppLineItem.PricebookEntry.Product2.Needs_FTE_for_Quote__c == true) {
                    isSpillmanProd = true;
                } 
            }
            if(isSpillmanProd == true && !recordId.startsWith('a09')){
                if(opp[0].Account.FTE__c == NULL || opp[0].Account.FTE__c == 0){
                    message = alertMessageMap.get('FTE_Required_For_Host_Account').Message__c;
                }
                else if(opp[0].Purchasing_Entity__c == null){
                    message = alertMessageMap.get('Primary_Billing_Entity_Check').Message__c;
                }
                
                if(!opp[0].Opportunity_Agency__r.isEmpty()){
                    for(SubAgency__c subAcc : opp[0].Opportunity_Agency__r){
                        if(subAcc.FTE__c ==0 || subAcc.FTE__c == NULL){
                            message = alertMessageMap.get('FTE_Required_For_Secondary_Account').Message__c;
                        } 
                        else if(opp[0].Purchasing_Entity__c == null && subAcc.Billing_Agency__c == NULL){
                            message = alertMessageMap.get('Billing_Entity_Check_Opp_SecondaryAccs').Message__c;
                        }
                        else if(!opp[0].Opportunity_Agency__r.isEmpty() && subAcc.Billing_Agency__c == NULL){
                            message = alertMessageMap.get('Billing_Entity_Check_For_Secondary_Accs').Message__c;
                        }
                    } 
                }
                
            }if(isVestaProd == true) {
                if(opp[0].Opportunity_Agency__r.isEmpty()) {
                    message = alertMessageMap.get('End_User_Site_Validation_For_Vesta_Opp').Message__c;  
                }else if(! opp[0].Opportunity_Agency__r.isEmpty()){
                    for(SubAgency__c subAcc : opp[0].Opportunity_Agency__r){
                        if(subAcc.End_User_Site__c == null) {
                            message = alertMessageMap.get('EndUserSite_Validation_For_SecondaryOpp').Message__c;
                        }
                    }
                } 
            }
        }
        return message;
    }  
    @AuraEnabled
    public static String updateOppMCN(String oppId, String mcnID) {
        system.debug('oppId==>' + oppId + '+++ mcnID==>' + mcnID );         
        try{
            //if(String.isBlank(Opp.CDH_Account__c)){
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.CDH_Account__c = mcnID;           
            OpportunityTriggerHandler.TriggerDisabled =true;           
            update opp;
            OpportunityTriggerHandler.TriggerDisabled =false;           
            //}   
        }
        catch(DMLException ex){
            system.debug('Exception is...'+ex.getMessage());
        }        
        return 'Success';
    }
}