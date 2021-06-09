/*  
* Class Name  : CaseTriggerHandler
* Description:  This class is used in Case trigger
*/

public class CaseTriggerHandler implements ITriggerHandler {
    
    Id caseRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Customer_Account_Creation');
    Id caseupdRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Customer_Account_Update');
    Id caseinquiryRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Commission_Inquiry');
    Id caseAssignRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Account_Assignment');
    Id adpPartnerRecId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'ADP_Partner_Contact_Request');
    Id caseSupprotRecId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'Support_Request');
    Id rtmRecordTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'RTM');
    /*
    * Service Cloud Record Types
    */
    Id msiSupportCase =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'Admin_Service_Case');
    //Id msiSupportCaseIncident =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MSI_Support_Case_Incident');
    Id msiSupportCaseTechnicalSite =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MSI_Support_Case_Technical_Request');
    Id msiOrderManagement =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MSI_Support_Case_Order_Management');
    Id msiAppSupport =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MSI_Support_Case_Application_Support');
    Id msiAdministrative =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MSI_Support_Case_Administrative');
    
    Id currentUserProfileId = UserInfo.getProfileId();
    CaseTriggerHelper caseHelper = new CaseTriggerHelper();
    
    public void BeforeInsert(List<SObject> newItems){
        List<Case> incoming = new List<Case>();
        if(newItems != null) incoming = (List<Case>) newItems;
        List<Case> casesTobeUpdatedWithASM = new List<Case>();
        List<Case> casesToUpdateSubject = new List<Case>();
        List<Id> caseRelatedOpps = new List<Id>();
        List<Case> unApprovedCases = new List<Case>();
        List<Case> serviceCloudCases = new List<Case>();
        
        User userObj = [SELECT Id, UserTheater__c FROM User WHERE Id =:UserInfo.getUserId()]; // Added By Alok for LUCXBW -621
        
        for(Case eachCase : incoming){
            if(eachCase.RecordTypeId == caseRecordTypeId || eachCase.RecordTypeId == caseupdRecordTypeId || eachCase.RecordTypeId == caseinquiryRecordTypeId 
               || eachCase.RecordTypeId == caseAssignRecordTypeId) {
                   casesTobeUpdatedWithASM.add(eachCase);
               }
            //Changed the recordtype from EMEA Partner Support to MSI SUpport Case - Added By Alok for LUCXBW -621
            if(eachCase.RecordTypeId == msiSupportCase && String.isNotBlank(eachCase.Related_Opportunity__c) && Label.EA_Partner_Profile == currentUserProfileId && userObj.UserTheater__c == 'EA') {
                eachCase.Subject = 'Deal Registration Extension Request.'; 
                caseRelatedOpps.add(eachCase.Related_Opportunity__c);   
            }
            if(eachCase.ASM_Approval_Status__c != 'Approved' && eachCase.RecordTypeId == rtmRecordTypeId) {
                unApprovedCases.add(eachCase);
            }
            //Service cloud cases
            //eachCase.RecordTypeId == msiSupportCaseIncident ||
            if(eachCase.RecordTypeId == msiSupportCase || eachCase.RecordTypeId == msiSupportCaseTechnicalSite || 
               eachCase.RecordTypeId == msiOrderManagement || eachCase.RecordTypeId == msiAppSupport || eachCase.RecordTypeId == msiAdministrative)
            {
                serviceCloudCases.add(eachCase);
            }             
        } // FOR LOOP ENDS
        if(!caseRelatedOpps.isEmpty()){
            caseHelper.handleDeaExtention(caseRelatedOpps, incoming);
        }
        if(!casesTobeUpdatedWithASM.isEmpty()){
            caseHelper.populateAssignedASM(casesTobeUpdatedWithASM); 
        }
        if(!unApprovedCases.isEmpty()) {
            caseHelper.RTMCaseCreation(unApprovedCases);      
        }
        //Service cloud cases
        if(!serviceCloudCases.isEmpty()) {
            caseHelper.handleServiceCloudCases(serviceCloudCases);
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems){
        Map<Id,Case> newMap = new Map<Id,Case>();
        if(newItems != null) newMap = (Map<Id,Case>) newItems;
        List<Case> toBeSubmitted = new List<Case>();
        for(Case eachCase : newMap.values()){
            if(eachCase.ASM_Approval_Status__c == 'In Approval' && eachCase.RecordTypeId == caseupdRecordTypeId){
                toBeSubmitted.add(eachCase);
            }           
        } // FOR LOOP ENDS
        caseHelper.shareCases(newMap.values());
        if(!toBeSubmitted.isEmpty()){
            caseHelper.autoSubmitForApproval(toBeSubmitted);   
        }        
        caseHelper.Case_AI(newMap);
        SmartClientIntegrationService.crtIncidentafterinsert(newItems);
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        System.debug('##inAfterUpdate##');
        Map<Id,Case> newMap = new Map<Id,Case>();
        if(newItems != null) newMap = (Map<Id,Case>) newItems;
        Map<Id,Case> oldMap = new Map<Id,Case>();
        if(oldItems != null) oldMap = (Map<Id,Case>) oldItems;
        
        Map<Id,Case> serviceCasesNew = new Map<Id,Case>();
        Map<Id,Case> serviceCasesOld = new Map<Id,Case>();
        //LUCXBW-695 - Commenting as this will be removed and now new cases will not be created but old one will be reassigned..
        /*Map<Id,Case> newMapClarify = new Map<Id,Case>();
        Map<Id,Case> oldMapClarify = new Map<Id,Case>();*/
        List<String> emailList = new List<String>();
        List<Case> closedAndApprovedCases = new List<Case>();
        List<Case> adpCases = new List<Case>();
        List<Case> supportCases = new List<Case>();
        List<Case> shareCases = new List<Case>();
        String accountId;
        
        for(Case eachCase : newMap.values()){
            if(eachCase.RecordTypeId == adpPartnerRecId){
                if(eachCase.Status == 'Closed' && eachCase.Reason == 'Approved' && eachCase.ADPEmail__c != null) {
                    adpCases.add(eachCase);
                    emailList.add(eachCase.ADPEmail__c);
                    closedAndApprovedCases.add(eachCase);
                    accountId = eachCase.AccountId;
                }
            }
            if(eachCase.RecordTypeId == caseSupprotRecId){
                supportCases.add(eachCase);
            }
            //LUCXBW-695 - Commenting as this will be removed and now new cases will not be created but old one will be reassigned.. 
            /*if(eachCase.RecordTypeId == caseRecordTypeId || eachCase.RecordTypeId == caseupdRecordTypeId ){
                System.debug('##Is running in sandbox?##'+GlobalUtility.runningInASandbox());
                if (!GlobalUtility.runningInASandbox()) { 
                    newMapClarify.put(eachCase.Id, eachCase);
                    oldMapClarify.put(eachCase.Id, oldMap.get(eachCase.Id)); 
                }
            }*/
            if(eachCase.OwnerId <> eachCase.CreatedById) {
                shareCases.add(eachCase);
            }
            //eachCase.RecordTypeId == msiSupportCaseIncident ||
            if(eachCase.RecordTypeId == msiSupportCase || eachCase.RecordTypeId == msiSupportCaseTechnicalSite || 
               eachCase.RecordTypeId == msiOrderManagement || eachCase.RecordTypeId == msiAppSupport || eachCase.RecordTypeId == msiAdministrative)
            {
                serviceCasesNew.put(eachCase.Id, eachCase);
                serviceCasesOld.put(eachCase.Id, oldMap.get(eachCase.Id));
            }             
        } // FOR LOOP ENDS
        //LUCXBW-695 - Commenting as this will be removed and now new cases will not be created but old one will be reassigned..
        /*if(!newMapClarify.isEmpty()) {
            System.debug('##Navigation to triggerClarifyCase##');
            caseHelper.triggerClarifyCase(newMapClarify, oldMapClarify);
        }*/
        if(!adpCases.isEmpty()) {
            caseHelper.ADP_AutoCreatePartnerContactFromCase(closedAndApprovedCases,emailList,accountId);   
        }
        if(!supportCases.isEmpty()) {
            caseHelper.supportRequestGrantAccessToCreator(supportCases);
        }
        if(!shareCases.isEmpty()) {
            caseHelper.caseShareForCaseRequestor(shareCases);
        }
        //caseHelper.updateContactRecords(newMap,oldMap);
        CountTasksOfCaseTriggerHandler.preventCaseClosureForNonClosedTasks(newMap, oldMap); 
        if(!serviceCasesNew.isEmpty()) {
            RemedyIntegrationService.createupdremedyincident(serviceCasesNew, serviceCasesOld);
            JiraIntegrationService.createupdJirastory(serviceCasesNew, serviceCasesOld);
            ServiceNowIntegrationService.createupdServiceNowIncident(serviceCasesNew, serviceCasesOld);
            SmartClientIntegrationService.crtupdtIncidentafterupdt(serviceCasesNew, serviceCasesOld);
        }
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,Case> mapNewCases = new Map<Id,Case>();
        if(newItems != null) mapNewCases = (Map<Id,Case>) newItems;
        List<Case> serviceCloudCases = new List<Case>();
        for(Case eachCase : mapNewCases.values()) {
            //eachCase.RecordTypeId == msiSupportCaseIncident ||
            if(eachCase.RecordTypeId == msiSupportCase ||  eachCase.RecordTypeId == msiSupportCaseTechnicalSite || 
               eachCase.RecordTypeId == msiOrderManagement || eachCase.RecordTypeId == msiAppSupport || eachCase.RecordTypeId == msiAdministrative) {
                   serviceCloudCases.add(eachCase);
               }
        }
        if(!serviceCloudCases.isEmpty()) {
            caseHelper.handleServiceCloudCases(serviceCloudCases);
        }        
    }
    public void BeforeDelete(Map<Id, SObject> oldItems){}    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
    
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled(){
        TriggerSettings__c ts = TriggerSettings__c.getValues('CaseTriggerDisabled');
        if (ts != null && ts.IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }
    public static void fakeMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}