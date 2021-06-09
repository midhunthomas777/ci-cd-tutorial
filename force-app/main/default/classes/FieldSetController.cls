public class FieldSetController {
    
    @AuraEnabled
    public static ParentWrapper findParentId(Id currentRecord, String parentObject) {
        String sObjectName = currentRecord.getSObjectType().getDescribe().getName();
        String returnString = '';
        List<SObject> records = (List<SObject>)Database.query('SELECT '+parentObject+' FROM '+sObjectName+' WHERE Id = \''+currentRecord+'\'');
        if(!records.isEmpty() && sObjectName != 'ProcessInstanceWorkitem') {
            returnString = (String)records.get(0).get(parentObject);
        } else {
            SObject PI = records.get(0).getSObject('ProcessInstance');
            returnString = (String) PI.get('TargetObjectId');
        }
        
        Id parentId = returnString;
        String objectAPIName = parentId.getSObjectType().getDescribe().getName();
        system.debug('####objectAPIName##### => ' + objectAPIName);
        return new ParentWrapper(parentId, objectAPIName, objectAPIName.toLowerCase());
    }
    
    @AuraEnabled
    public static List<String> readFieldSet(String fieldSetName, String ObjectName) {
        List<String> fields = new List<String>();
        for(Schema.FieldSetMember fieldMember : GlobalUtility.readFieldSet(fieldSetName, ObjectName)) {
            fields.add(fieldMember.getFieldPath());
        }
        return fields;
    }
    
    public class ParentWrapper {
        @AuraEnabled
        public String parentId{get;set;}
        @AuraEnabled
        public String objectAPIName{get;set;}
        @AuraEnabled
        public String lowerCaseName{get;set;}        
        public ParentWrapper(String parentId, String objectAPIName, String lowerCaseName) {
            this.parentId = parentId;
            this.objectAPIName = objectAPIName;
            this.lowerCaseName = lowerCaseName;
        }
    }
}