public class ContactTriggerHelper {
    
    Id partnerContactRT = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
    
    public void ldpIsInsert(Map<Id,Contact> mapNewContact){
        List<Id> listTriggerIds = new List<Id>();
        List<Contact> updateContacts = new List<Contact>();
        
        for(Contact conRecs : [Select Id, Account.Type, Account.RecordtypeId, Account.Partner_Region__c, recordtypeId, ldap_batch__c, ldap_update__c, email, ldap_login__c, 
                               Contact_type__c, Account_region__c from Contact where ID IN: mapNewContact.keyset()]) 
        {
            if (conRecs.ldap_update__c != 'Y' && (String.isBlank(conRecs.ldap_batch__c)) && conRecs.ldap_batch__c != 'E' && conRecs.ldap_batch__c != 'Q') 
            {
                if (conRecs.AccountId != System.label.EMEA_Contact_Registration && conRecs.recordtypeId == partnerContactRT 
                    && !(userinfo.getUserType() == 'PowerPartner' && conRecs.Account.Partner_Region__c == 'EMEA')
                    && (conRecs.email !=null || conRecs.ldap_login__c != NULL)) 
                {
                    system.debug('Testing EMEA block');
                    listTriggerIds.add(conRecs.Id);  
                }
            } else if (conRecs.ldap_update__c == 'Y'){    
                conRecs.ldap_update__c = 'N';
                conRecs.ldap_batch__c = '';
                updateContacts.add(conRecs); 
            }
        }
        
        if(updateContacts.size() > 0){
            update updateContacts;
        }
        
        if (!listTriggerIds.isEmpty() && !System.isBatch() && !System.isFuture()) {
            callLdap stub = new callLdap();
            stub.queryBatch(listTriggerIds);
        }
    }
    
    public void ldpIsUpdate(Map<Id,Contact> mapNewContact, Map<Id,Contact> mapOldRecs){     
        List<Id> triggerIds = new List<Id>();
        List<Id> updateIds = new List<Id>();      
        List<Contact> updateContacts = new List<Contact>();
        for(Contact conRecs : [Select Id, account.type, Account.RecordtypeId, Account.Partner_Region__c, recordtypeId,ldap_batch__c, ldap_update__c, email, 
                               ldap_login__c, Contact_type__c, Account_region__c from Contact where ID IN: mapNewContact.keySet()])
        {
            if (conRecs.ldap_update__c!='Y' && (String.isBlank(conRecs.ldap_batch__c)) && conRecs.ldap_batch__c!='E' && conRecs.ldap_batch__c!='Q') {
                if (conRecs.recordtypeId == partnerContactRT  && (conRecs.email!=null || conRecs.ldap_login__c!=null)) {
                    if (conRecs.AccountId!=system.label.EMEA_Contact_Registration && mapOldRecs.get(conRecs.Id).ldap_update__c != 'Y' 
                        && mapOldRecs.get(conRecs.Id).ldap_batch__c == conRecs.ldap_batch__c && mapOldRecs.get(conRecs.Id).Contact_type__c == conRecs.Contact_type__c 
                        && !(userinfo.getUserType() == 'PowerPartner' && conRecs.Account.Partner_Region__c == 'EMEA')
                        && (conRecs.ldap_login__c == NULL || mapOldRecs.get(conRecs.Id).ldap_login__c != conRecs.ldap_login__c) 
                        && ( mapOldRecs.get(conRecs.Id).Account_region__c==conRecs.Account_region__c)){
                            system.debug('Testing EMEA block-11');
                            triggerIds.add(conRecs.Id);                          
                        } else if (mapOldRecs.get(conRecs.Id).ldap_update__c != 'Y' && mapOldRecs.get(conRecs.Id).ldap_batch__c == conRecs.ldap_batch__c 
                                   && mapOldRecs.get(conRecs.Id).Contact_type__c == conRecs.Contact_type__c  && conRecs.ldap_login__c!=NULL 
                                   && mapOldRecs.get(conRecs.Id).ldap_login__c == conRecs.ldap_login__c &&( mapOldRecs.get(conRecs.Id).Account_region__c==conRecs.Account_region__c)) 
                        {
                            updateIds.add(conRecs.Id);
                        } 
                }
            } else if (conRecs.ldap_update__c=='Y'){    
                conRecs.ldap_update__c='N';
                conRecs.ldap_batch__c='';
                updateContacts.add(conRecs);
            }
        }
        if(!updateContacts.isEmpty()){
            update updateContacts;
        }
        
        if (!triggerIds.isEmpty() && !System.isBatch() && !System.isFuture()) {
            callLdap stub = new callLdap();
            stub.queryBatch(triggerIds);
        }
        
        if (!updateIds.isEmpty() && !System.isBatch() && !System.isFuture()) {
            callLdap stub = new callLdap();
            stub.updateBatch(updateIds);
        }
    }
    
