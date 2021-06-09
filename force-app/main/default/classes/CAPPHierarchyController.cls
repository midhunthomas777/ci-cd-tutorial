public class CAPPHierarchyController{
    
    public class SRResponseWrapper{
       	@AuraEnabled
        public List<SRWrapper> SRData{get;set;}
        @AuraEnabled
        public List<String> expandedRows{get;set;}
        public SRResponseWrapper(List<SRWrapper> SRData, List<String> expandedRows){
            this.SRData = SRData;
            this.expandedRows = expandedRows;
        }
    }
    public Class SRWrapper{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String account{get;set;}
        @AuraEnabled
        public String site{get;set;}
        @AuraEnabled
        public String srRecordURL{get;set;}
        @AuraEnabled
        public String accountURL{get;set;}
        @AuraEnabled
        public String siteURL{get;set;}
        @AuraEnabled
        public List<FieldsWrapper> fields{get;set;}
        @AuraEnabled
        public List<Items> items{get;set;}
    }
    public Class Items{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String account{get;set;}
        @AuraEnabled
        public String site{get;set;}
        @AuraEnabled
        public String srRecordURL{get;set;}
        @AuraEnabled
        public String accountURL{get;set;}
        @AuraEnabled
        public String siteURL{get;set;}
        @AuraEnabled
        public List<FieldsWrapper> fields{get;set;}
        @AuraEnabled
        public List<Items> items{get;set;}
    }
    public class FieldsWrapper{
    	@AuraEnabled
        public String fieldName{get;set;}
        @AuraEnabled
        public String fieldType{get;set;}
        @AuraEnabled
        public String fieldLabel{get;set;}
        @AuraEnabled
        public String fieldValue{get;set;}
        @AuraEnabled
        public String referenceName{get;set;}
    }
    
    public static Map<String,List<FieldsWrapper>> getFieldSetFields(){
    	Map<String,List<FieldsWrapper>> fieldsWithFieldSet = new Map<String,List<FieldsWrapper>>();
        List<String> initialFields = new List<String>{'Id','Name','Account__c','Site__c'};
        Map<String, SObjectField> systemFields = Schema.getGlobalDescribe().get('System_Relationship__c').getDescribe().fields.getMap();
        Map<String, Schema.FieldSet> fieldSetMapSR = Schema.SObjectType.System_Relationship__c.fieldSets.getMap();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get('System_Relationship__c');
        for(Schema.FieldSet fieldSetObj : fieldSetMapSR.values()){
            List<FieldsWrapper> fieldsWrapList = new List<FieldsWrapper>();
            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetObj.getName()).getFields()){
                SObjectField fieldToken = systemFields.get(fieldMember.getFieldPath());
                DescribeFieldResult fieldDescription = fieldToken.getDescribe();
                if(fieldDescription.isAccessible() && !initialFields.contains(fieldMember.getFieldPath())){
                    FieldsWrapper fieldsWrap = new FieldsWrapper();
                    fieldsWrap.fieldName = fieldMember.getFieldPath();
                    fieldsWrap.fieldType = String.valueOf(fieldMember.getType());
                    fieldsWrap.fieldLabel = fieldMember.getLabel();
                    fieldsWrapList.add(fieldsWrap);
                }
            }
            fieldsWithFieldSet.put(fieldSetObj.getLabel(),fieldsWrapList);
        }
        return fieldsWithFieldSet;
    }
    
    @AuraEnabled
    public static SRResponseWrapper getData(String cappRecordId){
        String query;
        List<SRWrapper> systemRelations = new List<SRWrapper>();
        List<String> fields = new List<String>();
        List<String> expandedRows = new List<String>();
        List<String> initialFields = new List<String>{'Id','Name','Account__c','Account__r.Name','Site__c','Site__r.Name'};
        List<SRResponseWrapper> finalData = new List<SRResponseWrapper>();
        Map<String,List<FieldsWrapper>> fieldsWithFieldSet = CAPPHierarchyController.getFieldSetFields();
        Map<Id,List<System_Relationship__c>> childSRMaps = new Map<Id,List<System_Relationship__c>>();
        List<Customer_Portfolio_Presence__c> cappRecord = [SELECT Id,RecordType.Name FROM Customer_Portfolio_Presence__c where Id = :cappRecordId];
        List<FieldsWrapper> fieldsWrapperList = fieldsWithFieldSet.get(cappRecord.get(0).RecordType.Name);
        fields.addAll(initialFields);
        if(fieldsWrapperList != NULL){
            for(FieldsWrapper fieldWrap : fieldsWrapperList){
                fields.add(fieldWrap.fieldName);
                if(fieldWrap.fieldType.equals('REFERENCE')){
                    String relationshipField = fieldWrap.fieldName.substringBefore('__c')+'__r.Name';
                    fields.add(relationshipField);
                }
            }
        }
        
        if(!fields.isEmpty()){
            if(!fields.contains('System_Parent__c')){
                fields.add('System_Parent__c');
            }
            query = 'SELECT '+String.join(fields, ',')+' FROM System_Relationship__c';
        }
        String finalQuery = query+' where CAPP__c = :cappRecordId AND System_Parent__c != NULL Order BY CreatedDate ASC';
        for(System_Relationship__c childSR : Database.query(finalQuery)){
            if(childSRMaps.containsKey(childSR.System_Parent__c)){
                List<System_Relationship__c> existingSRs = childSRMaps.get(childSR.System_Parent__c);
                existingSRs.add(childSR);
                childSRMaps.PUT(childSR.System_Parent__c, existingSRs);
            }else{
                childSRMaps.PUT(childSR.System_Parent__c, new List<System_Relationship__c>{childSR});
            }  
        }
        
        finalQuery = query+' where CAPP__c = :cappRecordId AND System_Parent__c = NULL Order BY CreatedDate ASC';
        for(System_Relationship__c parentSR : Database.query(finalQuery)){
            SRWrapper parentWrapper = new SRWrapper();
            parentWrapper.name = parentSR.Name;
            parentWrapper.account = parentSR.Account__r.Name;
            parentWrapper.site = parentSR.Site__r.Name;
            parentWrapper.srRecordURL = '/'+parentSR.Id;
            parentWrapper.accountURL = parentSR.Account__c == null?'':'/'+parentSR.Account__c;
            parentWrapper.siteURL = parentSR.Site__c == null?'':'/'+parentSR.Site__c;
            if(fieldsWrapperList != NULL){
                List<FieldsWrapper> fieldsWrapList = new List<FieldsWrapper>();
                for(FieldsWrapper fieldWrap : fieldsWrapperList){
                    String referenceName = '';
                    object value = parentSR.get(fieldWrap.fieldName);
                    String fieldValue = value == null?'':String.valueOf(value);
                    if(fieldWrap.fieldType.equals('REFERENCE') && String.isNotBlank(fieldValue)){
                        fieldValue = '/'+fieldValue;
                        String relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                        referenceName = String.valueOf(parentSR.getSObject(relationShipField).get('Name'));
                    }
                    FieldsWrapper fieldInstance = new FieldsWrapper();
                    fieldInstance.fieldName  	= fieldWrap.fieldName;
                    fieldInstance.fieldType  	= fieldWrap.fieldType;
                    fieldInstance.fieldLabel 	= fieldWrap.fieldLabel; 
                    fieldInstance.fieldValue 	= fieldValue;
                    fieldInstance.referenceName = referenceName;
                    fieldsWrapList.add(fieldInstance);
                }
                parentWrapper.fields = fieldsWrapList;
            }
            expandedRows.add(parentSR.Name);
            List<Items> child = new List<Items>();
                
            if(!childSRMaps.isEmpty()){
                List<System_Relationship__c> childSRMapValues = childSRMaps.get(parentSR.Id);
                if(childSRMapValues != null){
                    for(System_Relationship__c childSR : childSRMapValues){
                        Items childWrapper = new Items();
                        childWrapper.name = childSR.Name;
                        childWrapper.account = childSR.Account__r.Name;
                        childWrapper.site = childSR.Site__r.Name;
                        childWrapper.srRecordURL = '/'+childSR.Id;
                        childWrapper.accountURL = childSR.Account__c == null?'':'/'+childSR.Account__c;
                        childWrapper.siteURL = childSR.Site__c == null?'':'/'+childSR.Site__c;
                        if(fieldsWrapperList != NULL){
                            List<FieldsWrapper> fieldsWrapList = new List<FieldsWrapper>();
                            for(FieldsWrapper fieldWrap : fieldsWrapperList){
                                String referenceName = '';
                                object value = childSR.get(fieldWrap.fieldName);
                                String fieldValue = value == null?'':String.valueOf(value);
                                if(fieldWrap.fieldType.equals('REFERENCE') && String.isNotBlank(fieldValue)){
                                    fieldValue = '/'+fieldValue;
                                    String relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                    referenceName = String.valueOf(childSR.getSObject(relationShipField).get('Name'));
                                }
                                FieldsWrapper fieldInstance = new FieldsWrapper();
                                fieldInstance.fieldName  	= fieldWrap.fieldName;
                                fieldInstance.fieldType  	= fieldWrap.fieldType;
                                fieldInstance.fieldLabel 	= fieldWrap.fieldLabel;
                                fieldInstance.fieldValue 	= fieldValue;
                                fieldInstance.referenceName = referenceName;
                                fieldsWrapList.add(fieldInstance);
                            }
                            childWrapper.fields = fieldsWrapList;
                        }
                        expandedRows.add(childSR.Name);
                        List<Items> grandChild = new List<Items>();
                        List<System_Relationship__c> grandChildSRMapValues = childSRMaps.get(childSR.Id);
                        
                        if(grandChildSRMapValues != null){
                            for(System_Relationship__c grandChildSR : grandChildSRMapValues){
                                Items grandChildWrapper = new Items();
                                grandChildWrapper.name = grandChildSR.Name;
                                grandChildWrapper.account = grandChildSR.Account__r.Name;
                                grandChildWrapper.site = grandChildSR.Site__r.Name;
                        		grandChildWrapper.srRecordURL = '/'+grandChildSR.Id;
                                grandChildWrapper.accountURL = grandChildSR.Account__c == null?'':'/'+grandChildSR.Account__c;
                                grandChildWrapper.siteURL = grandChildSR.Site__c == null?'':'/'+grandChildSR.Site__c;
                                if(fieldsWrapperList != NULL){
                                    List<FieldsWrapper> fieldsWrapList = new List<FieldsWrapper>();
                                    for(FieldsWrapper fieldWrap : fieldsWrapperList){
                                        String referenceName = '';
                                        object value = grandChildSR.get(fieldWrap.fieldName);
                                        String fieldValue = value == null?'':String.valueOf(value);
                                        if(fieldWrap.fieldType.equals('REFERENCE') && String.isNotBlank(fieldValue)){
                                            fieldValue = '/'+fieldValue;
                                            String relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                            referenceName = String.valueOf(grandChildSR.getSObject(relationShipField).get('Name'));
                                        }
                                        FieldsWrapper fieldInstance = new FieldsWrapper();
                                        fieldInstance.fieldName  	= fieldWrap.fieldName;
                                        fieldInstance.fieldType  	= fieldWrap.fieldType;
                                        fieldInstance.fieldLabel 	= fieldWrap.fieldLabel;
                                        fieldInstance.fieldValue 	= fieldValue;
                                        fieldInstance.referenceName = referenceName;
                                        fieldsWrapList.add(fieldInstance);
                                    }
                                    grandChildWrapper.fields = fieldsWrapList;
                                }
                                expandedRows.add(grandChildSR.Name);
                                List<Items> grandGrandChild = new List<Items>();
                                List<System_Relationship__c> grandGrandChildSRMapValues = childSRMaps.get(grandChildSR.Id);
                                
                                if(grandGrandChildSRMapValues != null){
                                    for(System_Relationship__c grandGrandChildSR : grandGrandChildSRMapValues){
                                        Items grandGrandChildWrapper = new Items();
                                        grandGrandChildWrapper.name = grandGrandChildSR.Name;
                                        grandGrandChildWrapper.account = grandGrandChildSR.Account__r.Name;
                                        grandGrandChildWrapper.site = grandGrandChildSR.Site__r.Name;
                                        grandGrandChildWrapper.srRecordURL = '/'+grandGrandChildSR.Id;
                                        grandGrandChildWrapper.accountURL = grandGrandChildSR.Account__c == null?'':'/'+grandGrandChildSR.Account__c;
                                        grandGrandChildWrapper.siteURL = grandGrandChildSR.Site__c == null?'':'/'+grandGrandChildSR.Site__c;
                                        if(fieldsWrapperList != NULL){
                                            List<FieldsWrapper> fieldsWrapList = new List<FieldsWrapper>();
                                            for(FieldsWrapper fieldWrap : fieldsWrapperList){
                                                String referenceName = '';
                                                object value = grandGrandChildSR.get(fieldWrap.fieldName);
                                                String fieldValue = value == null?'':String.valueOf(value);
                                                if(fieldWrap.fieldType.equals('REFERENCE') && String.isNotBlank(fieldValue)){
                                                    fieldValue = '/'+fieldValue;
                                                    String relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
                                                    referenceName = String.valueOf(grandGrandChildSR.getSObject(relationShipField).get('Name'));
                                                }
                                                FieldsWrapper fieldInstance = new FieldsWrapper();
                                                fieldInstance.fieldName  	= fieldWrap.fieldName;
                                                fieldInstance.fieldType  	= fieldWrap.fieldType;
                                                fieldInstance.fieldLabel 	= fieldWrap.fieldLabel;
                                                fieldInstance.fieldValue 	= fieldValue;
                                                fieldInstance.referenceName = referenceName;
                                                fieldsWrapList.add(fieldInstance);
                                            }
                                            grandGrandChildWrapper.fields = fieldsWrapList;
                                        }
                                        expandedRows.add(grandGrandChildSR.Name);
										List<Items> superGrandChild = new List<Items>();
										List<System_Relationship__c> superGrandChildSRMapValues = childSRMaps.get(grandGrandChildSR.Id);
										
										if(superGrandChildSRMapValues != null){
											for(System_Relationship__c superGrandChildSR : superGrandChildSRMapValues){
												Items superGrandChildWrapper = new Items();
												superGrandChildWrapper.name = superGrandChildSR.Name;
												superGrandChildWrapper.account = superGrandChildSR.Account__r.Name;
												superGrandChildWrapper.site = superGrandChildSR.Site__r.Name;
												superGrandChildWrapper.srRecordURL = '/'+superGrandChildSR.Id;
												superGrandChildWrapper.accountURL = superGrandChildSR.Account__c == null?'':'/'+superGrandChildSR.Account__c;
												superGrandChildWrapper.siteURL = superGrandChildSR.Site__c == null?'':'/'+superGrandChildSR.Site__c;
												if(fieldsWrapperList != NULL){
													List<FieldsWrapper> fieldsWrapList = new List<FieldsWrapper>();
													for(FieldsWrapper fieldWrap : fieldsWrapperList){
														String referenceName = '';
														object value = superGrandChildSR.get(fieldWrap.fieldName);
														String fieldValue = value == null?'':String.valueOf(value);
														if(fieldWrap.fieldType.equals('REFERENCE') && String.isNotBlank(fieldValue)){
															fieldValue = '/'+fieldValue;
															String relationShipField = fieldWrap.fieldName.substringBefore('__c')+'__r';
															referenceName = String.valueOf(superGrandChildSR.getSObject(relationShipField).get('Name'));
														}
														FieldsWrapper fieldInstance = new FieldsWrapper();
														fieldInstance.fieldName  	= fieldWrap.fieldName;
														fieldInstance.fieldType  	= fieldWrap.fieldType;
														fieldInstance.fieldLabel 	= fieldWrap.fieldLabel;
														fieldInstance.fieldValue 	= fieldValue;
														fieldInstance.referenceName = referenceName;
														fieldsWrapList.add(fieldInstance);
													}
													superGrandChildWrapper.fields = fieldsWrapList;
												}
												expandedRows.add(superGrandChildWrapper.Name);
												superGrandChild.add(superGrandChildWrapper);
											}//End of superGrandChild Loop 
										}
										grandGrandChildWrapper.items = superGrandChild;
                                        grandGrandChild.add(grandGrandChildWrapper);
                                    }//End of grandGrandChild Loop
                                }
                                grandChildWrapper.items = grandGrandChild;
                                grandChild.add(grandChildWrapper);
                            }// End of grandChild Loop
                        }
                        childWrapper.items = grandChild;
                        child.add(childWrapper);
                    }// End of Child loop
                }
            }
            parentWrapper.items = child;
            systemRelations.add(parentWrapper);
        }// End of Parent loop
        SRResponseWrapper finalWrapper = new SRResponseWrapper(systemRelations,expandedRows);
        return finalWrapper;
    }    
}