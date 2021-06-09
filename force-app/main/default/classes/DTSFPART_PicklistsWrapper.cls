public class DTSFPART_PicklistsWrapper {
    
    public class PicklistWrapper {
        @AuraEnabled
        public List<Values> values {get;set;}
        @AuraEnabled
        public String eTag {get;set;}
        @AuraEnabled
        public String defaultValue {get;set;}
        @AuraEnabled
        public Map<String, Integer> controllerValues {get;set;}
    }

    public class Values {
        @AuraEnabled
        public String attributes {get;set;}
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
        @AuraEnabled
        public List<Integer> validFor {get;set;}
    }
}