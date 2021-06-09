public class NewCAPPControllerWrapper{
    
    public class DependentPicklistWrapper{
        @AuraEnabled
        public String validFor;
    }
    
    public class picklistMapping{
        @AuraEnabled
        public List<PicklistWrapper> picklistValues{get;set;}
        @AuraEnabled
        public Boolean isFieldDisable{get;set;} 
        public picklistMapping(List<PicklistWrapper> picklistValues, Boolean isFieldDisable) {
            this.picklistValues = picklistValues;
            this.isFieldDisable = isFieldDisable;
        }        
    }
    
    public class PicklistWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        public PicklistWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }        
    }
    
    public class CAPPS{
        @AuraEnabled
        public String sectionName{get;set;}
        @AuraEnabled
        public String currentRecordId{get;set;}
        @AuraEnabled
        public String currentObjName{get;set;}
        @AuraEnabled
        public String recordID{get;set;}
        @AuraEnabled
        public List<CAPPRecords> fields{get;set;}
    }
    
    public class CAPPRecords{
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
        @AuraEnabled
        public String fieldValue{get;set;}
    }
    public class FieldSetMemberWrapper{
        @AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
        @AuraEnabled
        public String fieldLabel{get;set;}
        @AuraEnabled
        public String fieldHelp{get;set;}
        @AuraEnabled
        public String fieldValue{get;set;}
        @AuraEnabled
        public Boolean isReadOnly{get;set;}
        @AuraEnabled
        public String vendorValue{get;set;}
        @AuraEnabled
        public Boolean isFormula{get;set;}
        @AuraEnabled
        public String systemRelationAccount{get;set;}
        @AuraEnabled
        public List<picklistMapping> pickValues{get;set;} 
        public FieldSetMemberWrapper(String fieldName,String fieldType,String fieldLabel,String fieldHelp, 
                                     List<picklistMapping> pickValues,String fieldValue,String vendorValue,
                                     String systemRelationAccount,Boolean isReadOnly,Boolean isFormula) 
        {
            this.fieldName	  		   = fieldName;
            this.fieldType 	  		   = fieldType;
            this.fieldLabel     	   = fieldLabel;
            this.fieldHelp      	   = fieldHelp;
            this.pickValues     	   = pickValues;
            this.fieldValue	    	   = fieldValue;
            this.vendorValue  		   = vendorValue;
            this.systemRelationAccount = systemRelationAccount;
            this.isReadOnly	   		   = isReadOnly;
            this.isFormula			   = isFormula;
        }        
    }
}