/**
 * @author: WGVR43 
 * @date: 20.08.2020
 * @group: DTSFPART
 * @description: 
 */

@IsTest
public with sharing class DTSFPART_PopulateMCNPermissions_Test {

	private static final Integer parentNumber = 2;
	private static final Integer mcnNumber = 5;

	@TestSetup
	private static void setup() {
		DTSFPART_TestDataSetUpUtils.insertCustomSettings();

		TriggerSettings__c triggerSettings = [SELECT Id, Name, IsActive__c FROM TriggerSettings__c WHERE Name = 'CustomerAccountTriggerDisabled'];
		triggerSettings.IsActive__c = true;
		update triggerSettings;

		Id partnerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
		Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');

		List<Account> parentAccounts = DTSFPART_TestDataSetUpUtils.createAccounts(parentNumber, partnerRecordTypeId);
		DTSFPART_TestDataSetUpUtils.createMCNAccounts(mcnNumber, mcnRecordTypeId, parentAccounts, true);

		List<Partner_Type__c> partnerTypes = new List<Partner_Type__c>();
		for(Account account: parentAccounts) {
			partnerTypes.add(new Partner_Type__c(
					Account__c = account.Id,
					Program__c = 'RADIO',
					Status__c = 'Active',
					Purchasing_Method__c = 'Tier 16',
					US_Federal__c = true,
					RHO__c = true
			));
		}
		insert partnerTypes;

		List<Technology_Specialization__c> programDetails = new List<Technology_Specialization__c>();
		for(Integer i = 0; i < parentNumber; i++) {
			programDetails.add(new Technology_Specialization__c(
					Community_Type__c = 'Value Added Reseller',
					Account__c = parentAccounts[i].Id,
					Partner_Program__c = partnerTypes[i].Id,
					Technology_Specialization__c = 'Mission Critical Radio Systems', //'Unlicensed Radio',
					Technology_Specialization_Status__c = 'Active'
			));
		}
		insert programDetails;
	}
	@IsTest
	private static void createMcn() {
		List<Account>  parentAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%' LIMIT :parentNumber];
		Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');

		List<Id> mcnIds = new List<Id>();

		List<Account> mcns = DTSFPART_TestDataSetUpUtils.createMCNAccounts(mcnNumber, mcnRecordTypeId, parentAccounts, false);
		insert mcns;
		Test.startTest();
		Map<Id, List<Account>> newMcnByParent = DTSFPART_Utils.groupObjectsByIdField(mcns, 'ParentId');
		DTSFPART_PopulateMCNPermissions job = new DTSFPART_PopulateMCNPermissions(newMcnByParent, mcnIds, 'create');
		job.execute(null);
		Test.stopTest();

		List<Id> parentIds = new List<Id>();
		for(Account pAccount: parentAccounts) {
			parentIds.add(pAccount.Id);
		}

		Map<Id, Technology_Specialization__c> programDetailToParentAccount = new Map<Id, Technology_Specialization__c>();
		for(Technology_Specialization__c programDetail: [
				SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c, Account__c
				FROM Technology_Specialization__c
				WHERE Account__c IN :parentIds
		]){
			programDetailToParentAccount.put(programDetail.Account__c, programDetail);
		}

		List<MCN_Permission__c> mcnPermissions = [
				SELECT Id, Contact_MCN_Permissions__c, MCN_Permissions__c, Customer_OR_Partner_Account__c
				FROM MCN_Permission__c
				WHERE MCN_Account__c IN :mcnIds
		];

		for(MCN_Permission__c mcnPermission: mcnPermissions) {
			System.assert(compareCsv(programDetailToParentAccount.get(mcnPermission.Customer_OR_Partner_Account__c).Contact_Mcn_Permissions__c,
					mcnPermission.Contact_MCN_Permissions__c), 'Contact MCN Permissions are incorrect');
			System.assert(compareCsv(programDetailToParentAccount.get(mcnPermission.Customer_OR_Partner_Account__c).MCN_Permissions__c,
					mcnPermission.MCN_Permissions__c), 'MCN Permissions are incorrect');
		}
	}

	@IsTest
	private static void changeAccount() {
		List<Account>  parentAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%' LIMIT :parentNumber];
	
		List<Id> parentIds = new List<Id>();
		for(Account pAccount: parentAccounts) {
			parentIds.add(pAccount.Id);
		}
        
		List<Account> mcns = [SELECT Id, ParentId, Motorola_Customer_Number__c, Parent_Record_Type__c FROM Account WHERE ParentId IN :parentIds];
		MCN_Permission__c mcnPerm = new MCN_Permission__c(
				MCN_Account__c = mcns[0].Id,
				Customer_OR_Partner_Account__c = mcns[0].ParentId,
				Contact_Mcn_Permissions__c = ''
		);
		insert mcnPerm;
		Test.startTest();
			Integer parent = 0;
		List<Id> mcnIds = new List<Id>();
			for(Account mcn: mcns){
				mcn.ParentId = parentAccounts[parent].Id;
				mcn.Motorola_Customer_Number__c = string.valueof(integer.valueof(math.random()*100000000))+'00';
				if(parent == parentNumber - 1){
					parent = 0;
				} else {
					parent++;
				}
				mcnIds.add(mcn.Id);
			}
			Map<Id, List<Account>> newMcnByParent = DTSFPART_Utils.groupObjectsByIdField(mcns, 'ParentId');
			DTSFPART_PopulateMCNPermissions job = new DTSFPART_PopulateMCNPermissions(newMcnByParent, mcnIds,
					new Map<Id, List<Account>>(), new List<Id>(), new DTSFPART_ContactMcnPermRemovalReference(), 'update');
			job.execute(null);

		Test.stopTest();

		Map<Id, Technology_Specialization__c> programDetailToParentAccount = new Map<Id, Technology_Specialization__c>();
		for(Technology_Specialization__c programDetail: [
				SELECT Id, Contact_Mcn_Permissions__c, MCN_Permissions__c, Account__c
				FROM Technology_Specialization__c
				WHERE Account__c IN :parentIds
		]){
			programDetailToParentAccount.put(programDetail.Account__c, programDetail);
		}

		List<MCN_Permission__c> mcnPermissions = [
				SELECT Id, Contact_MCN_Permissions__c, MCN_Permissions__c, Customer_OR_Partner_Account__c
				FROM MCN_Permission__c
				WHERE Customer_OR_Partner_Account__c IN :parentIds
		];

		for(MCN_Permission__c mcnPermission: mcnPermissions) {
			System.assert(compareCsv(programDetailToParentAccount.get(mcnPermission.Customer_OR_Partner_Account__c).Contact_Mcn_Permissions__c,
					mcnPermission.Contact_MCN_Permissions__c), 'Contact MCN Permissions are incorrect');
			System.assert(compareCsv(programDetailToParentAccount.get(mcnPermission.Customer_OR_Partner_Account__c).MCN_Permissions__c,
					mcnPermission.MCN_Permissions__c), 'MCN Permissions are incorrect');
		}

	}

	static Boolean compareCsv(String expected, String actual) {
		if (expected != actual) {
			if (expected == null || actual == null) {
				return false;
			}

			List<String> exp = expected.split(';');
			List<String> act = actual.split(';');

			if (exp.size() != act.size()) return false;
			for (String item : act) {
				if (!exp.contains(item)) return false;
			}
		}
		return true;
	}
}