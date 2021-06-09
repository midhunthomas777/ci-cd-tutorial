public class AccountCAPPAndSRHierarchyController {
    
    public class AccountResponseWrapper{
        @AuraEnabled
        public List<AccountWrapper> finalData{get;set;}
        @AuraEnabled
        public List<String> expandedRows{get;set;}
        public AccountResponseWrapper(List<AccountWrapper> finalData, List<String> expandedRows){
            this.finalData = finalData;
            this.expandedRows = expandedRows;
        }
    }
    public Class AccountWrapper{
        @AuraEnabled
        public List<FieldsWrapper> fieldList {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }
    public Class Items{
        @AuraEnabled
        public List<FieldsWrapper> fieldList {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }
    public Class FieldsWrapper{
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public String fieldLabel {get;set;}
        @AuraEnabled
        public String fieldType {get;set;}
        @AuraEnabled
        public String fieldValue {get;set;}
        @AuraEnabled
        public String referenceName {get;set;}
        @AuraEnabled
        public String referenceValue {get;set;}
    }
    
    @AuraEnabled
    public static AccountResponseWrapper getFieldsData(String accountId){
        List<String> accFieldsList,cappFieldsList,srFieldsList;
        List<String> expandedRows = new List<String>();
        Map<Id,List<System_Relationship__c>> cappIdWithSRRecordsMap = new Map<Id,List<System_Relationship__c>>();
        Map<Id,List<System_Relationship__c>>  parentAndChildSRRecMap = new Map<Id,List<System_Relationship__c>>();
        //List<System_Relationship__c> firstLevelParentAndChildSRList = new List<System_Relationship__c>();
        Set<Id> cappIdSet = new Set<Id>();
        List<Customer_Portfolio_Presence__c> cappRecordsList = new List<Customer_Portfolio_Presence__c>();
        //Set<Id> firstLevelParentSRIds = new Set<Id>();
        List<AccountWrapper> finalWrapperList = new List<AccountWrapper>();
        Map<String, SObjectField> fieldsSRSchemaMap = Schema.getGlobalDescribe().get('System_Relationship__c').getDescribe().fields.getMap();
        Map<String, SObjectField> fieldsCAPPSchemaMap = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().fields.getMap();
        Map<String, SObjectField> fieldsAccountSchemaMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
        
        for(MR_Digitization_Settings__mdt eachRecord : [Select Field_Names__c,SObject__c FROM MR_Digitization_Settings__mdt])
        {
            if(eachRecord.SObject__c == 'Account'){
                accFieldsList = eachRecord.Field_Names__c.split(',');
                for(String field : accFieldsList){
                    if(fieldsAccountSchemaMap.get(field).getDescribe().getType().equals('REFERENCE')){
                        accFieldsList.add(fieldsAccountSchemaMap.get(field).getDescribe().getName().substringBefore('__c')+'__r.Name');
                    }
                } 
            }
            if(eachRecord.SObject__c == 'Customer_Portfolio_Presence__c'){
                cappFieldsList = eachRecord.Field_Names__c.split(',');
                for(String field : cappFieldsList){
                    if(fieldsCAPPSchemaMap.get(field).getDescribe().getType().equals('REFERENCE')){
                        cappFieldsList.add(fieldsAccountSchemaMap.get(field).getDescribe().getName().substringBefore('__c')+'__r.Name');
                    }
                }
            }
            if(eachRecord.SObject__c == 'System_Relationship__c'){
                srFieldsList = eachRecord.Field_Names__c.split(',');
                List<String> tempSRFieldsList = new List<String>();
                for(String field : srFieldsList){
                    if(String.valueOf(fieldsSRSchemaMap.get(field).getDescribe().getType()).equals('REFERENCE')){
                        tempSRFieldsList.add(fieldsSRSchemaMap.get(field).getDescribe().getName().substringBefore('__c')+'__r.Name');
                    } 
                }
                srFieldsList.addAll(tempSRFieldsList);
            }
        }
        //String query = 'SELECT '+String.join(accFieldsList,',')+', (SELECT ' + String.join(srFieldsList,',') +
        //' FROM System_Relationships__r) FROM ACCOUNT WHERE ID = :accountId';
        String accQuery = 'SELECT '+String.join(accFieldsList,',')+', (SELECT CAPP__c FROM System_Relationships__r) FROM ACCOUNT WHERE ID = :accountId';   
        List<Account> accWithCappIdList = Database.query(accQuery);
        for(System_Relationship__c srRecord : accWithCappIdList[0].System_Relationships__r) {
            cappIdSet.add(srRecord.CAPP__c);
        }
        System.debug('cappidset..'+cappIdSet);
        String CAPPQuery = 'SELECT '+String.join(cappFieldsList,',')+', (SELECT ' + String.join(srFieldsList,',') +
            ' FROM System_Relationships__r) FROM customer_portfolio_presence__c WHERE ID = :cappIdSet';
        List<Customer_Portfolio_Presence__c> cappWithSRsList = Database.query(CAPPQuery);
        Integer counter = 0;
        for(Integer i=0;i<cappWithSRsList.size();i++) {
            for(System_Relationship__c SRRecord : cappWithSRsList[i].System_Relationships__r) {
                if(SRRecord.System_Parent__c != null) {
                    if(parentAndChildSRRecMap.containsKey(SRRecord.System_Parent__c)) {
                        List<System_Relationship__c> SRRecordsList = parentAndChildSRRecMap.get(SRRecord.System_Parent__c); 
                        SRRecordsList.add(SRRecord);
                        //firstLevelParentSRIds.add(srRecord.System_Parent__c);
                        parentAndChildSRRecMap.put(SRRecord.System_Parent__c, SRRecordsList);
                    } else {
                        //firstLevelParentSRIds.add(srRecord.System_Parent__c);
                        parentAndChildSRRecMap.put(SRRecord.System_Parent__c,  new List<System_Relationship__c>{SRRecord});
                    }
                }
            }
        }
        
        for(Account acc : accWithCappIdList){
            AccountWrapper accountWrapInstance = new AccountWrapper();
            List<FieldsWrapper> parentFieldWrapperList = new List<FieldsWrapper>();
            FieldsWrapper accountFieldWrap = new FieldsWrapper();
            accountFieldWrap.fieldValue = acc.Name;
            accountFieldWrap.fieldType  = 'STRING';
            accountFieldWrap.fieldName  = 'genericName';
            accountFieldWrap.fieldLabel = 'GenericName';
            parentFieldWrapperList.add(accountFieldWrap);
            for(String eachField : accFieldsList){
                if(!eachField.contains('__r') && eachField != 'Id'){
                    FieldsWrapper fieldWrap = new FieldsWrapper();
                    DescribeFieldResult fieldDescription = fieldsAccountSchemaMap.get(eachField).getDescribe();
                    if(fieldDescription.isAccessible()) {
                    object value = acc.get(fieldDescription.getName());
                    fieldWrap.fieldValue = value == null?'':String.valueOf(value);
                    fieldWrap.fieldType = String.valueOf(fieldDescription.getType());
                    fieldWrap.fieldName = fieldDescription.getName();
                    fieldWrap.fieldLabel = fieldDescription.getLabel();
                    fieldWrap.referenceName = '';
                    if(fieldDescription.getType().equals('REFERENCE') && String.isNotBlank(fieldWrap.fieldValue)){
                        fieldWrap.fieldValue = '/'+fieldWrap.fieldValue;
                        String relationShipField;
                        if(fieldDescription.isCustom()){
                            relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                        }else{
                            relationShipField = fieldWrap.fieldName.substringBefore('Id');
                        }
                        fieldWrap.referenceName = String.valueOf(acc.getSObject(relationShipField).get('Name'));
                    } else {
                        fieldWrap.referenceName = ''; 
                        fieldWrap.referenceValue = ''; 
                    }
                    parentFieldWrapperList.add(fieldWrap);
                    }
                }
            }
            expandedRows.add(acc.Name);
            accountWrapInstance.fieldList = parentFieldWrapperList;
            List<Items> childCAPPRecords = new List<Items>();
            if(counter < cappWithSRsList.size()) {
                for(Customer_Portfolio_Presence__c eachRecord : cappWithSRsList){
                    Items childCAPPItem = new Items();
                    List<FieldsWrapper> cappFieldsWrapList = new List<FieldsWrapper>();
                    FieldsWrapper cappFieldWrap = new FieldsWrapper();
                    cappFieldWrap.fieldValue = eachRecord.Name;
                    cappFieldWrap.fieldType  = 'STRING';
                    cappFieldWrap.fieldName  = 'genericName';
                    cappFieldWrap.fieldLabel = 'GenericName';
                    cappFieldsWrapList.add(cappFieldWrap);
                    for(String eachField : cappFieldsList){
                        if(!eachField.contains('__r') && eachField !='Id'){
                            FieldsWrapper fieldWrap = new FieldsWrapper();
                            DescribeFieldResult fieldDescription = fieldsCAPPSchemaMap.get(eachField).getDescribe();
                            if(fieldDescription.isAccessible()) {
                            fieldWrap.fieldName = fieldDescription.getName();
                            fieldWrap.fieldLabel = fieldDescription.getLabel();
                            object value = eachRecord.get(fieldDescription.getName());
                            fieldWrap.fieldValue = value == null?'':String.valueOf(value);
                            fieldWrap.fieldType = String.valueOf(fieldDescription.getType());
                            if(fieldDescription.getName() == 'Name') {
                                fieldWrap.fieldName = 'cappName';
                                fieldWrap.referenceName = 'cappName__r';
                                fieldWrap.referenceValue = fieldWrap.fieldValue;
                                fieldWrap.fieldValue = '/'+eachRecord.Id;
                            } else if(!fieldWrap.fieldType.equals('REFERENCE')){
                                fieldWrap.referenceName = '';
                                fieldWrap.referenceValue = '';
                            }else if(fieldWrap.fieldType.equals('REFERENCE')){
                                String relationShipField;
                                if(fieldDescription.isCustom()){
                                    relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                    fieldWrap.referenceName = relationShipField;
                                }else{
                                    relationShipField = fieldWrap.fieldName.substringBefore('Id');
                                    fieldWrap.referenceName = relationShipField;
                                }
                                if(String.isNotBlank(fieldWrap.fieldValue)) {
                                    fieldWrap.fieldValue = '/'+fieldWrap.fieldValue;
                                    fieldWrap.referenceValue = String.valueOf(eachRecord.getSObject(relationShipField).get('Name'));
                                }else{
                                    fieldWrap.referenceValue ='';
                                }
                            }
                            cappFieldsWrapList.add(fieldWrap);
                            }
                        }
                    }
                    
                    expandedRows.add(eachRecord.Name);
                    childCAPPItem.fieldList = cappFieldsWrapList;
                    List<Items> grandChildSRItemsList = new List<Items>();
                    //if(!cappIdWithSRRecordsMap.isEmpty()) {
                    List<System_Relationship__c> existingSRList = cappWithSRsList[counter].System_Relationships__r;
                    
                    if(!existingSRList.isEmpty()) {
                        for(System_Relationship__c SRRecord : existingSRList) {
                            if(SRRecord.System_Parent__c == null) {	
                                Items grandChildSRItem = new Items();
                                List<FieldsWrapper> SRFieldsWrapList = new List<FieldsWrapper>();
                                FieldsWrapper SRFieldWrap = new FieldsWrapper();
                                SRFieldWrap.fieldValue = SRRecord.Name;
                                SRFieldWrap.fieldType  = 'STRING';
                                SRFieldWrap.fieldName  = 'genericName';
                                SRFieldWrap.fieldLabel = 'GenericName';
                                SRFieldsWrapList.add(SRFieldWrap);
                                for(String eachField : srFieldsList){
                                    if(!eachField.contains('__r') && eachField != 'CAPP__c' && eachField !='Id'){
                                        FieldsWrapper fieldWrap = new FieldsWrapper();
                                        DescribeFieldResult fieldDescription = fieldsSRSchemaMap.get(eachField).getDescribe();
                                        if(fieldDescription.isAccessible()) {
                                        fieldWrap.fieldName = fieldDescription.getName();
                                        fieldWrap.fieldLabel = fieldDescription.getLabel();
                                        object value = SRRecord.get(fieldDescription.getName());
                                        fieldWrap.fieldValue = value == null?'':String.valueOf(value);
                                        fieldWrap.fieldType = String.valueOf(fieldDescription.getType());
                                        if(fieldDescription.getName() == 'Name') {
                                            fieldWrap.fieldName = 'SR Name';
                                            fieldWrap.referenceName = 'SRName__r';
                                            fieldWrap.referenceValue = fieldWrap.fieldValue;
                                            fieldWrap.fieldValue = '/'+SRRecord.Id;
                                        }else if(fieldDescription.getName() == 'Account__c') {
                                            fieldWrap.fieldLabel = 'System Relationship Account'; 
                                        } if(fieldDescription.getName() != 'Name') {
                                            if(!fieldWrap.fieldType.equals('REFERENCE')){
                                            fieldWrap.referenceName = '';
                                            fieldWrap.referenceValue = '';
                                        }else if(fieldWrap.fieldType.equals('REFERENCE')){
                                            String relationShipField;
                                            if(fieldDescription.isCustom()){
                                                relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                                fieldWrap.referenceName = relationShipField;
                                            }else{
                                                relationShipField = fieldWrap.fieldName.substringBefore('Id');
                                                fieldWrap.referenceName = relationShipField;
                                            }
                                            if(String.isNotBlank(fieldWrap.fieldValue)) {
                                                fieldWrap.fieldValue = '/'+fieldWrap.fieldValue;
                                                fieldWrap.referenceValue = String.valueOf(SRRecord.getSObject(relationShipField).get('Name'));
                                            }else{
                                                fieldWrap.referenceValue ='';
                                            }
                                        }
                                        }
                                        SRFieldsWrapList.add(fieldWrap);
                                        }
                                    } 
                                }
                                grandChildSRItem.fieldList = SRFieldsWrapList;
                                List<Items> grandGrandChildSRItemList = new List<Items>();
                                if(parentAndChildSRRecMap.containsKey(SRRecord.Id)) {
                                    expandedRows.add(SRRecord.Name);
                                    List<System_Relationship__c> childSRList = parentAndChildSRRecMap.get(SRRecord.Id);
                                    for(System_Relationship__c childSRRecord : childSRList) {
                                        Items grandGrandChildSRItem = new Items();
                                        List<FieldsWrapper> grandGrandChildSRFieldsWrapList = new List<FieldsWrapper>();
                                        FieldsWrapper grandChildSRfieldWrap = new FieldsWrapper();
                                        grandChildSRfieldWrap.fieldValue = childSRRecord.Name;
                                        grandChildSRfieldWrap.fieldType  = 'STRING';
                                        grandChildSRfieldWrap.fieldName  = 'genericName';
                                        grandChildSRFieldWrap.fieldLabel = 'GenericName';
                                        grandGrandChildSRFieldsWrapList.add(grandChildSRfieldWrap);
                                        for(String eachField : srFieldsList){
                                            if(!eachField.contains('__r') && eachField != 'CAPP__c' && eachField !='Id'){
                                                FieldsWrapper fieldWrap = new FieldsWrapper();
                                                DescribeFieldResult fieldDescription = fieldsSRSchemaMap.get(eachField).getDescribe();
                                                fieldWrap.fieldName = fieldDescription.getName();
                                                fieldWrap.fieldLabel = fieldDescription.getLabel();
                                                object value = childSRRecord.get(fieldDescription.getName());
                                                fieldWrap.fieldValue = value == null?'':String.valueOf(value);
                                                fieldWrap.fieldType = String.valueOf(fieldDescription.getType());
                                                if(fieldDescription.getName() == 'Name') {
                                                    fieldWrap.fieldName = 'SR Name';
                                                    fieldWrap.referenceName = 'SRName__r';
                                                    fieldWrap.referenceValue = fieldWrap.fieldValue;
                                                    fieldWrap.fieldValue = '/'+childSRRecord.Id;
                                                }else if(fieldDescription.getName() == 'Account__c') {
                                                    fieldWrap.fieldLabel = 'System Relationship Account';
                                                }if(fieldDescription.getName() != 'Name') {
                                                if(fieldWrap.fieldType.equals('REFERENCE')){
                                                    String relationShipField;
                                                    if(fieldDescription.isCustom()){
                                                        relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                                        fieldWrap.referenceName = relationShipField;
                                                    }else{
                                                        relationShipField = fieldWrap.fieldName.substringBefore('Id');
                                                        fieldWrap.referenceName = relationShipField;
                                                    }
                                                    if(String.isNotBlank(fieldWrap.fieldValue)) {
                                                        fieldWrap.fieldValue = '/'+fieldWrap.fieldValue;
                                                        fieldWrap.referenceValue = String.valueOf(childSRRecord.getSObject(relationShipField).get('Name'));
                                                    } else{
                                                        fieldWrap.referenceName = relationShipField;
                                                        fieldWrap.referenceValue ='';   
                                                    }
                                                }else {
                                                    fieldWrap.referenceName = '';
                                                    fieldWrap.referenceValue = '';
                                                }
                                                }
                                                grandGrandChildSRFieldsWrapList.add(fieldWrap);
                                            }
                                        }
                                        grandGrandChildSRItem.fieldList = grandGrandChildSRFieldsWrapList;
                                        List<Items> thirdLevelSRItemsList = new List<Items>();
                                        if(parentAndChildSRRecMap.containsKey(childSRRecord.Id)) {
                                            expandedRows.add(childSRRecord.Name);
                                            List<System_Relationship__c> thirdLevelSRList = parentAndChildSRRecMap.get(childSRRecord.Id);
                                            for(System_Relationship__c thirdLevelSRRecord : thirdLevelSRList) {
                                                Items thirdLevelSRItem = new Items();
                                                List<FieldsWrapper> thirdLevelSRFieldsWrapList = new List<FieldsWrapper>(); 
                                                FieldsWrapper thirdLevelSRfieldWrap = new FieldsWrapper();
                                                thirdLevelSRfieldWrap.fieldValue = thirdLevelSRRecord.Name;
                                                thirdLevelSRfieldWrap.fieldType  = 'STRING';
                                                thirdLevelSRfieldWrap.fieldName  = 'genericName';
                                                thirdLevelSRfieldWrap.fieldLabel = 'GenericName';
                                                thirdLevelSRFieldsWrapList.add(thirdLevelSRfieldWrap);
                                                for(String eachField : srFieldsList){
                                                    if(!eachField.contains('__r') && eachField != 'CAPP__c' && eachField !='Id'){
                                                        FieldsWrapper fieldWrap = new FieldsWrapper();
                                                        DescribeFieldResult fieldDescription = fieldsSRSchemaMap.get(eachField).getDescribe();
                                                        fieldWrap.fieldName = fieldDescription.getName();
                                                        fieldWrap.fieldLabel = fieldDescription.getLabel();
                                                        object value = thirdLevelSRRecord.get(fieldDescription.getName());
                                                        fieldWrap.fieldValue = value == null?'':String.valueOf(value);
                                                        fieldWrap.fieldType = String.valueOf(fieldDescription.getType());
                                                        if(fieldDescription.getName() == 'Name') {
                                                            fieldWrap.fieldName = 'SR Name';
                                                            fieldWrap.referenceName = 'SRName__r';
                                                            fieldWrap.referenceValue = fieldWrap.fieldValue;
                                                            fieldWrap.fieldValue = '/'+thirdLevelSRRecord.Id;
                                                        } else if(fieldDescription.getName() == 'Account__c') {
                                                            fieldWrap.fieldLabel = 'System Relationship Account';
                                                        }if(fieldDescription.getName() != 'Name') {
                                                        if(!fieldWrap.fieldType.equals('REFERENCE')){
                                                            fieldWrap.referenceName = '';
                                                            fieldWrap.referenceValue = '';
                                                        }else if(fieldWrap.fieldType.equals('REFERENCE')){
                                                            String relationShipField;
                                                            if(fieldDescription.isCustom()){
                                                                relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                                            }else{
                                                                relationShipField = fieldWrap.fieldName.substringBefore('Id');
                                                            }
                                                            if(String.isNotBlank(fieldWrap.fieldValue)) {
                                                                fieldWrap.fieldValue = '/'+fieldWrap.fieldValue;
                                                                fieldWrap.referenceValue = String.valueOf(thirdLevelSRRecord.getSObject(relationShipField).get('Name'));
                                                                fieldWrap.referenceName = relationShipField;
                                                            }
                                                        }
                                                        }
                                                        thirdLevelSRFieldsWrapList.add(fieldWrap);
                                                    }  
                                                }
                                                thirdLevelSRItem.fieldList = thirdLevelSRFieldsWrapList;
                                                List<Items> fourthLevelSRItemsList = new List<Items>();
                                                if(parentAndChildSRRecMap.containsKey(thirdLevelSRRecord.Id)) {
                                                    expandedRows.add(thirdLevelSRRecord.Name);
                                                    List<System_Relationship__c> fourthLevelSRList = parentAndChildSRRecMap.get(thirdLevelSRRecord.Id);
                                                    for(System_Relationship__c fourthLevelSRRecord : fourthLevelSRList) {
                                                        Items fourthLevelSRItem = new Items();
                                                        List<FieldsWrapper> fourthLevelSRFieldsWrapList = new List<FieldsWrapper>();
                                                        FieldsWrapper fourthLevelSRfieldWrap = new FieldsWrapper();
                                                        fourthLevelSRfieldWrap.fieldValue = fourthLevelSRRecord.Name;
                                                        fourthLevelSRfieldWrap.fieldType  = 'STRING';
                                                        fourthLevelSRfieldWrap.fieldName  = 'genericName';
                                                        fourthLevelSRfieldWrap.fieldLabel = 'GenericName';
                                                        fourthLevelSRFieldsWrapList.add(fourthLevelSRfieldWrap);
                                                        for(String eachField : srFieldsList){
                                                            if(!eachField.contains('__r') && eachField != 'CAPP__c' && eachField !='Id'){
                                                                FieldsWrapper fieldWrap = new FieldsWrapper();
                                                                DescribeFieldResult fieldDescription = fieldsSRSchemaMap.get(eachField).getDescribe();
                                                                fieldWrap.fieldName = fieldDescription.getName();
                                                                fieldWrap.fieldLabel = fieldDescription.getLabel();
                                                                object value = fourthLevelSRRecord.get(fieldDescription.getName());
                                                                fieldWrap.fieldValue = value == null?'':String.valueOf(value);
                                                                fieldWrap.fieldType = String.valueOf(fieldDescription.getType());
                                                                if(fieldDescription.getName() == 'Name') {
                                                                    fieldWrap.fieldName = 'SR Name';
                                                                    fieldWrap.referenceName = 'SRName__r';
                                                                    fieldWrap.referenceValue = fieldWrap.fieldValue;
                                                                    fieldWrap.fieldValue = '/'+fourthLevelSRRecord.Id;
                                                                }else if(fieldDescription.getName() == 'Account__c') {
                                                                    fieldWrap.fieldLabel = 'System Relationship Account';
                                                                }if(fieldDescription.getName() != 'Name') {
                                                                if(!fieldWrap.fieldType.equals('REFERENCE')){
                                                                    fieldWrap.referenceName = '';
                                                                    fieldWrap.referenceValue = '';
                                                                }else if(fieldWrap.fieldType.equals('REFERENCE')){
                                                                    String relationShipField;
                                                                    if(fieldDescription.isCustom()){
                                                                        relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                                                    }else{
                                                                        relationShipField = fieldWrap.fieldName.substringBefore('Id');
                                                                    }
                                                                    if(String.isNotBlank(fieldWrap.fieldValue)) {
                                                                        fieldWrap.fieldValue = '/'+fieldWrap.fieldValue;
                                                                        fieldWrap.referenceValue = String.valueOf(fourthLevelSRRecord.getSObject(relationShipField).get('Name'));
                                                                        fieldWrap.referenceName = relationShipField;
                                                                    }
                                                                }
                                                                }
                                                                fourthLevelSRFieldsWrapList.add(fieldWrap);
                                                            } 
                                                        }
                                                        fourthLevelSRItem.fieldList = fourthLevelSRFieldsWrapList;
                                                        List<Items> fifthLevelSRItemsList = new List<Items>();
                                                        //Start of fifth level SR Item
                                                        if(parentAndChildSRRecMap.containsKey(fourthLevelSRRecord.Id)) {
                                                            expandedRows.add(fourthLevelSRRecord.Name);
                                                            List<System_Relationship__c> fifthLevelSRList = parentAndChildSRRecMap.get(fourthLevelSRRecord.Id);
                                                            for(System_Relationship__c fifthLevelSRRecord : fifthLevelSRList) {
                                                                Items fifthLevelSRItem = new Items();
                                                                List<FieldsWrapper> fifthLevelSRFieldsWrapList = new List<FieldsWrapper>(); 
                                                                FieldsWrapper fifthLevelSRfieldWrap = new FieldsWrapper();
                                                                fifthLevelSRfieldWrap.fieldValue = fifthLevelSRRecord.Name;
                                                                fifthLevelSRfieldWrap.fieldType  = 'STRING';
                                                                fifthLevelSRfieldWrap.fieldName  = 'genericName';
                                                                fifthLevelSRfieldWrap.fieldLabel = 'GenericName';
                                                                fifthLevelSRFieldsWrapList.add(fifthLevelSRfieldWrap);
                                                                for(String eachField : srFieldsList){
                                                                    if(!eachField.contains('__r') && eachField != 'CAPP__c' && eachField !='Id'){
                                                                        FieldsWrapper fieldWrap = new FieldsWrapper();
                                                                        DescribeFieldResult fieldDescription = fieldsSRSchemaMap.get(eachField).getDescribe();
                                                                        fieldWrap.fieldName = fieldDescription.getName();
                                                                        fieldWrap.fieldLabel = fieldDescription.getLabel();
                                                                        object value = fifthLevelSRRecord.get(fieldDescription.getName());
                                                                        fieldWrap.fieldValue = value == null?'':String.valueOf(value);
                                                                        fieldWrap.fieldType = String.valueOf(fieldDescription.getType());
                                                                        if(fieldDescription.getName() == 'Name') {
                                                                            fieldWrap.fieldName = 'SR Name';
                                                                            fieldWrap.referenceName = 'SRName__r';
                                                                            fieldWrap.referenceValue = fieldWrap.fieldValue;
                                                                            fieldWrap.fieldValue = '/'+fifthLevelSRRecord.Id;
                                                                        }else if(fieldDescription.getName() == 'Account__c') {
                                                                            fieldWrap.fieldLabel = 'System Relationship Account'; 
                                                                        }if(fieldDescription.getName() != 'Name') { 
                                                                       if(!fieldWrap.fieldType.equals('REFERENCE')){
                                                                            fieldWrap.referenceName = '';
                                                                            fieldWrap.referenceValue = '';
                                                                        }else if(fieldWrap.fieldType.equals('REFERENCE')){
                                                                            String relationShipField;
                                                                            if(fieldDescription.isCustom()){
                                                                                relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                                                            }else{
                                                                                relationShipField = fieldWrap.fieldName.substringBefore('Id');
                                                                            }
                                                                            if(String.isNotBlank(fieldWrap.fieldValue)) {
                                                                                fieldWrap.fieldValue = '/'+fieldWrap.fieldValue;
                                                                                fieldWrap.referenceValue = String.valueOf(fifthLevelSRRecord.getSObject(relationShipField).get('Name'));
                                                                                fieldWrap.referenceName = relationShipField;
                                                                            }
                                                                        }
                                                                        }
                                                                        fifthLevelSRFieldsWrapList.add(fieldWrap);
                                                                    }
                                                                    
                                                                }
                                                                fifthLevelSRItem.fieldList = fifthLevelSRFieldsWrapList;
                                                                fifthLevelSRItemsList.add(fifthLevelSRItem);
                                                            }        
                                                        }//End of Fifth Level SR Loop
                                                        fourthLevelSRItem.Items = fifthLevelSRItemsList;
                                                        fourthLevelSRItemsList.add(fourthLevelSRItem);
                                                    }
                                                } //End Fourth Level SR Loop
                                                thirdLevelSRItem.Items = fourthLevelSRItemsList;
                                                thirdLevelSRItemsList.add(thirdLevelSRItem);
                                            }
                                        }//End Third Level SR Loop
                                        grandGrandChildSRItem.Items = thirdLevelSRItemsList;
                                        grandGrandChildSRItemList.add(grandGrandChildSRItem);
                                    }  
                                } //End GrandGrandChild Loop
                                grandChildSRItem.items = grandGrandChildSRItemList;
                                grandChildSRItemsList.add(grandChildSRItem); 
                            }  
                        }//End Grandchild Loop  
                    }
                    //}
                    
                    childCAPPItem.items = grandChildSRItemsList;
                    childCAPPRecords.add(childCAPPItem); 
                    counter++;    
                } 
            } //End Child Loop
            accountWrapInstance.items = childCAPPRecords;
            finalWrapperList.add(accountWrapInstance);
        }//End parentLoop
        AccountResponseWrapper finalWrapper = new AccountResponseWrapper(finalWrapperList,expandedRows);
        return finalWrapper;
        
    }
}