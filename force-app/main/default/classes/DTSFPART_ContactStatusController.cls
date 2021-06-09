public class DTSFPART_ContactStatusController {
    
    public class contactWrapper{
        @AuraEnabled
        public String enterpriseStatus{get;set;}
        @AuraEnabled
        public String status{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static contactWrapper getContactStatus(String currentRecordId){
        contactWrapper wrapperInstance = new contactWrapper();
        List<Contact> contactRecords = [Select Id, Name, Enterprise_Permission_Status__c,Status__c from Contact Where 
                                        Id = :currentRecordId];
        if(!contactRecords.isEmpty()){
            wrapperInstance.enterpriseStatus = contactRecords.get(0).Enterprise_Permission_Status__c;
            wrapperInstance.status = contactRecords.get(0).Status__c;
        }                          
        return wrapperInstance;
    }
}