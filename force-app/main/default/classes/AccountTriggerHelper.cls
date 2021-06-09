/*******************************************************************************
 * Description : Helper class for AccountTriggerHandler
 * Author : Anand Sengunthar
 * Date : 9th Oct 2019
 ******************************************************************************/
public class AccountTriggerHelper {

	Id prosRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
	Id partRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
	Id custRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('SoldToAccount').getRecordTypeId();
	Id mcnRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Motorola_Customer_Number').getRecordTypeId();
	Id archiveRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Archived').getRecordTypeId();
	Id competitorRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Competitor').getRecordTypeId();

	public void deleteMCNaccounts(){
		List<Account> mcns = [SELECT Id FROM Account WHERE parentId = null AND Customer_or_Prospect_Account__c= null AND Motorola_Customer_Number__c='' AND recordTypeId =: mcnRecordtypeId];
		if(mcns.size()>0) {
			delete mcns;
		}
	}

	public void updateOpenRTM(Set<Id> parentCustAccs) {
		List<Account> toBeUdpatedCustomers = new List<Account>();
		for(Account eachParentAccount : [SELECT Id,Name,recordtype.name,Primary_Route_To_Market__c,Region__c,
										(SELECT Id,Primary_Route_To_Market__c FROM ChildAccounts WHERE Primary_Route_To_Market__c = 'Open')
										FROM Account WHERE recordtypeId=:custRecordtypeId AND Region__c = 'NA'
																										AND Id IN : parentCustAccs])
		{
			if(eachParentAccount.ChildAccounts.size()>0) {
				eachParentAccount.Primary_Route_To_Market__c = 'Open';
			} else {
				eachParentAccount.Primary_Route_To_Market__c = '';
			}
			toBeUdpatedCustomers.add(eachParentAccount);
		}
		if(!toBeUdpatedCustomers.isEmpty()) {
			try {
				update toBeUdpatedCustomers;
			} catch(Exception exp) {
				System.debug('Exception found: '+exp.getMessage());
			}
		}
	}
	
	public void createExternalReference (Map<id,External_Reference__c> acctExtRef){
		Set<String> extRefIds = new Set<string>();
		List<External_Reference__c> extRefsToInsert=new List<External_Reference__c>();
		Map<id,List<String> > existingAcctExtRefMap = new Map<id,List<String> >();
		Map<String,External_Reference__c> existingRefMap=new Map<String,External_Reference__c>();
		List<Account_External_Reference__c> acctExtRefstoInsert = new List<Account_External_Reference__c>();

		for(External_Reference__c ref : acctExtRef.values()) {
			extRefIds.add(ref.External_Id__c);
		}

		Map<Id,External_Reference__c> existingExtRefs = new Map<id,External_Reference__c>([select Id,name,External_Id__c,External_System__c from External_Reference__c where External_Id__c in: extRefIds]);

		for(External_Reference__c ref:existingExtRefs.values()) {
			existingRefMap.put(ref.External_ID__c,ref);
		}
		for(Account_External_Reference__c acctRef :[select id,account__c,External_Reference__c,External_Reference__r.External_Id__c from Account_External_Reference__c where account__c in: acctExtRef.keySet() and External_Reference__c in:existingExtRefs.keySet()]) {
			if(acctExtRef.containsKey(acctRef.Account__c) && acctRef.External_Reference__r.external_id__c==acctExtRef.get(acctRef.account__c).external_id__c) {
				existingAcctExtRefMap.get(acctRef.Account__c).add(acctRef.External_Reference__r.External_id__c);
			}
		}

		for( External_Reference__c ref : acctExtRef.values()) {
			if(!existingRefMap.containsKey(ref.External_Id__c)) {
				extRefsToInsert.add(ref);
			}
		}
		if(!extRefsToInsert.isEmpty()) {
			insert extRefsToInsert;
		}
		for(External_Reference__c ref: extRefsToInsert) {
			existingRefMap.put(ref.External_Id__c,ref);
		}
		for(Id acctId : acctExtRef.keySet()) {
			if((existingAcctExtRefMap.keySet().contains(acctId) && !existingAcctExtRefMap.get(acctId).contains(acctExtRef.get(acctId).External_Id__c))
			|| !existingAcctExtRefMap.keySet().contains(acctId))
			{
				acctExtRefstoInsert.add(new Account_External_Reference__c(
								Account__c=acctId,
								External_Reference__c=existingRefMap.get(acctExtRef.get(acctId).External_Id__c).id
								));
			}
		}
		if(!acctExtRefstoInsert.isEmpty()) {
			insert acctExtRefstoInsert;
		}

	}
	public void deleteExternalReferences(Map<id,String> delExtRef){
		List<Account_External_Reference__c> acctExtRefs=[select id,account__c,External_Reference__r.name from Account_External_Reference__c where account__c in:delExtRef.keySet() and External_Reference__r.name in: delExtRef.values()];
		List<Account_External_Reference__c> delAcctExtRefs = new List<Account_External_Reference__c>();
		for(Account_External_Reference__c acctRef:acctExtRefs) {
			if(delExtRef.get(acctRef.account__c)==acctRef.external_Reference__r.name) {
				delAcctExtRefs.add(acctRef);
			}
		}
		if(!delAcctExtRefs.isEmpty()) {
			delete delAcctExtRefs;
		}
	}

