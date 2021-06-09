/**
 *  DocumentChangeHistory
 *   
 *  Checks if Agreement Document Tracking is enabled and if so create activity entry.
 *  This check is performed by Attachment and Agreement Document Trigger during Edit and Delete process.
 *  
 *  Rules specify the conditions under which the history record is created:
 *  1. Admin Object Flag is not set to false (default for flag is true)
 *  2. Allowed if (parent) Agreement's Status_Category/Status is any of the following combination:-
 *      - In Effect
 *      - Expired
 *      - Terminated
 *      - Amended
 *      - Cancelled
 */
 /*  
* Modification Log 
* ============================================================================= 
* Ver   Date        Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   22-Apr-10   Apptus Team                   Initial Code
* 1.1   10-Apr-12   Shipra Upadhyaya              Modification in isValidTrackingStatus method is required to adhere
                                                  Ticket INC000006621107 .It has been approved by Deepthi and Christine Seton.
*/
public with sharing class DocumentChangeHistory {

    public static String PROFILE_SYS_ADMIN = 'System Administrator';
    public static String ADMIN_ENABLE_DOCUMENT_TRACKING = 'APTS_Enable_Document_Tracking';
    // status_category
    public Static String STATUS_CATEGORY_IN_EFFECT = 'In Effect';
    public Static String STATUS_CATEGORY_EXPIRED = 'Expired';
    public Static String STATUS_CATEGORY_TERMINATED = 'Terminated';
    public Static String STATUS_CATEGORY_AMENDED = 'Amended';
    public Static String STATUS_CATEGORY_CANCELLED = 'Cancelled';
    public Static String ACTION_ADDED = 'Added';
    public Static String ACTION_EDITED = 'Edited';
    public Static String ACTION_DELETED = 'Deleted';
    public Static String TARGET_AGREEMENT_DOCUMENT = 'Agreement Documents';
    public Static String TARGET_NOTES_ATTACHMENT = 'Notes & Attachments';
    
    // error message
    public static String ERROR_MESSAGE = 'Error creating tracking entry.';
    
    //private Apttus__APTS_Agreement__c agmt = null;
    //added by shipra to avoid exception
    private List<Apttus__APTS_Agreement__c> agmt = new List<Apttus__APTS_Agreement__c>();
    private Set<ID> recTypeIds = null;
    private String adminFlag='true';
        
    // prevent empty instantiation
    private DocumentChangeHistory() {
        init(); 
    }
    
    /**
    * Constructor with parent Agreement identifier.
    */
    public DocumentChangeHistory(ID agmtId) {
        this();
        system.debug('agreement id here in constructor is **'+agmtId); 
        getAgreement(agmtId);               
    }
    private void init() {
        
        //  admin flag for tracking
        List<Apttus__APTS_Admin__c> adminList = [select name, Apttus__Value__c 
                        from Apttus__APTS_Admin__c
                        where name = :ADMIN_ENABLE_DOCUMENT_TRACKING limit 1];
                        
        if ((adminList != null) && (!adminList.isEmpty())) {    
            adminFlag = adminList[0].Apttus__Value__c;
        }   
        System.debug('Admin entry '+adminFlag);
        System.debug('Admin record ' + adminList);
    }
    private void getAgreement(ID agmtId) {
    //Added debug by Shipra
    system.debug('agreement id here is **'+agmtId);                           
        agmt = [select Id, Name
                , Apttus__Status_Category__c
                , Apttus__Status__c
                , RecordTypeId
                from Apttus__APTS_Agreement__c
                where Id = :agmtId];    
                System.debug('AGMT-RECORD-TYPE-ID' + agmt);
    }
    public Boolean isTrackingEnabled() {
        if(adminFlag==null || adminFlag == 'true' || adminFlag=='')
            return true;
        else 
            return false;
    }
    
    public Boolean isValidTrackingStatus(){
        /*Modified by Shipra to avoid exception ..
            It'll work in our case when user does not have access to query Agreement 
            because in that case agmt will be empty and it'll return false .It should
            be fine to return false because agreement record we are inserting is for 
            status 'Request' which does not lie in TRUE condition (got to know this from
            comments at top of the class)So,anyways it has to return false only .
            For normal cases user having access to Activity history for Agreement attachment
            should have access to agreemet So,It will check for conditions and return appropriate */
            
        if(!agmt.isEmpty()){
             if(agmt[0].Apttus__Status_Category__c!=STATUS_CATEGORY_IN_EFFECT && 
                agmt[0].Apttus__Status_Category__c!=STATUS_CATEGORY_EXPIRED &&
                agmt[0].Apttus__Status_Category__c!=STATUS_CATEGORY_TERMINATED &&
                agmt[0].Apttus__Status_Category__c!=STATUS_CATEGORY_AMENDED &&
                agmt[0].Apttus__Status_Category__c!=STATUS_CATEGORY_CANCELLED)
                return false;
            else
                return true;
           }
           else{
                return false;             
           }
           
           /* previous snippet was ..
              if(agmt ==null || (agmt.Apttus__Status_Category__c!=STATUS_CATEGORY_IN_EFFECT && 
                agmt.Apttus__Status_Category__c!=STATUS_CATEGORY_EXPIRED &&
                agmt.Apttus__Status_Category__c!=STATUS_CATEGORY_TERMINATED &&
                agmt.Apttus__Status_Category__c!=STATUS_CATEGORY_AMENDED &&
                agmt.Apttus__Status_Category__c!=STATUS_CATEGORY_CANCELLED ))
                return false;
            else
                return true; */  
        }
    
    public void createTrackingEntry(String docName, String action, String target){
        /* Here if user in not having access so that agreement can be queried it 'll 
        go to catch block due to error in 116 .It should be fine for our case as we 
        need not create track on agreement with status ='Request'and we are inserting 
        likewise in generate pdf button for presales. */
        
        Task taskObj = new Task();
        taskObj.subject = 'Document '+action + ' in '+target;
        taskObj.Description = docName ;
        taskObj.ownerId = UserInfo.getUserId();
        taskObj.WhatId = agmt[0].Id;
        taskObj.status='Completed';
        System.debug('Task before insert '+taskObj);
        try{
            insert taskObj;
        }catch (Exception e){
            System.debug('Error when creating Activity history:' + e);
        }
    }

}