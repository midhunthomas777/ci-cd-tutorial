/***
 * This class is used for sharing Customer,MCN Accounts and Leads with Executive Role of Partner Aaccount
 * This class is used to Share the CUstomer,MCN Account and Leads with Partner Users based on Lookup to contact on respective records
 *
 * Sampe aacLeadPartnerMap = {'00Q4C000003GbWaUAK','0014C00000DiVx1QAF'} - Customer AccId,Patner Account Id
   MCN Acc Id, PartnerAccount Id
   Lead Id,Partner Account Id
   ---------------
   aacLeadPartnerUserMap - Customer Account Id, Contact Id
   MCN Account Id,  Contact Id
   Lead Id, Contact Id
 * **/
public class PartnerSharingHelper {
    public void shareToExecutiveRoles(Set<Id> allMRChangedCustomers) {
        Set<String> roles = new Set<String> {'%PartnerExecutive%'};
        Set<Id> allPartners = new Set<Id>();
        Map<Id,Set<Id> > customerMRMap = new Map<Id,Set<Id> >();
        for(Account mcn : [Select Id,Assigned_MR__c,ParentId from Account where ParentId IN : allMRChangedCustomers and Assigned_MR__c != NULL]) {
            if(!customerMRMap.containsKey(mcn.ParentId)) {
                customerMRMap.put(mcn.ParentId, new Set<Id> {mcn.Assigned_MR__c});
            }
            customerMRMap.get(mcn.ParentId).add(mcn.Assigned_MR__c);
        }
        for(Id custId : customerMRMap.keySet()) {
            allPartners.addAll(customerMRMap.get(custId));
        }
        Map<Id, List<Id> > partnerGroupIdMap = fetchAllGroups(allPartners,roles);
        List<AccountShare> toBeInsertedAS = new List<AccountShare>();
        for(Id custId : customerMRMap.keySet()) {
            for(Id partnerId : customerMRMap.get(custId)) {
                if(partnerGroupIdMap.containsKey(partnerId)) {
                    for(String userGroupId :  partnerGroupIdMap.get(partnerId)) {
                        toBeInsertedAS.add(new AccountShare(
                                    AccountId = custId,
                                    UserOrGroupId = userGroupId,
                                    AccountAccessLevel = 'Edit',
                                    OpportunityAccessLevel = 'None',
                                    ContactAccessLevel = 'Read'
                                    ));
                    }
                }
            }
        }
        if(!toBeInsertedAS.isEmpty()) {
            Delete [SELECT Id FROM AccountShare WHERE AccountId IN : allMRChangedCustomers AND UserOrGroup.Type ='Queue' AND RowCause='Manual'];
            Database.insert(toBeInsertedAS, false);
        }
    }
    public void shareToAllRoles(Map<Id,Id> aacLeadPartnerMap) {
        Set<String> roles = new Set<String> {'%User%','%PartnerExecutive%'};
        Map<Id, List<Id> > partnerGroupIdMap = fetchAllGroups(new Set<Id>(aacLeadPartnerMap.values()),roles);
        Map<Id,Set<Id> > customerMRMap = new Map<Id,Set<Id> >();
        List<AccountShare> toBeInsertedAS = new List<AccountShare>();
        for(Id incoming : aacLeadPartnerMap.keySet()) {
            if(aacLeadPartnerMap.containsKey(incoming)) {
                if(partnerGroupIdMap.containsKey(aacLeadPartnerMap.get(incoming))) {
                    for(Id usrOrGrpId : partnerGroupIdMap.get(aacLeadPartnerMap.get(incoming))) {
                        System.debug('usrOrGrpId==incoming==>'+usrOrGrpId+'=='+incoming);
                        System.debug('String.valueOf(incoming).substring(0,3)##' +String.valueOf(incoming).substring(0,3));
                        if(String.isNotBlank(usrOrGrpId) && String.valueOf(incoming).substring(0,3) == '001') {
                            AccountShare execShare = new AccountShare();
                            execShare.AccountId = incoming;
                            execShare.UserOrGroupId = usrOrGrpId;
                            execShare.AccountAccessLevel = 'Edit';
                            execShare.OpportunityAccessLevel = 'None';
                            execShare.ContactAccessLevel = 'Read';
                            toBeInsertedAS.add(execShare);
                            System.debug(toBeInsertedAS);
                        }
                    }
                }
            }
        }
        if(!toBeInsertedAS.isEmpty()) {
            System.debug('#######toBeInsertedAS############ => ' + toBeInsertedAS);
            Database.delete([SELECT Id FROM AccountShare WHERE AccountId IN: aacLeadPartnerMap.keySet() AND UserOrGroup.Type ='Queue' AND RowCause='Manual' AND AccountId != NULL], false);
            Database.insert(toBeInsertedAS, false);
        }
    }