	@future
	public static void shareProspectWithPartnerExec(Map<Id,Id> partnerProspectMap){
		PartnerSharingHelper partnerHelper = new PartnerSharingHelper();
		partnerHelper.shareToAllRoles(partnerProspectMap);
	}
	@future
	public static void updateParentExternalReferences(Map<Id,Id> ParentMCNMap,String externalSystem){
		Map<Id,Account_External_Reference__c> acctExtRef = new Map<Id,Account_External_Reference__c>();
		List<Account_External_Reference__c> parentExtRef= new List<Account_External_Reference__c>();
		for(Account_External_Reference__c acctRef : [select id,External_Reference__r.name,account__c,External_Reference__c,External_Reference__r.External_Id__C from Account_External_Reference__c where account__c in:ParentMCNMap.values() and External_Reference__r.External_System__c=:externalSystem]) {
			acctExtRef.put(acctRef.account__c,acctRef);
		}
		List<Account> parentAccts = [select id,Golden_Id__c from Account where Golden_Id__c=:null and id in:ParentMCNMap.keySet()];
		for(Account acct : parentAccts) {
			system.debug(acct);

			Id childAccId=ParentMCNMap.get(acct.id);
			if(acctExtRef.containsKey(childAccId)) {
				Account_External_Reference__c acctRef= acctExtRef.get(childAccId);
				system.debug(acctRef);
				acct.Golden_Id__c = acctRef.External_Reference__r.name;
				parentExtRef.add(new Account_External_Reference__c(account__c=acct.id,External_Reference__c=acctRef.External_Reference__c));
				system.debug(acct.golden_id__c);
				system.debug(parentExtRef);

			}
		}
		if(!parentExtRef.isEmpty()) {
			insert parentExtRef;
		}
		if(!parentAccts.isEmpty()) {
			update parentAccts;
		}
	}
	@future
	public static void updateGoldenId(Set<Id> acctIds){
		List<Account> accts=[select id, Golden_Id__c from account where id in : acctIds];
		for(Account acct : accts) {
			String externalName=acct.golden_id__c.substringBefore('(');
			acct.Golden_Id__c=externalName;
		}
		update accts;
	}


