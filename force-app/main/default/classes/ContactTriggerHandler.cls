/*  
* Class Name  : ContactTriggerHandler
* Description:  This class is used in Contact trigger
*/

public class ContactTriggerHandler implements ITriggerHandler {
    Id standardContactRT = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','EMS_Standard_Contact');
    Id partnerContactRT = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','MPE_Partner_Contact');
    Id customerContactRT = GlobalUtility.getRecordTypeIdByDeveloperName('Contact','EMS_Standard_Contact');
    PartnerSharingHelper partnerSharingHelper = new PartnerSharingHelper();//SF-2144-Lead Admin Tag Permissions
    ContactTriggerHelper triggerHelper = new ContactTriggerHelper();//SF-2248
    public static Boolean TriggerDisabled = false;

    public Boolean isDisabled() {
        TriggerSettings__c ts = TriggerSettings__c.getValues('ContactTriggerDisabled');
        if (ts != null && ts.IsActive__c)
            return true;
        else
            return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
        system.debug('inside contacttrigger');
        List<Contact> lstNewContact = new List<Contact>();
        if(newItems!=null) lstNewContact = (List<Contact>) newItems;

        User currentUser = GenericWithoutSharing.getCurrentUser();
        List<Contact> partnerContacts = new List<Contact>();
        Set<Id> accountIds = new Set<Id>();
        for(Contact conVar : lstNewContact) {
            // Setting the Record Type of Contact to Standard in Lead Conversion process
            if(String.isNotBlank(currentUser.Contact.AccountId) && conVar.AccountId != currentUser.Contact.AccountId){
                conVar.RecordTypeId = standardContactRT;
            }

            /*Commented by Brijesh for Ticket LUCXBW-675
            // Setting the Account to EMEA Registration
            if(currentUser.ContactId != null && currentUser.Contact.Account.Partner_Region__c == 'EMEA'){
                conVar.AccountId = System.Label.EMEA_Contact_Registration;
            }*/

            // Setting the contact owner and region from Account
            if(conVar.RecordTypeId == partnerContactRT) {
                partnerContacts.add(conVar);
                accountIds.add(conVar.AccountId);
                if(GlobalUtility.isLoggedinCustomerCommunityUser()) {
                    conVar.OwnerId = currentUser.Contact.Account.OwnerId;
                }
            }
        }

        if(!partnerContacts.isEmpty()){
            triggerHelper.populateRegion(partnerContacts, accountIds);
        }
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Contact> mapOldContact = new Map<Id,Contact>();
        Map<Id,Contact> mapNewContact = new Map<Id,Contact>();
        if(oldItems != null) mapOldContact = (Map<Id,Contact>) oldItems;
        if(newItems != null) mapNewContact = (Map<Id,Contact>) newItems;

        Map<Id,Contact> validateContacts = new Map<Id,Contact>();
        List<Contact> modifiedAccOrRegion  = new List<Contact>();
        Set<Id> accountIds = new Set<Id>();

        for(Contact conVar : mapNewContact.values()) {
            Contact oldCon = mapOldContact.get(conVar.Id);
            if(conVar.RecordTypeId == partnerContactRT && !conVar.Delete_Requested__c) {
                if(conVar.AccountId != oldCon.AccountId || conVar.Partner_region__c  != oldCon.Partner_region__c){
                    modifiedAccOrRegion.add(conVar);
                    accountIds.add(conVar.AccountId);
                }
            }
            if(conVar.Email != oldCon.Email){
                validateContacts.put(conVar.Id,conVar);
            }
        }

        if(!modifiedAccOrRegion.isEmpty()){
            triggerHelper.populateRegion(modifiedAccOrRegion, accountIds);
        }

        if(!validateContacts.isEmpty()){
            ContactTriggerHelper.syncLDAPInfoToUser(validateContacts.keySet());
        }
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        Map<Id,Contact> mapOldContact = new Map<Id,Contact>();
        if(oldItems != null) mapOldContact = (Map<Id,Contact>) oldItems;
        triggerHelper.createContactOnDelete_isAfter(mapOldContact.values());//SF-2248
    }

    public void afterUndelete(Map<Id, SObject> oldItems) {}

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Contact> mapNewContact = new Map<Id,Contact>();
        Map<Id,Contact> mapOldContact = new Map<Id,Contact>();

