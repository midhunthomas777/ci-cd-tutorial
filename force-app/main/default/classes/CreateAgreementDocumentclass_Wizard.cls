public class CreateAgreementDocumentclass_Wizard
{

    @future(callout=true)
    public static void updateAgreement(string agreeId,Id recordtypeid) {
    
         ID eNDARecordTypeID = [select Id from RecordType where Name = 'eNDA' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1].id;
         ID MSIEntityRecordTypeID = [select Id from RecordType where Name = 'Motorola Entity' and SobjectType = 'Account' Limit 1].id;
         ID MSISignatoryID;
         ID MSIEntityID;
         
  
         Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
         agr = [select m_GTM_Region__c,CreatedBy.id, CreatedBy.email, MSI_Signatory_eNDA__c,MSI_Entity_eNDA__c,Description_of_Project_Program__c from Apttus__APTS_Agreement__c where id= :agreeId limit 1];
         ID createdbyid = agr.CreatedBy.id;
         string msisgntry = agr.MSI_Signatory_eNDA__c;
         string msientity = agr.MSI_Entity_eNDA__c;
         string Description = agr.Description_of_Project_Program__c;
         
                                                    
         if(recordtypeid == eNDARecordTypeID ){
         agr.Business_Contact__c = createdbyid;
         //agr.m_Responsible_Attorney__c = NDASpecid;
         agr.Business_Justification__c = Description;

         if(msisgntry !=null && msisgntry!='' ){
             List<User> usr = [select id from user where Name like :msisgntry and IsActive = True ];
             if(!usr.isempty()){
              MSISignatoryID = usr[0].id; }
         }
         if(msientity !=null && msientity !='' ){
             List<Account> acc = [select id from account where Name like :msientity+'%' and RecordTypeID = :MSIEntityRecordTypeID limit 1 ];
             if(!acc.isempty()){
              MSIEntityID = acc[0].id; }
         }
         agr.MSI_Contract_Signatory__c = MSISignatoryID; 
         agr.Motorola_Entity_Account__c = MSIEntityID; 
         system.debug('MSI signatory is ' +MSISignatoryID);     
                 
         update agr; 
         
         }
    }
    
    @future(callout=true)
    public static void generateDoc(String MySessionID,String agreeId, Id recordtypeid) {
    
         ID eNDARecordTypeID = [select Id from RecordType where Name = 'eNDA' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1].id;
         Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c(); 
         ID templateId;
         String generatedDocId;
         
         Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
         agr = [select m_GTM_Region__c,CreatedBy.id, CreatedBy.email,Apttus__Description__c,MSI_Entity_eNDA__c,m_Responsible_Attorney__c,Language_Selection__c from Apttus__APTS_Agreement__c where id= :agreeId limit 1];
         string Language = agr.Language_Selection__c;
         ID createdbyid = agr.CreatedBy.id;
         string region = agr.m_GTM_Region__c;
         ID resAttorney = agr.m_Responsible_Attorney__c;
         Boolean notifyEmail = False;
         
         system.debug('Responsible attorney id is ' +resAttorney);
         
         if(agr.Apttus__Description__c != null && (resAttorney == '00580000003Qb86AAC' || resAttorney == '00580000003Qb6PAAS') ){
             notifyEmail = True;
         }
         else if(resAttorney != '00580000003Qb86AAC' && resAttorney != '00580000003Qb6PAAS'){
             notifyEmail = True;
         }
         
         system.debug('Flag is '+notifyEmail );
                  
         if(recordtypeid == eNDARecordTypeID && Language == 'English'){
         templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'NDA - Universal English'];
         templateId=templatesOb.Id; }
         
         else if(recordtypeid == eNDARecordTypeID && Language == 'Portuguese'){
         templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'NDA - Universal Portuguese'];
         templateId=templatesOb.Id; } 
         
         else if(recordtypeid == eNDARecordTypeID && Language == 'Polish'){
         templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'NDA - Polish'];
         templateId=templatesOb.Id; }   
         
         else if(recordtypeid == eNDARecordTypeID && Language == 'German'){
         templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'NDA - German'];
         templateId=templatesOb.Id; }
         
         else if(recordtypeid == eNDARecordTypeID && Language == 'English - Israel'){
         templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'NDA - Universal English'];
         templateId=templatesOb.Id; }
         
         system.debug('Template id is ' +templateId);
         Id proposalId = agreeId;
         String accessLevel = 'Read Only';
         String docFormat = 'pdf';
         String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() +
         '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
         
         String SessionId = MySessionID ; //This is the session Id. 
         
         if(!Test.isrunningtest())
         generatedDocId = Apttus.MergeWebService.generateDoc(templateId
         ,proposalId, accessLevel, docFormat, SessionId , apiServerURL);
         else
         {

         Apttus__APTS_Template__c Template_eNDA = [Select Id from Apttus__APTS_Template__c where Name ='NDA - Universal English' limit 1];
         agreeId=Template_eNDA.id;
         attachment att = [Select Id from attachment where parentid = :agreeId limit 1];
         generatedDocId= att.id;
         }
         
          if (generatedDocId != Null ) {
          
             List<String> sendToaddr = new List<String>();
             List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
             Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment(); 
             Attachment att = new Attachment();
             att = [select Name, Body, BodyLength from Attachment where ParentId = :agreeId AND Id =:generatedDocId];
               efa.setFileName(att.Name);
               efa.setBody(att.Body);
               fileAttachments.add(efa);
             
             sendToaddr.add(agr.createdby.email);
             If(notifyEmail == True){
                 system.debug('Entering into loop...');
                 User u = [Select email from User where Id =:resAttorney];
                 sendToaddr.add(u.email);
             }
             sendToaddr.add('NAAGREE1@motorolasolutions.com');
             system.debug('Toaddress is ' +sendToaddr);
             system.debug('Responsible attorney id is ' +resAttorney);
    
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
             mail.setToAddresses(sendToaddr);
             mail.setTargetObjectId(createdbyid);
             mail.setTemplateId([select id from EmailTemplate where Name =:'eNDA Email Notification'].id) ; 
             mail.setWhatId(agreeId);
             mail.setFileAttachments(fileAttachments);
             mail.setUseSignature(false);
             mail.setSaveAsActivity(false);    
             try{
             system.debug('entering into sendemail... ');
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); }
             Catch(exception e) {
             system.debug(e.getMessage()); }
             } 
         
         }
         
     @future(callout=true)
        public static void updateProcAgreement(String agreeId, Id recordtypeid) {
         
         ID ProcRecordTypeID = [select Id from RecordType where Name = 'Procurement' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1].id;
         ID MSIEntityRecordTypeID = [select Id from RecordType where Name = 'Motorola Entity' and SobjectType = 'Account' Limit 1].id;
         ID MSIEntityID;
         ID MSIContractSignatoryID = [select Id from User where Core_ID__c = 'CMA035' Limit 1].id;

        
         Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
         agr = [select m_GTM_Region__c,CreatedBy.id,Procurement_Category__c,Apttus__Parent_Agreement__c,Procurement_Manager__c, Background_Information_for_Wizard__c,Apttus__Perpetual__c, Apttus__Contract_Start_Date__c, CreatedBy.email,Term_of_Agreement__c,MSI_Entity_eNDA__c,RecordtypeId,Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c where id= :agreeId limit 1];
         Date startDate = agr.Apttus__Contract_Start_Date__c;
         string msientity = agr.MSI_Entity_eNDA__c;
         string Binfo = agr.Background_Information_for_Wizard__c;
         //string term = agr.Term_of_Agreement__c;
         Id ProcMgrid = agr.Procurement_Manager__c;
         string procCat = agr.Procurement_Category__c;
         string reg = agr.m_GTM_Region__c;
         Date endDate = agr.Apttus__Contract_End_Date__c;
         if(endDate == null) {
         agr.Apttus__Perpetual__c = true;
         }
         
         
         /*if(term == '1 Year') {
         endDate = startDate.addyears(1);
         }
         else if (term == '2 Years'){
         endDate = startDate.addyears(2);
         }
         else if (term == '3 Years'){
         endDate = startDate.addyears(3);
         }
         else if (term == '5 Years'){
         endDate = startDate.addyears(5);
         }
         else if(term == 'No Expiry Date'){
         endDate = null;
         }*/
       
         if(msientity !=null && msientity !='' ){
             List<Account> acc = [select id from account where Name like :msientity+'%' and RecordTypeID = :MSIEntityRecordTypeID limit 1 ];
             if(!acc.isempty()){
              MSIEntityID = acc[0].id; }
         }
         
         agr.Motorola_Entity_Account__c = MSIEntityID;
        // agr.Apttus__Contract_End_Date__c = endDate; 
         agr.Background_Information__c = Binfo;
        // agr.MSI_Contract_Signatory__c = ProcMgrid;
         
        if(procCat == 'Tradeshows, Meetings, & Events' && reg != 'EMEA' && reg != 'Asia Pacific'){
             agr.MSI_Contract_Signatory__c = MSIContractSignatoryID ;
             //agr.Ready_For_Submission__c = True;
            //agr.APTPS_Ready_For_Approval__c = True;
         }
         
        //if(procCat == 'Technical Services'){
             // agr.MSI_Contract_Signatory__c = '005800000068uRx';
             //agr.Ready_For_Submission__c = True;
            //agr.APTPS_Ready_For_Approval__c = True;
         //}    
                        
         else {
          agr.MSI_Contract_Signatory__c = ProcMgrid;
          
          }
         
         update agr; 
    
        }
     
     @future(callout=true)
        public static void procSendEmail(String MySessionID, String agreeId, String createdByEmail, ID CreatedById) {
        
            Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c(); 
            ID templateId;
            String generatedDocId;

            Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c();
            agr = [select Indirect_Category__c,Motorola_Contract_Signatory__c,Termination_for_Convenience__c,Supplier_Requires_Ownership_Rights__c,Apttus__Parent_Agreement__c,Payment_Terms__c,Does_this_transaction_involve_Executive__c,Procurement_Category__c,Software_as_a_Service_SaaS__c,RecordtypeId,SaaS_or_Cloud_Computing__c,Will_CP_transmit_Motorola_Data__c,Apttus__Total_Contract_Value__c,MSI_Entity_eNDA__c,m_GTM_Region__c,Contracting_Party_Account__c,Apttus__Contract_Start_Date__c,Proc_Wiz_PreApproval_Cond__c,Apttus__Description__c,Standard_Non_Standard__c,Apttus__Subtype__c,Apttus__Parent_Agreement__r.Payment_Terms__c,Apttus__Parent_Agreement__r.Termination_for_Convenience__c,Apttus__Parent_Agreement__r.Personal_Information__c,Apttus__Parent_Agreement__r.Supplier_Requires_Ownership_Rights__c,Finance_Approval_and_Approved_ESR__c,Apttus__Parent_Agreement__r.Apttus__Total_Contract_Value__c,Apttus__Parent_Agreement__r.Apttus__Contract_Start_Date__c,Created_from_Wizard__c,Apttus__Amendment_Effective_Date__c,Amendment_Change_Order_Value__c,Ready_For_Submission__c,Apttus__Parent_Agreement__r.PII_Storage_Location__c,Apttus__Parent_Agreement__r.PII_Location_Details_for_other__c,Apttus__Parent_Agreement__r.PII_Encryption_at_Rest__c,
            Apttus__Parent_Agreement__r.PII_Encryption_in_Transit__c,Apttus__Parent_Agreement__r.PII_Incident_Management_Clause_Details__c,Apttus__Parent_Agreement__r.PII_Breach_Notification_Clause_Details__c,Apttus__Parent_Agreement__r.PII_Litigation_Investigation_Support__c from Apttus__APTS_Agreement__c where id= :agreeId limit 1];
            string ApttusDescription = agr.Apttus__Description__c;
            Date startDate = agr.Apttus__Contract_Start_Date__c;
            string MotEnt = agr.MSI_Entity_eNDA__c;
            Date todaysDate = system.today();
            Date datecriteria;
            
            datecriteria = todaysDate.addyears(2);
            system.debug('Date criteria is ' +datecriteria);
            
          /*  if (agr.Indirect_Category__c == 'Software' && agr.SaaS_or_Cloud_Computing__c== 'Yes' && agr.Will_CP_transmit_Motorola_Data__c == 'No' && agr.Apttus__Total_Contract_Value__c < 250000) {
            
              templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'Rider for Subscription Agreement'];
              templateId=templatesOb.Id;  
            
            } 
            else */ 
            if (agr.Procurement_Category__c == 'Tradeshows, Meetings, & Events' && agr.Apttus__Total_Contract_Value__c < 250000 && MotEnt == 'Motorola Solutions, Inc.' && agr.m_GTM_Region__c == 'North America' && agr.Contracting_Party_Account__c != null && agr.Proc_Wiz_PreApproval_Cond__c <= 730 && agr.Apttus__Description__c == null) {
            
              templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'Hotel Addendum'];
              templateId=templatesOb.Id; 
              
              system.debug('Template id is ' +templateId);
            
            }
            else if (agr.Procurement_Category__c == 'HR Services' && agr.Contracting_Party_Account__c != null && agr.Apttus__Subtype__c == 'Change Order' && agr.Software_as_a_Service_SaaS__c == 'No' && agr.Apttus__Total_Contract_Value__c < 100000 && MotEnt == 'Motorola Solutions, Inc.' && (agr.m_GTM_Region__c == 'North America' || agr.m_GTM_Region__c == 'Global') && agr.Apttus__Parent_Agreement__c != null && agr.Proc_Wiz_PreApproval_Cond__c <= 365 && agr.Apttus__Description__c == null){
              templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'Change Order Request Template'];
              templateId=templatesOb.Id; 
              
              system.debug('Template id' +templateId);
            }
            
            else if (agr.Procurement_Category__c == 'Technical Services' && agr.Created_from_Wizard__c != null){
              templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'IT SOW Procurement Template'];
              templateId=templatesOb.Id; 
              
              system.debug('Template id' +templateId);
            }            
            
            else {
            templateId = Null;
            system.debug('Entering into else loop ' +templateId);
            }
            
            if(Test.isrunningTest())
            {
            Account a=[Select Id from Account where recordtype.name='Motorola Entity' limit 1];
            agr.Motorola_Entity_Account__c= a.id;
            Apttus__APTS_Template__c Template_HR = [Select Id from Apttus__APTS_Template__c where Name ='Change Order Request Template' limit 1];
            templateId=Template_HR.id;
            }
                        
            if (templateId != Null ) {
            system.debug('Template id is ' +templateId);
            Id proposalId = agreeId;
            String accessLevel = 'Read Only';
            String docFormat = 'docx';
            String apiServerURL = System.Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/Soap/u/14.0/' + UserInfo.getOrganizationId();
            String SessionId = MySessionID ;  
            
            if(!Test.IsrunningTest())
            generatedDocId = Apttus.MergeWebService.generateDoc(templateId
            ,proposalId, accessLevel, docFormat, SessionId , apiServerURL);
            else
            {
            Apttus__APTS_Template__c Template_HR = [Select Id from Apttus__APTS_Template__c where Name ='Change Order Request Template' limit 1];
            agreeId=Template_HR.id;
            attachment att = [Select Id from attachment where parentid =:agreeId limit 1];
            generatedDocId = att.id;
            }
            
            if (generatedDocId != Null ) {
            List<String> sendToaddr = new List<String>();
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
             Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment(); 
             Attachment att = new Attachment();
             att = [select Name, Body, BodyLength from Attachment where ParentId = :agreeId AND Id =:generatedDocId];
               efa.setFileName(att.Name);
               efa.setBody(att.Body);
               fileAttachments.add(efa);
            sendToaddr.add(createdByEmail);
            // User u = [Select email from User where Id =:NDASpecid];
           //  sendToaddr.add(u.email);
             system.debug('Toaddress is ' +sendToaddr);
    
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
             mail.setToAddresses(sendToaddr);
             mail.setTargetObjectId(CreatedById);
             mail.setTemplateId([select id from EmailTemplate where Name =:'Proc Wiz Email Notification'].id) ; 
             mail.setWhatId(agreeId);
             mail.setFileAttachments(fileAttachments);
             mail.setUseSignature(false);
             mail.setSaveAsActivity(false);    
             try{
             system.debug('entering into sendemail... ');
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); }
             Catch(exception e) {
             system.debug(e.getMessage()); }             
             }
             } 
             
             else if(templateId == Null) { 
             system.debug('Entering into template id null loop');
             List<String> sendToaddr = new List<String>();
             sendToaddr.add(createdByEmail);
             system.debug('Toaddress is ' +sendToaddr);
    
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
             mail.setToAddresses(sendToaddr);
             mail.setTargetObjectId(CreatedById);
             mail.setTemplateId([select id from EmailTemplate where Name =:'Proc Wiz Email Notification'].id) ; 
             mail.setWhatId(agreeId);
             mail.setUseSignature(false);
             mail.setSaveAsActivity(false);    
             try{
             system.debug('entering into sendemail for null template id... ');
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); }
             Catch(exception e) {
             system.debug(e.getMessage()); }
             
             }                 
              if (templateId != Null && agr.Procurement_Category__c == 'Tradeshows, Meetings, & Events') {
              system.debug('Update agreement as approved');
              agr.Apttus__Status_Category__c = 'In Authoring'; 
              agr.Apttus__Status__c = 'Contract Approved'; 
              agr.Apttus_Approval__Approval_Status__c = 'Approved';
              agr.Standard_Non_Standard__c = 'Standard Terms on Motorola’s Paper';
                  try{
                      update agr;
                  } catch(Exception exp){
                      System.debug('Exception found:'+exp.getMessage());
                  }
              }
              
              else if (templateId != Null && agr.Procurement_Category__c == 'Technical Services' && agr.Contracting_Party_Account__c != null && agr.Apttus__Subtype__c == 'SOW or Sub-Agreement' && agr.Contracting_Party_Account__c != null && agr.Software_as_a_Service_SaaS__c == 'No' && agr.Apttus__Total_Contract_Value__c < 50000 &&  agr.MSI_Entity_eNDA__c == 'Motorola Solutions, Inc.' && (agr.m_GTM_Region__c == 'North America' || agr.m_GTM_Region__c == 'Global') && agr.Apttus__Parent_Agreement__c != null && agr.Finance_Approval_and_Approved_ESR__c != 'No') {
              system.debug('Update agreement as approved');
              agr.Apttus__Status_Category__c = 'In Authoring'; 
              agr.Apttus__Status__c = 'Contract Approved'; 
              agr.Apttus_Approval__Approval_Status__c = 'Approved';
              agr.Standard_Non_Standard__c = 'Standard Terms on Motorola’s Paper';
              agr.Ready_For_Submission__c = True;             
              update agr;
              }
              
              else if (templateId != Null && agr.Procurement_Category__c == 'HR Services') {
              system.debug('Update agreement as approved');
              agr.Apttus__Status_Category__c = 'In Authoring'; 
              agr.Apttus__Status__c = 'Contract Approved'; 
              agr.Apttus_Approval__Approval_Status__c = 'Approved';
              agr.Standard_Non_Standard__c = 'Standard Terms on Motorola’s Paper';
              agr.Motorola_Contract_Signatory__c = 'Tammy Clark';
              agr.Payment_Terms__c = agr.Apttus__Parent_Agreement__r.Payment_Terms__c;
              agr.Apttus__Amendment_Effective_Date__c = agr.Apttus__Contract_Start_Date__c;
              agr.Amendment_Change_Order_Value__c = agr.Apttus__Total_Contract_Value__c;
              agr.Termination_for_Convenience__c = agr.Apttus__Parent_Agreement__r.Termination_for_Convenience__c;
              agr.Personal_Information__c = agr.Apttus__Parent_Agreement__r.Personal_Information__c;
              
              agr.PII_Storage_Location__c = agr.Apttus__Parent_Agreement__r.PII_Storage_Location__c;
              agr.PII_Location_Details_for_other__c = agr.Apttus__Parent_Agreement__r.PII_Location_Details_for_other__c;
              agr.PII_Encryption_at_Rest__c = agr.Apttus__Parent_Agreement__r.PII_Encryption_at_Rest__c;
              agr.PII_Encryption_in_Transit__c = agr.Apttus__Parent_Agreement__r.PII_Encryption_in_Transit__c;
              agr.PII_Incident_Management_Clause_Details__c = agr.Apttus__Parent_Agreement__r.PII_Incident_Management_Clause_Details__c;
              agr.PII_Breach_Notification_Clause_Details__c = agr.Apttus__Parent_Agreement__r.PII_Breach_Notification_Clause_Details__c;
              agr.PII_Litigation_Investigation_Support__c = agr.Apttus__Parent_Agreement__r.PII_Litigation_Investigation_Support__c;              
              
              agr.Supplier_Requires_Ownership_Rights__c = agr.Apttus__Parent_Agreement__r.Supplier_Requires_Ownership_Rights__c;
              if(!Test.isRunningTest()){
              agr.Apttus__Total_Contract_Value__c = agr.Apttus__Parent_Agreement__r.Apttus__Total_Contract_Value__c + agr.Amendment_Change_Order_Value__c;
              agr.Apttus__Contract_Start_Date__c = agr.Apttus__Parent_Agreement__r.Apttus__Contract_Start_Date__c;
              agr.Ready_For_Submission__c = True;
              update agr;
              }
              }
             
             }        
         
        
         
}