	//Added by Durga as part of CDM project
	public void updateRTMandMRonPros(List<Account> prospects){
		List<Account> toBeUpdatedPros = new List<Account>();
		for(Account acc:[SELECT Id,Name,Primary_Route_to_Market__c,createdby.AccountId FROM Account where Id IN:prospects]) {
			if(acc.createdby.AccountId!= null) {
				acc.Primary_Route_to_Market__c='MR Led';
				acc.Region__c = 'NA';
				acc.Assigned_MR__c = acc.createdby.AccountId;
				toBeUpdatedPros.add(acc);
			}
		}

		if(toBeUpdatedPros.size()>0) {
			update toBeUpdatedPros;
		}
	}
	//Added by Durga as part of CDM project
	//Insert a site object record when a prospect/customer account is created.
	public void insertSiteAddress(List<Account> accounts){

		List<Technical_Site__c> toBeInsertedSite = new List<Technical_Site__c>();
		system.debug('enters into insertSiteAddress');
		for(Account acc:[SELECT Id,Name,BillingState,BillingCountry,BillingStreet, BillingCity,BillingPostalCode,BillingStateCode,BillingCountryCode,Billing_County__c
						FROM Account where Id IN:accounts]) {
			Technical_Site__c site = new Technical_Site__c();
			site.Name = acc.Name;
			site.Status__c = 'Active';
			site.Customer__c = acc.id;
			site.Primary_Street__c = acc.BillingStreet;
			site.Primary_City__c = acc.BillingCity;
			site.Country__c = acc.BillingCountryCode;
			site.State_Province__c  = acc.BillingStateCode;
			site.Primary_Zip_Postal_Code__c = acc.BillingPostalCode;
			site.Site_County__c = acc.Billing_County__c;
			site.Site_Usage__c = 'Headquarters';
			if(!Test.isRunningTest()) {
				site.Site_ID__c = 'SITE-'+string.valueof(System.now());
			}else{
				site.Site_ID__c = 'SITE-'+acc.Name+string.valueof(System.now());
			}


			toBeInsertedSite.add(site);
		}

		if(toBeInsertedSite.size()>0) {
			insert toBeInsertedSite;
		}
	}

	//Update site object record when a prospect account address is updated.
	public void updateSiteAddress(Set<Id> prosIds){
		system.debug('Entering into updateSiteAddress method handler');
		List<Technical_Site__c> prospectSites = new List<Technical_Site__c>();
		List<Technical_Site__c> toBeUpdatedSite = new List<Technical_Site__c>();
		Map<Id, List<Technical_Site__c> > prosToSiteMap = new Map<Id, List<Technical_Site__c> >();
		prospectSites = [select id,Customer__c from Technical_Site__c where Customer__c= :prosIds and Site_Usage__c Includes('Headquarters')];
		if(!prospectSites.isEmpty()) {
			for(Technical_Site__c site:prospectSites) {
				if(prosToSiteMap.containsKey(site.Customer__c))
					prosToSiteMap.get(site.Customer__c).add(site);
				else
					prosToSiteMap.put(site.Customer__c, new List<Technical_Site__c> {site});
			}
		}
		for(Account acc:[SELECT Id,Name,BillingState,BillingCountry,BillingStreet, BillingCity,BillingPostalCode,BillingStateCode,BillingCountryCode,Billing_County__c
						FROM Account where Id IN:prosIds]) {
			if(!prosToSiteMap.isEmpty()) {
				List<Technical_Site__c> site = prosToSiteMap.get(acc.id);
				site[0].Name = acc.Name;
				site[0].Primary_Street__c = acc.BillingStreet;
				site[0].Primary_City__c = acc.BillingCity;
				site[0].Country__c = acc.BillingCountryCode;
				site[0].State_Province__c  = acc.BillingStateCode;
				site[0].Primary_Zip_Postal_Code__c = acc.BillingPostalCode;
				site[0].Site_County__c = acc.Billing_County__c;
				toBeUpdatedSite.add(site[0]);
			}
		}
		if(toBeUpdatedSite.size()>0) {
			update toBeUpdatedSite;
		}
	}         //Endedby Durga as part of CDM project

