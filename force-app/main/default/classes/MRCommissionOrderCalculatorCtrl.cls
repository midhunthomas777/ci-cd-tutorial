public class MRCommissionOrderCalculatorCtrl {
    
    @AuraEnabled   
    public static map<String,List<String>> getFieldSets(){
        System.debug('getFieldSets####>');
        Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.MR_Commission_Calculator__c.fieldSets.getMap();
        List<Schema.FieldSet> lstField= new List<Schema.FieldSet>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get('MR_Commission_Calculator__c');
        Map<String,List<String>> mapFieldSet = new Map<String,List<String>>();
         System.debug('FsMap.keyset()####>' + FsMap.keyset());
        for(String fieldSetName : FsMap.keyset()) {
            List<String> lstFieldApi =new List<String>();
            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
                lstFieldApi.add(fieldMember.getFieldPath());
            }
            mapFieldSet.put(fieldSetName, lstFieldApi);
        }
        return mapFieldSet;
    }
    
    
    @AuraEnabled
    public static String fetchSitePrefix(){
        return CPQUtility.fetchSitePrefix();
    }
    
    @AuraEnabled
    public static Boolean isCCMR(String partnerID){
        system.debug('partnerID is###########################'+partnerID);
        List<Contact> contact= [SELECT Account.Partner_Community_Types__c FROM Contact WHERE User__c!=null AND AccountId=:partnerID];
        system.debug('contact.size is###########################'+contact.size());
		//SF-2219-Vesta Changes
        //if(contact.size()>0 && contact.get(0).Account.Partner_Community_Types__c.contains('CallWorks')){
        if(contact.size()>0 && contact.get(0).Account.Partner_Community_Types__c.contains('Command Central NG911')){
            return true;
        }
        else if(true){
            List<User> usr=[SELECT Id from User WHERE Id=:UserInfo.getUserId() AND AccountID = null];
            if(usr.size()>0){
                return true;
            }else{
                return false; 
            }
        }
        else{
            return false; 
        }
    }
}