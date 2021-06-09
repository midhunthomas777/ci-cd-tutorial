public without sharing class NewOpportunityCtrl {
    
    @AuraEnabled
    public static String getUserTheme(){
        return GlobalUtility.userTheme();
    }
    
    @AuraEnabled
    public static String fetchOpportunityAccess() {     
        Map<String, Alerts_And_Messages__mdt> alertMessageMap = GlobalUtility.metaMessagesMap(null, 'New_Opportunity');
        if(!Schema.sObjectType.Opportunity.isCreateable()){
            return alertMessageMap.get('Insufficient_Privileges').Message__c;
        }else{
            return '';
        }
    }
    
    @AuraEnabled
    public static List<Sobject> getMCN(String recId){
        return MRCPQ_ProceedToQuoteController.getMCN(recId);
    }
    
    @AuraEnabled
    public static String cloneRecords(List<String> userSelectedChildAPIs, String originalRecId, String functionality, Opportunity newRec) {
        Savepoint sp = Database.setSavepoint();
        try{
            insert newRec;
            UtilsDeeperClone.cloneFuture(ID.valueOf(originalRecId),newRec.Id, userSelectedChildAPIs);
            return newRec.Id;
        }catch(Exception ex){
            Database.rollback(sp);
            return 'Error'+ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static Map<String, String> fetchCustomerAccount(Id originalRecId, String functionality,Boolean isClone) {
        Map<String, String> oppAPIAccValMap = new Map<String, String>();
        Opportunity dbOpportunity =new Opportunity();
        Account dbAccount = new Account();
        List<Clone_Framework_Child__mdt> metaList = [Select Child_Object_API__c,Order__c,Parent_Relationship_API_Name__c from Clone_Framework_Child__mdt 
                                                     where Clone_Framework__r.DeveloperName =: functionality order by Order__c ASC];
        List<String> parentObjectFields = new List<String>();
        for(Clone_Framework_Child__mdt meta : metaList)  {
            if(isClone){
                parentObjectFields.add(meta.Child_Object_API__c );
            }else{
                parentObjectFields.add(meta.Parent_Relationship_API_Name__c);
            }
        }
        if(isClone){
            dbOpportunity = Database.query('Select '+ String.join(parentObjectFields, ',') +' from Opportunity where Id =: originalRecId');
        }else{
            dbAccount = Database.query('Select '+ String.join(parentObjectFields, ',') +' from Account where Id =: originalRecId');
        }
        for(Clone_Framework_Child__mdt meta : metaList) {
            if(isClone){
                if(String.isNotBlank(String.valueOf(dbOpportunity.get(meta.Child_Object_API__c))) ){
                    oppAPIAccValMap.put(meta.Child_Object_API__c, String.valueOf(dbOpportunity.get(meta.Child_Object_API__c)));
                } else {
                    oppAPIAccValMap.put(meta.Child_Object_API__c, '');
                }
            }else{
                if(String.isNotBlank(String.valueOf(dbAccount.get(meta.Parent_Relationship_API_Name__c))) ){
                    oppAPIAccValMap.put(meta.Child_Object_API__c, String.valueOf(dbAccount.get(meta.Parent_Relationship_API_Name__c)));
                } else {
                    oppAPIAccValMap.put(meta.Child_Object_API__c, '');
                }
            }
        }
        return oppAPIAccValMap;
    }
    
    @AuraEnabled
    public static Map<String, Alerts_And_Messages__mdt> getMetaMessages(String metaName) {
        return GlobalUtility.metaMessagesMap(NULL, metaName);
    }
    
    public class FieldSetMember {        
        public FieldSetMember(Schema.FieldSetMember f) {
            this.DBRequired = f.DBRequired;
            this.fieldPath = f.fieldPath;
            this.label = f.label;
            this.required = f.required;
            this.type = '' + f.getType();
        }        
        public FieldSetMember(Boolean DBRequired) {
            this.DBRequired = DBRequired;
        }        
        @AuraEnabled
        public Boolean DBRequired { get;set; }        
        @AuraEnabled
        public String fieldPath { get;set; }        
        @AuraEnabled
        public String label { get;set; }        
        @AuraEnabled
        public Boolean required { get;set; }        
        @AuraEnabled
        public String type { get; set; }
    }
    
    @AuraEnabled
    public static Map<String,List<FieldSetMember>> getFieldSets(String objectName) {
        Map<String,List<FieldSetMember>> mapFieldSet = new Map<String,List<FieldSetMember>>();        
        Schema.FieldSet fs1 = Schema.SObjectType.Opportunity.fieldSets.NewCloneOpportunityLeftUI;       
        List<FieldSetMember> fset1 = new List<FieldSetMember>();
        for(Schema.FieldSetMember fieldMember : fs1.getFields()) {
            fset1.add(new FieldSetMember(fieldMember));
        }
        mapFieldSet.put('NewCloneOpportunityLeftUI', fset1);
        
        Schema.FieldSet fs2 = Schema.SObjectType.Opportunity.fieldSets.NewCloneOpportunityRightUI;        
        List<FieldSetMember> fset2 = new List<FieldSetMember>();
        for(Schema.FieldSetMember fieldMember : fs2.getFields()) {            
            fset2.add(new FieldSetMember(fieldMember));
        }
        mapFieldSet.put('NewCloneOpportunityRightUI', fset2);
        return mapFieldSet;
    }
    //SF-2699
    @AuraEnabled
    public static Map<String, List<AddressCtrl.AddressDef>> getOpportunityRegionTerritory(String objName,String controllingField,String dependentField,Boolean isStd){
        return AddressCtrl.getFieldDependencies(objName,controllingField,dependentField,isStd);
    }
    //SF-2699
    @AuraEnabled
    public static List<Sobject> getAccRegionTerritory(String recId){ 
        System.debug('Ctrl recId===>' +recId);
        if(recId.startsWith('001')){
            List<Account> lstAccs = [SELECT Region__c,Territory__c FROM Account WHERE Id =: recId];
            if(!lstAccs.isEmpty()){
                system.debug('lstAccsTerritory__c==>' + lstAccs[0].Territory__c);
                system.debug('lstAccsRegion__c==>' + lstAccs[0].Region__c);
                return lstAccs;
            }
        }
        return null;
    }
}