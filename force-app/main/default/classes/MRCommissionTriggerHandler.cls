public class MRCommissionTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;    
    private PartnerSharingHelper partnerSharingHelper = new PartnerSharingHelper();
    public Boolean isDisabled(){
        if (TriggerSettings__c.getValues('MRCommissionTriggerDisabled').IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }   
    public void beforeInsert(List<SObject> newItems){   
        System.debug('Before Insert MR Calc###########=>');
        List<MR_Commission_Calculator__c> mrCommLst = (List<MR_Commission_Calculator__c>) newItems;  
        // CheckOrderAmount(mrCommLst[0]);
        List<MR_Commission_Calculator__c> toBeSent = new List<MR_Commission_Calculator__c>();
        for(MR_Commission_Calculator__c incoming:mrCommLst){
            if(String.isNotBlank(incoming.Opportunity__c)){
                toBeSent.add(incoming);
            }
        }        
        if(!toBeSent.isEmpty()){
            populateDetailsFromOpportunity(toBeSent);    
        }
        
        
        Map<String, Map<String, String>> orderTypes = orderTypeQuestionResponses(mrCommLst[0]);        
        System.debug('orderTypes###########=>' +orderTypes);
        commissionCalculation(mrCommLst[0], orderTypes);  
        checkOverrideCommissionDollar(mrCommLst);
    }   
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        List<MR_Commission_Calculator__c> mrCommLst = (List<MR_Commission_Calculator__c>) newItems.values();
        Map<Id,MR_Commission_Calculator__c> mrCommLstOldMap = (Map<Id,MR_Commission_Calculator__c>) oldItems;
        
        List<MR_Commission_Calculator__c> toBeSent = new List<MR_Commission_Calculator__c>();
        
        for(MR_Commission_Calculator__c incoming:mrCommLst){            
            MR_Commission_Calculator__c oldMRC = mrCommLstOldMap.get(incoming.Id);
            if(incoming.Opportunity__c != oldMRC.Opportunity__c && String.isNotBlank(incoming.Opportunity__c)){
                toBeSent.add(incoming);
            }
        }        
        if(!toBeSent.isEmpty()){
            populateDetailsFromOpportunity(toBeSent);    
        }
        
        system.debug('mrCommLst[0] &&&&&'+mrCommLst[0]);
        Map<String, Map<String, String>> orderTypes = orderTypeQuestionResponses(mrCommLst[0]);
        
        commissionCalculation(mrCommLst[0], orderTypes);
        checkOverrideCommissionDollar(mrCommLst);
        System.debug('Updated value########' +mrCommLst[0].Box_Service_Product__c );
    }
    
    public Map<String, Map<String, String>> orderTypeQuestionResponses(MR_Commission_Calculator__c mRC){
        Map<String, Map<String, String>> orderTypesQuestions = new Map<String, Map<String, String>>();
        for(MR_Commission_Calculator_Questions__mdt question: [Select MasterLabel,MR_Order_Types_for_CPQ__r.DeveloperName,Question_Type__c,
                                                               Is_Active_Question__c,Execution_Order__c FROM MR_Commission_Calculator_Questions__mdt 
                                                               where Is_Active_Question__c = TRUE AND                                                                  
                                                               Question_Type__c LIKE :'%Input%'])
        {
            if(String.valueOf(mRC.get(question.MasterLabel)) !='No' && String.valueOf(mRC.get(question.MasterLabel)) != null) {
                system.debug('(question.MasterLabel)'+(question.MasterLabel));
                system.debug('value is'+String.valueOf(mRC.get(question.MasterLabel)));                    
                system.debug('order type dev'+orderTypesQuestions.get(question.MR_Order_Types_for_CPQ__r.DeveloperName));
                
                
                Map<String, String> tempMap = orderTypesQuestions.get(question.MR_Order_Types_for_CPQ__r.DeveloperName);
                if(tempMap != NULL) {
                    tempMap.put(question.MasterLabel, String.valueOf(mRC.get(question.MasterLabel)));
                    orderTypesQuestions.put(question.MR_Order_Types_for_CPQ__r.DeveloperName, tempMap);                    
                } else {
                    Map<String, String> questionsResponses = new Map<String, String>();
                    questionsResponses.put(question.MasterLabel, String.valueOf(mRC.get(question.MasterLabel)));
                    orderTypesQuestions.put(question.MR_Order_Types_for_CPQ__r.DeveloperName, questionsResponses);
                }
            }            
        }
        system.debug('orderTypesQuestions are'+orderTypesQuestions);
        return orderTypesQuestions;
    }  
    // before insert or update
    public void commissionCalculation(MR_Commission_Calculator__c mRC, Map<String, Map<String, String>> orderTypes){          
        List<Account> accounts = [SELECT Id,Motorola_Customer_Number__c,Assigned_MR__c,Primary_Route_to_Market__c,ParentId FROM Account WHERE Id =: mRC.Motorola_Customer_Number__c
                                  AND Recordtype.Developername='Motorola_Customer_Number' Limit 1];
        system.debug('orderTypes ==>' + orderTypes);
        system.debug('accounts moto'+accounts);
        String partnerId ;
        if(!accounts.isEmpty() ){
            if(accounts.get(0).Primary_Route_to_Market__c =='Open'){
                if(String.isNotBlank(mRC.Partner_Account__c)){
                    partnerId=mRC.Partner_Account__c;
                    system.debug('if partnerId'+partnerId);
                    
                }else{
                    partnerId= [SELECT AccountId FROM User WHERE ID =: UserInfo.getUserId()].AccountID;
                    system.debug('else partnerId'+partnerId);
                }            
            }else if(UserInfo.getUserType() == 'Standard' && String.isNotBlank(mRC.Partner_Account__c)){//SF-1803 
                partnerId=mRC.Partner_Account__c;                
            }else{
                partnerId=accounts[0].Assigned_MR__c;                
            }
        }
        
        if(!accounts.isEmpty()){
            Map<String, Map<String, Decimal>> returnorderTypesMap = MRCommissionCalculatorCtrl.commissionCalculationAllOrderTypes(accounts[0].Motorola_Customer_Number__c,
                                                                                                                                  partnerId,
                                                                                                                                  accounts[0].ParentId,orderTypes);
            System.debug('returnorderTypesMap#######=>' + returnorderTypesMap);
            Map<String,MR_Commission_Calculator_Questions__mdt> outputQuestionsMap = new Map<String,MR_Commission_Calculator_Questions__mdt>(); 
            for(MR_Commission_Calculator_Questions__mdt question : [Select MasterLabel,MR_Order_Types_for_CPQ__r.DeveloperName,Question_Type__c,
                                                                    Is_Active_Question__c,Execution_Order__c FROM MR_Commission_Calculator_Questions__mdt 
                                                                    where Is_Active_Question__c = TRUE AND                                                                  
                                                                    Question_Type__c LIKE :'%Output%' order by Execution_Order__c Asc]) 
            {
                outputQuestionsMap.put(question.MasterLabel,question);              
            }  
            Map<String, Decimal> returnCommissionMap;            
            for(String OrderType : returnorderTypesMap.keySet()){                
                for(String incoming : returnorderTypesMap.get(orderType).keySet()){ 
                    System.debug('incoming###########=>' + incoming);   
                    System.debug('returnorderTypesMap.get(orderType).get(incoming)###########=>' + returnorderTypesMap.get(orderType).get(incoming)); 
                    mRC.put(incoming, returnorderTypesMap.get(orderType).get(incoming)) ;                                    
                }   
            }
            checkOrderAmount(mRC);     
        }
    }
    public static void updateQuestionsOnOverrideOrderAmount(MR_Commission_Calculator__c mRC, String orderType){        
        for(MR_Commission_Calculator_Questions__mdt question : [Select MasterLabel,MR_Order_Types_for_CPQ__r.DeveloperName,Question_Type__c,
                                                                Is_Active_Question__c,Execution_Order__c FROM MR_Commission_Calculator_Questions__mdt 
                                                                where Is_Active_Question__c = TRUE AND 
                                                                MR_Order_Types_for_CPQ__r.DeveloperName =:orderType AND                                                                
                                                                Question_Type__c LIKE :'%Input%']) 
        {
            System.debug('Before YEs String.valueOf(mRC.get(question.MasterLabel))#########' + String.valueOf(mRC.get(question.MasterLabel)));
            if(String.valueOf(mRC.get(question.MasterLabel)) == 'YES'){  
                System.debug('Yes question.MasterLabel#########' + question.MasterLabel);
                mRC.put(question.MasterLabel,'NO');                   
                //}else if(!question.MasterLabel.contains('Order_Amount') && !question.MasterLabel.contains('Override_Commission_Dollars') && (String.valueOf(mRC.get(question.MasterLabel)) != '0')){
                //mRC.put(question.MasterLabel, 0);
            }else if(question.MasterLabel.contains('PE')){
                if(String.valueOf(mRC.get(question.MasterLabel)) == null || String.valueOf(mRC.get(question.MasterLabel)) =='' ){
                    mRC.Box_PE_Discount_Percentage__c = 0;
                }
                if(decimal.valueOf(String.valueOf(mRC.get(question.MasterLabel))) > 0){
                    mRC.Box_PE_Discount_Percentage__c = 0;  
                }
            }  
            System.debug('question.MasterLabel#########' + question.MasterLabel);
            System.debug('String.valueOf(mRC.get(question.MasterLabel))#########' + String.valueOf(mRC.get(question.MasterLabel)));
        } 
    }  
    @TestVisible 
    private void populateDetailsFromOpportunity(List<MR_Commission_Calculator__c> newMRCommissions){
        Set<Id> oppIds = new Set<Id>();
        for(MR_Commission_Calculator__c incoming:newMRCommissions){
            if(!String.isBlank(incoming.Opportunity__c)){
                oppIds.add(incoming.Opportunity__c);    
            }  
        }
        if(oppIds.size() > 0 ){
            String partnerId= [SELECT AccountId FROM User WHERE ID =: UserInfo.getUserId()].AccountID;
            system.debug('partnerId for opportunity#####'+partnerId);
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,CDH_Account__c,Amount FROM Opportunity WHERE Id IN:oppIds]);            
            for(MR_Commission_Calculator__c incoming:newMRCommissions){
                system.debug('for opportunity case################');
                incoming.Motorola_Customer_Number__c = oppMap.get(incoming.Opportunity__c).CDH_Account__c;
                incoming.Partner_Account__c = partnerId;
            }
        }
    }
    public void checkOrderAmount(MR_Commission_Calculator__c mRC){
        if(mRC.Box_Order_Amount__c == 0 ){
            mRC.Box_Base_Selling_Percentage__c = 0;
            mRC.Box_Commission_Percentage__c = 0;
            mRC.Box_Effective_Commission_Percentage__c =0;
            mRC.Box_Effective_Commission_Dollars__c =0;
        } 
        if(mRC.System_Order_Amount__c == 0 ){
            mRC.System_Base_Selling_Percentage__c = 0;
            mRC.System_Commission_Percentage__c = 0;
            mRC.System_Effective_Commission_Percent__c =0;
            mRC.System_Effective_Commission_Dollars__c =0;
        } else if(mRC.System_Order_Amount__c > 0 ) {
            mRC.Box_Base_Selling_Percentage__c = 0;
            mRC.Box_Commission_Percentage__c = 0;
            mRC.Box_Effective_Commission_Percentage__c =0;
            mRC.Box_Effective_Commission_Dollars__c =0;
        }    
        if(mRC.CCMR_Order_Amount__c == 0 ){               
            mRC.CCMR_Commission_Percentage__c = 0;
            mRC.CCMR_Effective_Commission_Percentage__c =0;
            mRC.CCMR_Effective_Commission_Dollars__c =0;
        }     
        if(mRC.SEC_Order_Amount__c == 0 ){                
            mRC.SEC_Commission_Percentage__c = 0;
            mRC.SEC_Effective_Commission_Percentage__c =0;
            mRC.SEC_Effective_Commission_Dollars__c =0;
        }
        //SF-1801
        if(mRC.SO_Order_Amount__c == 0 ){                
            mRC.SO_Commission_Percentage__c = 0;
            mRC.SO_Effective_Commission_Percentage__c =0;
            mRC.SO_Effective_Commission_Dollars__c =0;
        }else if(mRC.SO_Order_Amount__c > 0 ) {
            //Box
            mRC.Box_Base_Selling_Percentage__c = 0;
            mRC.Box_Commission_Percentage__c = 0;
            mRC.Box_Effective_Commission_Percentage__c =0;
            mRC.Box_Effective_Commission_Dollars__c =0;
            //System
            mRC.System_Base_Selling_Percentage__c = 0;
            mRC.System_Commission_Percentage__c = 0;
            mRC.System_Effective_Commission_Percent__c =0;
            mRC.System_Effective_Commission_Dollars__c =0;
            //CCMR
            mRC.CCMR_Commission_Percentage__c = 0;
            mRC.CCMR_Effective_Commission_Percentage__c =0;
            mRC.CCMR_Effective_Commission_Dollars__c =0;
            //SEC
            mRC.SEC_Commission_Percentage__c = 0;
            mRC.SEC_Effective_Commission_Percentage__c =0;
            mRC.SEC_Effective_Commission_Dollars__c =0;
        }
        //SF-1803
        if(mRC.MSI_Order_Amount__c == 0 ){            
            mRC.MSI_Commission_Percentage__c = 0;
            mRC.MSI_Effective_Commission_Percentage__c =0;
            mRC.MSI_Effective_Commission_Dollars__c =0;
        } 
    }
    public void checkOverrideCommissionDollar(List<MR_Commission_Calculator__c> mrCommLst){
        if(mrCommLst[0].Box_Override_Commission_Dollars__c > 0){
            updateQuestionsOnOverrideOrderAmount(mrCommLst[0],'Box');
        }
        if(mrCommLst[0].System_Override_Commission_Dollars__c > 0){
            updateQuestionsOnOverrideOrderAmount(mrCommLst[0],'System');
        }
        if(mrCommLst[0].CCMR_Override_Commission_Dollars__c > 0){
            updateQuestionsOnOverrideOrderAmount(mrCommLst[0],'Command_Center_MR_CCMR');
        }
        if(mrCommLst[0].SEC_Override_Commission_Dollars__c > 0){
            updateQuestionsOnOverrideOrderAmount(mrCommLst[0],'Software_Enterprise_Commission');
        }   
        //SF-1801
         if(mrCommLst[0].SO_Override_Commission_Dollars__c > 0){
            updateQuestionsOnOverrideOrderAmount(mrCommLst[0],'Service_Only');
        }  
        //SF-1803
         if(mrCommLst[0].SO_Override_Commission_Dollars__c > 0){
            updateQuestionsOnOverrideOrderAmount(mrCommLst[0],'MSI_Inside_Sales_Led');
        }  
    }
    
    public void beforeDelete(Map<Id, SObject> oldItems){}
    public void afterInsert(Map<Id, SObject> newItems){
        List<MR_Commission_Calculator__c> newMRDetails = (List<MR_Commission_Calculator__c>) newItems.values();
        Map<Id,Id> mrShareMap = new Map<Id,Id>();
        
        for(MR_Commission_Calculator__c mrRec : [SELECT Id,CreatedById,Opportunity__c,OwnerId,CreatedBy.AccountId,CreatedBy.UserType
                                                 FROM MR_Commission_Calculator__c 
                                                 WHERE Id IN :newMRDetails AND CreatedById IN (SELECT Id FROM User WHERE IsActive=true)
                                                 AND Opportunity__c!=null] ){
                                                     if(mrRec.CreatedBy.UserType == 'PowerPartner') {
                                                         mrShareMap.put(mrRec.Id, mrRec.CreatedBy.AccountId);
                                                     }
                                                 }
        if(!mrShareMap.isEmpty()) {
            System.debug('######After Insert mrShareMap######' + mrShareMap);
            partnerSharingHelper.shareToExecutiveRoles(mrShareMap);
        }
        
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        List<MR_Commission_Calculator__c> newMRDetails = (List<MR_Commission_Calculator__c>) newItems.values();
        Map<Id,Id> mrShareMap = new Map<Id,Id>();
        for(MR_Commission_Calculator__c mrRec : [SELECT Id,CreatedById,Opportunity__c,OwnerId,CreatedBy.AccountId,CreatedBy.UserType
                                                 FROM MR_Commission_Calculator__c 
                                                 WHERE Id IN :newMRDetails AND CreatedById IN (SELECT Id FROM User WHERE IsActive=true)
                                                 AND Opportunity__c!=null ] ){
                                                     if(mrRec.OwnerId<>mrRec.CreatedById && string.valueOf(mrRec.OwnerId).startsWith('005') && mrRec.CreatedBy.UserType == 'PowerPartner'){
                                                         mrShareMap.put(mrRec.Id, mrRec.CreatedBy.AccountId);
                                                     }
                                                 }
        if(!mrShareMap.isEmpty()) {
            System.debug('######After Update mrShareMap######' + mrShareMap);
            partnerSharingHelper.shareToExecutiveRoles(mrShareMap);
        }
    }      
    public void afterDelete(Map<Id, SObject> oldItems){}
    public void afterUndelete(Map<Id, SObject> oldItems){}
}