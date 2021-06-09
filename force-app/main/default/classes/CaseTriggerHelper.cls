public class CaseTriggerHelper {
    
    public void handleDeaExtention(List<Id> caseRelatedOpps, List<Case> incoming) {
        Set<Id> oppsWithExistingCases = new Set<Id>();
        Map<Id,Case> existingCaseMap = new Map<Id,Case>([SELECT Id,Related_Opportunity__c FROM Case WHERE Related_Opportunity__c IN : caseRelatedOpps]);
        for(Case incomingCase : existingCaseMap.values()){
            oppsWithExistingCases.add(incomingCase.Related_Opportunity__c);
        }
        if(!oppsWithExistingCases.isEmpty()) {
            for(Case eachCase : incoming){
                if(oppsWithExistingCases.contains(eachCase.Related_Opportunity__c)){
                    eachCase.addError(Label.DR_Extension_Case_Creation_Validation_Error);
                    return;

                }
            }
        }
    }
    
    public void populateAssignedASM(List<Case> incomingCases){
        Id caseRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Customer_Account_Creation');
        Id caseupdRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Customer_Account_Update');       
        Set<Id> acctIds = new Set<Id>();
        List<CAM_Geo_Onboarding_Map__c> CamGeo =new List<CAM_Geo_Onboarding_Map__c>();
        for(Case cas : incomingCases){
            if(String.isNotBlank(cas.AccountId)){
                acctIds.add(cas.AccountId);                 
            }
        }
        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id,BillingCountry,BillingStateCode,BillingState,Federal_Agency__c, Billing_County__c,
                                                      Territory__c,OwnerId,Owner.ManagerId FROM Account WHERE Id IN:acctIds]);
        for(Case cas : incomingCases){
            if(cas.RecordTypeId == caseupdRecordTypeId){
                /*SF-2104 --Start-------------*/
                Account acc = accMap.get(cas.AccountId);
                if(acc.Owner.ManagerId !=null && acc.OwnerId != null){
                    cas.Assigned_ASM__c=acc.Owner.ManagerId;
                }else{
                    cas.Assigned_ASM__c=Label.NA_Govt_Customer_Data_Team;
                }             
                System.debug('Account Owner Manager ASM===>' + cas.Assigned_ASM__c);
                /*---SF-2104 --End-------------*/
                if( cas.ASM_Approval_status__c != 'Approved'){
                    cas.ASM_Approval_status__c= 'In Approval';
                }                             
            }
        }
        
        for(Case cas : incomingCases){
            String camFedAgency = '';
            if(caseRecordTypeId == cas.RecordTypeId){
                Account acc = accMap.get(cas.AccountId);
                String camCountry = acc.BillingCountry;            
                camFedAgency = acc.Federal_Agency__c;
                String accBillingState = acc.BillingState;
                String camStateCode = acc.BillingStateCode;
                String camBCounty = (acc.Billing_County__c != null) ? acc.Billing_County__c.toUpperCase() : '';
                String camCommunity = (acc.Federal_Agency__c == null) ? 'State and Local MR' : 'Federal MR';
                if (acc.Federal_Agency__c == null){
                    CamGeo = new List<CAM_Geo_Onboarding_Map__c>();
                    if(camBCounty != '' ){
                        // Select ASM at the State and County level if there is no County value for the corresponding Account.
                        CamGeo = [SELECT Channel_Account_Manager__c,Director__c,State_County__c,Territory__c,County__c from CAM_Geo_Onboarding_Map__c 
                                  WHERE Country__c=:camCountry AND State_Province__c = :camStateCode AND Community__c =: camCommunity
                                  AND County__c =: camBCounty AND Track__c = 'Radio' AND Function__c = 'Onboarding'];
                    } else {
                        // Select ASM at the state level if there is no County value for the corresponding Account.
                        CamGeo = [SELECT Channel_Account_Manager__c,Director__c,State_County__c,Territory__c,County__c from CAM_Geo_Onboarding_Map__c 
                                  WHERE Country__c=:camCountry AND County__c = :camStateCode AND Community__c =: camCommunity
                                  AND Track__c = 'Radio' AND Function__c = 'Onboarding' LIMIT 1];
                    }
                }
                else if(acc.Federal_Agency__c == 'Department of Defense'){
                    CamGeo = new List<CAM_Geo_Onboarding_Map__c>();
                    System.debug('accBillingState ####==>'+accBillingState);
                    if(String.isNotBlank(accBillingState)){
                        CamGeo = [SELECT Name, Channel_Account_Manager__c,Director__c,Country__c,State_Province__c,Territory__c, County__c FROM CAM_Geo_Onboarding_Map__c 
                                  WHERE Country__c =: camCountry AND State_Province__c = :camStateCode AND Community__c =: camCommunity
                                  AND Federal_Agency__c = :camFedAgency AND Track__c = 'Radio' AND Function__c = 'Onboarding'];
                        if(CamGeo.size()>0) { 
                            for(CAM_Geo_Onboarding_Map__c c:CamGeo ) { // Start of For Loop - DOD ASM Assignment
                                if(c.Country__c == camCountry && c.State_Province__c == camStateCode && c.County__c == camBCounty ) {
                                    cas.Assigned_ASM__c = c.Channel_Account_Manager__c;
                                    cas.Hidden_CAM__c = c.Director__c;
                                    break;
                                }                              
                            }                 
                        }
                    }
                    
                    if(accBillingState == '' || accBillingState == null ) {
                        
                        CamGeo = [SELECT Name, Channel_Account_Manager__c,Director__c,Country__c,State_Province__c,Territory__c, County__c FROM CAM_Geo_Onboarding_Map__c 
                                  WHERE State_Province__c =: camStateCode AND Community__c =: camCommunity AND Federal_Agency__c = :camFedAgency 
                                  AND Track__c = 'Radio' AND Function__c = 'Onboarding' ORDER BY Country__c DESC];
                        if(CamGeo.size()>0) { 
                            for(CAM_Geo_Onboarding_Map__c c:CamGeo ) { // Start of For Loop - DOD ASM Assignment - State and County NULL
                                if(c.Country__c == camCountry && (accBillingState == '' || accBillingState  == null)){
                                    cas.Assigned_ASM__c = c.Channel_Account_Manager__c; // For APAC
                                    cas.Hidden_CAM__c = c.Director__c;
                                    break;
                                } else if(c.Country__c != camCountry && (c.Country__c == '' || c.Country__c == null)){
                                    cas.Assigned_ASM__c = c.Channel_Account_Manager__c; //All other states & countries in the world 
                                    cas.Hidden_CAM__c = c.Director__c;
                                    break;
                                } 
                            }  
                        }  
                    }
                } 
                // for other Federal Agencies like DOS, Federal Law Enforcement and Civil Agencies, routing is done globally
                else if(acc.Federal_Agency__c == 'Department of State' || acc.Federal_Agency__c == 'Law Enforcement Agencies' || acc.Federal_Agency__c == 'Civil Agencies') {
                    CamGeo = new List<CAM_Geo_Onboarding_Map__c>();
                    CamGeo = [SELECT Channel_Account_Manager__c,Director__c,Territory__c FROM CAM_Geo_Onboarding_Map__c 
                              WHERE Community__c =: camCommunity AND Federal_Agency__c = :camFedAgency  AND Track__c = 'Radio' AND Function__c = 'Onboarding'];
                }
            } 
            if(camFedAgency == '' || camFedAgency == null || camFedAgency != 'Department of Defense'){
                if(CamGeo != null  && CamGeo.size()>0 ){  
                    cas.Assigned_ASM__c = CamGeo[0].Channel_Account_Manager__c;
                    cas.Hidden_CAM__c = CamGeo[0].Director__c;
                } 
            }     
            System.debug('Case ASM===>'+ cas.Assigned_ASM__c);
        }
    }
    
    public void RTMCaseCreation(List<Case> newItems){
        Set<Id> accountIds = new Set<Id>();
        for(Case eachCase : newItems){ 
            accountIds.add(eachCase.AccountId);
        }
        System.Debug('newItems==>'+newItems);
        Map<Id, Account> accountIdsMap = new Map<Id, Account>();
        for(Account eachAccount : [Select Motorola_Customer_Number__c,Owner.ManagerId from Account where ID IN : accountIds]){
            accountIdsMap.put(eachAccount.Id, eachAccount);
            System.Debug('eachAccount.Id==>'+eachAccount.Id);
        }
        for(Case eachCase : newItems){ 
            System.Debug('eachCase==>'+eachCase.AccountId);
            Account dbAccount = accountIdsMap.get(eachCase.AccountId);
            if(dbAccount != NULL) {
                eachCase.Subject = 'Route to Market Change Request: ' + dbAccount.Motorola_Customer_Number__c;           
                eachCase.ASM_Approval_Status__c = 'In Approval';            
                eachCase.Assigned_ASM__c = dbAccount.Owner.ManagerId;
                eachCase.Case_Requestor__c = Userinfo.getUserId();   
            }
        }
    }
    
    public void shareCases(List<Case> caseToBeShared){
        List<CaseShare> caseShareToBeInserted = new List<CaseShare>();
        for(Case incoming : caseToBeShared){ 
            caseShareToBeInserted.add(new CaseShare(caseId = incoming.Id,UserOrGroupId = Label.Customer_Data_Team_group_id,CaseAccessLevel = 'Edit'));
            if(String.isNotBlank(incoming.Assigned_ASM__c)){
                caseShareToBeInserted.add(new CaseShare(caseId = incoming.Id,UserOrGroupId = incoming.Assigned_ASM__c,CaseAccessLevel = 'Read'));    
            }
            if(String.isNotBlank(incoming.Hidden_CAM__c)){
                caseShareToBeInserted.add(new CaseShare(caseId = incoming.Id,UserOrGroupId = incoming.Hidden_CAM__c,CaseAccessLevel = 'Read'));    
            }
        } 
        if(!caseShareToBeInserted.isEmpty()){
            Database.insert(caseShareToBeInserted,false);
        }
    }
    
    public void autoSubmitForApproval(List<Case> newlyCreatedCases){
        Id caseRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Customer_Account_Creation');
        Id caseupdRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Customer_Account_Update');
        Id caseinquiryRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Commission_Inquiry');        
        Map<String,String> recortypeIdCommentsMap = new Map<String,String>();
        recortypeIdCommentsMap.put(caseupdRecordTypeId,'Submitting MR Customer update request for approval.');
        recortypeIdCommentsMap.put(caseinquiryRecordTypeId,'Submitting MR Inquiry request for approval.');
        recortypeIdCommentsMap.put(caseRecordTypeId,'Submitting MR Customer Create request for approval.');
        for(Case incoming : newlyCreatedCases){
            try{
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setComments(recortypeIdCommentsMap.get(incoming.RecordTypeId));
                request.setObjectId(incoming.Id);
                Approval.ProcessResult result = Approval.process(request); 
            }catch(Exception e){
                System.debug('Unhandled Exception ###==>'+e);
            }
        }
    }
    
    public void Case_AI(Map<Id,Case> newMap){
        List<Case> casesToBeUpdated = new List<Case>();
        List<AssignmentRule> ARList = new List<AssignmentRule>();
        ARList = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]; 
        if(!ARList.isEmpty()) {
            AssignmentRule AR = ARList.get(0);
            for(Case caseToBeUpdated : [SELECT ID FROM CASE WHERE ID IN : newMap.keySet()]) {
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id; 
                dmlOpts.EmailHeader.triggerUserEmail = true;
                caseToBeUpdated.setOptions(dmlOpts);
                casesToBeUpdated.add(caseToBeUpdated);
            }  
            Database.update(casesToBeUpdated); 
        }
    }  
    
    public void caseShareForCaseRequestor(List<Case> shareCases){
        List<CaseShare> caseAddShares = new List<CaseShare>();
        system.debug('Sharing cases'+caseAddShares);
        for(Case incomingCase : shareCases){ 
            if(incomingCase.OwnerId <> incomingCase.CreatedById){         
                caseAddShares.add(new CaseShare(
                    CaseId = incomingCase.Id,
                    UserOrGroupId = incomingCase.CreatedById,
                    CaseAccessLevel = 'Edit',//SF-1997 -Support Request Case Sharing with Case Requestor with Edit access
                    RowCause='Manual'
                )); 
            }           
        }     
        if (!caseAddShares.isEmpty()) { 
            Database.insert(caseAddShares, false); 
        }
    }
    
    public void updateContactRecords(Map<Id, Case> newItems,Map<Id, Case> oldItems){
        //List<Contact> toBeUpdated = new List<Contact>();
        Id msiSupportCase =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'Admin_Service_Case');

        Set<Id> contactsToBeDeleted = new Set<Id>();
        Set<Id> casesToBeDeleted = new Set<Id>();
        for(Case updatedCase : newItems.values()){
            Case oldCase = (Case) oldItems.get(updatedCase.Id);
            /*Changed the recordtype from EMEA Partner Support to MSI Support Case - Added By Brijesh for LUCXBW -675 and commented the initial if block as its no more in use after removal of "Request New Contact" button
            if(updatedCase.Status != oldCase.Status && updatedCase.Status == 'Closed' && updatedCase.recordtypeId == msiSupportCase && updatedCase.ContactId!=null){
                Contact updCon = new Contact();
                updCon.Id = updatedCase.ContactId;
                updCon.AccountId = updatedCase.AccountId;
                toBeUpdated.add(updCon);
            } else*/
            if(updatedCase.Status != oldCase.Status && updatedCase.Status == 'Cancelled' && updatedCase.recordtypeId == msiSupportCase) {                    //Changed the recordtype from EMEA Partner Support to MSI Support Case - Added By Brijesh for LUCXBW -675
                contactsToBeDeleted.add(updatedCase.ContactId);
                casesToBeDeleted.add(updatedCase.Id);  
            }
        }
        /*if(!toBeUpdated.isEmpty()){
            update toBeUpdated;
        }*/

        if(!(casesToBeDeleted.isEmpty() && contactsToBeDeleted.isEmpty())){
            deleteRelatedRecords(casesToBeDeleted,contactsToBeDeleted);
        }
    }        
    
    @future @TestVisible
    private static void deleteRelatedRecords(Set<Id> caseIds, Set<Id> contactIds){
        List<Case> updateCase = new List<Case>();
        for(Case updCase:[SELECT Id,ContactId,Comments__c,Case_Comment__c FROM Case WHERE Id IN:caseIds]){
            updCase.ContactId = null;
            updCase.Case_Comment__c = 'As Case is Cancelled, related requested Contact is deleted';
            updateCase.add(updCase);
        }
        if(!updateCase.isEmpty()){
            update updateCase;    
        }
        delete [SELECT Id FROM Contact WHERE Id IN:contactIds];
    }
    
    public void ADP_AutoCreatePartnerContactFromCase(List<Case> closedAndApprovedCases,List<String> emailLst, String accountId){
        ID partnerContactRecId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Partner').RecordTypeId;
        Map<String,Contact> accContact = new Map<String,Contact>();
        Contact cont;
        String tag;
        Decimal globalGroupId;
        List<Contact> inscontactlist = new List<Contact>();
        Account partAcc;
        if(accountId != null){
            partAcc = [select account.ADP_Global_Account_Name1__r.name,ADP_Global_Account_Name1__r.GitLab_Group_Id__c,
                       BillingState, BillingCountry, BillingPostalCode from Account where Id = :accountId];
            globalGroupId = partAcc.ADP_Global_Account_Name1__r.GitLab_Group_Id__c;
        }
        if(emailLst.size()>0 && globalGroupId != null){
            accContact = ADP_FindDuplicateContact.getDuplicateContact(globalGroupId,emailLst);
        }
        System.debug('Outside if accContact==>'+accContact);
        System.debug('closedAndApprovedCases==>'+closedAndApprovedCases);
        if(!closedAndApprovedCases.isEmpty()){
            for(Case eachCase : closedAndApprovedCases){
                if(eachCase.Admin__c == True){
                    tag = 'ADP';
                } else if (eachCase.Admin__c == False){
                    tag = 'Developer';
                }
                if(accContact.containsKey(eachCase.ADPEmail__c.toLowerCase()) && accContact!=null){
                    System.debug('Inside if accContact==>'+accContact);
                    if(accContact.get(eachCase.ADPEmail__c.toLowerCase()).Tag__c == null ||
                       !accContact.get(eachCase.ADPEmail__c.toLowerCase()).Tag__c.contains('ADP')){
                           cont = new Contact(Id=accContact.get(eachCase.ADPEmail__c.toLowerCase()).Id,Email=accContact.get(eachCase.ADPEmail__c.toLowerCase()).Email, 
                                              Tag__c=accContact.get(eachCase.ADPEmail__c.toLowerCase()).Tag__c);
                           if((cont.Tag__c == null || cont.Tag__c.trim() == '') &&  tag == 'ADP'){
                               cont.Tag__c = 'SFDC Partner Admin;ADP' ;
                           } else if((cont.Tag__c == null || cont.Tag__c.trim() == '') && tag == 'Developer'){
                               system.debug('++123++cont.Tag__c '+cont.Tag__c+ '  tag '+tag);
                               cont.Tag__c = 'ADP' ;
                           } else if(cont.Tag__c != null && !cont.Tag__c.contains('SFDC Partner Admin') && tag == 'ADP'){ 
                               system.debug('++++cont.Tag__c '+cont.Tag__c+ '  tag '+tag);
                               cont.Tag__c = cont.Tag__c + ';' +'SFDC Partner Admin;ADP';                                                           
                           } else if(cont.Tag__c != null && cont.Tag__c.contains('SFDC Partner Admin') && tag == 'ADP'){ 
                               cont.Tag__c = cont.Tag__c + ';' +'ADP';                                                          
                           } else if(cont.Tag__c != null && tag == 'Developer'){ 
                               cont.Tag__c = cont.Tag__c + ';' +'ADP';                                                         
                           }
                       }
                    system.debug('cont===>'+cont);
                    if(cont != null){
                        inscontactlist.add(cont);
                    }
                    system.debug('eachCase.ADPEmail__c.toLowerCase'+eachCase.ADPEmail__c.toLowerCase());
                    system.debug('globalgroupid'+globalgroupid);
                    system.debug('accContact.containsKey(eachCase.ADPEmail__c.toLowerCase'+accContact.containsKey(eachCase.ADPEmail__c.toLowerCase()));
                } else if((!accContact.containsKey(eachCase.ADPEmail__c.toLowerCase())&& globalgroupid!=null)) {
                    cont = new Contact();
                    cont.FirstName = eachCase.Associate_First_Name__c;
                    cont.LastName = eachCase.Associate_Last_Name__c;
                    cont.Email = eachCase.ADPEmail__c;
                    cont.MobilePhone = eachCase.ADPContactPhone__c; 
                    cont.AccountId = accountId;
                    cont.MailingPostalCode = partAcc.BillingPostalCode;
                    cont.MailingState = partAcc.BillingState;
                    cont.MailingCountry = partAcc.BillingCountry;
                    cont.Primary_Contact_Type__c = eachCase.ADPConRole__c;
                    cont.RecordTypeId = partnerContactRecId;
                    cont.title = eachCase.Title__c;
                    if(tag == 'ADP'){
                        cont.Tag__c = 'SFDC Partner Admin;ADP';
                    }else if(tag == 'Developer'){
                        cont.Tag__c = 'ADP';
                    }
                    if(cont != null){
                        inscontactlist.add(cont);
                    }
                }
            }
        }
        System.debug('inscontactlist==>'+inscontactlist);
        if(!inscontactlist.isEmpty()) {
            
            upsert inscontactlist;
        }
    }
    
    public void supportRequestGrantAccessToCreator(List<Case> supportCases){
        List<CaseTeamMember> listUserTeamMember = new List<CaseTeamMember>();
        Case_Record_Type_Support_Request__c CaseSupportRequest = Case_Record_Type_Support_Request__c.getInstance();
        for(Case newcase : supportCases) {
            listUserTeamMember.add(new CaseTeamMember(
                MemberId = newcase.CreatedById,
                ParentId = newcase.Id,
                TeamRoleId = CaseSupportRequest.Case_TeamRoleId__c
            )); 
        }
        if(!listUserTeamMember.isEmpty()) {
            Database.insert(listUserTeamMember, false);
        }
    }
    /*
    LUCXBW-695 - Commenting as this will be removed and now new cases will not be created but old one will be reassigned..
    public void triggerClarifyCase(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        Set<Id> AcctId = new Set<Id>();
        Id caseRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Customer_Account_Creation');
        Id caseupdRecordTypeId =  GlobalUtility.getRecordTypeIdByDeveloperName('Case', 'MR_Customer_Account_Update');
        List<String> ccAddresses = new List<String>();
        for(Case cas : [SELECT Id,AccountId,RecordTypeId, CreatedById, CreatedBy.email,CreatedBy.ContactId,Status,Trigger_Clarify_Case__c, ASM_Approval_Status__c 
                        FROM Case WHERE Id IN: newCaseMap.keySet()])
        {
            if (cas.Trigger_Clarify_Case__c != oldCaseMap.get(cas.Id).Trigger_Clarify_Case__c){
                if(cas.CreatedBy.ContactId != NULL){
                    System.debug('##Checking all the inbound parameters in triggerClarifyCase##');
                    System.debug('##cas.RecordTypeId##'+cas.RecordTypeId);
                    System.debug('##cas.ASM_Approval_Status__c##'+cas.ASM_Approval_Status__c);
                    System.debug('##cas.Trigger_Clarify_Case__c##'+cas.Trigger_Clarify_Case__c);
                    if(caseRecordTypeId == cas.RecordTypeId && cas.ASM_Approval_Status__c == 'Approved' && cas.Trigger_Clarify_Case__c == TRUE){
                        ccAddresses = System.Label.Email_Addresses.split(',');
                        ccAddresses.add(cas.CreatedBy.email);
                        sendEmail(Label.MR_Customer_Accounts_Data_Management_Email_Template, cas.CreatedBy.ContactId, cas.Id, cas.CreatedBy.email, ccAddresses);
                    } else if(caseupdRecordTypeId == cas.RecordTypeId  && cas.ASM_Approval_Status__c == 'Approved' && cas.Trigger_Clarify_Case__c == TRUE){
                        ccAddresses = System.Label.Email_Addresses.split(',');  // Configure the CC Email address in the Custom Label
                        ccAddresses.add(cas.CreatedBy.email);
                        sendEmail(Label.MR_Customer_Accounts_Upd_Data_Management_Email_Template, cas.CreatedBy.ContactId, cas.Id, cas.CreatedBy.email,ccAddresses);
                    }
                } 
            }   
        }
    }
    public void sendEmail(String emailTemplateId, String ownerId, String caseId, String senderEmail, List<String> ccAddresses) {  
        AccAndConData__c ad = AccAndConData__c.getValues('Current'); // Getting GateKeeping Team email ID from Custom Settings
        String owAddr, owEmail;
        for(OrgWideEmailAddress owa : [select id,DisplayName, Address from OrgWideEmailAddress where DisplayName ='NA Govt. Customer Data Team']) {
            if(owa.DisplayName.contains('NA Govt. Customer Data Team') && owa.DisplayName == 'NA Govt. Customer Data Team'){
                owAddr =   owa.id;     
                owEmail =  owa.Address;
            }
        }
        List<ContentDocumentLink> ContDoc  =[SELECT ContentDocumentId, ContentDocument.Title, LinkedEntityId, ContentDocument.FileExtension FROM ContentDocumentLink where LinkedEntityId in (SELECT Id FROM Case where Id =:caseId) and LinkedEntity.Type='Case'];
        List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
        Set<String> docIDs = new Set<String>();
        
        for(ContentDocumentLink cd : ContDoc) {
            docIDs.add(cd.ContentDocumentId); 
        }
        Map<Id, Blob> mapCD = new Map<Id,Blob>();
        for(ContentVersion cvers:[select Id,versionData,ContentDocumentId,FileExtension from ContentVersion where ContentDocumentId IN :docIDs]){
            mapCD.put(cvers.ContentDocumentId,cvers.versionData);
        }
        for(ContentDocumentLink cdl:ContDoc){
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(cdl.ContentDocument.Title+'.'+cdl.ContentDocument.FileExtension);
            efa.setBody(mapCD.get(cdl.ContentDocumentId));
            efaList.add(efa);
        }
        for(Attachment attach:[select Id,Name,Body, BodyLength,ContentType,ParentId from Attachment where ParentId =:caseId]){
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(attach.Name);
            efa.setBody(attach.Body);
            efaList.add(efa);
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(owAddr);
        mail.setToAddresses(new List<String>{ad.Gatekeeping_Team_Emailid__c});
        mail.setCcAddresses(ccAddresses);
        mail.setReplyTo(owEmail); 
        mail.setTargetObjectId(ownerId);        
        mail.setWhatId(caseId);
        mail.setTemplateId(emailTemplateId);   
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false);      
        System.debug('###MAIL####'+mail);
        if(!efaList.isEmpty()){
            mail.setFileAttachments(efaList);
        }
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(exception e){
            system.debug(e.getMessage());
        }
    }
    */
    public void handleServiceCloudCases(List<Case> serviceCloudCases) {
        Set<Id> serviceCloudAccountIds = new Set<Id>();
        List<Case> serviceCloudTechCases = new List<Case>();
        Set<Id> serviceCloudTechIds = new Set<Id>();
        Set<Id> serviceCloudUpdateCustNum = new Set<Id>();
        List<Case> casesToBeUpdated = new List<Case>();
        for(Case eachCase : serviceCloudCases) {
            if(eachCase.AccountId != NULL && eachCase.Customer_Account__c == NULL && eachCase.Technical_Site__c == NULL) {
                casesToBeUpdated.add(eachCase);
                serviceCloudAccountIds.add(eachCase.AccountId);
            } else if(eachCase.AccountId != NULL && eachCase.Customer_Account__c == NULL && eachCase.Technical_Site__c != NULL) { 
                serviceCloudTechCases.add(eachCase);
                serviceCloudTechIds.add(eachCase.Technical_Site__c);
            } else if(eachCase.AccountId == NULL && eachCase.Technical_Site__c != NULL) {
                serviceCloudTechCases.add(eachCase);
                serviceCloudTechIds.add(eachCase.Technical_Site__c);
            } else if (eachCase.AccountId != NULL && eachCase.Customer_Account__c != NULL) {
                casesToBeUpdated.add(eachCase);
                serviceCloudUpdateCustNum.add(eachCase.Customer_Account__c);
            }
        }
        if(!casesToBeUpdated.isEmpty()) {
            if(!serviceCloudAccountIds.isEmpty()) {
                system.debug('####serviceCloudAccountIds####### => ' + serviceCloudAccountIds);
                Map<Id, Account> customerMap = new Map<Id, Account>();
                for(Account caseAccount : [Select Id,RecordTypeId,Motorola_Customer_Number__c,
                                           (Select Id,Motorola_Customer_Number__c from ChildAccounts where RecordType.DeveloperName = 'Motorola_Customer_Number') 
                                           from Account where ID =: serviceCloudAccountIds]) 
                {
                    system.debug('####caseAccount####### => ' + caseAccount);
                    customerMap.put(caseAccount.Id, caseAccount);
                }
                Id custRecordtypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
                Id partnerAccountRecId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','Partner');
                for(Case eachCase : casesToBeUpdated) {
                    system.debug('####eachCase####### => ' + eachCase);
                    Account parentAccount = customerMap.get(eachCase.AccountId);
                    if(parentAccount != NULL) {
                        if(parentAccount.RecordTypeId == custRecordtypeId && parentAccount.ChildAccounts.size() > 1 && eachCase.Customer_Account__c == NULL ) {
                            system.debug ('eachCase.Customer_Account__c####'+eachCase.Customer_Account__c);
                            system.debug('Trigger.isInsert'+Trigger.isInsert);
                            system.debug('Trigger.isUpdate'+Trigger.isUpdate);
                            system.debug('eachCase.Origin'+eachCase.Origin);
                            system.debug('UserInfo.getUserId()'+UserInfo.getUserId());
                            if((Trigger.isInsert || Trigger.isUpdate) && !eachCase.Origin.startswith('Email') && UserInfo.getUserId() != System.Label.Mulesoft_User_Id) {
                                eachCase.addError('Please select a Customer Account Number as selected Customer has more than 1');
                            } else if (Trigger.isUpdate && eachCase.Origin.startswith('Email') && UserInfo.getUserId() != System.Label.Salesforce_Operations_User_Id){
                                eachCase.addError('Please select a Customer Account Number as selected Customer has more than 1');
                            }
                        } else if(parentAccount.RecordTypeId == custRecordtypeId && parentAccount.ChildAccounts.size() == 1) {
                            eachCase.Customer_Account__c = parentAccount.ChildAccounts.get(0).Id;
                            eachCase.Customer_Number__c = parentAccount.ChildAccounts.get(0).Motorola_Customer_Number__c;
                        } else if(parentAccount.RecordTypeId == partnerAccountRecId) {
                            eachCase.Customer_Number__c = parentAccount.Motorola_Customer_Number__c;
                        }
                    }
                }
            } else if (!serviceCloudUpdateCustNum.isEmpty()) {
                updateCustomerNumber(casesToBeUpdated, serviceCloudUpdateCustNum);
            }
        } 
        if(!serviceCloudTechCases.isEmpty()) {
            Map<Id, Technical_Site__c> techSitesMap = new Map<Id, Technical_Site__c>();
            for(Technical_Site__c caseTechSite : [Select Id,MCN_Account__c,Customer_Number__c,Customer__c from Technical_Site__c where ID IN : serviceCloudTechIds]) {
                techSitesMap.put(caseTechSite.Id, caseTechSite);
            }
            for(Case eachCase : serviceCloudTechCases) {
                Technical_Site__c techSite = techSitesMap.get(eachCase.Technical_Site__c);
                if(techSite.MCN_Account__c != NULL) {
                    if(eachCase.AccountId == NULL && techSite.Customer__c != NULL){
                        eachCase.AccountId = techSite.Customer__c;   
                    }
                    eachCase.Customer_Account__c = techSite.MCN_Account__c;
                    eachCase.Customer_Number__c = techSite.Customer_Number__c;
                }
            }
        }
    }
    
    public void updateCustomerNumber(List<Case> incoming, Set<Id> accountIds) {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Motorola_Customer_Number__c FROM Account where Id IN : accountIds]);
        for(Case eachCase : incoming) {
            Account caseMCN = accountMap.get(eachCase.Customer_Account__c);
            if(caseMCN != NULL) {
                eachCase.Customer_Number__c = caseMCN.Motorola_Customer_Number__c;
            }
        }
    }
}