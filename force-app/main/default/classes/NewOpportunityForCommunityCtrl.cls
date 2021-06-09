public class NewOpportunityForCommunityCtrl{
    
    @AuraEnabled
    public static Map<String,String> fetchAccessibleRecordTypes(){
        Map<String,String> recordTypeMap = new Map<String,String>();
        
        for(RecordTypeInfo info: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
            System.debug('####info###'+info);
            if(info.isAvailable() && !info.isMaster() ) {
                recordTypeMap.put(info.getRecordTypeId(), info.getName()); 
            }
        }
        return recordTypeMap;
    }
    
    @AuraEnabled      
    public static Boolean isPartnerUser() {
        return GlobalUtility.isLoggedinPartnerUser();
    } 
    
}