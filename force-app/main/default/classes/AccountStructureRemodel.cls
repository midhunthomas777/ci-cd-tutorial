/*************************************************************************************************
 * File Name  : AccountStructureRemodel
 * Description: AccountStructureRemodel class
 * Modification Log
 * =============================================================================
 *   Date               Author                 Modification
 * ---------------------------------------------------------------------------------------
 * 11-Nov-2018          Suveen                 Addition of createCustomersFromMCNs method for MNA
 **************************************************************************************************/

global class AccountStructureRemodel {

static Id custRecTypeId = GlobalUtility.recordTypeId('Account', 'Customer');
static Id mcnRecTypeId =  GlobalUtility.recordTypeId('Account', 'Motorola Customer Number');
	@AuraEnabled
	public static string validMCNForCustomerCreation(Id accountId) {
		Map<String, Alerts_And_Messages__mdt> alertMessageMap = GlobalUtility.metaMessagesMap(accountId, 'Creation_of_Customer_Account');
		System.debug('alertMessageMap###'+alertMessageMap);
		List<Account> mcnAcc = [SELECT Id,Name,MCN_Account_Name__c,ParentId,Territory__c,Region__c,Motorola_Customer_Number__c,Customer_or_Prospect_Account__c,RecordtypeId,OwnerId,
								BillingState,BillingCountry,billingcountrycode,BillingStreet, BillingCity,BillingPostalCode,
								ShippingState,ShippingCountry,ShippingCountryCode,ShippingStreet, ShippingCity,ShippingPostalCode FROM Account
								WHERE Id=:accountId AND ParentId = '' AND RecordTypeId=:mcnRecTypeId];
		/*start:Added as part of CDM project*/
		String profleId = userinfo.getProfileId();
		system.debug('Current users Profile: ' +profleId);
		if(profleId != Label.System_Administrator && profleId != Label.Dev_Ops_Administrator) {
			return alertMessageMap.get('Profile_Validation').message__c;
		} //End
		if(mcnAcc.isEmpty()) {

			return alertMessageMap.get('Customer_Account_exists').message__c;
		} else {
			return '';
		}
	}

	@AuraEnabled
	public static string validMCNForUnmerging(Id accountId){
		Map<String, Alerts_And_Messages__mdt> alertMessageMap = GlobalUtility.metaMessagesMap(accountId, 'Creation_of_Customer_Account');
		System.debug('alertMessageMap###'+alertMessageMap);
		List<Account> mcnAcc = [SELECT Id,Name,ParentId,Territory__c,Motorola_Customer_Number__c,Customer_or_Prospect_Account__c,RecordtypeId,OwnerId,
								BillingState,BillingCountry,BillingStreet, BillingCity,BillingPostalCode,
								ShippingState,ShippingCountry,ShippingStreet, ShippingCity,ShippingPostalCode,Region__c,
								Parent.Region__c,Parent.Territory__c FROM Account
								WHERE Id=:accountId AND ParentId!=''
										AND Motorola_Customer_Number__c!='' AND Is_Primary__c = FALSE];

		if(mcnAcc.size()==1) {
			List<Account> childMcns = [Select Id FROM Account WHERE ParentId=:mcnAcc[0].ParentId];
			if(childMcns.size()>0) {
				return '';
			} else {
				return alertMessageMap.get('Customer_Should_Have_Multiple_Children').message__c;
			}

		} else {
			return alertMessageMap.get('Criteria_for_Unmerging').message__c;
		}

	}


	@AuraEnabled
	webservice static void createNewCustomer(Id accountId){
		List<Account> mcnAcc = [SELECT Id,Name,MCN_Account_Name__c,ParentId,Territory__c,Region__c,Motorola_Customer_Number__c,Customer_or_Prospect_Account__c,RecordtypeId,OwnerId,
								BillingState,BillingCountry,billingcountrycode,BillingStreet, BillingCity,BillingPostalCode,
								ShippingState,ShippingCountry,ShippingCountryCode,ShippingStreet, ShippingCity,ShippingPostalCode FROM Account
								WHERE Id=:accountId AND ParentId = ''];
		System.debug('mcnAcc ##'+mcnAcc);
		if(!mcnAcc.isEmpty()) {
			Account acc = createCustomerAccount(mcnAcc[0]);
			mcnAcc[0].ParentId = acc.Id;
			update mcnAcc[0];
		}
	}
	@AuraEnabled
	webservice static void restructureTheMCNaccount(Id accountId){
		System.debug('Test Button###'+accountId);
		List<Account> mcnAcc = [SELECT Id,Name,MCN_Account_Name__c,ParentId,Territory__c,Motorola_Customer_Number__c,Customer_or_Prospect_Account__c,RecordtypeId,OwnerId,
								BillingState,BillingCountry,BillingStreet, BillingCity,BillingPostalCode,
								ShippingState,ShippingCountry,ShippingStreet, ShippingCity,ShippingPostalCode,Region__c,
								Parent.Region__c,Parent.Territory__c FROM Account
								WHERE Id=:accountId AND Customer_or_Prospect_Account__c!=''
										AND Motorola_Customer_Number__c!='' AND Is_Primary__c = FALSE];
		if(mcnAcc.size()==1) {
			System.debug('MCNSize' +mcnAcc.size());
			Id custAccId = mcnAcc[0].Customer_or_Prospect_Account__c;
			String customerNumer = mcnAcc[0].Motorola_Customer_Number__c;
			String oldParentTerritory = mcnAcc[0].Parent.Territory__c;
			String oldParentRegion = mcnAcc[0].Parent.Region__c;

			List<Contact> conLst = [SELECT Id,Name,AccountId from Contact WHERE AccountId=:custAccId];
			List<Note> noteLst = [SELECT Id,Body,Title,ParentId FROM Note WHERE ParentId=:custAccId];
			//List<Case> caseLst = [SELECT Id,AccountId FROM Case where AccountId=:custAccId AND status!='Closed'];
			List<BigMachines__Quote__c> quoteLst = [SELECT Id,BigMachines__Account__c,BigMachines__status__c FROM BigMachines__Quote__c WHERE
													Motorola_Customer_Number__c=:customerNumer AND BigMachines__Opportunity__c=''];
			Set<Id> oppIdSet = new Set<Id>();

			for(Opportunity opp:[SELECT Id,Name,AccountId,CDH_Account__c FROM Opportunity WHERE CDH_Account__c=:accountId]) {
				oppIdSet.add(opp.Id);
			}


			//List<Attachment>
			//reParentActiveCases(custAcc,caseLst);
			//List<Task> taskLst = [SELECT Id,AccountId,status FROM Task WHERE AccountId=:custAccId AND status!='Completed'];

			Account custAcc = createCustomerAccount(mcnAcc[0]);

			if(conLst.size()>0) {
				createContactRoles(custAcc,conLst);
			}

			if(noteLst.size()>0) {
				replicateNotes(custAcc,noteLst);
			}

			Account updatedMCN = reParentMcnAccount(custAcc,mcnAcc[0]);

			if(quoteLst.size()>0) {
				reParentQuotes(custAcc.Id,quoteLst);
			}

			if(!oppIdSet.isEmpty()) {
				reParentOpportunies(custAcc.Id,updatedmcn.Id,oppIdSet);
			}

		}

	}

	//MNA
	//mass creation of parent Customer accounts from MCN accounts
	public static void createCustomersFromMCNs(List<Account> allIcomingMcns) {
		List<Account> insertCustomerAccounts = new List<Account>();
		List<Account> updateParentOnMcns = new List<Account>();
		Map<String,Id> mcnIdMap = new Map<String,Id>();
		set<Id> mcnIds = new Set<Id>();
		Map<Id,List<Technical_Site__c> > mcnSiteMap = new Map<Id,List<Technical_Site__c> >();
		for(Account mcn : allIcomingMcns) {
			mcnIds.add(mcn.Id);
		}
		for(Technical_Site__c site : [SELECT Id,Primary_Street__c,Primary_Street_2__c,State_Province__c,Primary_City__c,Primary_Zip_Postal_Code__c,MCN_Account__c,
									Country__c,Site_County__c,MCN_Is_Primary__c,Customer__c FROM Technical_Site__c where Site_Usage__c INCLUDES('Headquarters')  AND MCN_Account__c in:mcnIds ORDER BY LastModifiedDate DESC ]) {
			if(mcnSiteMap.containsKey(site.MCN_Account__c))
				mcnSiteMap.get(site.MCN_Account__c).add(site);
			else
				mcnSiteMap.put(site.MCN_Account__c,new List<Technical_Site__c> {site});
		}

		for(Technical_Site__c site : [SELECT Id,Primary_Street__c,Primary_Street_2__c,State_Province__c,Primary_City__c,Primary_Zip_Postal_Code__c,MCN_Account__c,
									Country__c,Site_County__c,MCN_Is_Primary__c,Customer__c FROM Technical_Site__c where Site_Usage__c INCLUDES('Bill To')  AND MCN_Account__c in:mcnIds ORDER BY LastModifiedDate DESC ]) {
			if(mcnSiteMap.containsKey(site.MCN_Account__c))
				mcnSiteMap.get(site.MCN_Account__c).add(site);
			else
				mcnSiteMap.put(site.MCN_Account__c,new List<Technical_Site__c> {site});
		}

		for(Account mcn : allIcomingMcns) {
			mcnIdMap.put(mcn.Motorola_Customer_Number__c, mcn.Id);
			Account acc = new Account(Name=mcn.Name,NameLocal=mcn.Name,RecordtypeId = custRecTypeId,OwnerId = mcn.OwnerId);
			acc.Region__c = mcn.Region__c;
			acc.Territory__c = mcn.Territory__c;
			acc.MCN_Account_Number__c = mcn.Motorola_Customer_Number__c;
			acc.Market_Type__c='Direct';

			if(mcnSiteMap.containsKey(mcn.Id)) {
				Technical_Site__c site = mcnSiteMap.get(mcn.Id)[0];
				acc.billingStreet = site.Primary_Street__c;
				if(String.isNotBlank(site.Primary_Street_2__c))
					acc.billingStreet += ' '+site.Primary_Street_2__c;
				acc.BillingStateCode = site.State_Province__c;
				acc.BillingCountryCode = site.Country__c;
				acc.BillingCity = site.Primary_City__c;
				acc.BillingPostalCode = site.Primary_Zip_Postal_Code__c;
				acc.Billing_County__c = site.Site_County__c;

			}
			insertCustomerAccounts.add(acc);

		}
		//Create Parent account
		List<Id> custAccIds = new List<Id>();
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

		DataBase.SaveResult[] customerAccResult = Database.insert(insertCustomerAccounts,dml);
		for(DataBase.SaveResult dbCust: customerAccResult) {
			if (dbCust.isSuccess()) {
				custAccIds.add(dbCust.getId());
			}
		}
		//Link Parent account to MCN account
		for(Account dbCust : [Select Id,MCN_Account_Number__c from Account where Id IN : custAccIds]) {
			updateParentOnMcns.add(
				new Account(
					Id = mcnIdMap.get(dbCust.MCN_Account_Number__c),
					ParentId = dbCust.Id)
				);
		}
		update updateParentOnMcns;
	}
	//end of createCustomersFromMCNs method

	public static Account createCustomerAccount(Account mcn){
		System.debug('Entered createCustomerAccount');
		Account acc = new Account(Name=mcn.MCN_Account_Name__c,NameLocal=mcn.MCN_Account_Name__c,RecordtypeId = custRecTypeId,OwnerId = mcn.OwnerId);
		List<Technical_Site__c> sites = new List<Technical_Site__c>();
		for(Technical_Site__c site : [SELECT Id,Primary_Street__c,Primary_Street_2__c,State_Province__c,Primary_City__c,Primary_Zip_Postal_Code__c,
									Country__c,Site_County__c,MCN_Is_Primary__c,Customer__c FROM Technical_Site__c where Site_Usage__c INCLUDES('Headquarters')  AND MCN_Account__c =:mcn.id ORDER BY LastModifiedDate DESC ]) {
			sites.add(site);
		}

		for(Technical_Site__c site : [SELECT Id,Primary_Street__c,Primary_Street_2__c,State_Province__c,Primary_City__c,Primary_Zip_Postal_Code__c,
									Country__c,Site_County__c,MCN_Is_Primary__c,Customer__c FROM Technical_Site__c where Site_Usage__c INCLUDES('Bill To')  AND MCN_Account__c =:mcn.id ORDER BY LastModifiedDate DESC ]) {
			sites.add(site);
		}
		if(!sites.isEmpty()) {
			Technical_Site__c site = sites[0];
			acc.billingStreet = site.Primary_Street__c;
			if(String.isNotBlank(site.Primary_Street_2__c))
				acc.billingStreet += ' '+site.Primary_Street_2__c;
			acc.BillingStateCode = site.State_Province__c;
			acc.BillingCountryCode = site.Country__c;
			acc.BillingCity = site.Primary_City__c;
			acc.BillingPostalCode = site.Primary_Zip_Postal_Code__c;
			acc.Billing_County__c = site.Site_County__c;
		}
		acc.Region__c = mcn.Region__c;
		acc.Territory__c = mcn.Territory__c;
		acc.MCN_Account_Number__c = mcn.Motorola_Customer_Number__c;
		acc.Market_Type__c='Direct';

		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

		DataBase.SaveResult customerAccResult = Database.insert(acc,dml);

		return acc;
	}

	// SF-1944 changes done by venkat - Accountcontactrole to AccountContactRelation
	public static void createContactRoles(Account custAcc,List<Contact> conLst){
		List<AccountContactRelation> cRoleLst = new List<AccountContactRelation>();
		for(Contact cont:conLst) {
			AccountContactRelation role = new AccountContactRelation();
			role.AccountID = custAcc.Id;
			role.ContactId = cont.Id;
			cRoleLst.add(role);
		}

		if(cRoleLst.size()>0) {
			insert cRoleLst;
		}

	}

	public static void replicateNotes(Account partnerCust,List<Note> toBeReplicated){
		List<Note> toBeInserted = new List<Note>();

		for(Note N:toBeReplicated) {
			Note temp = new Note();
			temp.Body = N.Body;
			temp.Title = N.Title;
			temp.ParentId = partnerCust.Id;
			toBeInserted.add(temp);
		}

		if(toBeInserted.size()>0) {
			insert toBeInserted;
		}
	}

	public static Account reParentMcnAccount(Account custAcc,Account mcnAcc){
		System.debug('Entered reParentMcnAccount');
		Account acc = mcnAcc;
		acc.Customer_or_Prospect_Account__c = custAcc.Id;
		acc.parentId = custAcc.Id;
		acc.Is_Primary__c = TRUE;
		update acc;

		return acc;
	}

	public static void reParentQuotes(Id parentCust,List<BigMachines__Quote__c> quoteLst){
		List<BigMachines__Quote__c> toBeReparented = new List<BigMachines__Quote__c>();
		Integer countOfFinalized = 0;
		Id oldAccId;

		if(quoteLst.size()>0) {
			oldAccId = quoteLst[0].BigMachines__Account__c;
		}

		for(BigMachines__Quote__c bigquote:quoteLst) {
			bigquote.BigMachines__Account__c = parentCust;
			toBeReparented.add(bigquote);
			if(bigquote.BigMachines__status__c=='Finalized') {
				countOfFinalized++;
			}
		}

		System.debug('parentCust###'+parentCust);
		if(toBeReparented.size()>0) {
			update toBeReparented;
		}

		for(Integer i=0; i<toBeReparented.size(); i++) {
			System.debug('toBeReparented###==>'+toBeReparented[i].BigMachines__Account__c);
		}

		if(countOfFinalized>0 && oldAccId!=null) {
			//quotesInGoogle(parentCust,oldAccId);//SF-2223 - Commenting the GoogleFile Move
		}
	}

	@future
	public static void reParentOpportunies(Id parentCust, Id mcnAcc,Set<Id> toBeReparented){
		List<Opportunity> oppsToBeReparented = [SELECT Id,Name,AccountId,CDH_Account__c FROM Opportunity WHERE Id IN :toBeReparented];
		List<Opportunity> toBeUpdated = new List<Opportunity>();
		List<Apttus__APTS_Agreement__c> agreeUpdates = new List<Apttus__APTS_Agreement__c>();

		for(Opportunity opp:oppsToBeReparented) {
			opp.AccountId = parentCust;
			opp.CDH_Account__c = mcnAcc;
			toBeUpdated.add(opp);
		}

		if(toBeUpdated.size()>0) {
			update toBeUpdated;
		}

		// Agreeement Account Mapping based on Opportunity's Account Id
		List<Apttus__APTS_Agreement__c> agreementsTobeReparented = [SELECT Id,Apttus__Account__c,Apttus__Related_Opportunity__c,
																	Apttus__Related_Opportunity__r.AccountId FROM Apttus__APTS_Agreement__c WHERE
																	Apttus__Related_Opportunity__c IN :toBeReparented];
		for(Apttus__APTS_Agreement__c aptAg:agreementsTobeReparented) {
			if(aptAg.Apttus__Account__c!=null) {

				if(aptAg.Apttus__Account__c != aptAg.Apttus__Related_Opportunity__r.AccountId) {
					aptAg.Apttus__Account__c = aptAg.Apttus__Related_Opportunity__r.AccountId;
					agreeUpdates.add(aptAg);
				}
			}
		}

		if(agreeUpdates.size()>0) {
			database.update(agreeUpdates);
		}
	}

}