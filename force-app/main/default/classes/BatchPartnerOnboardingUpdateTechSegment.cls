global class BatchPartnerOnboardingUpdateTechSegment implements Database.Batchable<sObject> {
    global Id partnerAccountId = GlobalUtility.getRecordTypeIdByDeveloperName('Account', 'Partner');
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        return Database.getQueryLocator([SELECT Id,Partner_Technology_Segments__c, (SELECT Id,Account__c,Technology_Specialization_Status__c,
                                                                                    Technology_Specialization__c FROM Technology_Specializations__r WHERE Technology_Specialization_Status__c='Active') FROM Account
                                         WHERE recordTypeId=:partnerAccountId AND Partner_Technology_Segments__c = null]);        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        List<Technology_Specialization__c> programDataList= new List<Technology_Specialization__c>();
        Map<String,Set<String>> programDetailMap=new Map<String,Set<String>>();
        List<String> technologyValues=new List<String>();
        List<Account> accountToUpdate = new List<Account>();
        for(Account accData:accList){
            for(Technology_Specialization__c programData: accData.Technology_Specializations__r){
                if(programDetailMap.containsKey(programData.Account__c)){
                    Set<String> techList=programDetailMap.get(programData.Account__c);
                    techList.add(programData.Technology_Specialization__c);
                    programDetailMap.put(programData.Account__c,techList);
                }else{
                    programDetailMap.put(programData.Account__c,new Set<String>{programData.Technology_Specialization__c});
                }
            }             
            if(!programDetailMap.isEmpty()){
                accData.Partner_Technology_Segments__c=String.join(new List<String>(programDetailMap.get(accData.Id)),';');
                accountToUpdate.add(accData);
            }            
        }
        
        if(!accountToUpdate.isEmpty()){
            update accountToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}