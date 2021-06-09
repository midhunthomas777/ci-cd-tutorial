/*
 * Purpose  : 
 * 
 * JIRA Number      Date            Developer               Description
 * -----------      -----------     -------------------     -----------
 * LUCXBW-621       08-Aug-2020     Hemant R                 Create a close case on click of lightning action
 * LUCXBW-781       12-Jan-2020     Bona                     Before rendering the case creationform, we are checking whether case exist for that record.
 * CITIC-503        28-Jan-2021     Bona                     Added Name,contactId,Account Id to the SOQL query in the method : getChatTranscriptRecord
 * LUCXBW-784       01-Feb-2021     Bona                     Added the method  fetchAccountRecordType
 */
public class CreateCaseController {
    /*
* @description  : Fetch the Task record
* @param params : Task record id
* @return       : wrapperClass
*/
    @AuraEnabled
    public static task getTaskRecord(Id taskRecordId,String fieldAPIName) {
        String taskQuery = 'SELECT '+fieldAPIName+ ' FROM TASK WHERE Id =:taskRecordId';
        system.debug('taskQuery*****'+taskQuery);
        return Database.query(taskQuery);
    }
    // LUCXBW-781: for the livechattransacript  record, if the case exist then we show the case number or case creation form
    //CITIC-503 : Added AccountId,Contact.Name,ContactId,Name to the query
    @AuraEnabled
    public static LiveChatTranscript getChatTranscriptRecord(Id chatRecordId) {
        String ChatTranscriptQuery = 'SELECT  id,CaseId,Case.CaseNumber,AccountId,Contact.Name,ContactId,Name,Account.Recordtype.Name  FROM LiveChatTranscript WHERE Id =:chatRecordId';       
        return Database.query(ChatTranscriptQuery);
    }
    /*
* @description  : Update the task & case record
* @param params : Task record id , case record id
* @return       : none
*/
    @AuraEnabled
    public static Task updateTaskRecord(Id taskRecordId,Id caseRecordId) {
        try{
            Case cs = new Case(Status = 'Closed',Id = caseRecordId);
            update cs;
            Task taskrecord = new Task(Id=taskRecordId,WhatId = caseRecordId);
            update taskrecord;           
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());   
        }
        return null;
    }
    /*
* @description  : Fetch Case record type on the basis of user logged in.
* @param params : none
* @return       : Map<String,String>
*/
    @AuraEnabled        
    public static Map<String,String> getPickListValuesIntoList(){
        Map<String,String> recordTypes = new Map<String,String>();
        for(RecordTypeInfo info: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
            //Condition to fetch only MSI record type...
            if(info.isAvailable() && !info.isMaster() && info.getName().startsWith('MSI Support Case')) {
                recordTypes.put(info.getRecordTypeId(), info.getName());
            }
        }
        return recordTypes;
    }
    @AuraEnabled//(cacheable = true)
    public static List<RecordsData> fetchRecords(String objectName, String searchString,String caseRecordTypeId, String accountId) {
        String recordTypeName;
        if(String.isNotBlank(caseRecordTypeId))
            recordTypeName = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(caseRecordTypeId).getName();
        System.debug('recordTypeName***'+recordTypeName);
        System.debug('searchString***'+searchString);
        List<RecordsData> recordsDataList = new List<RecordsData>();
        String searchQuery = 'FIND \'' + String.escapeSingleQuotes(searchString.trim())+'*'+ '\' IN NAME FIELDS RETURNING Contact(Name,Id ';
        if(String.isNotBlank(accountId)){
            searchQuery =  searchQuery + ',AccountId WHERE AccountId=\''+accountId+'\' LIMIT 4)';
        }   
        else{
            searchQuery = searchQuery + ' LIMIT 4)';
        }
        /* if(String.isNotBlank(recordTypeName) && (recordTypeName == 'MSI Support Case' || recordTypeName == 'MSI Support Case - INCIDENT' || recordTypeName ==    'MSI Support Case - TECHNICAL REQUEST')){
            if(String.isNotBlank(accountId))
                searchQuery =  searchQuery + ',AccountId WHERE AccountId=\''+accountId+'\' LIMIT 4)';
            else
                searchQuery = searchQuery + ' LIMIT 4)';
            
        }
        else{
            searchQuery = searchQuery + ' LIMIT 4)';
        }*/
        System.debug('searchQuery******'+searchQuery);
        try {
            /*for(SObject s : Database.query(query)) {
recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
}*/
            List<List<sObject>> searchList = search.query(searchQuery);
            Contact[] searchContacts = (Contact[])searchList[0];
            for (Contact c : searchContacts) {
                recordsDataList.add( new RecordsData(c.Name, c.Id) );
            }
            System.debug('recordsDataList*****'+recordsDataList);
            return recordsDataList;
        } catch (Exception err) {
            System.debug('errorMessage***'+err.getMessage());
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }
    //Inner class with @AuraEnabled {get;set;} properties*  
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    /* @description  : Update the transcript record with caseId
    * @param params : transcript record id , case record id
    * @return       : none
    */
    @AuraEnabled
    public static LiveChatTranscript updateTranscriptRecord(Id transcriptRecordId,Id caseRecordId) {
        try{
            Case cs = new Case(Status = 'Closed',Id = caseRecordId);
            update cs;
            LiveChatTranscript transcriptrecord = new LiveChatTranscript(Id=transcriptRecordId,CaseId = caseRecordId);
            update transcriptrecord;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());    
        }
        return null;
    }
    //LUCXBW-784 to check the record type ,child accounts and based on that show the field customer number
    @AuraEnabled
    public static Map<String, String> getAccountChildRecords(string AccountId) {        
        Map<String, String> mapChildAct = new Map<String, String>();
        list<account> lstAccount  = [SELECT  id,name, MCN_Account_Name__c FROM Account  where ParentId  =:AccountId and recordtype.developername ='Motorola_Customer_Number' and ERP_Active__c = true];
        if(lstAccount.size() > 0){
            for(Account objAccount:lstAccount){
                mapChildAct.put(objAccount.id, objAccount.MCN_Account_Name__c+'('+objAccount.name+')');
            }
        }
        return mapChildAct;
    }

    //LUCXBW-784 -we are validating the contact in the case, to check whether that contact is mapped to the current account
    @AuraEnabled
    public static string validateContact(string ContactId){       
        contact contactObj = [SELECT id,AccountId FROM contact WHERE Id =:ContactId];
        return contactObj.AccountId; 
    }
   
    
}