	public void eaAgreeShare(Set<Id> accIds){
		List<Apttus__APTS_Agreement__c> aggrementRecs = [SELECT Business_Contact__c,Apttus__Account__r.ownerId FROM Apttus__APTS_Agreement__c
														WHERE Apttus__Account__c IN :accIds AND Hidden_Record_Type_Name__c='Reseller/Distributor' AND m_GTM_Region__c ='EMEA'
																																										AND Apttus__Account__r.owner.IsActive=true];
		Set<Id> businessContactIds = new set<Id>();
		List<Apttus__APTS_Agreement__Share> agrShare = new List<Apttus__APTS_Agreement__Share>();
		List<Apttus__APTS_Agreement__Share> agrShareList = new List<Apttus__APTS_Agreement__Share>();
		List<Apttus__APTS_Agreement__c> updBusinessCon = new List<Apttus__APTS_Agreement__c>();

		for(Apttus__APTS_Agreement__c agg:aggrementRecs) {
			businessContactIds.add(agg.Business_Contact__c);
		}

		if(businessContactIds.size()>0) {
			agrShare = [SELECT UserOrGroupId,AccessLevel,RowCause FROM Apttus__APTS_Agreement__Share WHERE UserOrGroupId IN :businessContactIds AND RowCause <> 'Owner'];
		}

		if(agrShare.size()>0) {
			delete agrShare;
		}

		for(Apttus__APTS_Agreement__c agg:aggrementRecs) {
			agg.Business_Contact__c = agg.Apttus__Account__r.ownerId;
			updBusinessCon.add(agg);
			agrShareList.add(new Apttus__APTS_Agreement__Share(ParentId = agg.id,
															UserOrGroupId = agg.Apttus__Account__r.ownerId,
															AccessLevel = 'Read',
															RowCause = Schema.Apttus__APTS_Agreement__Share.RowCause.AccountOwnerAccess__c));
		}
		if(updBusinessCon.size()>0) {
			update updBusinessCon;
		}

		if(agrShareList.size()>0) {
			insert agrShareList;
		}
	}

	public void updateOwnrOFMcns(Set<Id> accIds){
		List<Account> mcnsToBeUpdated = new List<Account>();

		for(Account acc: [SELECT Id,Name,Customer_or_Prospect_Account__r.ownerid,OwnerId FROM Account WHERE Customer_or_Prospect_Account__c IN:accIds]) {
			acc.OwnerId = acc.Customer_or_Prospect_Account__r.ownerid;
			mcnsToBeUpdated.add(acc);
		}

		if(mcnsToBeUpdated.size()>0) {
			update mcnsToBeUpdated;
		}
	}

	public void handleChildsOnMerge(List<Account> parentAccs){
		List<Account> CDHAcc= [Select Id,Name,ParentId,Customer_or_Prospect_Account__c,Customer_or_Prospect_Account__r.ownerId from Account
							where recordtype.name='Motorola Customer Number' and (ParentId='' OR ParentId=NULL) and Customer_or_Prospect_Account__c!=''
													and Customer_or_Prospect_Account__c IN:parentAccs];

		List<Account> UpdateLst=new List<Account>();

		for(Account Ac:CDHAcc) {
			Ac.ParentId = Ac.Customer_or_Prospect_Account__c;
			Ac.Is_Primary__c = FALSE;
			UpdateLst.add(Ac);
		}
		if(UpdateLst.size() > 0) {
			update UpdateLst;
		}
	}

	public Date populateAPRD(String region,Date progJoinDate){
		Date tempDate = progJoinDate;
		if(region=='EMEA') {
			Integer noOfYears = Date.Today().year()- tempDate.year(); // Number of Years since partner joined the program
			tempDate = tempDate.addmonths(1);
			tempDate = tempDate.toStartOfMonth();
			tempDate = tempDate.addmonths(1);
			tempDate = tempDate.addyears(1);
			for(Integer i=0; i<noOfYears; i++) {
				if(tempDate < Date.Today()) {
					tempDate = tempDate.addyears(1);
				}
			}
			return tempDate;
		} else if(region=='APAC' || region=='LACR' || region=='NAMR') {
			Date tempDate2;
			tempDate2 = tempDate.addyears(1);
			if(tempDate2 < Date.Today()) {
				tempDate2 = Date.Today().addyears(1);
			}
			return date.newinstance(tempDate2.year(),1,31);
		} else{
			return null;
		}
	}

	/*** Created this method to get the OwnerId based on Core Id***/
	public Map<String,Id> getOwnerIDfromCoreIDs(Set<String> coreids){
		Map<String,Id> ownerCoreMap = new Map<String,Id>();
		List<User> usrLst = [SELECT Id,Name,FederationIdentifier from User WHERE FederationIdentifier IN:coreids AND IsActive=true];
		if(coreids.size() > 0) {
			for(User us:usrLst) {
				ownerCoreMap.put(us.FederationIdentifier,us.Id);
			}
			return ownerCoreMap;
		} else {
			return null;
		}
	}

