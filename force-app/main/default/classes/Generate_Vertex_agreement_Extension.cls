public class Generate_Vertex_agreement_Extension
{

    private final Account account;        
    private ApexPages.StandardController stdController;    
    private ID agRecordTypeID = [select Id from RecordType where Name = 'Reseller/Distributor' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1].id;
  //  private ID motentId = [select Id from Account where Name = 'Motorola Solutions, Inc.' limit 1].id;
    public List<Apttus__APTS_Template__c> templatesOb = new List<Apttus__APTS_Template__c>();
    public static Id agreeId;
    
    private ID attorneyId = [select Id from user where name ='Kimberly Hakim' limit 1].id;

 public Generate_Vertex_agreement_Extension(ApexPages.StandardController controller) {
 
        stdController = controller;            
        account = (Account ) stdController.getRecord(); 
 
 }
 
 public PageReference createvertexAgreement(){
 
 try {
     system.debug('Entering into generate method');
     Apttus__APTS_Agreement__c newAgreement = new Apttus__APTS_Agreement__c();
     Account acc = [select Partner_Distributor_email__c, OwnerId, BillingState, Territory__c  from Account where Id= :account.id];
     List<Territory_Master__c> TMlist = new List<Territory_Master__c>();
     String State;
     String Territory;
     
     if (acc.Territory__c  != null) {
     
         Territory = acc.Territory__c;
     
     } else {
     
         Territory = '';    
     
     }
     
     if(acc.BillingState != null) {      
         TMlist = [SELECT State_Code__c, State_Province__c FROM Territory_Master__c WHERE State_Code__c = :acc.BillingState.toUpperCase() limit 1];
          if(TMlist.size() <=0 ) {
          State = 'Not Applicable';
          } else {
             State = TMlist[0].State_Province__c;  
           }    
     } else {
         State = 'Not Applicable';
     }
     
     system.debug('account id is ' +account.id);
     newAgreement.Name = 'Gen Vertex';
     newAgreement.Agreement_Title__c = 'Vertex Partner Agreement';
     newAgreement.RecordTypeID = +agRecordTypeID;
     newAgreement.Apttus__Subtype__c = 'Channel Partner (includes legacy G&PS, WNS and EMb Channel Partners)';
     newAgreement.m_Business_Unit__c = 'Government';
     newAgreement.m_GTM_Region__c = 'North America';
     newAgreement.m_State_Name__c = +State;
     newAgreement.m_State_and_Local_Territory__c = Territory;
     newAgreement.Apttus__Account__c = +account.id;
     newAgreement.Motorola_Entity_Account__c = '0018000001DSz7I';
     newAgreement.m_Responsible_Attorney__c = +attorneyId;
     newAgreement.Customer_Signatory_Email__c = acc.Partner_Distributor_email__c;
     newAgreement.Ready_For_Submission__c = True;
     newAgreement.Ready_For_eSignature__c = True;
     newAgreement.Apttus__Workflow_Trigger_Viewed_Final__c = True;
     newAgreement.Apttus__Contract_Start_Date__c =  system.today();
     newAgreement.Apttus__Perpetual__c = True;
     newAgreement.Business_Contact__c = acc.OwnerId; 
     newAgreement.Apttus__Total_Contract_Value__c = 0;
     
     insert newAgreement;
     
     newAgreement.Apttus__Status__c = 'Approved Request';
     update newAgreement;
     
     agreeId = newAgreement.id;
     String MySessionID = UserInfo.getSessionID(); 
     generateDoc(MySessionID,agreeId);
     return new PageReference('/'+newAgreement.id); 
 }
 catch (Exception e) { 
            account.adderror('There are errors in the Agreement record. Please correct them before proceeding further.');
            ApexPages.addmessages(e);    
            return ApexPages.currentPage();     
        }
 
 }
 
 
 @future(Callout = true)    
     public static void generateDoc(String MySessionID,String agreementId) {
         Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c(); 
         ID templateId;
         String generatedDocId;
         templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'VERTEX'];
         templateId=templatesOb.Id;
         
         Id proposalId = agreementId;
         String accessLevel = 'Read/Write';
         String docFormat = 'doc';
         String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() +
         '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
         String SessionId = MySessionID ; //This is the session Id. 
         if(!Test.isRunningTest()){
         generatedDocId = Apttus.MergeWebService.generateDoc(templateId
         ,proposalId, accessLevel, docFormat, SessionId , apiServerURL);
         }
     
     }  

}