        if(oldItems != null) mapOldContact = (Map<Id,Contact>) oldItems;
        if(newItems != null) mapNewContact = (Map<Id,Contact>) newItems;

        Map<Id,Contact> tagModifiedMap = new Map<Id,Contact>();
        Map<Id,Contact> mapNewContactPartner = new Map<Id,Contact>();
        Map<Id,Contact> mapOldContactPartner = new Map<Id,Contact>();
        Map<Id,Id> mapConAccNewIds = new Map<Id,Id>();//SF-2144-Lead Admin Tag Permissions
        Map<Id,Id> mapConAccOldIds = new Map<Id,Id>();//SF-2144-Lead Admin Tag Permissions
        for(Contact conTag : mapNewContact.values()) {
            if(!conTag.Delete_Requested__c){
                Contact oldContact = mapOldContact.get(conTag.Id);
                if(conTag.Tag__c != mapOldContact.get(conTag.Id).Tag__c && (conTag.RecordTypeId == partnerContactRT || conTag.RecordTypeId == customerContactRT)) {
                    tagModifiedMap.put(conTag.Id, conTag);
                    if(conTag.Tag__c != null && conTag.Tag__c.contains('Lead Admin')){//SF-2144-Lead Admin Tag Permissions
                        mapConAccNewIds.put(conTag.Id,conTag.AccountId);
                    }
                    if(oldContact.Tag__c != null && oldContact.Tag__c.contains('Lead Admin')){//SF-2144-Lead Admin Tag Permissions
                        mapConAccOldIds.put(conTag.Id,conTag.AccountId);
                    }
                }
                if(conTag.RecordTypeId == partnerContactRT) {
                    mapNewContactPartner.put(conTag.Id, conTag);
                    mapOldContactPartner.put(conTag.Id, oldContact);
                }
            }
        }
        if(!mapConAccNewIds.isEmpty()){//SF-2144-Lead Admin Tag Permissions
            System.debug('mapConAccNewIds==>'+mapConAccNewIds);
            partnerSharingHelper.shareAllLeadswithConTagLeadAdmin(mapConAccNewIds);
        }
        if(!mapConAccOldIds.isEmpty()){//SF-2144-Lead Admin Tag Permissions
            System.debug('mapConAccOldIds==>'+mapConAccOldIds);
            partnerSharingHelper.revokeAllLeadAccesswithConTagLeadAdmin(mapConAccOldIds);
        }
        if(Test.isRunningTest() || !GlobalUtility.runningInASandbox()) {
            triggerHelper.ldpIsUpdate(mapNewContactPartner,mapOldContactPartner);
        }
        if(!mapNewContactPartner.isEmpty() && !mapOldContactPartner.isEmpty()) {
            //MasterContactTrigger.masterContactTrigger_isInsert_update(mapNewContactPartner,mapOldContactPartner,false); no longer required as removing masterflag SF-2247
            triggerHelper.adp_PermissionsetAssignenment(mapNewContactPartner,mapOldContactPartner); //SF-2248
        }
        if(!tagModifiedMap.isEmpty() && !DTSFPART_Utils.isAsynchronous()) {
            TagBasedPermissionSets.assignPsetsBasedonTags(tagModifiedMap.keySet());
        }
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id,Contact> mapNewContact = new Map<Id,Contact>();
        Map<Id,Contact> mapOldContact = new Map<Id,Contact>();
        if(newItems != null) mapNewContact = (Map<Id,Contact>) newItems;
        if(Test.isRunningTest() || !GlobalUtility.runningInASandbox()) {
            triggerHelper.ldpIsInsert(mapNewContact);
        }

        Map<Id,Contact> mapNewContactPartner = new Map<Id,Contact>();
        Map<Id,Contact> mapOldContactPartner = new Map<Id,Contact>();
        for(Contact conTag : mapNewContact.values()) {
            Contact oldContact = mapOldContact.get(conTag.Id);
            if(conTag.RecordTypeId == partnerContactRT && !conTag.Delete_Requested__c) {
                mapNewContactPartner.put(conTag.Id, conTag);
                mapOldContactPartner.put(conTag.Id, oldContact);
            }
        }
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
        Map<Id,Contact> mapOldContact = new Map<Id,Contact>();
        if(oldItems != null) mapOldContact = (Map<Id,Contact>) oldItems;
        triggerHelper.createContactOnDelete_isbefore(mapOldContact.values());//SF-2248
    }
}