    public void shareToExecutiveRoles(Map<Id,Id> aacLeadPartnerMap){
        System.debug('aacLeadPartnerMap###+>'+aacLeadPartnerMap);
        Set<String> roles = new Set<String> {'%PartnerExecutive%'};
        Map<Id, List<Id> > partnerGroupIdMap = fetchAllGroups(new Set<Id>(aacLeadPartnerMap.values()),roles);
        System.debug('partnerGroupIdMap==> '+partnerGroupIdMap);
        List<LeadShare> toBeInsertedLS = new List<LeadShare>();
        List<AccountShare> toBeInsertedAS = new List<AccountShare>();
        List<OpportunityShare> toBeInsertedOS = new List<OpportunityShare>();
        List<CaseShare> toBeInsertedCS = new List<CaseShare>();
        List<MR_Commission_Calculator__Share> toBeInsertedMRCalc = new List<MR_Commission_Calculator__Share>();
        for(Id incoming : aacLeadPartnerMap.keySet()) {
            if(aacLeadPartnerMap.containsKey(incoming)) {
                if(partnerGroupIdMap.containsKey(aacLeadPartnerMap.get(incoming))) {
                    for(Id usrOrGrpId : partnerGroupIdMap.get(aacLeadPartnerMap.get(incoming))) {
                        System.debug('usrOrGrpId==incoming==>'+usrOrGrpId+'=='+incoming);
                        System.debug('String.valueOf(incoming).substring(0,3)##' +String.valueOf(incoming).substring(0,3));
                        if(String.isNotBlank(usrOrGrpId) && String.valueOf(incoming).substring(0,3) == '00Q') {
                            LeadShare execShare = new LeadShare();
                            execShare.LeadId = incoming;
                            execShare.UserOrGroupId = usrOrGrpId;
                            execShare.LeadAccessLevel = 'Edit';
                            toBeInsertedLS.add(execShare);
                        } else if(String.isNotBlank(usrOrGrpId) && String.valueOf(incoming).substring(0,3) == '001') {
                            AccountShare execShare = new AccountShare();
                            execShare.AccountId = incoming;
                            execShare.UserOrGroupId = usrOrGrpId;
                            execShare.AccountAccessLevel = 'Edit';
                            execShare.OpportunityAccessLevel = 'None';
                            execShare.ContactAccessLevel = 'Read';
                            toBeInsertedAS.add(execShare);
                            System.debug(toBeInsertedAS);
                        } else if (String.isNotBlank(usrOrGrpId) && String.valueOf(incoming).substring(0,3) == '006') {
                            OpportunityShare execShare = new OpportunityShare();
                            execShare.OpportunityId = incoming;
                            execShare.UserOrGroupId = usrOrGrpId;
                            execShare.OpportunityAccessLevel = 'Edit';
                            toBeInsertedOS.add(execShare);
                        } else if (String.isNotBlank(usrOrGrpId) && String.valueOf(incoming).substring(0,3) == '500') {
                            system.debug('Case sharing for MR digital');
                            //MR Digital
                            CaseShare execShare = new CaseShare();
                            execShare.CaseId = incoming;
                            execShare.UserOrGroupId = usrOrGrpId;
                            execShare.CaseAccessLevel = 'Edit';
                            execShare.RowCause='Manual';
                            toBeInsertedCS.add(execShare);
                            System.debug('toBeInsertedCS#####'+toBeInsertedCS);
                        }

                        else if (String.isNotBlank(usrOrGrpId) && incoming.getSObjectType().getDescribe().getName()=='MR_Commission_Calculator__c') {
                            system.debug('MR Program sharing for MR Program');
                            //MR Program
                            MR_Commission_Calculator__Share execShare = new MR_Commission_Calculator__Share();
                            execShare.ParentID = incoming;
                            execShare.UserOrGroupId = usrOrGrpId;
                            execShare.AccessLevel = 'Edit';
                            execShare.RowCause='Manual';
                            toBeInsertedMRCalc.add(execShare);
                            System.debug('toBeInsertedMRCalc#####'+toBeInsertedMRCalc);
                        }
                    }
                }
            }
        }
        if(!toBeInsertedLS.isEmpty()) {
            Database.insert(toBeInsertedLS,false);
        }

        if(!toBeInsertedOS.isEmpty()) {
            Database.insert(toBeInsertedOS,true);
        }
        //MR Digital
        if(!toBeInsertedCS.isEmpty()) {
            Database.insert(toBeInsertedCS,true);
        }
        //MR Program
        if(!toBeInsertedMRCalc.isEmpty()) {
            Database.insert(toBeInsertedMRCalc,true);
        }

        if(!toBeInsertedAS.isEmpty()) {
            System.debug('#######toBeInsertedAS############ => ' + toBeInsertedAS);
            Database.delete([SELECT Id FROM AccountShare WHERE AccountId IN: aacLeadPartnerMap.keySet() AND UserOrGroup.Type ='Queue' AND RowCause='Manual' AND AccountId != NULL], false);
            Database.insert(toBeInsertedAS, false);
        }
    }

