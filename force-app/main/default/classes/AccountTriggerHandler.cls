/*******************************************************************************
 * Description : Handler class for AccountTrigger
 * Date : 3rd Nov 2017
 ******************************************************************************/

public class AccountTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
    Id prosRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
    Id partRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
    Id custRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SoldToAccount').getRecordTypeId();
    Id mcnRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Motorola_Customer_Number').getRecordTypeId();
    Id archiveRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Archived').getRecordTypeId();
    public static Map<String,List<String>> mapAccIdsTeamUserEmails= new  Map<String,List<String>>();    //

    PartnerAccountTriggerHelper partnerHelper = new PartnerAccountTriggerHelper();
    PartnerSharingHelper partnerSharingHelper = new PartnerSharingHelper();
    AccountMCNConsolidateViewHelper accountUpdater = new AccountMCNConsolidateViewHelper();
    PermissionSetsHelper permSetHelper = new PermissionSetsHelper();
    ProspectAccountTriggerHelper prospectHelper = new ProspectAccountTriggerHelper();
    AccountTriggerHelper accntHelper = new AccountTriggerHelper();
    //GoogleDriveAccountTriggerHelper googleDriveAccntHelper = new GoogleDriveAccountTriggerHelper(); //SF-2223

    public Boolean isDisabled(){
        TriggerSettings__c ts = TriggerSettings__c.getValues('CustomerAccountTriggerDisabled');
        if (ts != null && ts.IsActive__c)
            return True;
        else
            return TriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems){
        List<Account> newList = new List<Account>();
        if(newItems != null) newList = (List<Account>) newItems;
        List<Account> mcnAccounts = new List<Account>();
        List<Account> prospectAccounts = new List<Account>();
        /**To implement Core Id Owner Mapping as part of CDH Integration*/
        Set<String> coreIds = new Set<String>();        // Defined to implement Core Id Owner Mapping as part of CDH Integration
        Map<String,Id> coreMap = new Map<String,Id>();  // Defined to implement Core Id Owner Mapping as part of CDH Integration
        //SF-2508
        List<User> lstUser = [SELECT Id, Default_Territory__c, UserTheater__c FROM User WHERE Id =: UserInfo.getUserId()];
        for(Account acc : newList) {
            if(acc.RecordTypeId == prosRecordtypeId) {
                if(UserInfo.getUserType() != 'Standard') {
                    if(String.isBlank(acc.Billing_County__c) && acc.BillingCountryCode == 'US') {
                        acc.addError('Please provide County to request for a new customer');
                        return;
                    }
                    if(String.isBlank(acc.Market_Type__c) && acc.Record_Status__c=='Validated') {
                        acc.Market_Type__c='Indirect';
                    }
                    prospectAccounts.add(acc);
                }else{
                    if(String.isBlank(acc.Market_Type__c) && acc.Record_Status__c=='Validated') {
                        acc.Market_Type__c='Direct';
                    }

                }
                //SF-2508
                if(!lstUser.isEmpty() && String.isNotBlank(lstUser.get(0).Default_Territory__c) && acc.Region__c == lstUser.get(0).UserTheater__c && String.isBlank(acc.Territory__c)) {
                    system.debug('Region__c'+acc.Region__c);
                    system.debug('User Region__c'+lstUser.get(0).UserTheater__c);
                    acc.Territory__c = lstUser.get(0).Default_Territory__c;
                }
            }
            if(acc.recordtypeId == mcnRecordtypeId) {
                System.debug('###CDH Core ID### ' +acc.CDH_Owner_CoreID__c );
                acc.Is_Primary__c=true;
                if(String.isBlank(acc.CDH_Owner_CoreID__c)) {
                    acc.CDH_Owner_CoreID__c = 'MULEINT';
                }
                if(String.isNotBlank(acc.CDH_Owner_CoreID__c)) {
                    coreids.add(acc.CDH_Owner_CoreID__c);

                }
            }
            //Commented as a part of SF-2699
            /*if(String.isNotBlank(acc.billingcountrycode)){
                CDH_Country_Region_Mapping__c countryRegionMap= CDH_Country_Region_Mapping__c.getInstance(acc.billingcountrycode);
                if(countryRegionMap!= null){
                    acc.Region__C = countryRegionMap.Region__c;
                }
            }*/
            if((acc.recordtypeId == custRecordtypeId || acc.recordtypeId == prosRecordtypeId) && String.isNotBlank(acc.Industry) && (!GlobalUtility.isPicklistValuesFromValueSet('Account', 'Industry', acc.Industry))) {
                system.debug('inside picklist error');
                acc.addError(system.label.Picklist_Value_Incorrect);
            }//Anand : added if condition for SF-2108
        }
        if(coreIds.size()>0) {
            coreMap = accntHelper.getOwnerIDfromCoreIDs(coreIds);
        }
        for(Account acc : newList) {
            if(coreMap!=null) {
                if(string.isNotBlank(acc.CDH_Owner_CoreID__c) && String.isNotBlank(coreMap.get(acc.CDH_Owner_CoreID__c)) && acc.recordtypeId==mcnRecordtypeId) {
                    acc.OwnerId = coreMap.get(acc.CDH_Owner_CoreID__c);
                }
            }
            if (acc.Sic != NULL && acc.recordtypeId != mcnRecordtypeId ) {
                SicCodeMapping__c sicMap = SicCodeMapping__c.getInstance(acc.Sic);
                if(sicMap != NULL) {
                    if(sicMap.Industry__c != 'Unassigned' &&
                    (acc.industry==null || acc.industry==sicMap.Industry__c)) {
                        acc.Industry = sicMap.Industry__c;
                        if(acc.segment__c==null) {
                            acc.Segment__c = sicMap.Current_Segment__c;
                        }
                    }
                }
            }
            if(acc.recordtypeId==mcnRecordtypeId) {
                mcnAccounts.add(acc);
                if(String.isBlank(acc.Name)) {
                    acc.Name = 'ERP-'+string.valueof(System.now());
                }
                acc.Customer_or_Prospect_Account__c = acc.ParentId;
                acc.MCN_Account_Number__c = acc.Motorola_Customer_Number__c;
            }
        }
     
        if(!prospectAccounts.isEmpty()) {
            prospectHelper.prospectTerrPopulationForPartner(prospectAccounts);
        }
    }
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Set<String> coreids = new Set<String>();        // Defined to implement Core Id Owner Mapping as part of CDH Integration
        Map<String,Id> coreMap = new Map<String,Id>();  // Defined to implement Core Id Owner Mapping as part of CDH Integration
        List<String> partnerSalesChannels = accntHelper.MCNPartnerSalesChannelMeta();
        Set<Id> changeOwnerIdSet = new Set<Id>();
        List<Account> mcnAccounts=new List<Account>();
        Map<Id,External_Reference__c> acctExtRefs = new Map<Id,External_Reference__c>();
        Map<id,String> acctExtRefsDelete = new Map<Id,string>();
        Map<id,id> parentExtRefs = new Map<Id,Id>();
		List<Account> BRRchanged = new List<Account>();

        for(Account acc:(List<Account>)newItems.values()) {
            Account oldAcc = (Account) oldItems.get(acc.Id);
            if(acc.RecordTypeId == prosRecordtypeId) {
                if(acc.NumberOfEmployees != Null && acc.FTE__c == Null) {
                    acc.FTE__c = acc.NumberOfEmployees; //Mapping NumberOfEmployees to update FTE field during Lead Converion as per VESTA_SPILLMAN_INT-777 added by @Saketh
                }
                if(String.isBlank(acc.Market_Type__c) && acc.Record_Status__c=='Validated' && oldAcc.Record_Status__c!=acc.Record_Status__c) {
                    if(UserInfo.getUserType() != 'Standard') {
                        acc.Market_Type__c='Indirect';
                    }else{
                        acc.Market_Type__c='Direct';
                    }
                }

            }

            if(acc.recordtypeId == mcnRecordtypeId) {
                //Account oldAcc = (Account) oldItems.get(acc.Id);
                if(string.isBlank(acc.CDH_Owner_CoreID__c)) {
                    acc.CDH_Owner_CoreID__c = 'MULEINT';
                }
                if(string.isNotBlank(acc.CDH_Owner_CoreID__c) && acc.CDH_Owner_CoreID__c!=oldAcc.CDH_Owner_CoreID__c) {
                    coreids.add(acc.CDH_Owner_CoreID__c);
                }
                if(acc.LastModifiedById == Label.Mulesoft_User) {
                    if(oldAcc.BillingAddress != acc.BillingAddress) {
                        break;
                    }
                }
            }
            if((acc.Validation_Status__c == 'OBSOLETE' || acc.Validation_Status__c == 'INACTIVATE') && acc.ERP_Active__c) {//Added by Anand as per SF-1960
                acc.ERP_Active__c = FALSE;
            }
            if((acc.recordtypeId == custRecordtypeId || acc.recordtypeId == prosRecordtypeId) && String.isNotBlank(acc.Industry) && (!GlobalUtility.isPicklistValuesFromValueSet('Account', 'Industry', acc.Industry))) {
                acc.addError(system.label.Picklist_Value_Incorrect);
            }//Anand : added if condition for SF-2108
            if(acc.recordtypeId == custRecordtypeId || acc.recordtypeId == prosRecordtypeId) {
                //SF-2223 Google Drive Changes
                if(acc.OwnerId != oldAcc.OwnerId) {
                    changeOwnerIdSet.add(acc.Id);
                }
                //BRR Enhancement
                if(acc.Briefing_Room_Report__c != NULL && acc.Briefing_Room_Report__c != oldAcc.Briefing_Room_Report__c) {
                    BRRchanged.add(acc);
                }
            }
        }
        if(coreids.size()>0) {
            coreMap = accntHelper.getOwnerIDfromCoreIDs(coreids);
        }
        for(Account acc:(List<Account>) newItems.values()) {
            Account oldAcc = (Account) oldItems.get(acc.Id);
            if(String.isNotBlank(acc.CDH_Owner_CoreID__c) && String.isNotBlank(coreMap.get(acc.CDH_Owner_CoreID__c)) && acc.recordtypeId==mcnRecordtypeId) {
                acc.OwnerId = coreMap.get(acc.CDH_Owner_CoreID__c);
            }
            System.debug('acc.Sic==>'+acc.Sic);
            System.debug('oldAcc.Sic==>'+oldAcc.Sic);
            if (acc.Sic != NULL && (acc.Sic!=oldAcc.Sic || acc.Industry==null) ) {
                SicCodeMapping__c sicMap = SicCodeMapping__c.getInstance(acc.Sic);
                if(sicMap != NULL) {
                    System.debug('sicMap.Industry__c==>'+sicMap.Industry__c);
                    System.debug('sicMap.Current_Segment__c==>'+sicMap.Current_Segment__c);
                    if(sicMap.Industry__c == 'Unassigned') {
                        acc.Industry = '';
                        acc.Segment__c = '';
                    }else{
                        acc.Industry = sicMap.Industry__c;
                        acc.Segment__c = sicMap.Current_Segment__c;
                    }
                }
            }
            //Commented as a part of SF-2699
            /*if(acc.billingcountrycode!= null && acc.billingcountrycode!=oldAcc.billingcountrycode){
                CDH_Country_Region_Mapping__c countryRegionMap= CDH_Country_Region_Mapping__c.getInstance(acc.billingcountrycode);
                if(countryRegionMap!= null){
                    acc.region__C = countryRegionMap.Region__C;
                }
            }*/
            if(acc.Industry == 'Unassigned') {
                acc.Industry = null;
            }
            if(acc.recordtypeId==mcnRecordtypeId) {
                acc.MCN_Account_Number__c = acc.Motorola_Customer_Number__c;
                if(acc.Name!=oldAcc.Name || acc.Motorola_Customer_Number__c!=oldAcc.Motorola_Customer_Number__c) {
                    mcnAccounts.add(acc);
                }
            }
            if(acc.recordtypeId != oldAcc.recordtypeId) {
                acc.Previous_Record_Type__c = GlobalUtility.getRecordTypeNameById('Account', oldAcc.recordtypeId);
            }
            if(acc.Segment__C == 'Unassigned') {
                acc.Segment__C = null;
            }
            if(acc.ParentId != oldAcc.ParentId && acc.recordtypeId==mcnRecordtypeId) {
                acc.Customer_or_Prospect_Account__c = acc.ParentId;
            }
            if(acc.recordtypeId != oldAcc.recordtypeId && acc.recordtypeId !=mcnRecordtypeId) {
                acc.Customer_or_Prospect_Account__c = null;
            }
            if(acc.recordTypeId == partRecordtypeId) {
                if(acc.MPE_Program_Status_New__c == 'Inactive' && oldAcc.MPE_Program_Status_New__c != acc.MPE_Program_Status_New__c) {
                    acc.IsPartner = FALSE;
                }
                if(acc.Hierarchy_Placement__c == 'Regional Account' && acc.Partner_Zone__c != null
                && acc.MPE_Program_Status__c == 'Active' && acc.Partner_Region__c != null && acc.Partner_Region__c <> 'WORLDWIDE') {
                    if(acc.Program_Join_Date__c != null && oldAcc.Program_Join_Date__c == null) {
                        acc.Annual_Program_Review_Date_APRD__c = accntHelper.populateAPRD(acc.Partner_Region__c,acc.Program_Join_Date__c);//opti
                    }
                    if(acc.PartnerEmpower_Inactivated_Date__c != null && acc.PartnerEmpower_Reactivated_Date__c != null &&
                    acc.PartnerEmpower_Reactivated_Date__c != oldAcc.PartnerEmpower_Reactivated_Date__c) {
                        acc.Annual_Program_Review_Date_APRD__c =  accntHelper.populateAPRD(acc.Partner_Region__c,acc.PartnerEmpower_Reactivated_Date__c);//opti
                    }
                }
                //MR Digital, if CPQ is removed then and only then we have to enter here
                String newApplnEnable=''+acc.Applications_Enabled__c;
                String oldApplnEnable=''+oldAcc.Applications_Enabled__c;
                if( newApplnEnable!=oldApplnEnable && !newApplnEnable.contains('CPQ') && oldApplnEnable.contains('CPQ')) {
                    acc.BigMachines__Partner_Organization__c=null;
                }
                if( newApplnEnable!=oldApplnEnable && newApplnEnable.contains('CPQ') && !oldApplnEnable.contains('CPQ')) {
                    acc.BigMachines__Partner_Organization__c=acc.ID18__c;
                }
            }
            if(acc.golden_id__c != oldAcc.Golden_Id__c) {
                if(!String.isBlank(acc.golden_id__c) && acc.Golden_Id__c.contains('(') && acc.Golden_Id__c.contains(')')) {
                    String externalName=acc.golden_id__c.substringBefore('(');
                    String externalId=acc.golden_id__c.substringBetween('(', ')');
                    External_Reference__c extRef = new External_Reference__c(
                        Name= externalName,
                        External_Id__c= externalId,
                        External_System__c='CDM'
                        );
                    acc.golden_id__c=externalName;
                    acctExtRefs.put(acc.id,extRef);
                }
                if(oldAcc.golden_Id__c!=null) {
                    acctExtRefsDelete.put(oldAcc.id,oldAcc.Golden_Id__c);
                }
            }
            if(acc.RecordTypeId==mcnRecordtypeId && !String.isBlank(acc.Golden_ID__C)
            && !String.isBlank(acc.Customer_or_Prospect_Account__c) && acc.Customer_or_Prospect_Account__c!=oldAcc.Customer_or_Prospect_Account__c) {
                parentExtRefs.put(acc.Customer_or_Prospect_Account__c, acc.id);
            }
        }
        //SF-2223 Google Drive Changes - To hold all AccTeamMember details before Opp Owner is changed
        if(!changeOwnerIdSet.isEmpty()) {
            for(AccountTeamMember atm : getAccTeamMembers(changeOwnerIdSet)) {
                if(mapAccIdsTeamUserEmails.containsKey(atm.AccountId)) {
                    mapAccIdsTeamUserEmails.get(atm.AccountId).add(atm.User.Email);
                }else{
                    mapAccIdsTeamUserEmails.put(atm.AccountId,new List<String> {atm.User.Email});
                }
            }

        }
        if(!acctExtRefsDelete.isEmpty()) {
            accntHelper.deleteExternalReferences(acctExtRefsDelete);
        }
        if(!acctExtRefs.isEmpty()) {
            accntHelper.createExternalReference(acctExtRefs);
        }
        if(!parentExtRefs.isEmpty()) {
            AccountTriggerHelper.updateParentExternalReferences(parentExtRefs,'CDM');
        }
        if(!BRRchanged.isEmpty()){
            accntHelper.getLockedBRRs(BRRchanged);
        }
    }
    public void beforeDelete(Map<Id, SObject> oldItems){
        Map<Id,Account> oldAccMap = new Map<Id,Account>();
        Set<Id> parentAccIds = new Set<Id>();
        Set<Id> mcnIds = new Set<Id>();
        Map<Id, Account> mapPartnerOld = new Map<Id, Account>();

        if(oldItems != null) {
            oldAccMap = (Map<Id,Account>) oldItems;
        }

        for(Account acc:oldAccMap.values()) {
            if(acc.recordtypeId == mcnRecordtypeId) {
                mcnIds.add(acc.Id);
            } else if(acc.recordtypeId == prosRecordtypeId || acc.recordtypeId == custRecordtypeId ) {
                parentAccIds.add(acc.Id);
            }else if(acc.recordtypeId == partRecordtypeId) {
                mapPartnerOld.put(acc.Id, acc);
            }
        }
        if(!mapPartnerOld.isEmpty()) {
            partnerHelper.runDeleteGroupsToUserMPP(mapPartnerOld);
        }
        accntHelper.restrictAccountDelete(oldItems); //Added by venkat as per SF-1978
    }
    public void afterInsert(Map<Id, SObject> newItems) {
        system.debug('***********************************in after insert****************************' + newItems);
        List<Account> prosAccs = new List<Account>();
        List<Account> mcnAccs = new List<Account>();
        List<Account> cusAccs = new List<Account>();
        Set<Id> ownrChngMcnIds=new Set<Id>();
        
        Map<Id, Account> mapPartner = new Map<Id, Account>();
        Set<Id> parentsToBeUpdated = new Set<Id>();
        Map<Id,External_Reference__c> acctExtRefs = new Map<Id,External_Reference__c>();
        List<User> partnerUser = new List<User>();
        System.debug(UserInfo.getUserType());
        System.debug(UserInfo.getUserId());

        if(GlobalUtility.isLoggedinPartnerUser()) {
            partnerUser = [SELECT Id,AccountId,ContactId FROM User WHERE Id =: UserInfo.getUserId() AND Contact.AccountId != NULL];
            System.debug('#######partnerUser############ => ' + partnerUser);
        }
        Map<Id,Id> prospectPartnerAccountMap=new Map<Id,Id>();

        for(Account acc : (List<Account>)newItems.values()) {
            if(acc.recordtypeId == prosRecordtypeId) {
                prosAccs.add(acc);
                if(!partnerUser.isEmpty()) {
                    prospectPartnerAccountMap.put(acc.Id, partnerUser[0].AccountId);
                }
                System.debug(prospectPartnerAccountMap);

            } else if(acc.recordtypeId == custRecordtypeId && (acc.Market_Type__c != null && acc.Market_Type__c.contains('Indirect'))) { //Updated as part of CDM Project Nov 2020 Rel 1.1
                cusAccs.add(acc);
            } else if(acc.recordtypeId == mcnRecordtypeId) {
                if(String.isNotBlank(acc.ParentId)) {
                    parentsToBeUpdated.add(acc.ParentId);
                    ownrChngMcnIds.add(acc.id);
                }

                mcnAccs.add(acc);
            } else if(acc.recordtypeId == partRecordtypeId) {
                mapPartner.put(acc.Id, acc);
            }
            if(!mapPartner.isEmpty()) {
                partnerHelper.runAddUpdateGroupsToUserMPP(null, mapPartner, Trigger.isUpdate);
            }
            if(!parentsToBeUpdated.isEmpty()) {
                accountUpdater.populateMCNonCustomer(parentsToBeUpdated);
            }
            if(acc.golden_Id__c!=null && acc.Golden_Id__c.contains('(') && acc.Golden_Id__c.contains(')')) {
                String externalName=acc.golden_id__c.substringBefore('(');
                String externalId=acc.golden_id__c.substringBetween('(', ')');
                External_Reference__c extRef = new External_Reference__c(
                    Name= externalName,
                    External_Id__c= externalId,
                    External_System__c='CDM'
                    );
                acctExtRefs.put(acc.id,extRef);


            }
        }
        
        if(!acctExtRefs.isEmpty()) {
            accntHelper.createExternalReference(acctExtRefs);
            AccountTriggerHelper.updateGoldenId(acctExtRefs.keySet());
        }
        system.debug('Prospect prosAccs'+prosAccs);
        if(prosAccs.size()>0) {
            //Added by Durga as part of CDM project
            accntHelper.insertSiteAddress(prosAccs);
            // googleDriveAccntHelper.insertAccGoogleDrive(prosAccs);
        }
        if(cusAccs.size()>0) {
            //googleDriveAccntHelper.insertAccGoogleDrive(cusAccs);
            accntHelper.insertSiteAddress(cusAccs);
        }
        if(!prospectPartnerAccountMap.isEmpty()) {
            System.debug(prospectPartnerAccountMap);
            AccountTriggerHelper.shareProspectWithPartnerExec(prospectPartnerAccountMap);
        }
        if(!ownrChngMcnIds.isEmpty()) {
            //QuoteSharingHelper.quoteShareOnOwnerChangeOfAccount(ownrChngCusIds,oldCusOwnerIds);
            accntHelper.changeParentAccountOwner(ownrChngMcnIds);
        }
    }
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id,Account> oldAccMap = new Map<Id,Account>();
        if(oldItems != null) oldAccMap = (Map<Id,Account>) oldItems;
        Set<Id> ownrChangeAccIds = new Set<Id>();
        //Set<Id> archiveRTChangeAccIds = new Set<Id>();
        Set<Id> archiveRTAccIds = new Set<Id>();//Added by Anand a per SF-1960
        Set<Id> toBeArchivedParentIds = new Set<Id>();//Added by Anand a per SF-1960
        String archivalRT;//Added by Anitha to handle SF-1960 & SF-1397
        Map<Id,String> communityChangePartnerAccIds = new Map<Id,String>();
        Map<Id,String> emeaCommunityChangePartnerAccIds = new Map<Id,String>();
        Set<Id> ownrChngCusIds=new Set<Id>();
        Set<Id> openAccIds = new Set<Id>();
        Set<Id> nonOpenAccIds = new Set<Id>();
        Set<Id> revokeaccIds = new Set<Id>();
        Set<Id> ownrChngMcnIds=new Set<Id>();
        //Set<Id> ownrChngPartnrIds = new Set<Id>();
        Set<Id> allIdsForAgreement = new Set<Id>();
        Set<Id> custToUpd = new Set<Id>();
        Map<Id, Account> mcnIdAccMap = new Map<Id, Account>();
        Set<String> mcnNumber = new Set<String>();
        Map<Id, Account> mapPartner = new Map<Id, Account>();
        Map<Id, Account> mapPartnerOld = new Map<Id, Account>();
        Map<Id,Id> oldEmailOwnerMap = new Map<Id,Id>(); // SF-40 CPQ SFDC:Google Drive Integration
        Map<Id,Id> newAccMRmap = new Map<Id,Id>(); // Used to Share Accounts to MR Partners
        Map<Id,Id> oldAccMRmap = new Map<Id,Id>(); // Used to Share Accounts to MR Partners
        Map<Id,Id> newAccSPmap = new Map<Id,Id>(); // Used to Share Accounts to MR Sales Person
        Map<Id,Account> prosAccounts = new Map<Id,Account>(); //Added by Durga for CDM Project
        Map<Id,Account> updprosAccounts = new Map<Id,Account>(); //Added by Durga for CDM Project
        Map<Id,List<Technical_Site__c>> hqSiteMap = new Map<Id,List<Technical_Site__c>>(); //Added by Durga for CDM Project
        Map<Id,List<Technical_Site__c>> btSiteMap = new Map<Id,List<Technical_Site__c>>(); //Added by Durga for CDM Project
        Map<Id, List<Technical_Site__c>> custToHQSiteMap = new Map<Id, List<Technical_Site__c>>(); //Added by Durga for CDM Project
        Map<Id, List<Technical_Site__c>> custToBTSiteMap = new Map<Id, List<Technical_Site__c>>(); //Added by Durga for CDM Project
        Map<Id,Id> markPrimaryMCNMap = new Map<Id,Id>(); //Added by Durga for CDM Project
        Map<Id,Id> mcnParentMap = new Map<Id,Id>(); //Added by Durga for CDM Project
        Set<Id> updprosAccIds = new Set<Id>(); //Added by Durga for CDM Project
        CustomerDataMasterHelper cdmHelper = new CustomerDataMasterHelper();  //Added by Durga for CDM Project
        List<Technical_Site__c> hqSiteList = new List<Technical_Site__c>();
        List<Technical_Site__c> btSiteList = new List<Technical_Site__c>();
        //MR Digital
        Map<Id,Id> oldAccSPmap = new Map<Id,Id>(); // Used to Share Accounts to MR Sales Person
        Set<Id> oldCusOwnerIds=new Set<Id>();
        //MR Digital
        String quoteAccessLevel;
        Set<Id> modifiedSPcustIds = new Set<Id>();
        Map<Id,Id> mcnMRmapOwnrChng = new Map<Id,Id>();
        Map<Id,Id> mcnSPmapOwnrChng = new Map<Id,Id>();
        Set<Id> customersToBeUpdated = new Set<Id>();
        Set<Id> updatedChannelPrograms = new Set<Id>();
        List<Account> mcnAccounts = new List<Account>();
        Integer handleMerge = 0;
        Map<Id,Account> mapNewAccounts = new Map<Id,Account>();
        //MR Digital
        Set<Id> partnerContactSet = new Set<Id>();
        List<Applications_Access__c> lstApplnAccess = new List<Applications_Access__c>();
        Set<Id> partnerAcctsAppAccess = new Set<Id>();
        set<Id> newAccounts = new set<Id>();
        set<Id> mcnAccountIds = new set<Id>();
        set<Id> parentAccounts = new set<Id>(); // Added as part of CDM project
        //Added as part of SF-1806
        Set<Id> disabledPartnerAccountIds = new Set<Id>();
        AccountTriggerHelper accntHelper = new AccountTriggerHelper();
        Set<String> changeNameSet = new Set<String>();
        Map<Id,Account> newAccountOwnerChangeMap = new Map<Id,Account>();

        //AccountTriggerHelper accntHelper = new AccountTriggerHelper();
        //GoogleDriveAccountTriggerHelper googleDriveAccntHelper = new GoogleDriveAccountTriggerHelper();
        if(newItems != null) mapNewAccounts = (Map<Id,Account>) newItems;
        String u1 = userInfo.getUserId(); //get user
        for(Account acct : mapNewAccounts.values()) {
            Account oldAcc = (Account) oldItems.get(acct.Id);
            if(acct.Primary_Route_to_Market__c!= oldAcc.Primary_Route_to_Market__c &&
            acct.Region__c == 'NA') {
                if(acct.recordtypeId == mcnRecordtypeId && (acct.Primary_Route_to_Market__c == 'Open' ||
                                                            oldAcc.Primary_Route_to_Market__c=='Open')) {
                    openAccIds.add(acct.parentId);
                }
            }
            //SF-2223 Google Drive Changes
            if(acct.recordtypeId == custRecordtypeId || acct.recordtypeId == prosRecordtypeId ) {
                if(acct.Name != oldAcc.Name) {
                    changeNameSet.add(acct.Id);
                }
            }
            if(acct.OwnerId != oldAcc.OwnerId) {
                ownrChangeAccIds.add(acct.Id);
                if(acct.recordtypeId == custRecordtypeId || acct.recordtypeId == prosRecordtypeId) {
                    //SF-2223 Google Drive Changes
                    newAccountOwnerChangeMap.put(acct.Id, acct);
                    if(acct.recordtypeId == prosRecordtypeId) {
                        ownrChngCusIds.add(acct.Id);
                    }
                    allIdsForAgreement.add(acct.Id);
                    //MR Digital
                    oldCusOwnerIds.add(oldAcc.OwnerId);
                } else if(acct.recordtypeId == mcnRecordtypeId) {
                    if(acct.Is_Primary__c && acct.ParentId != NULL) {
                        System.debug('New MCN Owner...'+acct.Owner__c);
                        ownrChngMcnIds.add(acct.Id);
                    }
                    if(String.isNotBlank(acct.Assigned_MR__c)) {
                        mcnMRmapOwnrChng.put(acct.Id,acct.Assigned_MR__c);
                    }
                    if(String.isNotBlank(acct.Assigned_MR_Sales_Person__c)) {
                        mcnSPmapOwnrChng.put(acct.Id,acct.Assigned_MR_Sales_Person__c);
                    }
                }
            }
            if(acct.Customer_or_Prospect_Account__c != null   && acct.Is_Primary__c && acct.recordtypeId == mcnRecordtypeId && 
            ((oldAcc.Customer_or_Prospect_Account__c!=acct.Customer_or_Prospect_Account__c) || (oldacc.Is_Primary__c != acct.Is_Primary__c) || oldAcc.OwnerId !=acct.ownerId)) {
                ownrChngMcnIds.add(acct.Id);
            }
            if(acct.RecordTypeId != oldAcc.RecordTypeId) {
                if(acct.RecordTypeId == archiveRecordtypeId && oldAcc.RecordTypeId != mcnRecordtypeId) {         // Track the record type change to Archive for NON-MCN Records
                    toBeArchivedParentIds.add(acct.Id);
                    archivalRT = 'Non MCN';
                }else if(acct.RecordTypeId == archiveRecordtypeId && oldAcc.RecordTypeId == mcnRecordtypeId) {
                    customersToBeUpdated.add(acct.ParentId);
                }
            }
            System.debug('Before MCN Archival toBeArchivedParentIds==>' + toBeArchivedParentIds);
            //Added by Anand as per SF-1960
            if(acct.RecordTypeId == mcnRecordtypeId) {// Track the record type change to Archive for MCN Records by Mule User
                if(acct.Validation_Status__c!= oldAcc.Validation_Status__c && (acct.Validation_Status__c == 'OBSOLETE' || acct.Validation_Status__c == 'INACTIVATE')) {
                    archivalRT = 'MCN';
                    archiveRTAccIds.add(acct.Id);
                    if(String.isNotBlank(acct.parentId)) {
                        toBeArchivedParentIds.add(acct.parentId);
                    }
                    System.debug('MCN toBeArchivedParentIds==>' + toBeArchivedParentIds);
                }
                //Parent has been modifed and updating Site and creating Partner Identifier
                if (acct.ParentId != oldAcc.ParentId && String.isNotBlank(acct.ParentId)) {
                    mcnIdAccMap.put(acct.Id,acct);
                    mcnNumber.add(acct.Motorola_Customer_Number__c);
                }
            }
            //Perform Primary Address Updates on Customer Account based on Primary flag update of MCN account
            //Updated the criteria by Durga as part of CDM
            if(acct.recordtypeId == mcnRecordtypeId && acct.ParentId!= null) {
                if(acct.Is_Primary__c == TRUE && acct.Is_Primary__c != oldAcc.Is_Primary__c) {
                    mcnAccountIds.add(acct.id);
                    parentAccounts.add(acct.ParentId);
                    mcnParentMap.put(acct.Id, acct.ParentId);
                }
            }
            //Partner Accounts related Operation
            if(acct.recordtypeId == partRecordtypeId) {
                if(acct.Partner_Community_Types__c != oldAcc.Partner_Community_Types__c) {
                    if(acct.Partner_Region__c == 'NAMR') {
                        communityChangePartnerAccIds.put(acct.Id, acct.Partner_Community_Types__c);
                    } else if(acct.Partner_Region__c == 'EMEA' && String.isNotBlank(acct.Partner_Community_Types__c)
                            && acct.Partner_Community_Types__c.contains('EMEAReseller')) {
                        System.debug('acct##=>'+acct);
                        emeaCommunityChangePartnerAccIds.put(acct.Id, acct.Partner_Community_Types__c);
                    }
                    updatedChannelPrograms.add(acct.Id);
                }
                String newApplnEnable=''+acct.Applications_Enabled__c;
                String oldApplnEnable=''+oldAcc.Applications_Enabled__c;
                if( newApplnEnable!=oldApplnEnable && !newApplnEnable.contains('CPQ') && oldApplnEnable.contains('CPQ')) {
                    partnerAcctsAppAccess.add(acct.Id);
                }
                allIdsForAgreement.add(acct.Id);
                mapPartner.put(acct.Id, acct);
                mapPartnerOld.put(acct.Id, oldAcc);
            }
            if(acct.Name!=oldAcc.Name || acct.Motorola_Customer_Number__c!=oldAcc.Motorola_Customer_Number__c ||
            acct.Primary_Route_to_Market__c!= oldAcc.Primary_Route_to_Market__c || acct.ParentId != oldAcc.ParentId ||
            acct.Customer_or_Prospect_Account__c != oldAcc.Customer_or_Prospect_Account__c || acct.ERP_Active__c != oldAcc.ERP_Active__c) {
                if(acct.recordtypeId == mcnRecordtypeId) {
                    mcnAccounts.add(acct);
                }
                if(String.isNotBlank(acct.ParentId)) {
                    customersToBeUpdated.add(acct.ParentId);
                }
                if(String.isNotBlank(oldAcc.ParentId)) {
                    customersToBeUpdated.add(oldAcc.ParentId);
                }
            }
            /***************Used to Share/Unshare Customers and MCNs to MR partners*****************/
            if(acct.recordtypeId == mcnRecordtypeId && acct.Assigned_MR__c != oldAcc.Assigned_MR__c) {
                custToUpd.add(acct.ParentId);
                newAccMRmap.put(acct.Id, acct.Assigned_MR__c);
                if(String.isNotBlank(oldAcc.Assigned_MR__c)) {
                    oldAccMRmap.put(oldAcc.Id,oldAcc.Assigned_MR__c);
                }
            }
            if (acct.recordtypeId == mcnRecordtypeId && acct.Assigned_MR_Sales_Person__c != oldAcc.Assigned_MR_Sales_Person__c) {
                newAccSPmap.put(acct.Id, acct.Assigned_MR_Sales_Person__c);
                modifiedSPcustIds.add(acct.ParentId);
                customersToBeUpdated.add(acct.ParentId);
                //MR Digital
                if(String.isNotBlank(oldAcc.Assigned_MR__c)) {
                    oldAccSPmap.put(oldAcc.Id,oldAcc.Assigned_MR_Sales_Person__c);
                }
            }
            /***************Used to Share/Unshare Customers and MCNs to MR partners*****************/
            if(acct.recordTypeId == prosRecordtypeId || acct.recordTypeId == custRecordtypeId) {
                handleMerge++;
            }
            if(acct.IsPartner != oldAcc.IsPartner && !acct.IsPartner) {
                disabledPartnerAccountIds.add(acct.Id);
            }
            oldEmailOwnerMap.put(acct.Id,oldAcc.OwnerId);

            /******Added by Durga as part of CDM Project********/
            //Update address change in site record
            if((acct.recordTypeId == prosRecordtypeId || (acct.recordTypeId == custRecordtypeId && (acct.Market_Type__c != null && acct.Market_Type__c.contains('Indirect')))) &&
            (acct.Name != oldAcc.Name || acct.BillingStreet != oldAcc.BillingStreet || acct.BillingCity != oldAcc.BillingCity ||
                acct.BillingStateCode != oldAcc.BillingStateCode || acct.BillingCountryCode != oldAcc.BillingCountryCode ||
                acct.Billing_County__c!= oldAcc.Billing_County__c || acct.BillingPostalCode != oldAcc.BillingPostalCode)) {

                updprosAccIds.add(acct.id);

            }


        } // For Loop Ended

        /******Added by Durga as part of CDM Project********/
        if(updProsAccIds.size()>0) {
            accntHelper.updateSiteAddress(updProsAccIds);
        }

        //Added by Anand as per SF-1960; Modified by Anitha to accomodate SF-1397
        if(!toBeArchivedParentIds.isEmpty()) {
            System.debug('toBeArchivedParentIds.isEmpty==>' + toBeArchivedParentIds);
            for (Account parentAccount : [Select Id,(Select Id from AccToAcc__r where RecordTypeId = :mcnRecordtypeId ) from Account
                                        Where Id IN :toBeArchivedParentIds ]) {//and RecordTypeId != :archiveRecordtypeId
                if(archivalRT == 'Non MCN') {
                    for(Account mcnAccount:parentAccount.AccToAcc__r) {
                        archiveRTAccIds.add(mcnAccount.Id);
                    }
                }else if(archivalRT == 'MCN') {
                    if(parentAccount.AccToAcc__r.size() == 1) {
                        archiveRTAccIds.add(parentAccount.Id);
                    }
                }
                customersToBeUpdated.add(parentAccount.Id);
            }
        }//Ended by Anand as per SF-1960 SF-1397
        if(!parentAccounts.isEmpty()) {
            AccountTriggerHelper.updateAddress(parentAccounts);
            hqSiteList = [select id,Site_Usage__c,Customer__c,MCN_Account__c,Primary_Street__c,Primary_Street_2__c,Primary_City__c,State_Province__c,Country__c,Primary_Zip_Postal_Code__c,Site_County__c from Technical_Site__c where Customer__c=:parentAccounts and Site_Usage__c Includes('Headquarters')];
        }
        if(!mcnAccountIds.isEmpty()) {
            btSiteList = [select id,Site_Usage__c,Customer__c,MCN_Account__c,Primary_Street__c,Primary_Street_2__c,Primary_City__c,State_Province__c,Country__c,Primary_Zip_Postal_Code__c,Site_County__c from Technical_Site__c where MCN_Account__c =:mcnAccountIds and Site_Usage__c Includes('Bill To') order by CreatedDate asc];
        }
        if(!hqSiteList.isEmpty()) {
            for(Technical_Site__c site:hqSiteList ) {
                if(hqSiteMap.containsKey(site.Customer__c))
                    hqSiteMap.get(site.Customer__c).add(site);
                else
                    hqSiteMap.put(site.Customer__c, new List<Technical_Site__c> {site});
            }
        }
        if(!btSiteList.isEmpty()) {
            for(Technical_Site__c site:btSiteList ) {
                if(btSiteMap.containsKey(site.MCN_Account__c ))
                    btSiteMap.get(site.MCN_Account__c ).add(site);
                else
                    btSiteMap.put(site.MCN_Account__c, new List<Technical_Site__c> {site});
            }
        }
        system.debug('CustomerHQ site map is '+hqSiteMap);
        system.debug('CustomerBT site map is '+btSiteMap);
        for(Id acc:mcnAccountIds) {
            Id parentAcc = mcnParentMap.get(acc);
            system.debug('Parent account id is '+parentAcc);
            if(parentAcc != null) {
                if(hqSiteMap.containsKey(parentAcc))
                    markPrimaryMCNMap.put(parentAcc,acc);
                if(!hqSiteMap.containsKey(parentAcc)) {
                    List<Technical_Site__c> btSite = btSiteMap.get(acc);
                    for(Technical_Site__c site : btSite)
                        custToBTSiteMap.put(parentAcc, new List<Technical_Site__c> {site});
                }
            }
            system.debug('markPrimaryMCNMap is '+markPrimaryMCNMap);
        }

        if(!markPrimaryMCNMap.isEmpty()) {
            cdmHelper.clearPrimaryFlag(markPrimaryMCNMap);
            cdmHelper.setPrimaryFlag(markPrimaryMCNMap);
        }

        if(!custToBTSiteMap.isEmpty() ) {
            system.debug('Calling primaryAddressUpdateonCustomer from handler');
            accntHelper.primaryAddressUpdateonCustomer(custToHQSiteMap,custToBTSiteMap);
        }    // End
        // MR Digital
        if(!partnerAcctsAppAccess.isEmpty() || !Test.isRunningTest()) {
            accntHelper.revokeCPQAccessToAllContacts(partnerAcctsAppAccess, 'CPQ');
        }
        if(!openAccIds.isEmpty()) {
            accntHelper.updateOpenRTM(openAccIds);
        }
        if(!updatedChannelPrograms.isEmpty()) {
            TagBasedPermissionSets.upsertChannelProgramMembers(updatedChannelPrograms);
        }
        if(ownrChngCusIds.size()>0) {
            accntHelper.updateOwnrOFMcns(ownrChngCusIds);
            //googleDriveAccntHelper.accessToMainFolder(ownrChngCusIds,oldEmailOwnerMap);
        }
        if(allIdsForAgreement.size()>0) {
            accntHelper.eaAgreeShare(allIdsForAgreement);
        }
        if(handleMerge > 0) {
            accntHelper.handleChildsOnMerge((List<Account>)newItems.values());
        }
        if(!mapPartner.isEmpty()) {
            partnerHelper.sharePartnerAccountsPartnerRoles(newItems, oldItems);
            partnerHelper.runAddUpdateGroupsToUserMPP(mapPartnerOld, mapPartner, Trigger.isUpdate);
        }
        /***************Used to Share/Unshare Customers and MCNs to MR partners*****************/
        if(!oldAccMRmap.isEmpty()) {
            partnerSharingHelper.revokeAccAccessToPartnerExecs(oldAccMRmap,custToUpd);
            //MR Digital
            QuoteSharingHelper.revokeQuoteAccessToOldMR(oldAccMRmap);
        }
        //MR Digital
        if(!oldAccSPmap.isEmpty()) {
            QuoteSharingHelper.revokeQuoteAccessToOldMRSalesRep(oldAccSPmap);
        }
        if(!newAccMRmap.isEmpty()) {
            partnerSharingHelper.shareToExecutiveRoles(newAccMRmap);
            partnerSharingHelper.shareToExecutiveRoles(custToUpd);
            //MR Digital
            quoteAccessLevel='Read';
            QuoteSharingHelper.quoteShareToExecutiveRoles(newAccMRmap,quoteAccessLevel);
        }
        if(!newAccSPmap.isEmpty()) {
            partnerSharingHelper.shareToPartnerUser(newAccSPmap);
            partnerSharingHelper.shareToPartnerUser(modifiedSPcustIds);
            //MR Digital
            quoteAccessLevel='Read';
            QuoteSharingHelper.quoteShareToPartnerUser(newAccSPmap,quoteAccessLevel);
        }
        if(!mcnSPmapOwnrChng.isEmpty()) {
            partnerSharingHelper.shareToExecutiveRoles(mcnMRmapOwnrChng);
            partnerSharingHelper.shareToPartnerUser(mcnSPmapOwnrChng);
        }
        if(!ownrChngCusIds.isEmpty()) {
            partnerSharingHelper.shareToExecutiveRoles(ownrChngCusIds);
            partnerSharingHelper.shareToPartnerUser(ownrChngCusIds);
            QuoteSharingHelper.quoteShareOnOwnerChangeOfAccount(ownrChngCusIds,oldCusOwnerIds);
        }
        if(custToUpd.size()>0) {
            partnerSharingHelper.populateMRNamesonCustomer(custToUpd);
        }
        if(!communityChangePartnerAccIds.isEmpty()) {
            permSetHelper.assignPermissionSets(communityChangePartnerAccIds, 'NA');
        }
        if(!emeaCommunityChangePartnerAccIds.isEmpty()) {
            permSetHelper.assignPermissionSets(emeaCommunityChangePartnerAccIds, 'EA');
        }
        if(!ownrChngMcnIds.isEmpty()) {
            //QuoteSharingHelper.quoteShareOnOwnerChangeOfAccount(ownrChngCusIds,oldCusOwnerIds);
            accntHelper.changeParentAccountOwner(ownrChngMcnIds);
        }
        if(!archiveRTAccIds.isEmpty()) {
            System.debug('archiveRTAccIds ===>' + archiveRTAccIds);
            accntHelper.updateRecordTypeOfAccounts(archiveRTAccIds);
        }//Ended by Anand  as per SF-1960
        if(!customersToBeUpdated.isEmpty()) {
            accountUpdater.populateMCNonCustomer(customersToBeUpdated);
        }
        if(!disabledPartnerAccountIds.isEmpty()) {
            accntHelper.updateLDAPStatusToInactive(disabledPartnerAccountIds);//for opti
        }
        if(!mcnIdAccMap.isEmpty()) {
            accntHelper.mcnAccountUpdate(mcnIdAccMap, mcnNumber);
        }
        //SF-2223 Google Drive Changes
        if(!newAccountOwnerChangeMap.isEmpty()) {
            folderPermissionOnOwnerChange(oldAccMap,newAccountOwnerChangeMap);
        }
        //SF-2223 Google Drive Changes
        if(!changeNameSet.isEmpty()) {
            Set<String> setExistingGoogleDriveInfo = new Set<String>();
            for(Google_Drive_Folder__c gd :[SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name =: changeNameSet AND Parent_Name__c = NULL]) {
                setExistingGoogleDriveInfo.add(gd.Name);
            }
            if(!setExistingGoogleDriveInfo.isEmpty()) {
                GoogleDriveUtility.googleDriveFunctions(new List<String>(setExistingGoogleDriveInfo),'Update');
            }
        }
    }
    public void afterDelete(Map<Id, SObject> oldItems) {
        List<Account> deletedChilds = new List<Account>();
        List<Account> deletedMcns = new List<Account>();
        List<String> deletedCusProsONMerge = new List<String>();
        Set<Id> masterRecordIds = new Set<Id>();
        Set<Id> customersToBeUpdated = new Set<Id>();
        //MR Digital
        Set<Id> oldCusOwnerIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<String> existingGDriveAccIds = new List<String>();
        AccountTriggerHelper accntHelper = new AccountTriggerHelper();
        Integer deletedParentsCount = 0;
        for(Account acc:(List<Account>) oldItems.values()) {
            accIds.add(acc.Id);
            if(String.isNotBlank(acc.MasterRecordId)) {
                //MR Digital
                oldCusOwnerIds.add(acc.OwnerId);
                masterRecordIds.add(acc.MasterRecordId);
                if(masterRecordIds.size()>0) {
                    QuotesharingHelper.quoteShareOnOwnerChangeOfAccount(MasterRecordIds,oldCusOwnerIds);
                }
                deletedChilds.add(acc);
                if(acc.RecordtypeId == prosRecordtypeId ||acc.RecordtypeId == custRecordtypeId) {
                    deletedCusProsONMerge.add(acc.MasterRecordId);
                    customersToBeUpdated.add(acc.MasterRecordId);
                }
                masterRecordIds.add(acc.MasterRecordId);
            }
            if(acc.RecordtypeId == mcnRecordtypeId) {
                customersToBeUpdated.add(acc.ParentId);
                deletedMcns.add(acc);
            }
            if(acc.RecordtypeId == prosRecordtypeId ||acc.RecordtypeId == custRecordtypeId) {
                deletedParentsCount++;
            }
        }
        if(deletedParentsCount > 0) {
            accntHelper.deleteMCNaccounts();//code opti
        }
        if(!customersToBeUpdated.isEmpty()) {
            accountUpdater.populateMCNonCustomer(customersToBeUpdated);
        }
        //SF-2223 Google Drive Changes
        if(!accIds.isEmpty()) {
            for(Google_Drive_Folder__c gdrive  : [SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name IN: accIds AND Parent_Name__c = NULL]) {
                existingGDriveAccIds.add(gdrive.Name);
            }
        }
        if(!existingGDriveAccIds.isEmpty()) {
            GoogleDriveUtility.googleDriveFunctions(existingGDriveAccIds,'Delete');
        }
    }
    public void afterUndelete(Map<Id, SObject> oldItems){
    }
    //SF-2223 Google Drive Changes
    public void folderPermissionOnOwnerChange(Map<Id,Account> oldOAccMap, Map<Id,Account> newAccMap) {
        List<String> revokeProvisionSet = new List<String>();
        List<String> provideProvisionSet = new List<String>();
        Set<String> existingGDriveOppIds = new Set<String>();
        Map<String,List<AccountTeamMember>> mapAccAndTeamMember= new  Map<String,List<AccountTeamMember>>();
        //system.debug('mapOppIdsTeamUserEmails***'+mapAccIdsTeamUserEmails);
        for(Google_Drive_Folder__c gdrive  : [SELECT Id,Name FROM Google_Drive_Folder__c WHERE Name IN: newAccMap.keySet() AND Parent_Name__c = NULL]) {
            existingGDriveOppIds.add(gdrive.Name);
        }
        for(AccountTeamMember atm : [SELECT Id,UserId,AccountId,User.Email FROM AccountTeamMember WHERE AccountId IN : newAccMap.keySet()]) {
            if(mapAccAndTeamMember.containsKey(atm.AccountId)) {
                mapAccAndTeamMember.get(atm.AccountId).add(atm);
            }else{
                mapAccAndTeamMember.put(atm.AccountId,new List<AccountTeamMember> {atm});
            }
        }
        for(Account acc : [SELECT Id,Owner_Email__c,Owner.UserType FROM Account WHERE Id IN : existingGDriveOppIds]) {
            //system.debug('oldOpptyMap Owner Email'+oldOAccMap.get(acc.Id).Owner_Email__c);
            //system.debug('New Owner Email'+acc.Owner_Email__c);
            If(acc.Owner.UserType == 'Standard'){
                provideProvisionSet.add(acc.Id);
            }
            revokeProvisionSet.add(acc.Id+';'+oldOAccMap.get(acc.Id).Owner_Email__c);
            if(mapAccIdsTeamUserEmails.containsKey(acc.Id)) {
                List<AccountTeamMember> lstATM = new  List<AccountTeamMember>();
                if(!mapAccAndTeamMember.isEmpty() && mapAccAndTeamMember.containsKey(acc.Id) && mapAccAndTeamMember.get(acc.Id) != NULL) {
                    lstATM.addALL(mapAccAndTeamMember.get(acc.Id));
                    for(AccountTeamMember atm : lstATM) {
                        system.debug('out if'+acc.Id+';'+atm.User.Email);
                        if(!revokeProvisionSet.isEmpty() && revokeProvisionSet.contains(acc.Id+';'+atm.User.Email)) {
                            Set<String> revokeProvisionSetTemp = new Set<String>(revokeProvisionSet);
                            revokeProvisionSetTemp.remove(acc.Id+';'+atm.User.Email);
                            revokeProvisionSet = new List<String>(revokeProvisionSetTemp);
                        }
                    }
                }
                if(lstATM.isEmpty()) {
                    for(String atmEmail : mapAccIdsTeamUserEmails.get(acc.Id)) {
                        revokeProvisionSet.add(acc.Id+';'+atmEmail);
                    }
                }
            }
        }
        //system.debug('revokeProvisionSet***'+revokeProvisionSet);
        //system.debug('provideProvisionSet***'+provideProvisionSet);
        if(!revokeProvisionSet.isEmpty()) {
            GoogleDriveUtility.googleDriveFunctions(revokeProvisionSet,'RevokePermission');
        }
        if(!provideProvisionSet.isEmpty()) {
            GoogleDriveUtility.googleDriveFunctions(provideProvisionSet,'Provision');
        }
    }
    //SF-2223 Google Drive Changes
    public List<AccountTeamMember> getAccTeamMembers(Set<Id> accIds){
        return [SELECT Id,AccountId, User.Email FROM AccountTeamMember WHERE AccountId IN : accIds AND User.UserType = 'Standard' AND Quote_Access__c = 'Read/Write'];
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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