	//MR Digital
	public void revokeCPQAccessToAllContacts(Set<Id> acctIds, String appName) {
		List<Applications_Access__c> appAccesses = new List<Applications_Access__c>();
		system.debug('anand acctid'+acctIds);
		for(Applications_Access__c appAccess : [SELECT Id,App_Access_Status__c FROM Applications_Access__c WHERE App_Name__c =: appName AND App_Access_Status__c='Active'
																																								AND Contact__r.AccountId IN : acctIds])
		{
			appAccess.App_Access_Status__c = 'InActive';
			appAccesses.add(appAccess);
		}
		DataBase.update(appAccesses);

	}

	//Updating the MCN RT as Archived RT
	//Added as part of SF-1397
	//Anand Added as per SF-1960
	public void updateRecordTypeOfAccounts(Set<Id> archiveRTAccIds){
		System.debug('updateRecordTypeOfAccounts archiveRTAccIds==>' + archiveRTAccIds);
		List<Account> toBeUpdated = new List<Account>();
		for(Account acnt : [SELECT Id,RecordTypeId FROM Account WHERE Id IN:archiveRTAccIds]) {
			acnt.RecordTypeId = archiveRecordtypeId;
			toBeUpdated.add(acnt);
		}
		if(!toBeUpdated.isEmpty()) {
			try{
				update toBeUpdated;
			}catch(Exception e) {
				System.debug('Exception in Archiving Accounts##=>'+e);
			}
		}
	}        //Ended by Anand as per SF-1960

	//Added as part of SF-1806
	public void updateLDAPStatusToInactive(Set<Id> disabledPartnerAccountIds){
		List<Contact> partnerContactsToBeDisabled = [Select Id,LDAP_Login__c from Contact where AccountId IN :disabledPartnerAccountIds and LDAP_Login__c !=null];
		set<Id> conIds = new Set<Id>();
		for(Contact con:partnerContactsToBeDisabled) {
			conIds.add(con.Id);
		}
		LDAPUpdateBatch ldapBatch = new LDAPUpdateBatch();
		ldapBatch.contactIds = conIds;
		ldapBatch.updateLDAPStatusToActive=false;
		Database.executeBatch(ldapBatch, 1);
	}

