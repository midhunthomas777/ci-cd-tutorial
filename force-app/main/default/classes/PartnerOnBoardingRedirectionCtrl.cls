public class PartnerOnBoardingRedirectionCtrl {
    @AuraEnabled
    public static void generateAccessCode(string partnerEmpowerId){
        try{
            String accessCode= new Uuid().getValue();
            if(String.isNotBlank(accessCode)){
                Empower_Application__c empowerAppln=new Empower_Application__c(Id=partnerEmpowerId,Access_Code__c=accessCode);
                update empowerAppln;  
            }
        }catch(Exception e){
            system.debug('Exception-->'+e.getMessage());
        }
    }
    @AuraEnabled
    public static String getRecordId(string accessCode){
        List<Empower_Application__c> lstApplnEmp=[SELECT Id,Access_Code__c FROM Empower_Application__c WHERE Access_Code__c=:accessCode LIMIT 1];
        if(!lstApplnEmp.isEmpty()){
            return lstApplnEmp.get(0).Id;
        }else{
            return NULL;
        }
    }
}