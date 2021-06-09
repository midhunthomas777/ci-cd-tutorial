public class NewCAPPController{
    
    Public Static Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> recordTypeWithPicklist = new Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>>();
    @AuraEnabled
    public static List<String> getAssignedRecordTypes(){
        List<String> assignedRecordTypes = new List<String>();
        Schema.DescribeSObjectResult objectData = Customer_Portfolio_Presence__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = objectData.getRecordTypeInfos();
        for( Schema.RecordTypeInfo recordType : recordTypeInfo){
            if(recordType.isAvailable() || Test.isRunningTest()){ 
                if(recordType.Name!='Master'){
                    assignedRecordTypes.add(recordType.Name);
                }
            }
        }
        return assignedRecordTypes;
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getCAPPDetails(String objName){
        Map<String,List<String>> tabWithSection = new Map<String,List<String>>();
        List<String> layoutsName = new List<String>();
        List<String> sectionNames = NewCAPPController.getAssignedRecordTypes();
        for(MR_Digitization_Settings__mdt tabName : [Select MasterLabel, DeveloperName from MR_Digitization_Settings__mdt 
                                                     where Category__c = 'CAPP' order by MasterLabel])
        {
            layoutsName.add(objName+'-'+tabName.MasterLabel);
        }
        for(Metadata.Metadata layout : Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutsName)){
            Metadata.Layout layoutMd = (Metadata.Layout) layout;    
            String tab = layoutMd.fullName.substringAfterLast('__c-');
            for(Metadata.LayoutSection section : layoutMd.layoutSections) {
                if(section.label != 'Custom Links'){ 
                    if(tabWithSection.containsKey(tab)){
                        List<String> sections = tabWithSection.get(tab);
                        if(sectionNames.contains(section.label)){
                            sections.add(section.label);
                        }
                        tabWithSection.put(tab,sections);
                    }else{
                        List<String> sections = new List<String>();
                        if(sectionNames.contains(section.label)){
                            sections.add(section.label);
                        }
                        tabWithSection.put(tab,sections);
                    }
                }
            }
        }
        return tabWithSection;
    }
    
    @AuraEnabled
    public static Map<String,Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>> getfieldsWithSections(){
        String objName = 'Customer_Portfolio_Presence__c';
        String srObjName = 'System_Relationship__c';
        Map<String,Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>> response = new Map<String,Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>();
        Map<String, Schema.FieldSet> fieldSetMapCAPP = Schema.SObjectType.Customer_Portfolio_Presence__c.fieldSets.getMap();
        Map<String, Schema.FieldSet> fieldSetMapSR = Schema.SObjectType.System_Relationship__c.fieldSets.getMap();
        Map<String,List<String>> tabWithSections = NewCAPPController.getCAPPDetails(objName);
        Map<String,String> recordTypesMap = NewCAPPController.getRecordTypes(objName);
        Set<String> SRfieldSetLabels = new Set<String>();
        List<String> allsections = new List<String>();
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objName);
        Schema.SObjectType objSR = Schema.getGlobalDescribe().get(srObjName);
        Map<String, SObjectField> cappFields = sObj.getDescribe().fields.getMap();
        Map<String, SObjectField> systemFields = objSR.getDescribe().fields.getMap();
        for(List<String> sectionList : tabWithSections.values()){
            for(String sectionName : sectionList){
                allsections.add(sectionName);    
            }
        }
        for(Schema.FieldSet fieldSet : fieldSetMapSR.values()){
            SRfieldSetLabels.add(fieldSet.getLabel());
        }
        
        for(Schema.FieldSet fieldSetObj : fieldSetMapCAPP.values()){
            if(allsections.contains(fieldSetObj.getLabel())){
                List<NewCAPPControllerWrapper.FieldSetMemberWrapper> wrapperList = new List<NewCAPPControllerWrapper.FieldSetMemberWrapper>();
                List<NewCAPPControllerWrapper.FieldSetMemberWrapper> systemWrapperList = new List<NewCAPPControllerWrapper.FieldSetMemberWrapper>();
                Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>> sectionDetails = new Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>();
                for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetObj.getName()).getFields()){
                    SObjectField fieldToken = cappFields.get(fieldMember.getFieldPath());
                    DescribeFieldResult fieldDescription = fieldToken.getDescribe();
                    if(fieldDescription.isAccessible() && !fieldDescription.isCalculated()){
                        Boolean isReadOnly = false;
                        if(!fieldDescription.isUpdateable()){
                            isReadOnly = true;
                        }
                        List<NewCAPPControllerWrapper.picklistMapping> PickValuesMapping = new List<NewCAPPControllerWrapper.picklistMapping>();
                        if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST'){
                            Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> picklistValuesMap = NewCAPPController.getpicklistValues(objName,fieldMember.getFieldPath(),recordTypesMap,fieldSetObj.getLabel());
                            for(String picklistMapKey : picklistValuesMap.keySet()){
                                if(picklistMapKey.equals('NOCONTROLLER')){
                                    PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistValuesMap.get(picklistMapKey),isReadOnly == true?true:false));
                                }else{
                                    PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistValuesMap.get(picklistMapKey),isReadOnly == true?true:true));
                                }
                            } 
                        }
                        String helptext = fieldDescription.getInlineHelpText();
                        wrapperList.add(new NewCAPPControllerWrapper.FieldSetMemberWrapper(fieldMember.getFieldPath(), String.valueOf(fieldMember.getType()),
                                                                                           fieldMember.getLabel(),helptext == null?'':helptext,
                                                                                           PickValuesMapping,'','','',isReadOnly,false));   
                    }
                }
                sectionDetails.put('SLF',wrapperList);
                
                if(SRfieldSetLabels.contains(fieldSetObj.getLabel())){
                    for(Schema.FieldSetMember fieldMember : objSR.getDescribe().fieldSets.getMap().get(fieldSetObj.getName()).getFields()){
                        SObjectField fieldToken = systemFields.get(fieldMember.getFieldPath());
                        DescribeFieldResult fieldDescription = fieldToken.getDescribe();
                        if(fieldDescription.isAccessible() && !fieldDescription.isCalculated()){
                            Boolean isReadOnly = false;
                            if(!fieldDescription.isUpdateable()){
                                isReadOnly = true;
                            }
                            List<NewCAPPControllerWrapper.picklistMapping> PickValuesMapping = new List<NewCAPPControllerWrapper.picklistMapping>();
                            if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST'){
                                Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> picklistValuesMap = NewCAPPController.getpicklistValues(srObjName,fieldMember.getFieldPath(),recordTypesMap,'');
                                for(String picklistMapKey : picklistValuesMap.keySet()){
                                    if(picklistMapKey.equals('NOCONTROLLER')){
                                        PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistValuesMap.get(picklistMapKey),isReadOnly == true?true:false));
                                    }else{
                                        PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistValuesMap.get(picklistMapKey),isReadOnly == true?true:true));
                                    }
                                } 
                            }
                            String helptext = fieldDescription.getInlineHelpText();
                            systemWrapperList.add(new NewCAPPControllerWrapper.FieldSetMemberWrapper(fieldMember.getFieldPath(), String.valueOf(fieldMember.getType()),
                                                                                                     fieldMember.getLabel(),helptext == null?'':helptext,
                                                                                                     PickValuesMapping,'','','',isReadOnly,false));   
                        }
                    }
                    sectionDetails.put('ASSF',systemWrapperList);
                }else{
                    sectionDetails.put('ASSF',systemWrapperList);
                }
                response.put(fieldSetObj.getLabel(),sectionDetails);
            }
        }
        System.debug('#######response########### => ' +  JSON.serializePretty(response));
        return response;
    }

    @AuraEnabled
    public static Map<String,Map<String,Map<String,Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>>>>> getFieldSets(String currentRecordId){
        String objName = 'Customer_Portfolio_Presence__c';
        String srObjName = 'System_Relationship__c';
        Map<String,Schema.FieldSet> CAPPfieldSetWithLabels = new Map<String,Schema.FieldSet>();
        Map<String,Schema.FieldSet> SRfieldSetWithLabels = new Map<String,Schema.FieldSet>();
        Map<String,Map<String,Map<String,Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>>>>> CAPPS = new Map<String,Map<String,Map<String,Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>>>>>();
        Map<String, Schema.FieldSet> fieldSetMapCAPP = Schema.SObjectType.Customer_Portfolio_Presence__c.fieldSets.getMap();
        Map<String, Schema.FieldSet> fieldSetMapSR = Schema.SObjectType.System_Relationship__c.fieldSets.getMap();
        Map<String,List<String>> tabWithSection = NewCAPPController.getCAPPDetails(objName);
        Map<String,String> recordTypesMap = NewCAPPController.getRecordTypes(objName);
        Map<String,List<Customer_Portfolio_Presence__c>> CAPPRecords = NewCAPPController.getCAPPSRecords(currentRecordId,objName,recordTypesMap);
        Map<String,List<System_Relationship__c>> SRRecords = NewCAPPController.getSRRecords(currentRecordId,recordTypesMap);
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objName);
        Schema.SObjectType objSR = Schema.getGlobalDescribe().get(srObjName);
        Map<String, SObjectField> cappFields = sObj.getDescribe().fields.getMap();
        Map<String, SObjectField> systemFields = objSR.getDescribe().fields.getMap();
        
        for(Schema.FieldSet fieldSet : fieldSetMapCAPP.values()){
            CAPPfieldSetWithLabels.put(fieldSet.getLabel(),fieldSet);
        }
        for(Schema.FieldSet fieldSet : fieldSetMapSR.values()){
            SRfieldSetWithLabels.put(fieldSet.getLabel(),fieldSet);
        }
        
        for(String tab : tabWithSection.keySet()){
            Map<String,Map<String,Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>>>> sectionWithData = new Map<String,Map<String,Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>>>>();
            for(String sectionName : tabWithSection.get(tab)){
                Integer recordLevelCount = 1;
                Map<String,Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>>> finalData = new Map<String,Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>>>();
                if(CAPPRecords.containsKey(sectionName)){
                    for(Customer_Portfolio_Presence__c cappRecord : CAPPRecords.get(sectionName)){
                        Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>> recordLevelData = new Map<String,List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>>();
                        List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>> systemRelatedRecords = new List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>();
                        Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>> recordIdWithFields = new Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>();
                        List<NewCAPPControllerWrapper.FieldSetMemberWrapper> wrapperList = new List<NewCAPPControllerWrapper.FieldSetMemberWrapper>();
                        String vendorValue = '';
                        if(CAPPfieldSetWithLabels.containsKey(sectionName)){
                            Schema.FieldSet fieldsOfSection = CAPPfieldSetWithLabels.get(sectionName);
                            for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldsOfSection.getName()).getFields()){
                                SObjectField fieldToken = cappFields.get(fieldMember.getFieldPath());
                                DescribeFieldResult fieldDescription = fieldToken.getDescribe();
                                if(fieldDescription.isAccessible()){
                                    Boolean isReadOnly = false;
                                    if(!fieldDescription.isUpdateable()){
                                        isReadOnly = true;
                                    }
                                    List<NewCAPPControllerWrapper.picklistMapping> PickValuesMapping = new List<NewCAPPControllerWrapper.picklistMapping>();
                                    if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST'){
                                        Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> picklistValuesMap = NewCAPPController.getpicklistValues(objName,fieldMember.getFieldPath(),recordTypesMap,sectionName);
                                        for(String eachkey : picklistValuesMap.keySet()){
                                            if(eachkey.equals('NOCONTROLLER')){
                                                PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistValuesMap.get(eachkey),isReadOnly==true?true:false));
                                            }else{
                                                String controllingFieldValue = String.valueOf(cappRecord.get(eachkey));
                                                if(String.isNotBlank(controllingFieldValue)){
                                                    List<NewCAPPControllerWrapper.PicklistWrapper> picklistvalues = getPicklistByRTANDDependency(objName,recordTypesMap.get(sectionName),fieldMember.getFieldPath(),controllingFieldValue);
                                                    if(picklistvalues.isEmpty()){
                                                        PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistvalues,isReadOnly==true?true:true));
                                                    }else{
                                                        PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistvalues,isReadOnly==true?true:false));
                                                    }
                                                }else{
                                                    PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistValuesMap.get(eachkey),isReadOnly==true?true:true));
                                                }
                                            }
                                        } 
                                    }
                                    
                                    String fieldValue = String.valueOf(cappRecord.get(fieldMember.getFieldPath()));
                                    String helptext = fieldDescription.getInlineHelpText();
                                    if(fieldMember.getFieldPath().equals('Vendor__c') && String.isNotEmpty(fieldValue)){
                                        vendorValue = fieldValue;
                                    }
                                    wrapperList.add(new NewCAPPControllerWrapper.FieldSetMemberWrapper(fieldMember.getFieldPath(), String.valueOf(fieldMember.getType()),
                                                                                                       fieldMember.getLabel(), helptext == null?'':helptext,
                                                                                                       PickValuesMapping,fieldValue == null?'':fieldValue,
                                                                                                       fieldMember.getFieldPath().equals('Vendor_Product_Line__c')?vendorValue:'','',
                                                                                                       isReadOnly,fieldDescription.isCalculated()));   
                                }
                            }
                        }
                        DescribeFieldResult cappNameField = cappFields.get('Name').getDescribe();
                        if(cappNameField.isAccessible()){
                            wrapperList.add(new NewCAPPControllerWrapper.FieldSetMemberWrapper('Name', 'STRING', 'Name', '',new List<NewCAPPControllerWrapper.picklistMapping>{},cappRecord.Name,'','',true,false));
                        }
                        recordIdWithFields.put(cappRecord.Id,wrapperList);
                        systemRelatedRecords.add(recordIdWithFields);
                        recordLevelData.put('SLF',systemRelatedRecords);
                        
                        if(SRfieldSetWithLabels.containsKey(sectionName)){
                            List<System_Relationship__c> systemRelRecords = SRRecords.get(cappRecord.Id);
                            if(!systemRelRecords.isEmpty()){
                                List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>> accountSpecificRecords = new List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>();
                                for(System_Relationship__c systemRecord : systemRelRecords){
                                    Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>> systemRecIdWithFields = new Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>();
                                    List<NewCAPPControllerWrapper.FieldSetMemberWrapper> systemWrapperList = new List<NewCAPPControllerWrapper.FieldSetMemberWrapper>();
                                    Schema.FieldSet systemFieldsPerSection = SRfieldSetWithLabels.get(sectionName);
                                    DescribeFieldResult systemSiteField = systemFields.get('Site__c').getDescribe();
                                    if(systemSiteField.isAccessible() && String.isNotBlank(systemRecord.Site__c)){
                                        Boolean isSiteReadOnly = false;
                                        if(!systemSiteField.isUpdateable()){
                                            isSiteReadOnly = true;
                                        }
                                        systemWrapperList.add(new NewCAPPControllerWrapper.FieldSetMemberWrapper('Site__c', 'REFERENCE', 'Site', '',new List<NewCAPPControllerWrapper.picklistMapping>{},systemRecord.Site__c,'',systemRecord.Account__c,isSiteReadOnly,false));
                                    }
                                    for(Schema.FieldSetMember fieldMember : objSR.getDescribe().fieldSets.getMap().get(systemFieldsPerSection.getName()).getFields()){
                                        SObjectField fieldToken = systemFields.get(fieldMember.getFieldPath());
                                        DescribeFieldResult fieldDescription = fieldToken.getDescribe();
                                        if(fieldDescription.isAccessible()){
                                            Boolean isReadOnly = false;
                                            if(!fieldDescription.isUpdateable()){
                                                isReadOnly = true;
                                            }
                                            List<NewCAPPControllerWrapper.picklistMapping> PickValuesMapping = new List<NewCAPPControllerWrapper.picklistMapping>();
                                            if(String.valueOf(fieldMember.getType()) == 'PICKLIST' || String.valueOf(fieldMember.getType()) == 'MULTIPICKLIST'){
                                                Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> picklistValuesMap = NewCAPPController.getpicklistValues(srObjName,fieldMember.getFieldPath(),recordTypesMap,'');
                                                for(String eachkey : picklistValuesMap.keySet()){
                                                    if(eachkey.equals('NOCONTROLLER')){
                                                        PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistValuesMap.get(eachkey),isReadOnly==true?true:false));
                                                    }else{
                                                        String controllingFieldValue = String.valueOf(systemRecord.get(eachkey));
                                                        if(String.isNotBlank(controllingFieldValue)){
                                                            Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> dependentValuesMap = getFieldDependencies(srObjName,eachkey,fieldMember.getFieldPath());
                                                            List<NewCAPPControllerWrapper.PicklistWrapper> picklistvalues = dependentValuesMap.get(controllingFieldValue);
                                                            if(picklistvalues.isEmpty()){
                                                                PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistvalues,isReadOnly==true?true:true));
                                                            }else{
                                                                PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistvalues,isReadOnly==true?true:false));
                                                            }
                                                        }else{
                                                            PickValuesMapping.add(new NewCAPPControllerWrapper.picklistMapping(picklistValuesMap.get(eachkey),isReadOnly==true?true:true));
                                                        }
                                                    }
                                                } 
                                            }
                                            String fieldValue = String.valueOf(systemRecord.get(fieldMember.getFieldPath()));
                                            String helptext = fieldDescription.getInlineHelpText();
                                            systemWrapperList.add(new NewCAPPControllerWrapper.FieldSetMemberWrapper(fieldMember.getFieldPath(), String.valueOf(fieldMember.getType()),
                                                                                                                     fieldMember.getLabel(), helptext == null?'':helptext,
                                                                                                                     PickValuesMapping,fieldValue == null?'':fieldValue,'','',isReadOnly,
                                                                                                                     fieldDescription.isCalculated()));
                                        }
                                    }
                                    
                                    if(!systemWrapperList.isEmpty()){
                                        DescribeFieldResult systemNameField = systemFields.get('Name').getDescribe();
                                        if(systemNameField.isAccessible()){
                                            systemWrapperList.add(new NewCAPPControllerWrapper.FieldSetMemberWrapper('Name', 'STRING', 'Name', '',new List<NewCAPPControllerWrapper.picklistMapping>{},systemRecord.Name,'','',true,false));
                                        }
                                        systemRecIdWithFields.put(systemRecord.Id,systemWrapperList);
                                    }
                                    accountSpecificRecords.add(systemRecIdWithFields);
                                }
                                recordLevelData.put('ASSF',accountSpecificRecords);
                            }else{
                                Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>> recordsMap = new Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>();
                                recordLevelData.put('ASSF',new List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>{recordsMap});
                            }
                        }else{
                            Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>> recordsMap = new Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>();
                            recordLevelData.put('ASSF',new List<Map<String,List<NewCAPPControllerWrapper.FieldSetMemberWrapper>>>{recordsMap});
                        }
                        finalData.put(String.valueOf(recordLevelCount)+'-Record',recordLevelData);
                        recordLevelCount++;
                    }
                    sectionWithData.put(sectionName,finalData);
                }else{
                    sectionWithData.put(sectionName,finalData);
                }
            }
            CAPPS.put(tab,sectionWithData);
        }
        System.debug('#######CAPPS########### => ' +  JSON.serializePretty(CAPPS));
        return CAPPS;
    }       
    
    @AuraEnabled
    public static Map<String,String> getRecordTypes(String objName){
        Map<String,String> recordTypes = new Map<String,String>();
        for(RecordType RT : [SELECT Id,Name FROM RecordType WHERE SobjectType = :objName]){
            recordTypes.put(RT.Name, RT.Id);
        }
        System.debug('#######recordTypes########### => ' + recordTypes);
        return recordTypes;
    }
    
    @AuraEnabled
    public static Map<String,Map<String,String>> getControllingPicklistFields(){
        Map<String,Map<String,String>> response = new Map<String,Map<String,String>>();
        Map<String,String> cappFieldsMAP = new Map<String,String>();
        Map<String,String> systemFieldsMAP = new Map<String,String>();
        Schema.DescribeSObjectResult cappObjResult = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe();
        Schema.DescribeSObjectResult systemObjResult = Schema.getGlobalDescribe().get('System_Relationship__c').getDescribe();
        for(Schema.SObjectField eachField : cappObjResult.fields.getMap().values()){
            if(String.valueof(eachField.getDescribe().getType()) == 'PICKLIST'){
                String controllingField = String.valueOf(eachField.getDescribe().getController());
                if(String.isNotBlank(controllingField)){
                    cappFieldsMAP.put(controllingField,String.valueOf(eachField));
                }
            }
        }
        for(Schema.SObjectField eachField : systemObjResult.fields.getMap().values()){
            if(String.valueof(eachField.getDescribe().getType()) == 'PICKLIST'){
                String controllingField = String.valueOf(eachField.getDescribe().getController());
                if(String.isNotBlank(controllingField)){
                    systemFieldsMAP.put(controllingField,String.valueOf(eachField));
                }
            }
        }
        response.put('Customer_Portfolio_Presence__c',cappFieldsMAP);
        response.put('System_Relationship__c',systemFieldsMAP);
        System.debug('#######response########### => ' + response);
        return response;
    }
    
    @AuraEnabled
    public static Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> getpicklistValues(String objName,String field,Map<String,String> recordTypesMap,String recordTypeName){
        System.debug('#######objName########### => ' + objName);
        System.debug('#######field########### => ' + field);
        System.debug('#######recordTypesMap########### => ' + recordTypesMap);
        System.debug('#######recordTypeName########### => ' + recordTypeName);
        Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> finalResponse = new Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>>();
        List<NewCAPPControllerWrapper.PicklistWrapper> picklistValues = new List<NewCAPPControllerWrapper.PicklistWrapper>();
        Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objName).getDescribe();
        Schema.DescribeFieldResult fieldResult = objResult.fields.getMap().get(field).getDescribe();
        String controllingField = String.valueof(fieldResult.getController());
        if(String.isNotBlank(controllingField)){
            finalResponse.put(controllingField, picklistValues);
        }else if(String.isNotBlank(recordTypesMap.get(recordTypeName))){
            picklistValues = NewCAPPController.getPicklistValuesByRecordType(objName,field,recordTypesMap.get(recordTypeName));
            finalResponse.put('NOCONTROLLER', picklistValues);
        }else{
            for(Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                if(entry.isActive()){
                    picklistValues.add(new NewCAPPControllerWrapper.PicklistWrapper(entry.getLabel().unescapeHtml4(), entry.getValue().unescapeHtml4()));
                }
            }
            finalResponse.put('NOCONTROLLER', picklistValues);
        }
        System.debug('#######finalResponse########### => ' + finalResponse);
        return finalResponse;
    }
    
    public static List<NewCAPPControllerWrapper.PicklistWrapper> getPicklistValuesByRecordType(String objName,String field,String recordTypeId){
        List<NewCAPPControllerWrapper.PicklistWrapper> picklistValues = new List<NewCAPPControllerWrapper.PicklistWrapper>();
        String mapKey = recordTypeId+';'+field;
        
        if(recordTypeWithPicklist.containsKey(mapKey)){
            picklistValues = recordTypeWithPicklist.get(mapKey);
        }else{
            for(CAPP_Dependent_PickList__mdt picklistMetadata : [SELECT Values__c,Record_Type_Ids__c FROM CAPP_Dependent_PickList__mdt WHERE MasterLabel = : field]) {
                if(String.isNotBlank(picklistMetadata.Values__c) && String.isNotBlank(picklistMetadata.Record_Type_Ids__c) && 
                   picklistMetadata.Record_Type_Ids__c.contains(recordTypeId)) {
                       List<String> allPicklistValues = picklistMetadata.Values__c.split(';');
                       for(String value : allPicklistValues) {
                           picklistValues.add(new NewCAPPControllerWrapper.PicklistWrapper(value, value));
                       }  
                   }
            }
            recordTypeWithPicklist.put(mapKey, picklistValues);
        }
        System.debug('#######picklistValues########### => ' + picklistValues);
        return picklistValues;
    }
    
    @AuraEnabled
    public static List<NewCAPPControllerWrapper.PicklistWrapper> handlePicklistChange(String objName,String recordTypeName,String controllingField,String dependentField,String fieldValue){
        List<NewCAPPControllerWrapper.PicklistWrapper> picklistvalues = new List<NewCAPPControllerWrapper.PicklistWrapper>();
        if(objName.equals('Customer_Portfolio_Presence__c')){
            Map<String,String> recordTypesMap = NewCAPPController.getRecordTypes(objName);
            picklistvalues = NewCAPPController.getPicklistByRTANDDependency(objName,recordTypesMap.get(recordTypeName),dependentField,fieldValue);
        }else if(objName.equals('System_Relationship__c')){
            Map<String,List<NewCAPPControllerWrapper.PicklistWrapper>> fieldDependencyMap = NewCAPPController.getFieldDependencies(objName,controllingField,dependentField);
            picklistvalues = fieldDependencyMap.get(fieldValue);
        }
        System.debug('#######picklistvalues########### => ' + picklistvalues);
        return picklistvalues;
    }
    
    @AuraEnabled
    public static List<NewCAPPControllerWrapper.PicklistWrapper> getPicklistByRTANDDependency(String objName,String recordTypeId,String dependentField,String fieldValue){
        List<NewCAPPControllerWrapper.PicklistWrapper> responseList = new List<NewCAPPControllerWrapper.PicklistWrapper>();
        //String mapKey = recordTypeId+';'+dependentField+';'+fieldValue;
        String mapKey = dependentField+';'+fieldValue;
        System.debug('#######mapKey########### => ' + mapKey);
        if(recordTypeWithPicklist.containsKey(mapKey)){
            responseList = recordTypeWithPicklist.get(mapKey);
        }else{
            List<CAPP_Dependent_PickList__mdt> picklistMetadata = [SELECT Values__c FROM CAPP_Dependent_PickList__mdt WHERE MasterLabel = :mapKey];
            if(!picklistMetadata.isEmpty()) {
                if(String.isNotBlank(picklistMetadata.get(0).Values__c)) {
                    List<String> allPicklistValues = picklistMetadata.get(0).Values__c.split(';');
                    for(String value : allPicklistValues) {
                        responseList.add(new NewCAPPControllerWrapper.PicklistWrapper(value, value));
                    }
                }
            }
            recordTypeWithPicklist.put(mapKey, responseList);
        }
        System.debug('#######responseList########### => ' + responseList);
        return responseList;
    }
    
    @AuraEnabled
    public static Map<String, List<NewCAPPControllerWrapper.PicklistWrapper>> getFieldDependencies(String objName,String controllingField,String dependentField){
        Map<String, List<NewCAPPControllerWrapper.PicklistWrapper>> finalResponse = new Map<String, List<NewCAPPControllerWrapper.PicklistWrapper>>();
        Schema.DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objName).getDescribe();
        
        Schema.DescribeFieldResult controllingFieldResult = objResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldResult = objResult.fields.getMap().get(dependentField).getDescribe();
        List<Schema.PicklistEntry> controllingValues = controllingFieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : controllingValues){
            if(entry.isActive()){
                finalResponse.put(entry.getLabel(), new List<NewCAPPControllerWrapper.PicklistWrapper>());
            }
            
        }
        System.debug(finalResponse);
        for(Schema.PicklistEntry entry : dependentFieldResult.getPicklistValues()){
            if(entry.isActive()){
                Integer baseCount = 0;
                String jsonString = JSON.serialize(entry);
                NewCAPPControllerWrapper.DependentPicklistWrapper info = (NewCAPPControllerWrapper.DependentPicklistWrapper)JSON.deserialize(jsonString, NewCAPPControllerWrapper.DependentPicklistWrapper.class);
                String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
                for(Integer eachChar : hexString.getChars()){
                    Integer val = 0;
                    if(eachChar >= 65){
                        val = eachChar - 65 + 10;
                    }else{
                        val = eachChar - 48;
                    }
                    
                    if((val & 8) == 8){
                        finalResponse.get(controllingValues[baseCount + 0].getLabel()).add(new NewCAPPControllerWrapper.PicklistWrapper(entry.getLabel(),entry.getValue()));
                    }
                    if((val & 4) == 4){
                        finalResponse.get(controllingValues[baseCount + 1].getLabel()).add(new NewCAPPControllerWrapper.PicklistWrapper(entry.getLabel(),entry.getValue()));                
                    }
                    if((val & 2) == 2){
                        finalResponse.get(controllingValues[baseCount + 2].getLabel()).add(new NewCAPPControllerWrapper.PicklistWrapper(entry.getLabel(),entry.getValue()));                 
                    }
                    if((val & 1) == 1){
                        finalResponse.get(controllingValues[baseCount + 3].getLabel()).add(new NewCAPPControllerWrapper.PicklistWrapper(entry.getLabel(),entry.getValue()));                 
                    }
                    baseCount += 4;
                }
            }
        }
        System.debug('#######finalResponse########### => ' + finalResponse);
        return finalResponse;
    }
    
    @AuraEnabled
    public static String upsertCAPPS(String wrapper,String operation){
        String response = 'SUCCESS';
        try{
            String systemRelObjName = 'System_Relationship__c';
            String cappObjName = 'Customer_Portfolio_Presence__c';
            String referenceObjId = '',referenceObjName = '',accountIdForSR = '';
            List<SObject> CAPPs = (List<SObject>)Type.forName('List<Customer_Portfolio_Presence__c>').newInstance();
            List<SObject> systemRelations = (List<SObject>)Type.forName('List<System_Relationship__c>').newInstance();
            List<String> IntegerFieldtypes = new List<String>{'DOUBLE','CURRENCY','PERCENT'};
            Map<String,String> recordTypesMap = NewCAPPController.getRecordTypes(cappObjName);
            List<NewCAPPControllerWrapper.CAPPS> parseData = (List<NewCAPPControllerWrapper.CAPPS>)System.JSON.deserialize(wrapper, List<NewCAPPControllerWrapper.CAPPS>.class);
            
            for(NewCAPPControllerWrapper.CAPPS recordInstance : parseData){
                sobject CAPPInstance = Schema.getGlobalDescribe().get(cappObjName).newsObject();
                sobject SRInstance = Schema.getGlobalDescribe().get(systemRelObjName).newsObject();
                if(operation.equals('creation')){
                    referenceObjId = recordInstance.currentRecordId;
                    referenceObjName = recordInstance.currentObjName;
                    if(recordInstance.recordID.equals('CAPPRecordID')){
                        CAPPInstance.put('RecordTypeId', recordTypesMap.get(recordInstance.sectionName));
                        sobject cappRecord = NewCAPPController.getObjectInstance(recordInstance,IntegerFieldtypes,CAPPInstance);
                        CAPPs.add(cappRecord);
                    }else if(recordInstance.recordID.equals('SYSTEMRecordID')){
                        sobject systemRecord = NewCAPPController.getObjectInstance(recordInstance,IntegerFieldtypes,SRInstance);
                        systemRelations.add(systemRecord);
                    }
                }else if(operation.equals('updation')){
                    Id recordId = recordInstance.recordID;
                    String objectName = recordId.getSObjectType().getDescribe().getName();
                    if(objectName.equals(cappObjName)){
                        CAPPInstance.put('Id', recordId);
                        sobject cappRecord = NewCAPPController.getObjectInstance(recordInstance,IntegerFieldtypes,CAPPInstance);
                        CAPPs.add(cappRecord);
                    }else if(objectName.equals(systemRelObjName)){
                        SRInstance.put('Id', recordId);
                        sobject systemRecord = NewCAPPController.getObjectInstance(recordInstance,IntegerFieldtypes,SRInstance);
                        systemRelations.add(systemRecord);
                    }
                }
            }
            
            if(!referenceObjName.equals('Account') && operation.equals('creation')){
                List<Technical_Site__c> sites = [Select Id,Customer__c from Technical_Site__c WHERE Id = :referenceObjId 
                                                 LIMIT 1];
                accountIdForSR = sites.get(0).Customer__c;
            }
            if(!CAPPs.isEmpty()){
                List<Database.UpsertResult> cappRecordsResult = Database.upsert(CAPPs,false);
                for(Database.UpsertResult result : cappRecordsResult){
                    if(result.isSuccess() && result.isCreated()){
                        if(!systemRelations.isEmpty()){
                            if(referenceObjName.equals('Account')){
                                for(SObject systemRecord : systemRelations){
                                    systemRecord.put('CAPP__c',result.getId());
                                    systemRecord.put('Account__c',referenceObjId);
                                }
                            }else{
                                for(SObject systemRecord : systemRelations){
                                    systemRecord.put('CAPP__c',result.getId());
                                    systemRecord.put('Account__c',accountIdForSR);
                                    systemRecord.put('Site__c',referenceObjId);
                                }
                            }
                        }else{
                            Sobject systemRecord = Schema.getGlobalDescribe().get(systemRelObjName).newsObject();
                            if(referenceObjName.equals('Account')){
                                systemRecord.put('CAPP__c',result.getId());
                                systemRecord.put('Account__c',referenceObjId);
                            }else{
                                systemRecord.put('CAPP__c',result.getId());
                                systemRecord.put('Account__c',accountIdForSR);
                                systemRecord.put('Site__c',referenceObjId);
                            }
                            systemRelations.add(systemRecord);
                        }
                    }
                    if(!result.isSuccess()){
                        for(Database.Error err : result.getErrors()) {
                            System.debug('Error message during CAPP creation or updation = '+err.getMessage());
                            response = err.getMessage();
                        }
                        return response;
                    }
                }
            }
            
            if(!systemRelations.isEmpty()){
                List<Database.UpsertResult> systemRecordsResult = Database.upsert(systemRelations,false);
                for(Database.UpsertResult result : systemRecordsResult){
                    if(!result.isSuccess()){
                        for(Database.Error err : result.getErrors()) {
                            System.debug('Error message during SYSTEM RELATION Records updation = '+err.getMessage());
                            response = err.getMessage();
                        }
                        return response;
                    }
                }
            }
        }catch(Exception ex){
            System.debug('Line Number = '+ex.getLineNumber()+' Error message = '+ex.getMessage());
            response = ex.getMessage();
        }
        return response;
    }
    
    public static SObject getObjectInstance(NewCAPPControllerWrapper.CAPPS recordInstance, List<String> IntegerFieldtypes, SObject objInstance){
        for(NewCAPPControllerWrapper.CAPPRecords record : recordInstance.fields){
            if(String.isBlank(record.fieldValue) && !record.fieldName.equals('Name')){
                if(record.fieldType.equals('BOOLEAN')){
                    objInstance.put(record.fieldName,false);
                }else{
                    objInstance.put(record.fieldName,NULL);
                }
            }else if(!record.fieldName.equals('Name') && String.isNotBlank(record.fieldValue)){    
                if(IntegerFieldtypes.contains(record.fieldType)){
                    objInstance.put(record.fieldName,Integer.valueOf(record.fieldValue));
                }else if(record.fieldType.equals('BOOLEAN')){
                    objInstance.put(record.fieldName,Boolean.valueOf(record.fieldValue));
                }else if(record.fieldType.equals('DATE')){
                    objInstance.put(record.fieldName,Date.valueOf(record.fieldValue));
                }else if(record.fieldType.equals('DATETIME')){
                    objInstance.put(record.fieldName,Datetime.valueOf(record.fieldValue));
                }else{
                    objInstance.put(record.fieldName,record.fieldValue);
                }
            }
        }
        return objInstance;
    }
    
    @AuraEnabled
    public static Map<String,List<Customer_Portfolio_Presence__c>> getCAPPSRecords(String currentRecordId,String objName,Map<String,String> recordTypesMap) {
        List<String> fieldsList;
        Set<String> fields = new Set<String>();
        String lookupFieldname = 'Account__c';
        Set<String> cappIDs = new Set<String>();
        Map<String,List<Customer_Portfolio_Presence__c>> response = new Map<String,List<Customer_Portfolio_Presence__c>>();
        Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Customer_Portfolio_Presence__c.fieldSets.getMap();
        Id recordId = Id.valueOf(currentRecordId);
        String objectName = recordId.getSobjectType().getDescribe().getName();
        
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objName);
        for(Schema.FieldSet fieldSetObj : FsMap.values()) {
            if(recordTypesMap.containsKey(fieldSetObj.getLabel())){
                for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetObj.getName()).getFields()){
                    fields.add(fieldMember.getFieldPath());
                }
            }
        }
        fields.add('RecordTypeId');
        fields.add('RecordType.Name');
        fields.add('Name');
        fieldsList = new List<String>(fields);
        
        if(objectName.equals('Account')){
            lookupFieldname = 'Account__c';
        }else if(objectName.equals('Technical_Site__c')){
            lookupFieldname = 'Site__c';
        }
        
        String query = 'SELECT Id,CAPP__c FROM System_Relationship__c WHERE '+lookupFieldname+' =: currentRecordId';
        for(System_Relationship__c SR : Database.query(query)){
            cappIDs.add(SR.CAPP__c);
        }
        
        query = 'SELECT '+String.join(fieldsList, ',')+' FROM Customer_Portfolio_Presence__c Where Id IN :cappIDs';
        for(Customer_Portfolio_Presence__c CAPP : Database.query(query)){
            if(response.containsKey(CAPP.RecordType.Name)){
                List<Customer_Portfolio_Presence__c> existingCAPPs = response.get(CAPP.RecordType.Name);
                existingCAPPs.add(CAPP);
                response.PUT(CAPP.RecordType.Name,existingCAPPs);
            }else{
                response.PUT(CAPP.RecordType.Name,new List<Customer_Portfolio_Presence__c>{CAPP});
            }
        }
        return response;    
    }
    
    @AuraEnabled
    public static Map<String,List<System_Relationship__c>> getSRRecords(String currentRecordId,Map<String,String> recordTypesMap) {
        List<String> fieldsList;
        Set<String> fields = new Set<String>();
        String lookupFieldname = 'Account__c';
        Map<String,List<System_Relationship__c>> response = new Map<String,List<System_Relationship__c>>();
        Map<String, Schema.FieldSet> fieldSetMapSR = Schema.SObjectType.System_Relationship__c.fieldSets.getMap();
        String objectName = Id.valueOf(currentRecordId).getSobjectType().getDescribe().getName();
        
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get('System_Relationship__c');
        for(Schema.FieldSet fieldSetObj : fieldSetMapSR.values()) {
            if(recordTypesMap.containsKey(fieldSetObj.getLabel())){
                for(Schema.FieldSetMember fieldMember : sObj.getDescribe().fieldSets.getMap().get(fieldSetObj.getName()).getFields()){
                    fields.add(fieldMember.getFieldPath());
                }
            }
        }
        // Add other System_Relationship__c Fields
        fields.add('Name');
        fields.add('Account__c');
        fields.add('Site__c');
        fields.add('CAPP__c');
        fieldsList = new List<String>(fields);
        
        if(objectName.equals('Account')){
            lookupFieldname = 'Account__c';
        }else if(objectName.equals('Technical_Site__c')){
            lookupFieldname = 'Site__c';
        }
        String query = 'SELECT '+String.join(fieldsList, ',')+' FROM System_Relationship__c WHERE '+lookupFieldname+' =: currentRecordId';
        for(System_Relationship__c SR : Database.query(query)){
            if(response.get(SR.CAPP__c) != NULL){
                List<System_Relationship__c> existingSR = response.get(SR.CAPP__c);
                existingSR.add(SR);
                response.PUT(SR.CAPP__c,existingSR);
            }else{
                response.put(SR.CAPP__c,new List<System_Relationship__c>{SR});
            }
        }
        return response;    
    }
    @AuraEnabled
    public static String getRecTypeId(String recTypeName){
        RecordTypeInfo rtInfo = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(rectypeName);
        String cId = '';
        System.debug('rtInfo: ' + rtInfo + ', Name = ' + recTypeName);
        if(rtInfo != null &&rtInfo.isAvailable() && !rtInfo.isMaster()){
            if(rtInfo.name == recTypeName){
               //return the Id for the record type 
                cId = rtInfo.getRecordTypeId();
            }                
        }   
        //if the record type does not exist, or the user does not have access return empty srting
        return cId;
    }
    //SF-2538 Start
    @AuraEnabled
    public static String getCompetitorIntelligenceURL(String vendorId){
        String compIntURL = '';
        System.debug('vendorId: ' + vendorId );
        List<Account> vendorObj = [SELECT Id, Name, Competitor_Intelligence__c FROM Account  WHERE Id =:vendorId];
        if(!vendorObj.isEmpty())
            compIntURL = vendorObj[0].Competitor_Intelligence__c;
            
        return compIntURL;
    }
    
    @AuraEnabled 
    public static Boolean isVendorProdPresent(String vendorId, String cappRecordTypeName){
        Boolean disableVendorProd = true;
        System.debug('vendorId>>' + vendorId +' cappRecordTypeName>>'+cappRecordTypeName );
        List<Vendor_Product_Line__c> vendorProdList = [SELECT Id, Name, Account__c, CAPP_Record_Type_Text__c 
                                                     FROM Vendor_Product_Line__c 
                                                     WHERE Account__c =: vendorId 
                                                     AND CAPP_Record_Type_Text__c =: cappRecordTypeName]; 
        if(! vendorProdList.isEmpty() ){
            disableVendorProd = false;
        }
        return disableVendorProd;
    }
    //SF-2538 End
}