	@future
	public static void updateAddress(set<id> accs){
		Map<Id,List<Technical_Site__c> > accSiteMap = new Map<Id,List<Technical_Site__c> > ();
		List<Account> upAccs = new List<Account>();
		for(Technical_Site__c site : [SELECT Id,Primary_Street__c,Primary_Street_2__c,State_Province__c,Primary_City__c,Primary_Zip_Postal_Code__c,
									Country__c,Site_County__c,MCN_Is_Primary__c,Customer__c FROM Technical_Site__c where Site_Usage__c INCLUDES('Headquarters')
									AND Customer__c IN: accs AND MCN_Is_Primary__c = true ORDER BY LastModifiedDate DESC]) {
			if(accSiteMap.containsKey(site.Customer__c)) {
				accSiteMap.get(site.Customer__c).add(site);
			}else{
				accSiteMap.put(site.Customer__c,new List<Technical_Site__c> {site});
			}
		}
		
		for(Technical_Site__c site : [SELECT Id,Primary_Street__c,Primary_Street_2__c,State_Province__c,Primary_City__c,Primary_Zip_Postal_Code__c,
		Country__c,Site_County__c,MCN_Is_Primary__c,Customer__c FROM Technical_Site__c where Site_Usage__c INCLUDES('Bill To')
		AND Customer__c IN: accs AND MCN_Is_Primary__c = true ORDER BY LastModifiedDate DESC]){
			if(accSiteMap.containsKey(site.Customer__c)) {
				accSiteMap.get(site.Customer__c).add(site);
			}else{
				accSiteMap.put(site.Customer__c,new List<Technical_Site__c> {site});
			}
		}

		for(Account acc : [SELECT Id,BillingStreet,BillingCity,BillingStateCode,BillingState,BillingPostalCode,Billing_County__c,BillingCountryCode FROM Account
						WHERE Id IN: accs]) {
			if(accSiteMap.containsKey(acc.Id)) {
				Technical_Site__c site = accSiteMap.get(acc.Id)[0];
				acc.billingStreet = site.Primary_Street__c;
				if(String.isNotBlank(site.Primary_Street_2__c))
					acc.billingStreet += ' '+site.Primary_Street_2__c;
				acc.BillingStateCode = site.State_Province__c;
				acc.BillingCountryCode = site.Country__c;
				acc.BillingCity = site.Primary_City__c;
				acc.BillingPostalCode = site.Primary_Zip_Postal_Code__c;
				acc.Billing_County__c = site.Site_County__c;
				upAccs.add(acc);
			}
		}
		if(!upAccs.isEmpty()) {
			update upAccs;
		}
	}
	//Added by Durga as part of CDM Nov rel 1.1
	public void primaryAddressUpdateonCustomer(Map<Id,List<Technical_Site__c> > cusHQSiteMap,Map<Id,List<Technical_Site__c> > cusBTSiteMap){
		system.debug('Entreing into primaryAddressUpdateonCustomer method');
		set<Id> cusIdHQ = new set<Id>();
		set<Id> cusIdBT = new set<Id>();
		Map<Id,Account> parentsTobeUpdatedHQ = new Map<Id,Account>();
		Map<Id,Account> parentsTobeUpdatedBT = new Map<Id,Account>();
		CustomerDataMasterHelper cdmHelper = new CustomerDataMasterHelper();
		Map<Id,Id> primaryMCNMap = new Map<Id,Id>();
		system.debug('cusHQSiteMap is ' +cusHQSiteMap);
		system.debug('cusBTSiteMap is ' +cusBTSiteMap);
		if(!cusHQSiteMap.IsEmpty()) {
			cusIdHQ = cusHQSiteMap.keySet();
		}
		system.debug('HQ customer account ids are ' +cusIdHQ );
		if(cusIdHQ != null) {
			for(Id accId:cusIdHQ) {
				for(Technical_Site__c site:cusHQSiteMap.get(accId)) {
					Account updacc =  new Account();
					updacc.Id = accId;
					if(site.Primary_Street_2__c != null) {
						updacc.BillingStreet = site.Primary_Street__c +' ' +site.Primary_Street_2__c;
					}
					else{
						updacc.BillingStreet = site.Primary_Street__c;
					}
					updacc.BillingStateCode = site.State_Province__c;
					updacc.BillingCountryCode = site.Country__c;
					updacc.BillingCity = site.Primary_City__c;
					updacc.BillingPostalCode = site.Primary_Zip_Postal_Code__c;
					updacc.Billing_County__c = site.Site_County__c;
					parentsTobeUpdatedHQ.put(updacc.Id, updacc);
				}
			}
		}
		if(!cusBTSiteMap.IsEmpty()) {
			cusIdBT = cusBTSiteMap.keySet();
		}
		system.debug('BT customer account ids are ' +cusIdBT );
		if(cusIdBT != null) {
			for(Id accId : cusIdBT) {
				List<Technical_Site__c> siteList = new List<Technical_Site__c>();
				if(!cusBTSiteMap.isEmpty()) {
					for(Technical_Site__c site:cusBTSiteMap.get(accId)) {
						siteList.add(site);
					}
				}
				for(Technical_Site__c eachSite:siteList) {
					Account updac =  new Account();
					updac.Id = eachSite.Customer__c;
					if(eachSite.Primary_Street_2__c != null) {
						updac.BillingStreet = eachSite.Primary_Street__c +' ' +eachSite.Primary_Street_2__c;
					}
					else{
						updac.BillingStreet = eachSite.Primary_Street__c;
					}
					updac.BillingStateCode = eachSite.State_Province__c;
					updac.BillingCountryCode = eachSite.Country__c;
					updac.BillingCity = eachSite.Primary_City__c;
					updac.BillingPostalCode = eachSite.Primary_Zip_Postal_Code__c;
					updac.Billing_County__c = eachSite.Site_County__c;
					parentsTobeUpdatedBT.put(updac.Id, updac);
					primaryMCNMap.put(eachSite.Customer__c,eachSite.MCN_Account__c);
				}
			}
		}
		system.debug('parentsTobeUpdatedHQ map contains '+parentsTobeUpdatedHQ);
		system.debug('parentsTobeUpdatedBT map contains '+parentsTobeUpdatedBT);
		system.debug('primaryMCNMap contains '+primaryMCNMap);
		if(!parentsTobeUpdatedHQ.isEmpty()) {
			system.debug('Entering into maping HQ address to account');
			update parentsTobeUpdatedHQ.values();
		}
		if(!parentsTobeUpdatedBT.isEmpty()) {
			system.debug('Entering into maping BT address to account');
			update parentsTobeUpdatedBT.values();
			if(!primaryMCNMap.isEmpty()) {
				cdmHelper.clearPrimaryFlag(primaryMCNMap);
				cdmHelper.setPrimaryFlag(primaryMCNMap);
			}
		}


	}

