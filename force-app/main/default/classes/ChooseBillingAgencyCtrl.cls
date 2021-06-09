public class ChooseBillingAgencyCtrl {
    @AuraEnabled
    public static List<Opportunity> getHostAndSubAccDetails(String oppID) {
        List<Opportunity> oppWithSubAccs = [SELECT ID,Account.Name,CDH_Account__r.Name,CDH_Account__r.RecordType.DeveloperName,Account.FTE__c,Account.RecordType.DeveloperName,
                                            Purchasing_Entity__r.Name,Purchasing_Entity__r.RecordType.DeveloperName,(SELECT ID,Sub_Account__r.Name,Sub_Account__r.RecordType.DeveloperName,
                                                                                                                     MCN_Account__r.Name,FTE__c,Create_Quote__c,
                                                                                                                     Billing_Agency__r.Name FROM Opportunity_Agency__r) 
                                            FROM Opportunity WHERE Id=:oppID];
        return oppWithSubAccs;
    }
    
    @AuraEnabled
    public static List<Account> getMCNAccs(Map<String,String> accIDMap) {
        List<Account> AccsList = [SELECT Name,Motorola_Customer_Number__c,BillingStreet,BillingCity,BillingState,BillingCountry,
                                  Payment_Term__c,Primary_Route_to_Market__c FROM Account WHERE ID IN :accIDMap.keySet()];
        return AccsList;
    }
    @AuraEnabled
    public static String saveOppSubAccRecords(String selectedHostId,List<String> selectedSubAccIDList,String selectedBillingEntity) {
        String message = '';
        System.debug('IDs from helper..'+selectedHostId+'**'+selectedSubAccIDList+'**'+selectedBillingEntity);
        List<SObject> recsToUpdate = new List<SObject>();
        if(selectedBillingEntity != NULL) {
            if(String.isNotBlank(selectedHostId)){
                Opportunity opp = [SELECT ID FROM Opportunity WHERE ID = :selectedHostId];
                opp.Purchasing_Entity__c = selectedBillingEntity; 
                recsToUpdate.add(opp);
            }
            if(!selectedSubAccIDList.isEmpty()){
                List<SubAgency__c> subAccList = [SELECT ID FROM SubAgency__c WHERE ID IN :selectedSubAccIDList];
                if(!subAccList.isEmpty()){
                    for(SubAgency__c subAcc : subAccList){
                    subAcc.Billing_Agency__c = selectedBillingEntity;
                    //subAccList.add(subAcc);
                }
                    recsToUpdate.addAll(subAccList);  
                }
                
            }
        }
        if(!recsToUpdate.isEmpty()) {
            System.debug('Recs to update...'+recsToUpdate);
            Database.SaveResult[] srList = Database.update(recsToUpdate,false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {        
                    for(Database.Error err : sr.getErrors()) {
                        message = err.getMessage();
                        System.debug('Error Message..'+message);
                    }
                } else {
                    message = 'Succesfully updated';
                }
                
            }
                   }
         return message;
    }
    }