    private Map<Id,List<Id> > fetchAllGroups(Set<Id> allPartnerIds,Set<String> roles) {

        Map<Id,List<Id> > partnerRoleMap = new Map<Id,List<Id> >();
        Set<Id> UserRoleList = new Set<Id>();
        for(UserRole ur : [SELECT Id, Name, PortalRole,PortalAccountId FROM UserRole
                        WHERE PortalAccountId IN :allPartnerIds AND PortalAccountId!=null AND DeveloperName like: roles]) {
            UserRoleList.add(ur.id);
            if(!partnerRoleMap.containsKey(ur.PortalAccountId))
                partnerRoleMap.put(ur.PortalAccountId,new List<Id> {ur.Id});
            else
                partnerRoleMap.get(ur.PortalAccountId).add(ur.Id);
        }
        Map<Id,List<Id> > roleGrpMap = new Map<Id,List<Id> >();

        for(Group GL : [SELECT Id,Type,RelatedId FROM Group WHERE RelatedId in :userRoleList AND Type='Role' AND DeveloperName like: roles]) {
            if(!roleGrpMap.containsKey(GL.Id))
                roleGrpMap.put(GL.RelatedId,new List<id> {GL.Id});
            else
                roleGrpMap.get(GL.RelatedId).add(GL.Id);
        }

        Map<Id,List<Id> > partnerGroupIdMap = new Map<Id,List<Id> >();

        for(Id accId : partnerRoleMap.keySet()) {
            for(Id roleId : partnerRoleMap.get(accId)) {
                for(Id groupId : roleGrpMap.get(roleId)) {
                    if(!partnerGroupIdMap.containsKey(accId) )
                        partnerGroupIdMap.put(accId, new List<id> {groupId});
                    else
                        partnerGroupIdMap.get(accId).add(groupId);
                }
            }
        }
        system.debug('#####partnerGroupIdMap###### => ' + partnerGroupIdMap);
        return partnerGroupIdMap;
    }

