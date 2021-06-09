public class CloneCaseController {
    
    @AuraEnabled
    public static string isValidated(String caseId){
        system.debug('caseId is#####'+caseId);
        List<Case> lstCase=[SELECT Id,Description,Status,ParentId,AccountId,Account.RecordType.DeveloperName FROM Case WHERE
                            AccountId !=null and Id=:caseId];
        map<String,Alerts_And_Messages__mdt> mapMsg= new map<String,Alerts_And_Messages__mdt>(); 
        for(Alerts_And_Messages__mdt Msgs : [SELECT Message__c,Message_Type__c,DeveloperName,Success_OR_Error_Messages__r.User_Type__c,
                                             Success_OR_Error_Messages__r.Region__c FROM Alerts_And_Messages__mdt WHERE 
                                             Success_OR_Error_Messages__r.DeveloperName='Prospect_Account_Clone_Case'
                                             AND Success_OR_Error_Messages__r.Object_Name__c='Case']){
           		   If(Msgs.Success_OR_Error_Messages__r.User_Type__c=='Partner' && Msgs.Success_OR_Error_Messages__r.Region__c=='NA'){
                          mapMsg.put(Msgs.DeveloperName, Msgs);
                   } 
         }    
        if(!lstCase.isEmpty()){
            List<BigMachines__Quote__c> lstQuote=[SELECT Id FROM BigMachines__Quote__c WHERE BigMachines__Account__c=:lstCase.get(0).accountId];
            if(lstQuote.isEmpty() || lstCase.get(0).Account.RecordType.DeveloperName!='Prospect'){
                return mapMsg.get('Not_Prospect_OR_Not_Having_Quote').Message_Type__c+mapMsg.get('Not_Prospect_OR_Not_Having_Quote').Message__c;
            }
            if(lstCase.get(0).status != 'Closed' && lstCase.get(0).parentId==null){
                return mapMsg.get('Case_Is_Not_Closed').Message_Type__c+mapMsg.get('Case_Is_Not_Closed').Message__c;
            }else if(lstCase.get(0).parentId!=null){
                return mapMsg.get('Can_Not_Clone_a_Child_Case').Message_Type__c+mapMsg.get('Can_Not_Clone_a_Child_Case').Message__c;
            }
            List<Case> childCases=[SELECT Id,parentId FROM case WHERE  parentId=:caseId];
            if(!childCases.isEmpty()){
                return mapMsg.get('Case_Is_Already_Cloned').Message_Type__c+mapMsg.get('Case_Is_Already_Cloned').Message__c;
            }else{
                return mapMsg.get('Case_Cloned_Successfully').Message_Type__c+mapMsg.get('Case_Cloned_Successfully').Message__c;
            }
        }
        return mapMsg.get('Case_Is_Not_Having_Account').Message_Type__c+mapMsg.get('Case_Is_Not_Having_Account').Message__c;
    }
    
    @AuraEnabled
    public static string cloneCase(String caseId){
        List<Case> lstCase=[SELECT Id,Type,Priority,Subject,Description,Status,ParentId,AccountId,RecordTypeID FROM Case WHERE Id=:caseId];
        if(!lstCase.isEmpty()){
            case cs= lstCase.get(0).clone();
            cs.ParentId=lstCase.get(0).Id;
            cs.Status='New';
            cs.Description='Recreated the case';
            try{
                insert cs;
                if(cs.Id!=null){
                    return cs.Id;
                }
            }
            catch(Exception ex){
                return 'Fail';
            }
        }        
        return 'Fail';
    }
}