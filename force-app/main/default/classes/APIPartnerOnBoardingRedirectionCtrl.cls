public class APIPartnerOnBoardingRedirectionCtrl {
    @AuraEnabled
    public static void generateAccessCode(string partnerSDPId){
        try{
            String accessCode= new Uuid().getValue();
            if(String.isNotBlank(accessCode)){
                API_Partner_Application__c sdpAppln = new API_Partner_Application__c(Id=partnerSDPId, Access_Code__c=accessCode);
                update sdpAppln;  
            }
        }catch(Exception e){
            system.debug('Exception-->'+e.getMessage());
        } 
    }
    @AuraEnabled
    public static String getRecordId(string accessCode){
        List<API_Partner_Application__c> listSDPAppl=[SELECT Id, Access_Code__c FROM API_Partner_Application__c WHERE Access_Code__c=:accessCode LIMIT 1];
        if(!listSDPAppl.isEmpty())  return listSDPAppl.get(0).Id;
        else return NULL;        
    }
}