public class AgreementCreateSafeHarbor_Extension
{
    private final Apttus__APTS_Agreement__c agreement;        
    private ApexPages.StandardController stdController;    
    private ID agRecordTypeID = [select Id from RecordType where Name = 'Safe Harbor Ruling' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1].id;
    public List<Apttus__APTS_Template__c> templatesOb = new List<Apttus__APTS_Template__c>();
     
     public static Id newagree;
    
    public AgreementCreateSafeHarbor_Extension(ApexPages.StandardController controller) {
        stdController = controller;            
        agreement = (Apttus__APTS_Agreement__c) stdController.getRecord(); 
    }
    
     public PageReference createsafeharborAgreement() {
     try{   
            Apttus__APTS_Agreement__c agreeList = new Apttus__APTS_Agreement__c();
            agreeList = [select Contracting_Party_Account__c from Apttus__APTS_Agreement__c where id = :agreement.id ];
            Id Contpartyid = agreeList.Contracting_Party_Account__c;
            system.debug ('contracting party is  ' +Contpartyid);
                            
            Apttus__APTS_Agreement__c childAgreement = new Apttus__APTS_Agreement__c(Name='Safe Harbor', Agreement_Title__c = 'EU Model Clauses', Contracting_Party_Account__c = Contpartyid, Apttus__Contract_Start_Date__c = system.today(), RecordTypeID=agRecordTypeID, Apttus__Parent_Agreement__c=agreement.id);
            insert childAgreement;
            agreement.Hidden_safe_harbor_record_created__c = true;
            system.debug ('hidden safe harbor created is...  ' +agreement.Hidden_safe_harbor_record_created__c);
            update agreement; 
            newagree = childAgreement.id;
            String MySessionID = UserInfo.getSessionID(); 
            generateDoc(MySessionID,newagree);
            return new PageReference('/'+childAgreement.id+'/e?retURL=/'+childAgreement.id);     
            }
     catch (Exception e) { 
            agreement.adderror('There are errors in the Agreement record. Please correct them before proceeding further.');
            ApexPages.addmessages(e);    
            return ApexPages.currentPage();     
        }
    }  

     @future(Callout = true)    
     public static void generateDoc(String MySessionID,String agreeId) {
         system.debug('Entering into future method ' );
         Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c(); 
         ID templateId;
         String generatedDocId;
         templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'Safe Harbor Ruling Model Clauses'];
         templateId=templatesOb.Id;
         
         Id proposalId = agreeId;
         String accessLevel = 'Read Only';
         String docFormat = 'doc';
         String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() +
         '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
         String SessionId = MySessionID ; 
         generatedDocId = Apttus.MergeWebService.generateDoc(templateId
         ,proposalId, accessLevel, docFormat, SessionId , apiServerURL);
     
     }  
 
}