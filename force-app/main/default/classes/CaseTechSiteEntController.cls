public class CaseTechSiteEntController {
    
    @AuraEnabled
    public static String fetchTechSiteEntitlements(String decision,String caseRecordId) {
        String response = '';
        List<Case> caseRecord = [SELECT Id, Technical_Site__r.Site_ID__c, Serial__c FROM Case WHERE Id = :caseRecordId LIMIT 1];
        if(!caseRecord.isEmpty()){
            String techSiteId = caseRecord[0].Technical_Site__r.Site_ID__c;
            String serialNum = caseRecord[0].Serial__c;
            String param = '';
            String muleAPI = '';
            
            if( string.isNotBlank(techSiteId) &&  decision == 'SITE'){
                param = techSiteId;
                muleAPI = 'TechSiteEntitlement';
            } else if(string.isNotBlank(serialNum)  &&  decision == 'SERIAL'){
                param = serialNum;
                muleAPI = 'SerialEntitlement';
            }
            system.debug('##param##'+param);
            system.debug('##muleAPI##'+muleAPI);
            if(string.isNotBlank(techSiteId) || string.isNotBlank(serialNum)){
                HTTPAPIResponse res = MulesoftHelper.callMuleByMetadata(param, NULL,  muleAPI, 'Mulesoft');
                System.debug('res*****'+res);
                if(res.responseStatus == 200 || res.responseStatus == 201) {
                    return res.response.getBody();
                } else if(string.isBlank(techSiteId)) {
                    response = 'NOTECHSITE';
                } else if(string.isBlank(serialNum)) {
                    response = 'NOSERIALNUMBER';
                } else {
                    return 'APIError';
                }    
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static String updateCase(String caseRecordId, String contractNumber){
        try{
            update new Case (Id = caseRecordId, Contract__c = contractNumber);
            return '200';
        } catch(Exception ex){
            return '500';
        }
    }
}