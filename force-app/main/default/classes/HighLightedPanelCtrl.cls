public class HighLightedPanelCtrl {
    
    @AuraEnabled
    public static sObject getHighLightedFields (Id recId, String fieldSetName){
        return Database.query(GlobalUtility.fetchQueryByFieldSet(recId, fieldSetName));
    }
    
}