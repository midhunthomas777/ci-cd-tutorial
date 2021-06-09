/**
 * @author: WGVR43 
 * @date: 02.09.2020
 * @group: DTSFPART
 * @description: Test class for DTSFPART_McnPermissionTriggerHandler.
 */

@IsTest
public class DTSFPART_McnPermissionTriggerHandlerTest {

	private static Integer parentNumber = 2;
	private static Integer contactNumber = 2;
	private static Integer mcnNumber = 2;

	@TestSetup
	private static void testSetup(){
		DTSFPART_TestDataSetUpUtils.insertCustomSettings();
		TriggerSettings__c triggerSettings = [SELECT Id, Name, IsActive__c FROM TriggerSettings__c WHERE Name = 'CustomerAccountTriggerDisabled'];
		triggerSettings.IsActive__c = true;
		update triggerSettings;

		Id partnerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
		List<Account> parentAccounts = DTSFPART_TestDataSetUpUtils.createAccounts(parentNumber, partnerRecordTypeId);

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
					Community_Type__c = 'Service Partner',
					Account__c = parentAccounts[i].Id,
					Partner_Program__c = partnerTypes[i].Id
			));
		}
		insert programDetails;

		Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
		List<Contact> contacts = new List<Contact>();
		for(Contact contact: DTSFPART_TestDataSetUpUtils.createContacts(contactNumber, contactRecordTypeId, parentAccounts)){
			contact.Persona__c = 'OwnerExecutive';
			contacts.add(contact);
		}
		update contacts;

		Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
		List<Account> mcnAccounts = DTSFPART_TestDataSetUpUtils.createMCNAccounts(mcnNumber, mcnRecordTypeId, parentAccounts, true);
		for(Account account: parentAccounts) {
			account.Enterprise_Permission_Status__c = 'Completed';
		}
		update parentAccounts;
	}

	@IsTest
	static void checkMcnCreation(){
		List<Account>  parentAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%' LIMIT :parentNumber];
		Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');

		Set<Id> mcnIds = new Set<Id>();
		Test.startTest();
		DTSFPART_TestDataSetUpUtils.createMCNAccounts(mcnNumber, mcnRecordTypeId, parentAccounts, true);
		Test.stopTest();

		for(Account parentAccount: [SELECT Id, Enterprise_Permission_Status__c FROM Account WHERE Name LIKE 'Test Account%']){
			System.assertEquals('In Progress', parentAccount.Enterprise_Permission_Status__c);
		}
	}

	@IsTest
	static void checkMcnUpdate(){
		Set<Id> mcnIds = new Set<Id>();
		Set<Id> parentIds = new Set<Id>();
		for(Account mcn: [SELECT Id, ParentId FROM Account WHERE Name LIKE 'TestMCN%']){
			mcnIds.add(mcn.Id);
			parentIds.add(mcn.ParentId);
		}

		List<MCN_Permission__c> mcnPermissions = [SELECT Id, Contact_MCN_Permissions__c FROM MCN_Permission__c WHERE MCN_Account__c IN :mcnIds];
		List<String> mcnUnusedPermissions = getAllPermissions();
		System.assert(!mcnUnusedPermissions.isEmpty());

		for(MCN_Permission__c mcnPermission: mcnPermissions){
			mcnPermission.Contact_MCN_Permissions__c = String.join((Iterable<String>) mcnUnusedPermissions, ';');
		}

		Test.startTest();
			update mcnPermissions;
		Test.stopTest();
		for(Account parentAccount: [SELECT Id, Enterprise_Permission_Status__c FROM Account WHERE Id IN :parentIds]){
			System.assertEquals('In Progress', parentAccount.Enterprise_Permission_Status__c);
		}

	}

	@IsTest
	static void checkMcnDeletion(){
		Set<Id> mcnIds = new Set<Id>();
		Set<Id> parentIds = new Set<Id>();
		for(Account mcn: [SELECT Id, ParentId FROM Account WHERE Name LIKE 'TestMCN%']){
			mcnIds.add(mcn.Id);
			parentIds.add(mcn.ParentId);
		}

		Map<Id, MCN_Permission__c> mcnPermissions = new Map<Id, MCN_Permission__c>([SELECT Id, Contact_MCN_Permissions__c FROM MCN_Permission__c WHERE MCN_Account__c IN :mcnIds]);

		Test.startTest();
		delete mcnPermissions.values();
		Test.stopTest();


	}


	private static List<String> getAllPermissions(){
		Set<String> permissions = new Set<String>();
		Schema.DescribeFieldResult contactMcnField = MCN_Permission__c.Contact_MCN_Permissions__c.getDescribe();
		for(PicklistEntry entry: contactMcnField.getSobjectField().getDescribe().getPicklistValues()){
				permissions.add(entry.value);
		}

		return new List<String>(permissions);
	}
}