    public void shareToPartnerUser(Set<Id> allMRChangedCustomers){
        Set<Id> allMRSalesReps = new Set<Id>();
        Map<Id,Set<Id> > customerMRMap = new Map<Id,Set<Id> >();
        for(Account mcn : [Select Id,Assigned_MR_Sales_Person__c,ParentId from Account where ParentId IN : allMRChangedCustomers and Assigned_MR_Sales_Person__c != NULL]) {
            if(!customerMRMap.containsKey(mcn.ParentId)) {
                customerMRMap.put(mcn.ParentId, new Set<Id> {mcn.Assigned_MR_Sales_Person__c});
            }
            customerMRMap.get(mcn.ParentId).add(mcn.Assigned_MR_Sales_Person__c);
        }

        for(Id custId : customerMRMap.keySet()) {
            allMRSalesReps.addAll(customerMRMap.get(custId));
        }

        Map<Id,Id> conUsrMap = new Map<Id,Id>();

        for(User usr:[SELECT Id,ContactId FROM User WHERE ContactId IN:allMRSalesReps AND IsActive=TRUE AND ContactId != NULL]) {
            conUsrMap.put(usr.ContactId,usr.Id);
        }

        List<AccountShare> toBeInsertedAS = new List<AccountShare>();
        for(Id custId : customerMRMap.keySet()) {
            for(Id saleRepId : customerMRMap.get(custId)) {
                String userGroupId = conUsrMap.get(saleRepId);
                if(String.isNotBlank(userGroupId)) {
                    toBeInsertedAS.add(new AccountShare(
                                AccountId = custId,
                                UserOrGroupId = userGroupId,
                                AccountAccessLevel = 'Edit',
                                OpportunityAccessLevel = 'None',
                                ContactAccessLevel = 'Read'
                                ));
                }
            }
        }
        Delete [SELECT Id FROM AccountShare WHERE AccountId IN : allMRChangedCustomers AND UserOrGroup.Type ='User'
                                                                                                            AND RowCause='Manual' AND UserOrGroup.UserRole.PortalType = 'Partner'];
        if(!toBeInsertedAS.isEmpty()) {
            Database.insert(toBeInsertedAS, false);
        }
    }
    public void shareToPartnerUser(Map<Id,Id> aacLeadPartnerUserMap){

        List<LeadShare> toBeInsertedLS = new List<LeadShare>();
        List<AccountShare> toBeInsertedAS = new List<AccountShare>();

        List<User> usrLst = [SELECT Id,ContactId FROM User WHERE ContactId IN:aacLeadPartnerUserMap.values() AND IsActive=TRUE AND ContactId != NULL];
        Map<Id,Id> conUsrMap = new Map<Id,Id>();

        for(User usr:usrLst) {
            conUsrMap.put(usr.ContactId,usr.Id);
        }

        for(Id incoming:aacLeadPartnerUserMap.keyset()) {
            String usrOrGrpId = conUsrMap.get(aacLeadPartnerUserMap.get(incoming));
            if(String.isNotBlank(usrOrGrpId)) {
                if(String.valueOf(incoming).substring(0,3) == '00Q' && String.isNotBlank(usrOrGrpId)) {
                    LeadShare execShare = new LeadShare();
                    execShare.LeadId = incoming;
                    execShare.UserOrGroupId = usrOrGrpId;
                    execShare.LeadAccessLevel = 'Edit';
                    toBeInsertedLS.add(execShare);
                } else if(String.valueOf(incoming).substring(0,3) == '001' && String.isNotBlank(usrOrGrpId)) {
                    AccountShare execShare = new AccountShare();
                    execShare.AccountId = incoming;
                    execShare.UserOrGroupId = usrOrGrpId;
                    execShare.AccountAccessLevel = 'Edit';
                    execShare.OpportunityAccessLevel = 'None';
                    execShare.ContactAccessLevel = 'Read';
                    toBeInsertedAS.add(execShare);
                }
            }
        }
        if(toBeInsertedLS.size()>0) {
            database.insert(toBeInsertedLS,false);
        }
        Delete [SELECT Id FROM AccountShare WHERE AccountId IN : aacLeadPartnerUserMap.keySet() AND UserOrGroup.Type ='User'
                                                                                                                    AND RowCause='Manual' AND UserOrGroup.UserRole.PortalType = 'Partner' AND AccountId != NULL];
        if(toBeInsertedAS.size()>0) {
            database.insert(toBeInsertedAS,false);
        }
    }
    //leadOldConMap - Key is Lead Id and Value is Contact Id
    public void revokeAccessToPartnerUsers(Map<Id,Id> leadOldConMap){

        Set<Id> partnerUsrIds = new Set<Id>();
        for(User usr:[SELECT Id FROM User WHERE ContactId IN:leadOldConMap.values() AND ContactId!='']) {
            partnerUsrIds.add(usr.Id);
        }

        List<LeadShare> leadShrRcrds = [SELECT LeadId, Id, UserOrGroupId, LeadAccessLevel, RowCause FROM
                                        LeadShare WHERE LeadId IN:leadOldConMap.keySet() AND
                                        UserOrGroup.Type ='User' AND RowCause='Manual' AND UserOrGroupId IN:partnerUsrIds];

        database.delete(leadShrRcrds,false);
    }

