public class GlobalUtility {
    
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    } 
    //SF-2108:Anand: Created a method to restrict picklist values
    public static boolean isPicklistValuesFromValueSet(string objectName, string fieldName,string fieldValue){
        List<String> pickListValuesList= new List<String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult fieldInfo = describeResult.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldInfo.getPicklistValues();
        for(Schema.PicklistEntry currValue : picklistValues){
            pickListValuesList.add(currValue.getValue());            
        }
        if(pickListValuesList.contains(fieldValue))
            return true;
        else
            return false;
    }
    
    public static ID recordTypeId(String objectName, String recordTypeName) {  
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);
        // check the sObject is available in the system   
        if (sObj != null) {  
            Schema.DescribeSObjectResult sObjReslt = sObj.getDescribe();  
            // check the sObject result is not null  
            if (sObjReslt != null) {
                Map<String,Schema.recordTypeInfo> mapRecordsType = new Map<String,Schema.recordTypeInfo>();  
                mapRecordsType = sObjReslt.getRecordTypeInfosByName(); 
                // pass the recordtype  
               return mapRecordsType.get(recordTypeName).getRecordTypeId(); 
               //return sObjReslt.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            }  
        }  
        return null;  
    }  
    
    public static Map<String, String> fetchIntegrationUsers(String objectName) {
        Map<String, String> iUsers = new Map<String, String>();
        for(Integration_Users__mdt iUser : [Select DeveloperName, User_Id__c from Integration_Users__mdt where Object__c =: objectName]){
            iUsers.put(iUser.DeveloperName, iUser.User_Id__c);
        }
        return iUsers;
    }
    
    public static List<String> fetchFieldsByObject(String objectName, String type, Boolean onlyCustom, Boolean onlyStandard) {
        List<String> lookupFields = new List<String>();
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField fld :objectFields.values()){
            Schema.describeFieldResult dfield = fld.getDescribe();
            if(onlyCustom) {
                if (String.valueOf(dfield.getType()) == type && dfield.isCustom()){
                    lookupFields.add(String.valueOf(dfield.Name));
                }
            } else if(onlyStandard) {
                if (String.valueOf(dfield.getType()) == type && !dfield.isCustom()) {
                    lookupFields.add(String.valueOf(dfield.Name));
                }
            } else {
                if (String.valueOf(dfield.getType()) == type){
                    lookupFields.add(String.valueOf(dfield.Name));
                }
            }
        }        
        return lookupFields;
    }
    
    public static List<String> fetchAllFieldsByObject(String objectName){
        List<String> allFields = new List<String>();        
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for(Schema.SObjectField fld :objectFields.values()){
            Schema.describeFieldResult dfield = fld.getDescribe();            
            allFields.add(String.valueOf(dfield.Name));
        }
        
        return allFields;
    }
    
    public static String fetchQueryForAllFieldsByObject(String ObjectName){
        return 'SELECT '+String.join(fetchAllFieldsByObject(ObjectName),',')+' FROM '+ObjectName;
    }
    
    public static String fetchQueryByFieldSet(Id recordId, String fieldSetName) {
        String objectName = recordId.getSObjectType().getDescribe().getName();
        List<String> queryFields = new List<String>();
        for(Schema.FieldSetMember fieldMember : readFieldSet(fieldSetName, objectName)){
            queryFields.add(fieldMember.getFieldPath());
        }
        if(!queryFields.isEmpty()) {
            return 'Select Id, ' + String.join(queryFields, ',') + ' FROM ' + objectName+' WHERE Id=\''+recordId+'\'';    
        } else {
            return 'Select Id FROM ' + objectName+' WHERE Id=\''+recordId+'\'';
        }
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }  
    
    public static Map<String, Alerts_And_Messages__mdt> metaMessagesMap(Id recordId, String feature){
        Map<String, Alerts_And_Messages__mdt> metaMessagesMap = new  Map<String, Alerts_And_Messages__mdt>();
        //String objectName = recordId.getSObjectType().getDescribe().getName();
        for(Alerts_And_Messages__mdt refinedMessage:[Select Id,DeveloperName,Message__c, Message_Type__c, Success_OR_Error_Messages__r.DeveloperName,Success_OR_Error_Messages__r.Object_Name__c 
                                                     From Alerts_And_Messages__mdt Where Success_OR_Error_Messages__r.DeveloperName=:feature])
        {
            metaMessagesMap.put(refinedMessage.DeveloperName,refinedMessage);
        }    
        return metaMessagesMap;
    }
    
    /*public static List<Quick_Link_Framework__mdt> metaLinks(String linkLocation, String profileName){
        return [SELECT Id,MasterLabel,DeveloperName,Link__c,Link_Label__c,Target__c
                FROM Quick_Link_Framework__mdt WHERE MasterLabel=:profileName AND Link_Location__c=:linkLocation];
    }*/
    
    public static List<MR_Digitization_Settings__mdt> getDigitizationSettings(String developerName){
        return [SELECT Id,MasterLabel,DeveloperName,Long_Text_Area__c,Values__c
                FROM MR_Digitization_Settings__mdt WHERE DeveloperName=:developerName];
    }
    
    public static string userTheme(){
        return userInfo.getUiThemeDisplayed();
    }
    
    public static List<String> fetchPicklistsByObjectAndField(String objectName, String fieldName){ 
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : pick_list_values) {
            if(a.isActive()) {
                lstPickvals.add(a.getValue());   
            }
        }
        return lstPickvals;
    }
    
    //Below method will return ContentDocument infomation
    public static List<ContentDocumentLink> getContentDocuments(String recordId) {
        return [SELECT Id,ContentDocumentId,ContentDocument.Title,ContentDocument.OwnerId,ContentDocument.ParentId,ContentDocument.ContentSize,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
    }
    
    // This method returns ContentDocumentId along wiht the FileProperties (ContentVersion)
    public static Map<Id, ContentVersion> getContentVersionDetails(Set<Id> parentIds){
        Map<Id, ContentVersion> contentDocumentBodyMap = new Map<Id,ContentVersion>();
        Set<String> docIDs = new Set<String>();
        
        List<ContentDocumentLink> contentDocuments  =[SELECT ContentDocumentId, ContentDocument.Title, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId IN:parentIds];
        
        for(ContentDocumentLink cd : contentDocuments) {
            docIDs.add(cd.ContentDocumentId); 
        }
        
        for(ContentVersion cvers:[select Id,versionData,ContentDocumentId,FileType,Title from ContentVersion where ContentDocumentId IN :docIDs]){
            contentDocumentBodyMap.put(cvers.ContentDocumentId,cvers);
        }
        
        return contentDocumentBodyMap;
    }
    
    //Below method will return ContentVersion record it.
    public static ContentVersion createContentVersion(String name, Blob body){
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = name;
        contentVersion.Title = name;
        contentVersion.VersionData = body;
        return contentVersion;
    }
    //Below method will return ContentDocumentLink record it.
    public static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId,String shareType, String visibility){
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = shareType; // Inferred permission
        contentDocumentLink.Visibility = visibility;
        return contentDocumentLink;
    }
    
    @AuraEnabled
    public static String getBaseUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    public static ID getRecordTypeIdByDeveloperName(String objectName, String developerName) {
        Schema.SObjectType sObj = Schema.getGlobalDescribe().get(objectName);  
        // check the sObject is available in the system   
        if (sObj != null) {  
            Schema.DescribeSObjectResult sObjReslt = sObj.getDescribe();  
            // check the sObject result is not null  
            if (sObjReslt != null) {  
                Map<String,Schema.recordTypeInfo> mapRecordsType = new Map<String,Schema.recordTypeInfo>();  
                mapRecordsType = sObjReslt.getRecordTypeInfosByDeveloperName();  
                
                //system.debug('########mapRecordsType######## => ' + mapRecordsType);
                return mapRecordsType.get(developerName).getRecordTypeId();  
            }  
        }  
        return null;
    }   
    
    public static Map<String,String> fetchPicklistsByObjectAndFieldMap(String objectName, String fieldName){ 
        Map<String,String> pickDef = new Map<String,String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : pick_list_values) {
            if(a.isActive()) {
                pickDef.put(a.getValue(), a.getLabel());
            }
        }
        return pickDef;
    }
    
    public static List<String> fieldsByFieldSet(String objectName, String fieldSetName) {
        List<String> queryFields = new List<String>();
        for(Schema.FieldSetMember fieldMember : readFieldSet(fieldSetName, objectName)){
            queryFields.add(fieldMember.getFieldPath());
        }
        return queryFields;
    }
    
    public static Boolean isLoggedinPartnerUser() {
        if(UserInfo.getUserType() == 'PowerPartner') {
            return TRUE;
        }
        return FALSE;
    }
    
    public static void approvalProcessRejectionCmtsMandatory(Map<Id,Sobject> mapSobject){
        if(!mapSobject.isEmpty()){
            List<Id> processInstanceIds = new List<Id>{};
                for(ProcessInstance proIns : [SELECT ID, TargetObjectId FROM ProcessInstance WHERE Status='Rejected' AND TargetObjectId IN : mapSobject.keySet() ORDER BY CreatedDate DESC LIMIT 1 ]){
                    processInstanceIds.add(proIns.Id);
                }
            if(!processInstanceIds.isEmpty()){
                for (ProcessInstance processInst : [SELECT TargetObjectId,(SELECT Id, StepStatus, Comments FROM Steps WHERE StepStatus = 'Rejected' ORDER BY CreatedDate DESC LIMIT 1)
                                                    FROM ProcessInstance WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC])
                {
                    if (processInst.Steps[0].Comments == NULL || processInst.Steps[0].Comments.trim().length() == 0)
                    {
                        mapSobject.get(processInst.TargetObjectId).addError(System.label.Approval_Rejection_Comments_Mandatory);
                    }
                }  
            }
        }  
    }
    
   
    /* Developed below method as part of SF-1954 - APAC Communities: 
APAC Deal Registration - Displaying Message for Submitted Opportunity  */
    @AuraEnabled
    public static string submitAndProcessApprovalRequest(Id recordId, Id recordTypeId, String region, String functionality){
        String objectName = recordId.getSObjectType().getDescribe().getName();
        //String recordTypeName = getRecordTypeNameById(objectName, recordTypeId);
        String recordTypeName = getRecordTypeDeveloperNameById(objectName, recordTypeId);
        system.debug('##Id objectName##'+objectName);
        system.debug('##Id recordTypeName##'+recordTypeName);
        system.debug('##Id recordId##'+recordId);
        system.debug('##Id recordTypeId##'+recordTypeId);
        system.debug('##Id region##'+region);
        system.debug('##Id functionality##'+functionality);
        List<Submit_For_Approval_Queue_Finder__mdt> lstSubmitApprovalMeta = [Select MasterLabel,Approval_Process_API_Name__c,Object_Name__c,
                                                                             Record_Type__c,SkipEntryCriteria__c,Region__c,Submission_Comment__c,Submitter_User_Id__c,
                                                                             Queue_Id__c from Submit_For_Approval_Queue_Finder__mdt where MasterLabel =: functionality AND  
                                                                             Object_Name__c =:objectName AND Record_Type__c =:recordTypeName AND Region__r.MasterLabel =: region  LIMIT 1];
        
        system.debug('GloabalUtility recordId==>'+recordId + '----------REc');  
        if(!lstSubmitApprovalMeta.isEmpty()) {
            Approval.ProcessSubmitRequest subReq =  new Approval.ProcessSubmitRequest();
            subReq.setComments(lstSubmitApprovalMeta.get(0).Submission_Comment__c);
            subReq.setObjectId(recordId);
            if(String.isNotBlank(lstSubmitApprovalMeta.get(0).Queue_Id__c)){
                subReq.setNextApproverIds(new Id[] {lstSubmitApprovalMeta.get(0).Queue_Id__c}); //This is to run custom approval process
            } else {
                subReq.setSkipEntryCriteria(true);
                if(String.isNotBlank(lstSubmitApprovalMeta.get(0).Submitter_User_Id__c)){
                    subReq.setSubmitterId(lstSubmitApprovalMeta.get(0).Submitter_User_Id__c); 
                } else {
                    subReq.setSubmitterId(UserInfo.getuserId());
                }
                subReq.setProcessDefinitionNameOrId(lstSubmitApprovalMeta.get(0).Approval_Process_API_Name__c);
                //subReq.setSkipEntryCriteria(lstSubmitApprovalMeta.get(0).SkipEntryCriteria__c);
            }
            try{
                Approval.ProcessResult result = Approval.process(subReq);
                return 'success';
            }catch(exception e){
                system.debug('Error in Approval Process' + e.getMessage());
                return e.getMessage();
            }
        }
        return 'success';
    } 
    //Added as part of SF-2059 - Partners get redirected to wrong place after quote deletion
    @AuraEnabled
    public static Id deleteRecord(Id rec){        
        system.debug('id is===>'+rec);
        if(rec!=null){
            list<BigMachines__Quote__c> quotelist=[select id,name,BigMachines__Account__c from BigMachines__Quote__c where id=:rec];
            if(quotelist.size()>0){
                system.debug('id issss===>'+quotelist.size());
                Id recordid=quotelist[0].BigMachines__Account__c;
                delete quotelist[0];
                system.debug('*****'+recordid);     
                return recordid;
            }
            else{
                return null;
            }
        }
        else {
            return null;
        }        
    }
    
    public static Boolean isLoggedinCustomerCommunityUser() {
        if(UserInfo.getUserType() == 'PowerCustomerSuccess' ||  UserInfo.getUserType() == 'CspLitePortal' ) {
            return TRUE;
        }
        return FALSE;
    }
    
    public static String buildHttpUrl(Map<String, String> params){
        String url = '';
        for (String key : params.keySet()){
            if (url.length() != 0){
                url += '&';
            }                
            url += key + '=' + params.get(key);
        } 
        return EncodingUtil.urlEncode(url, 'UTF-8');
    }
    public static Map<String, CurrencyType> getConversionRate(Set<String> isoCodes){
        Map<String, CurrencyType> conversionRates = new Map<String, CurrencyType>();
        for(CurrencyType rate : [SELECT Id,IsoCode,ConversionRate,IsCorporate,DecimalPlaces FROM CurrencyType WHERE IsoCode IN : isoCodes AND isActive = True]){            
            conversionRates.put(rate.IsoCode, rate); 
        }                           
        //system.debug('test currency map--->'+conversionRates);
        return conversionRates;
    }
    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[SELECT Id FROM UserRole WHERE ParentRoleId IN :roleIds AND ParentRoleID != NULL]) {
            currentRoleIds.add(userRole.Id);
            //system.debug('userrolid***'+userRole.Id);
        }
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        }
        return currentRoleIds;
    }
    public static String getSObjectNameById(Id recordId){
       return recordId.getSobjectType().getDescribe().getName();
    }
    /*****
    ** Fetch the previous business days
    *****/
    public static Datetime subtractDays(Datetime startDate, Integer days, String businessHoursName)
    {
        BusinessHours bHours =  [SELECT Id FROM BusinessHours WHERE Name =: businessHoursName];
        //If startdate is not within working days, take previous working day
        startDate = getPreviousWorkingDay(startDate,bHours);
        for (Integer elapsed = 0; elapsed < days; elapsed++)
        {
            //Subtract 1 day
            startDate = startDate.addDays(-1);
            //Check if new date is within working days
            if (!BusinessHours.isWithin(bHours.Id, startDate))
            { 
                //If new date is not within working days, get previous working day
                startDate = getPreviousWorkingDay(startDate,bHours);
            }
        }
        return startDate;
    }
    /**
     * Recursive function to get previous working day
     * If date passed to this function is on a working day, this will return same date
     * If date passed to this function is not on a working day, this will return previous working day
     * *********************
     * For Example, if day passed to this function is Monday, this will return Monday
     * but if day passed to the function is Sunday, then this will return Friday
     * *********************
     * @param - d - Date to operate on
     * */
    public static Datetime getPreviousWorkingDay(Datetime d,BusinessHours bHours){
        
        
         //Check if new date is within working days
        if (!BusinessHours.isWithin(bHours.Id, d))
        {
            //New date is not within working days, recursively call same function to get previous date by subtracting 1 day
            d = d.addDays(-1);
            return getPreviousWorkingDay(d,bHours);
        } else{
            //New date is within working days, return this date
            return d;
        }
    }
    
        public static String getRecordTypeDeveloperNameById(String objectName, Id strRecordTypeId) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getDeveloperName();
    } 
}