    /*
    * Method name   : createContactOnDelete_isbefore
    * Description   : Invokes in Before delete operation of record ,This Trigger is used for Populating SFDC LMS Interface Object with the Deleted Contact
    * Return Type   : void
    * Parameter : trigger.oldvalues
    */
    public void createContactOnDelete_isbefore(list<contact> oldvalues){    
        List<Contact> partnerConList = new List<Contact>();
        Id mpeAccRecordId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Id mpeRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MPE_Partner_Contact').getRecordTypeId();
        Set<Id> deleteSetId = new Set<Id>();
        Map<String,Contact> mapForAccntName = new Map<String,Contact>();
        Set<String> ldapIdDupSet = new Set<String>();
        for(Contact cont :oldvalues){
            if(cont.RecordTypeId==mpeRecordId && cont.LDAP_Login__c !=null ){       
                mapForAccntName.put(cont.LDAP_Login__c,cont);
            }
            if(cont.RecordTypeId==mpeRecordId){
                deleteSetId.add(Cont.Id);
                partnerConList.add(cont);
            }
        }
        for(Contact conRec : [Select Id, LDAP_Login__c from Contact where RecordTypeId=:mpeRecordId and Account.Recordtypeid=:mpeAccRecordId 
                              and Id Not In: deleteSetId and LDAP_Login__c in :mapForAccntName.keyset() and LDAP_Login__c!=null ])
            ldapIdDupSet.add(conRec.LDAP_Login__c);
        ctrlCreateContactOnDelete cod =  new ctrlCreateContactOnDelete(mapForAccntName.keyset(),mapForAccntName,deleteSetId);
        cod.partnerConList = partnerConList;
        cod.ldapIdDupSet = ldapIdDupSet;
        cod.insertContacts();
        If(deleteSetId.size()>0){
            ctrlCreateContactOnDelete con = new ctrlCreateContactOnDelete();
            con.deleSet = mapForAccntName.keyset();
            con.ldapIdDupSet = ldapIdDupSet ;
            con.partnerConList = partnerConList;
            con.contactDeactivate(deleteSetId);
        }
    }
    