    //leadOldAccMap - Key is Lead Id and Value is Account Id
    public void revokeAccessToPartnerExecs(Map<Id,Id> leadOldAccMap){

        List<LeadShare> leadShrRcrds = [SELECT LeadId, Id, UserOrGroupId, LeadAccessLevel, RowCause FROM
                                        LeadShare WHERE LeadId IN:leadOldAccMap.keySet() AND
                                        UserOrGroup.Type ='Queue' AND RowCause='Manual'];

        database.delete(leadShrRcrds,false);
    }

    //MCN Account  Id , Partner Id as Value
    public void revokeAccAccessToPartnerExecs(Map<Id,Id> accOldAccMap,Set<Id> parentAccIds){
        Set<String> roles = new Set<String> {'%PartnerExecutive%'};

        Map<Id, List<Id> > partnerGroupMap = fetchAllGroups(new Set<Id>(accOldAccMap.values()),roles);
        List<id> roleIds = new List<Id>();
        for(List<Id> Ids : partnerGroupMap.values())
            roleIds.addAll(roleIds);

        List<AccountShare> accShrRcrds = [SELECT Id,AccountId FROM
                                        AccountShare WHERE (AccountId IN:accOldAccMap.keySet() OR AccountId IN:parentAccIds) AND UserOrGroupId IN: roleIds
                                        AND UserOrGroup.Type ='Queue' AND RowCause='Manual'];
        database.delete(accShrRcrds,false);

    }

    public void leadSharingOfAPandLALeads(Map<Id,Id> leadPartnerMap){
        Map<Id,List<User> > partnerAccUserMap = new Map<Id,List<User> >();
        List<LeadShare> toBeInsertedShareRecords = new List<LeadShare>();

        for(User leadPartUser:[SELECT Id,Contact.AccountId FROM User WHERE Contact.Radio_Lead_Contact__c = 'TRUE' AND Contact.AccountId IN :leadPartnerMap.values()]) {
            if(!partnerAccUserMap.containsKey(leadPartUser.Contact.AccountId)) {
                partnerAccUserMap.put(leadPartUser.Contact.AccountId,new List<User>());
            }
            partnerAccUserMap.get(leadPartUser.Contact.AccountId).add(leadPartUser);
        }

        System.debug('#######partnerAccUserMap#####==>'+partnerAccUserMap);

        for(Id leadId:leadPartnerMap.keySet()) {
            Id partnerAccId = leadPartnerMap.get(leadId);
            if(partnerAccUserMap.containsKey(partnerAccId)) {
                for(User leadUser:partnerAccUserMap.get(partnerAccId)) {
                    LeadShare partnerUserShare = new LeadShare();
                    partnerUserShare.LeadId = leadId;
                    partnerUserShare.UserOrGroupId = leadUser.ID;
                    partnerUserShare.LeadAccessLevel = 'Edit';
                    toBeInsertedShareRecords.add(PartnerUserShare);
                }
            }
        }

        System.debug('#######toBeInsertedShareRecords#####==>'+toBeInsertedShareRecords);

        if(!toBeInsertedShareRecords.isEmpty()) {
            Database.insert(toBeInsertedShareRecords,false);
        }
    }