	// Added a Method If Agreement is associated with Account, Account has not be delete - SF-1978
	public void restrictAccountDelete(Map<Id,SObject> oldItems) {
		Map<Id,Account> oldAccMap = (Map<Id,Account>) oldItems;
		List<Account> accCheck=[Select ID, Name,(Select ID from R00N50000001Xl0UEAS__r ) from Account where ID IN: oldAccMap.keyset()];
		For(Account acc: accCheck ){
			If(acc.R00N50000001Xl0UEAS__r.size()>0){
				Account accToDelete= oldAccMap.get(acc.ID);
				accToDelete.addError(Label.Restrict_Account_Delete_Message + acc.Name + Label.Restrict_Account_Delete_Message1); //SF-1978
			}
		}
	}

	public List<String> accountSalesChannelMeta(){
		List<MR_Digitization_Settings__mdt> salesChannels = GlobalUtility.getDigitizationSettings('SalesChannel');
		if(!salesChannels.isEmpty()) {
			return salesChannels.get(0).Long_Text_Area__c.split(',');
		}
		return new List<String>();
	}
	public List<String> MCNPartnerSalesChannelMeta(){
		List<MR_Digitization_Settings__mdt> salesChannels = GlobalUtility.getDigitizationSettings('MCNPartnerSalesChannel');
		if(!salesChannels.isEmpty()) {
			return salesChannels.get(0).Long_Text_Area__c.split(',');
		}
		return new List<String>();
	}
	//Update Sites and Partner Identifiers when Customer is changed
	public void mcnAccountUpdate(Map<Id,Account> mcnAccountMap, Set<String> mcnNumbers){
		List<Technical_Site__c> sitesToBeUpdated = new List<Technical_Site__c>();
		List<Partner_Identifier__c> identifiersToBeInserted = new List<Partner_Identifier__c>();
		Map<Id,String> parentAccountWithRecType = new Map<Id,String>();
		Map<Id,String> partnerAccountWithNumber = new Map<Id,String>();
		Set<Id> competitorAccountIds = new Set<Id>();
		Set<Id> recordtypeIDs = new Set<Id> {custRecordtypeId,partRecordtypeId,prosRecordtypeId,archiveRecordtypeId};

		for(Partner_Identifier__c partner : [SELECT ID_Number__c,Account__c FROM Partner_Identifier__c WHERE ID_Number__c
											IN : mcnNumbers])
		{
			partnerAccountWithNumber.put(partner.Account__c, partner.ID_Number__c);
		}

		for(Account eachAccount : [SELECT ParentId, Parent.RecordTypeId, Parent.MSI_Competitor_Account__c FROM Account
								WHERE Id IN :mcnAccountMap.keySet()])
		{
			if(eachAccount.Parent.MSI_Competitor_Account__c && eachAccount.Parent.RecordTypeId == competitorRecordtypeId) {
				competitorAccountIds.add(eachAccount.ParentId);
			}else{
				parentAccountWithRecType.put(eachAccount.ParentId, eachAccount.Parent.RecordTypeId);
			}
		}

		for(Technical_Site__c sites : [SELECT Id, MCN_Account__c, Customer__c FROM Technical_Site__c WHERE MCN_Account__c
									IN :mcnAccountMap.keySet()])
		{
			Id mcnParentId = mcnAccountMap.get(sites.MCN_Account__c).ParentId;
			Id parentRecordTypeId = parentAccountWithRecType.get(mcnParentId);
			if(mcnParentId != sites.Customer__c && (recordtypeIDs.contains(parentRecordTypeId) ||
													competitorAccountIds.contains(mcnParentId)))
			{
				sites.Customer__c = mcnParentId;
				sitesToBeUpdated.add(sites);
			}
		}

		for(Account partnerAcc : mcnAccountMap.values()) {
			if((partnerAccountWithNumber == NULL || !partnerAccountWithNumber.containsKey(partnerAcc.ParentId)) &&
			parentAccountWithRecType.get(partnerAcc.ParentId) == partRecordtypeId)
			{
				Partner_Identifier__c partnerIdentifier = new Partner_Identifier__c();
				partnerIdentifier.Account__c   = partnerAcc.ParentId;
				partnerIdentifier.ID_Number__c = partnerAcc.Motorola_Customer_Number__c;
				partnerIdentifier.ID_Type__c   = 'Motorola Customer Number';
				identifiersToBeInserted.add(partnerIdentifier);
			}
		}

		if(!identifiersToBeInserted.isEmpty()) {
			try{
				insert identifiersToBeInserted;
			}catch(Exception e) {
				System.debug('Exception during Partner Identifier Creation=='+e);
			}
		}

		if(!sitesToBeUpdated.isEmpty()) {
			try{
				update sitesToBeUpdated;
			} catch(Exception e) {
				System.debug('Exception during Site update=='+e);
			}
		}
	}