    /*
    *Description           :Invokes in After  delete operation of record ,This Trigger is used for Populating SFDC LMS Interface Object with the Deleted Contact.
    * @author            :Vivek Pokharia
    */ 
    public void createContactOnDelete_isAfter(list<contact> oldvalues){
        String tempAccountId;
        Set<String> setLdapDelete = new Set<String>();
        Set<String> setlmsAccountId = new Set<String>();
        List<SFDC_LMSInterface__c> listlmsSfdc = new List<SFDC_LMSInterface__c>();
        Id mpeRecordId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MPE_Partner_Contact').getRecordTypeId();
        
        for(Contact con: oldvalues)
        {
            if(con.RecordTypeId==mpeRecordId && con.LDAP_Login__c !=null)
                setLdapDelete.add(con.LDAP_Login__c);
            
            if(con.RecordTypeId==mpeRecordId && con.AccountId != null)
            {
                tempAccountId=con.AccountId;
                setlmsAccountId.add(tempAccountId.substring(0,15));        
            }
            
        }
        List<SFDC_LMSInterface__c> listForActiveSfdcLms = [select Id,Contact__c,Account_Id__c, Contact_LDAP_Login__c,Contact_Deleted_Internal__c,Contact_SFDC_ID__c,Contact_Active_Delete__c  from SFDC_LMSInterface__c where Contact_LDAP_Login__c in : setLdapDelete or Account_Id__c in :setlmsAccountId ];
        if(listForActiveSfdcLms.size()>0)
        {
            for(SFDC_LMSInterface__c sfdClms : listForActiveSfdcLms )
            {
                if(sfdClms.Contact_Deleted_Internal__c=='FALSE' && sfdClms.Contact_Active_Delete__c)
                {
                    listlmsSfdc.add(sfdClms);
                }       
            }
            if(listlmsSfdc.size()>0)
                delete listlmsSfdc;
        }
        
    }
    /*
    *Description           : This after update trigger will add the ADP Permission sets to the partner user
    whose partner contact is updated with ADP tag.
    - Admin permission set will be added when the contact has both SFDC Partner Admin & ADP tag's
    - Developer permission set will be added when the contact has ADP tag but dont have SFDC Partner Admin
    * @author            :Vivek Pokharia
    */
    public void adp_permissionsetAssignenment(map<id,contact> newvalaues,map<id,contact> oldvalues){
        Id partnerRecId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MPE_Partner_Contact').getRecordTypeId();
        ID partnerAdminPermission;//Admin Permission set
        ID AdpPartnerPermissionId;
        Set<ID> setAdminConId = new Set<ID>(); //List to add admin permission set
        Set<ID> setDevContId = new Set<ID>(); //List to add dev permission set
        List<ID> listAdContId = new List<ID>(); //combined list to reduce a soql query
        list<PermissionSetAssignment> removeadminPermissionSetAccess = new List<PermissionSetAssignment>();
        list<PermissionSetAssignment> removedevPermissionSetAccess = new List<PermissionSetAssignment>();
        List<Id> listAdmUserAccessRemovalIds = new List<Id>();
        List<Id> listDevUserAccessRemovalIds = new List<Id>();
        List<User> listUserAdmin=new List<User>();
        List<User> listUserDev=new List<User>();
        List <id>listAdminId=new List<Id>();
        List <id>listDevIds=new List<Id>();
        List<Id> listAdmUserIds = new List<Id>();
        List<Id> devuserIds = new List<Id>();
        Messaging.SingleEmailMessage mailUsername = new Messaging.SingleEmailMessage();          
        List<Messaging.SingleEmailMessage> mailList= new List<Messaging.SingleEmailMessage>();
        Integer tagCount = 0;
        for(Contact con :newvalaues.values()) {
            
            if(con.RecordTypeId != partnerRecId) {
                return;
            }
            if(oldvalues.get(con.id).Tag__c != con.Tag__c) {
                tagCount ++;
            }
            if(tagCount == 0){
                return;
            }
        }
        partnerAdminPermission = Label.ADP_Partner_Admin_Permissions;
        AdpPartnerPermissionId = Label.ADP_Partner_Non_Admin_Permissions;
        for(Contact con : newvalaues.values()) {
            if(con.RecordTypeId == PartnerRecId && con.Tag__c != null && con.Tag__c.contains('ADP')){
                if(oldvalues.get(con.id).Tag__c == null){
                    if(con.Tag__c.contains('SFDC Partner Admin')){                               
                        setAdminConId.add(con.id);
                        listAdContId.add(con.id);
                    }
                    else{                                
                        setDevContId.add(con.id);
                        listAdContId.add(con.id);
                    }
                }
                else if(oldvalues.get(con.id).Tag__c <> null && !oldvalues.get(con.id).Tag__c.contains('ADP')){
                    if(con.Tag__c.contains('SFDC Partner Admin')){                              
                        setAdminConId.add(con.id);
                        listAdContId.add(con.id);
                    }
                    else{                                
                        setDevContId.add(con.id);
                        listAdContId.add(con.id);
                    }
                } else if(!con.Tag__c.contains('SFDC Partner Admin') && oldvalues.get(con.id).Tag__c.contains('SFDC Partner Admin')) {                            
                    setDevContId.add(con.id);
                    listAdContId.add(con.id);
                    if(oldvalues.get(con.id).Tag__c.contains('SFDC Partner Admin'))
                    {
                        listAdmUserAccessRemovalIds.add(con.id);                              
                    }
                } else if(con.Tag__c.contains('SFDC Partner Admin') && con.Tag__c.contains('ADP')&& oldvalues.get(con.id).Tag__c.contains('ADP') && !oldvalues.get(con.id).Tag__c.contains('SFDC Partner Admin') ) {
                    setAdminConId.add(con.id);
                    listAdContId.add(con.id);
                    listDevUserAccessRemovalIds.add(con.id);
                }  
            }                   
            else  if(con.RecordTypeId == PartnerRecId && con.Tag__c != null && oldvalues.get(con.id).Tag__c!=null && !con.Tag__c.contains('ADP')){ 
                if(oldvalues.get(con.id).Tag__c.contains('SFDC Partner Admin') && oldvalues.get(con.id).Tag__c.contains('ADP'))
                    listAdmUserAccessRemovalIds.add(con.id);
                else if(!oldvalues.get(con.id).Tag__c.contains('SFDC Partner Admin'))
                    listDevUserAccessRemovalIds.add(con.id);
            } 
        }
        if(listAdContId != null){        
            
            Id owdId = Id.valueOf(Label.ADP_OrgWideEmailAddress);             
            Id templateId = Id.valueOf(Label.ADP_Welcome_Email_for_existing_SFDC_User);
            for(User usr : [select id,ContactId,isActive,Email from User where ContactId in :listAdContId]){ 
                if(usr.isActive == true && setAdminConId.contains(usr.contactid)){
                    listAdmUserIds.add(usr.id);
                }
                else if(usr.isActive == true && setDevContId.contains(usr.contactid)){
                    devuserIds.add(usr.id);
                } 
                
                List<String> sendToaddr = new List<String>();
                sendToaddr.add(usr.Email);
                system.debug('Toaddress list is  '+sendToaddr);
                mailUsername = new Messaging.SingleEmailMessage();                 
                mailUsername.setOrgWideEmailAddressId(owdId);
                mailUsername.setToAddresses(sendToaddr); 
                mailUsername.setTargetObjectId(usr.Id);      
                mailUsername.setTemplateID(templateId);
                mailUsername.saveAsActivity = false;
                mailList.add(mailUsername);                      
            }
        }
        try{
            if(listAdmUserIds != null){
                //Utilizing this existing helper class to add ADP Permission set
                MRCommissionDisputeAccessclass.provideaccess(listAdmUserIds,partnerAdminPermission);
            }
            if(devuserIds != null){
                //Utilizing this existing helper class to add ADP Permission set
                MRCommissionDisputeAccessclass.provideaccess(devuserIds,AdpPartnerPermissionId);
            }
            //included by madhavi to cover permissionset removal access
            if(listAdmUserAccessRemovalIds.size()>0)
            {
                
                listUserAdmin=[select id,ContactId,isActive,Email from User where ContactId in :listAdmUserAccessRemovalIds and isactive=true];
                removeadminPermissionSetAccess=[select AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId in :listUserAdmin and PermissionSetId=:partnerAdminPermission];
                system.debug('testing123'+removeadminPermissionSetAccess);
                
                if(removeadminPermissionSetAccess.size()>0)
                {
                    for(PermissionSetAssignment p:removeadminPermissionSetAccess)
                    {
                        listAdminId.add(p.id);
                    }
                    MRCommissionDisputeAccessclass.removeaccess(listAdminId);
                }
            }
            //included by madhavi to cover permissionset removal access
            if(listDevUserAccessRemovalIds.size()>0)
            {
                listUserDev=[select id,ContactId,isActive,Email from User where ContactId in :listDevUserAccessRemovalIds and isactive=true];
                removedevPermissionSetAccess=[select AssigneeId,PermissionSetId from PermissionSetAssignment where AssigneeId in :listUserDev and PermissionSetId=:AdpPartnerPermissionId];
                system.debug('testing1234'+removedevPermissionSetAccess);
                if(removedevPermissionSetAccess.size()>0)
                {
                    for(PermissionSetAssignment p:removedevPermissionSetAccess)
                    {
                        listDevIds.add(p.id);
                    }
                    MRCommissionDisputeAccessclass.removeaccess(listDevIds);
                }
            }
            
            // Including ADPFlag condition while sending email by Madhavi
            if(mailList.size()>0 ){
                ADPFlagforDM__c DM1=ADPFlagforDM__c.getValues('ADPFlagforContactTagupdate');
                Boolean ADPFlag=DM1.ADP_Flag__c;
                if(ADPFlag==true)
                {
                    system.debug('Email sent');          
                    Messaging.sendEmail(mailList);
                } 
            }
        }catch(Exception e){
        }    
    }