    public void removeLeadSharingOfAPandLALeads(Map<Id,Lead> leadPartnerMap){
        Set<Id> oldAssignedPartnerIds  =new Set<Id>();
        for(Lead moidifiedlead:leadPartnerMap.values()) {
            if(String.isNotBlank(moidifiedlead.Partner_Account_NA__c)) {
                oldAssignedPartnerIds.add(moidifiedlead.Partner_Account_NA__c);
            }
        }

        List<User> leadPartnerUsers = [SELECT Id,Contact.AccountId FROM User WHERE Contact.AccountId IN :oldAssignedPartnerIds];
        List<LeadShare> existingSharings = [SELECT LeadId, Id FROM LeadShare
                                            WHERE LeadID IN :leadPartnerMap.keySet() AND UserOrGroupId IN: leadPartnerUsers AND RowCause = 'Manual'];

        if(!existingSharings.isEmpty()) {
            Database.delete(existingSharings,false);
        }
    }


    Public void populateMRNamesonCustomer(Set<Id> CustAccIds){

        List<Account> custAccs = [SELECT Id,Assigned_MR_Names__c,
                                (SELECT Id,Assigned_MR__r.Name,Assigned_MR_Sales_Person__r.Name FROM ChildAccounts) FROM Account
                                WHERE Id IN:CustAccIds];

        List<Account> tobeUpdated = new List<Account>();

        for(Account acc:custAccs) {
            Set<String> tempSet = new Set<String>();
            for(Account chac:acc.ChildAccounts) {
                tempSet.add(chac.Assigned_MR__r.Name);
            }
            if(!tempSet.isEmpty()) {
                acc.Assigned_MR_Names__c = String.join(new List<String>(tempSet), '\n');
            }
            else{
                acc.Assigned_MR_Names__c = '';
            }

            tobeUpdated.add(acc);
        }
        if(tobeUpdated.size()>0) {
            update tobeUpdated;
        }
    }