	// updates the owner of the Parent based on the Primary MCN's Owner
	public void changeParentAccountOwner(Set<Id> ownrChngMcnIds) {
		System.debug('In Change Parent Owner...'+ownrChngMcnIds);
		List<Account> parentAccounts = new List<Account>();
		for(Account mcn : [Select Id,OwnerId,ParentId from Account where Id IN : ownrChngMcnIds AND Parent.RecordTypeId =: custRecordtypeId]) {
			parentAccounts.add(new Account(Id = mcn.ParentId, OwnerId = mcn.OwnerId));
		}
		Database.update(parentAccounts, false);
	}
    //BRR Enhancement
    public void getLockedBRRs(List<Account> lstAccount) {
        //system.debug('In isBRRLocked Method***********');
        Map<Id,String> accOwnerTerritoryMap = new Map<Id,String>();
        Set<String> setLockedBRRs = new Set<String>();
        Set<Id> brrId = new Set<Id>();
        Set<Id> accOwnerRole = new Set<Id>();
        Set<Id> subroles = new Set<Id>();
        for(Account acc : lstAccount) {
            accOwnerTerritoryMap.put(acc.ownerId, acc.Territory__c);
            brrId.add(acc.Briefing_Room_Report__c);
            accOwnerRole.add(acc.Owner_Role_Id__c);
        }
        if(!accOwnerRole.isEmpty()){
            subroles = GlobalUtility.getAllSubRoleIds(accOwnerRole); //subRoles of Acc Owner
           	subroles.addALL(accOwnerRole); // acc owner role
        }
        if(!subroles.isEmpty() && subroles.contains(userinfo.getUserRoleId())){
            Map<Id,Briefing_Room_Report__c> mapBRRWeek = BRRUtility.getBRR(brrId); 
			Map<String,MR_Digitization_Settings__mdt> mapTerritoryBRRMeta = BRRUtility.getLockdownDayByTerritory(accOwnerTerritoryMap.values());
            for(Account acc : lstAccount) { 
                Boolean isOutsideLockingPeriod = BRRUtility.isOutsideLockingPeriod(mapTerritoryBRRMeta,acc.Territory__c);
                //system.debug('mapTerritoryBRRMeta inside Helper'+mapTerritoryBRRMeta);
                //system.debug('isOutsideLockingPeriod***'+isOutsideLockingPeriod);
                if(acc.Briefing_Room_Report__c != NULL && mapBRRWeek.get(acc.Briefing_Room_Report__c).This_Week_BRR__c == True){                
                    if(isOutsideLockingPeriod){
                        acc.addError(system.label.BRR_Lock_Down);
                    }
                }else if(acc.Briefing_Room_Report__c != NULL && mapBRRWeek.get(acc.Briefing_Room_Report__c).Past_Week__c == True){
                    acc.addError(system.label.BRR_Lock_Down);
                }
            }
        }
    }
}