    @future
    public static void syncLDAPInfoToUser(Set<Id> contactIds){  
        List<User> usersToBeUpdated = new List<User>();
        for(User contactUser : [Select Id,ContactId,Contact.FirstName,Contact.LastName,FirstName,LastName,Email,FederationIdentifier,
                                Contact.Email,Contact.LDAP_Login__c from User where ContactId IN : contactIds AND IsPortalEnabled = TRUE]) 
        {
            Contact userContact = contactUser.Contact;
            if(userContact != NULL) {
                if(String.isNotBlank(contactUser.Contact.FirstName) && contactUser.Contact.FirstName != contactUser.FirstName) {
                    contactUser.FirstName = contactUser.Contact.FirstName;
                }
                if(String.isNotBlank(contactUser.Contact.LastName) && contactUser.Contact.LastName != contactUser.LastName) {
                    contactUser.LastName = contactUser.Contact.LastName;
                }
                if(String.isNotBlank(contactUser.Contact.Email) && contactUser.Contact.Email != contactUser.Email) {
                    contactUser.Email = contactUser.Contact.Email;
                }
                if(String.isNotBlank(contactUser.Contact.LDAP_Login__c) && contactUser.Contact.LDAP_Login__c != contactUser.FederationIdentifier) {
                    contactUser.FederationIdentifier = contactUser.Contact.LDAP_Login__c;
                }
            }
            usersToBeUpdated.add(contactUser);
        }
        update usersToBeUpdated;
    }
    
    public void populateRegion(List<Contact> partnerContacts, Set<Id> accountIds){
        Map<Id,Account> mapAcct = new Map<Id,Account>();
        for(Account accountObj : [Select Id, Partner_region__c from Account where Id IN : accountIds]){
            mapAcct.put(accountObj.id, accountObj);
        }
        for(Contact cont : partnerContacts){
            Account ContactAccoun = mapAcct.get(cont.AccountId);
            if(ContactAccoun != null){
                cont.Account_Region__c = ContactAccoun.Partner_Region__c;
                cont.Partner_Region__c = ContactAccoun.Partner_Region__c;    
            }
        }    
    }
    
}