    public Map<Id,Id> getAccountIdFromUser(Set<Id> oppCreators){
        Map<Id,Id> userAccMap = new Map<Id,Id>();
        for(User usr:[SELECT Id,Contact.AccountId FROM User WHERE Id IN:oppCreators AND Contact.AccountId!=null]) {
            userAccMap.put(usr.Id,usr.Contact.AccountId);
        }

        return userAccMap;
    }
    //SF-2144 - Lead Admin Tag Permissions
    public void shareAllLeadswithConTagLeadAdmin(Map<Id,Id>  conAccPartnerMap){
        List<LeadShare> toBeInsertedLS = new List<LeadShare>();
        Map<Id,Id> conUserMap = new Map<Id,Id>();
        Map<Id,List<Lead> > accLeadMap = new Map<Id,List<Lead> >();
        for(Contact con:[SELECT Id,User__c FROM Contact WHERE Id IN:conAccPartnerMap.keySet() AND User__r.IsActive =TRUE ]) {
            conUserMap.put(con.Id,con.User__c);
        }
        for(Lead lead:[SELECT Id,Partner_Account_NA__c FROM Lead WHERE Partner_Account_NA__c =: conAccPartnerMap.values() AND IsConverted =FALSE]) {
            if(lead.Partner_Account_NA__c!= null && accLeadMap.containsKey(lead.Partner_Account_NA__c)) {
                accLeadMap.get(lead.Partner_Account_NA__c).add(lead);
            }
            else{
                accLeadMap.put(lead.Partner_Account_NA__c,new List<Lead> {lead});
            }
        }
        try{
            for(Id con:conAccPartnerMap.keyset()) {
                Id userId = conUserMap.get(con);
                Id AccId = conAccPartnerMap.get(con);
                if(accLeadMap.containsKey(AccId)) {
                    for(Lead lead:accLeadMap.get(AccId)) {
                        LeadShare execShare = new LeadShare();
                        execShare.LeadId = lead.Id;
                        execShare.UserOrGroupId = userId;
                        execShare.LeadAccessLevel = 'Edit';
                        toBeInsertedLS.add(execShare);
                    }
                }
            }
            if(!toBeInsertedLS.isEmpty()) {
                Database.insert(toBeInsertedLS,false);
                assignPermissionSet(conUserMap.values());
            }
        }catch (Exception ex) {
            System.debug('#####Error Message######## => ' + ex.getMessage());
        }
    }
    //SF-2144 - Lead Admin Tag Permissions
    @future
    public static void assignPermissionSet(List<Id> userIds){
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        If(!userIds.isEmpty()){
            for(Id userId: userIds) {
                PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = Label.Partner_User_Lead_Reassign_PermissionSet, AssigneeId = userId);
                permissionSetList.add(psa);
            }
        }
        If(!permissionSetList.isEmpty()){
            Database.SaveResult[] srList1 = Database.insert(permissionSetList,false);
        }
    }
    //SF-2144 - Lead Admin Tag Permissions
    public void revokeAllLeadAccesswithConTagLeadAdmin(Map<Id,Id> conAccPartnerMap){
        Map<Id,Id> userConMap = new Map<Id,Id>();
        List<LeadShare> toBeInsertedLS = new List<LeadShare>();
        for(Contact con:[SELECT User__c,Id FROM Contact WHERE Id IN:conAccPartnerMap.keySet() AND User__r.IsActive =TRUE ]) {
            userConMap.put(con.Id,con.User__c);
        }
        List<Lead> leadlst = [SELECT Id FROM Lead WHERE Partner_Account_NA__c =: conAccPartnerMap.values() AND IsConverted =FALSE];
        List<LeadShare> leadShrRcrds = [SELECT Id FROM
                                        LeadShare WHERE LeadId IN:leadlst AND
                                        UserOrGroup.Type ='User' AND RowCause='Manual' AND UserOrGroupId IN:userConMap.values()];
        Set<Id> userIds = new Set<Id>();
        try{
            if(!leadShrRcrds.isEmpty()) {
                Database.DeleteResult[] deleteResults = database.delete(leadShrRcrds,false);//1.Delete all Leadsharing for this contact
                revokePermissionSet(userConMap.values());//2.Remove the Lead Partner Reassign PermissionSet
                if(!userConMap.isEmpty()) {//3.Provide sharing for the leads assigned by Partner_Assigned_Contact_NA__c
                    for(Lead lead: [SELECT Id,Partner_Assigned_Contact_NA__c FROM Lead WHERE Partner_Assigned_Contact_NA__c =: conAccPartnerMap.keySet() AND IsConverted =FALSE]) {
                        Id userId = userConMap.get(lead.Partner_Assigned_Contact_NA__c);
                        LeadShare execShare = new LeadShare();
                        execShare.LeadId = lead.Id;
                        execShare.UserOrGroupId = userId;
                        execShare.LeadAccessLevel = 'Edit';
                        toBeInsertedLS.add(execShare);
                    }
                }
                if(!toBeInsertedLS.isEmpty()) {
                    database.insert(toBeInsertedLS,false);
                }

            }
        }catch (Exception ex) {
            System.debug('#####Error Message######## => ' + ex.getMessage());
        }
    }
    //SF-2144 - Lead Admin Tag Permissions
    @future
    public static void revokePermissionSet(List<Id> userIds){
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        If(!userIds.isEmpty()){
            List<PermissionSetAssignment> psaLst = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =:userIds AND PermissionSetId =:Label.Partner_User_Lead_Reassign_PermissionSet];
            System.debug('psaLst########=>'+psaLst);
            Database.delete(psaLst,false);
        }
    }
}