public class GenericFieldSetController {
    @AuraEnabled
    public static FieldSetForm getForm(String objectName, String fieldSetName) {
        FieldSetForm form = new FieldSetForm();
        if(!String.isBlank(fieldSetName)){
            form.fields.addAll(getFields(objectName,fieldSetName));
        }
        return form;
    }
    
    public static List<Field> getFields(String objectName, String fieldSetName) {
        List<Field> fields = new List<Field>();
        Map<string,FieldSetMetadata__mdt> fieldSetMap=new Map<string,FieldSetMetadata__mdt>();
        for(FieldSetMetadata__mdt fsm : [Select MasterLabel,Description__c,Type_of_Field__c FROM FieldSetMetadata__mdt WHERE Object_Name__c=:objectName]){
            fieldSetMap.put(fsm.MasterLabel,fsm);
        }
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        for (Schema.FieldSetMember fsm : GlobalUtility.readFieldSet(fieldSetName, objectName)) {
            Map<String, SObjectField> fieldsMap = sObj.getDescribe().fields.getMap();
            SObjectField fieldToken = fieldsMap.get(fsm.getFieldPath());
            DescribeFieldResult selectedField = fieldToken.getDescribe();
            FieldSetMetadata__mdt dbMeta = fieldSetMap.get(fsm.fieldPath);
            if(dbMeta != NULL){
                fields.add(new Field(fsm,selectedField,dbMeta.Description__c,TRUE, dbMeta.Type_of_Field__c));
            } else {
                fields.add(new Field(fsm,selectedField,'',FALSE, NULL));
            }
        } 
        return fields;
    }
    public class FieldSetForm {
        @AuraEnabled public List<Field> fields;
        public FieldSetForm() {
            fields = new List<Field>();
        }
    }
    public class Field {
        @AuraEnabled public Boolean dbRequired;
        @AuraEnabled public String apiName;
        @AuraEnabled public String label;        
        @AuraEnabled public Boolean required;
        @AuraEnabled public String type;
        @AuraEnabled public String helpText;
        @AuraEnabled public String description;
        @AuraEnabled public Boolean isCustomLabel;   
        @AuraEnabled public String fieldType;
        public Field(Schema.FieldSetMember fldMem, DescribeFieldResult describeField,String description,Boolean isCustomLabel,String fieldType) {
            this.dbRequired = fldMem.DBRequired;
            this.apiName = fldMem.fieldPath;
            this.label = fldMem.label;
            this.required = fldMem.required;
            this.type = String.valueOf(fldMem.getType());
            this.helpText = describeField.getInlineHelpText();
            this.description=description;
            this.isCustomLabel=isCustomLabel;
            this.fieldType=fieldType;
        }
        public Field(Boolean DBRequired) {
            this.DBRequired = DBRequired;
        }
    }
    @AuraEnabled 
    public static String fetchUser(){ 
        List<User> userList = [SELECT Selected_User_Theater__c FROM User WHERE Id =: userInfo.getUserId()];
        if(!userList.isEmpty()){
            return userList.get(0).Selected_User_Theater__c;
        }else{
            return NULL;
        }
    }
}