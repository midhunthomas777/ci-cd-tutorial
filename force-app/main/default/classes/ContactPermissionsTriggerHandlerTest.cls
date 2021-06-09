/**
* @author MSI
* @modified Jan Sledziewski - 15.09.2020
* @date July 2020
* @description Test class for the controller class ContactPermissionsTriggerHandler
*/

@IsTest(SeeAllData = false)
private class ContactPermissionsTriggerHandlerTest {

	private static final String CONTACT_NAME = 'ContactPermissionsSpecial';
	@TestSetup
	static void testSetUp() {
		TestDataSetUpUtils.insertCustomSettings();// need custom settings for triggers to run

		Id partnerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
		List<Account> parentAccounts = TestDataSetUpUtils.createAccounts(1, partnerRecordTypeId);

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

		insert new Technology_Specialization__c(
				Community_Type__c = 'Service Partner',
				Account__c = parentAccounts[0].Id,
				Partner_Program__c = partnerTypes[0].Id
		);


		Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
		TestDataSetUpUtils.createMCNAccounts(1, mcnRecordTypeId, parentAccounts);


		Contact testContact = getTestContact();
		testContact.FirstName = CONTACT_NAME;
		insert testContact;
	}

	// @IsTest
	// static void contactCreation(){
	// 	Contact testContact = getTestContact();
	// 	Test.startTest();
	// 		Database.DMLOptions dml = new Database.DMLOptions(); 
	// 		dml.DuplicateRuleHeader.allowSave = true;
	// 		Database.insert(testContact, dml);
	// 	Test.stopTest();

	// 	Contact resultContact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
	// 	System.assertEquals('In Progress', resultContact.Enterprise_Permission_Status__c);
	// }

	// @IsTest
	// static void contactCreationInProgress(){
	// 	Contact testContact = getTestContact();
	// 	Test.startTest();
	// 		ContactPermissionsTriggerHandler.TriggerDisabled = true;
	// 		Database.DMLOptions dml = new Database.DMLOptions(); 
	// 		dml.DuplicateRuleHeader.allowSave = true;
	// 		Database.insert(testContact, dml);
	// 		ContactPermissionsTriggerHandler.TriggerDisabled = false;
	// 	Test.stopTest();

	// 	Contact resultContact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
	// 	System.assertEquals('In Progress', resultContact.Enterprise_Permission_Status__c);
	// }

	// @IsTest
	// static void contactUpdate(){
	// 	Contact testContact = getTestContact();
	// 	Database.DMLOptions dml = new Database.DMLOptions(); 
	// 	dml.DuplicateRuleHeader.allowSave = true;
	// 	Database.insert(testContact, dml);

	// 	Test.startTest();
	// 		Contact updateContact = [SELECT Id, Contact_MCN_Permissions__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
	// 		List<String> contactPermissions = new List<String>(DTSFPART_PermissionUtils.splitPermissions(updateContact.Contact_MCN_Permissions__c));
	// 		contactPermissions.add('OrderSubmission');

	// 		updateContact.Contact_MCN_Permissions__c = String.join((Iterable<String>) contactPermissions, ';');
	// 		update updateContact;
	// 	Test.stopTest();

	// 	Contact resultContact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
	// 	System.assertEquals('In Progress', resultContact.Enterprise_Permission_Status__c);
	// }

	// @IsTest
	// static void contactUpdateInProgress(){
	// 	Contact testContact = getTestContact();
	// 	Database.DMLOptions dml = new Database.DMLOptions(); 
	// 	dml.DuplicateRuleHeader.allowSave = true;
	// 	Database.insert(testContact, dml);

	// 	Test.startTest();
	// 		ContactPermissionsTriggerHandler.TriggerDisabled = true;
	// 		Contact updateContact = [SELECT Id, Contact_MCN_Permissions__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
	// 		List<String> contactPermissions = new List<String>(DTSFPART_PermissionUtils.splitPermissions(updateContact.Contact_MCN_Permissions__c));
	// 		contactPermissions.add('OrderSubmission');

	// 		updateContact.Contact_MCN_Permissions__c = String.join((Iterable<String>) contactPermissions, ';');
	// 		update updateContact;
	// 		ContactPermissionsTriggerHandler.TriggerDisabled = false;
	// 	Test.stopTest();

	// 	Contact resultContact = [SELECT Id, Enterprise_Permission_Status__c FROM Contact WHERE Id = :testContact.Id LIMIT 1];
	// 	System.assertEquals('In Progress', resultContact.Enterprise_Permission_Status__c);
	// }

	@IsTest
	static void permissionDeletion(){
		Contact testContact = [SELECT Id, FirstName FROM Contact WHERE FirstName = :CONTACT_NAME];

		Test.startTest();
			List<Contact_Permissions__c> contactPermissions = [SELECT Id, Contact__c FROM Contact_Permissions__c WHERE Contact__c = :testContact.Id];
			delete contactPermissions;
		Test.stopTest();

		List<Contact_Permissions__c> testContactPermissions = [SELECT Id, Contact__c FROM Contact_Permissions__c WHERE Contact__c = :testContact.Id];
		System.assert(testContactPermissions.isEmpty());
	}

	private static Contact getTestContact(){
		List<Account>  parentAccounts = [SELECT Id FROM Account WHERE Name LIKE 'Test Account%' LIMIT 1];
		Id contactRecordTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Contact', 'MPE_Partner_Contact');

		return new Contact(
				AccountId = parentAccounts.get(0).Id,
				RecordTypeId = contactRecordTypeId,
				LDAP_Login__c = 'masters',
				FirstName = 'ContactPermissions',
				LastName = 'TriggerHandlerTest',
				FirstNameLocal = 'ContactLocalName',
				Email = 'ContactPermissionsTest@dtsfpart.gmail.com',
				Tag__c = 'SFDCPartnerAdmin',
				LastNameLocal = 'Partner Contact',
				Persona__c = 'OwnerExecutive'
		);
	}
/*
	@IsTest
	static void ContactPermissionsTriggerHandler() {
		User partneruser = TestDataSetUpUtils.createCommunityUser();

		User usr = [SELECT Id,AccountId,ContactId FROM User WHERE Id = :partneruser.Id];

		Id mcnRecTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account', 'Motorola_Customer_Number');
		List<Account> mcnAcc = TestDataSetUpUtils.createAccounts(1, mcnRecTypeId);
		mcnAcc[0].Customer_or_Prospect_Account__c = usr.AccountId;
		mcnAcc[0].Motorola_Customer_Number__c = '123445';
		update mcnAcc;
		insert new MCN_Permission__c(MCN_Account__c = mcnAcc[0].Id, Customer_OR_Partner_Account__c = usr.AccountId, Contact_MCN_Permissions__c = 'OrderSubmission',
				Enterprise_MCN_Unique__c = usr.AccountId + '#' + mcnAcc[0].Id);
		insert new Contact_Permissions__c(Contact__c = usr.ContactId, MCN_Account__c = mcnAcc[0].Id, Parent_Account__c = usr.AccountId, Contact_MCN_Permissions__c = 'OrderSubmission');

		Contact_Permissions__c CP = [SELECT Id,Contact__c FROM Contact_Permissions__c WHERE Contact__c = :usr.ContactId LIMIT 1];
		update CP;
		delete CP;
	}

	@IsTest
	static void UserProvisioningHelper1() {
		User u = [SELECT Id, IsActive FROM User WHERE IsActive = false and FederationIdentifier != null and contactId != null limit 1];
		UserProvisioningHelper.createUserFromContact(u);
		UserProvisioningHelper.disableComUser(u.Id);
	}

	@IsTest
	public static void testUserUpdateTrigger() {
		Id accrectypeID = GlobalUtility.getRecordTypeIdByDeveloperName('Account', 'SoldToAccount');
		Id partnerCntRecId = GlobalUtility.getRecordTypeIdByDeveloperName('Contact', 'MPE_Partner_Contact');
		List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
		List<Contact> lstContact = TestDataSetUpUtils.createContacts(1, partnerCntRecId, lstAccount);
		Id p = [select id from profile where name = 'EMS Partner Administrator Profile NAMR'].id;
		User newUser = new User(alias = 'test123', email = 'test123asdfresdf@noemail.com',
				emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
				localesidkey = 'en_US', profileid = p, country = 'United States',
				ContactId = lstContact.get(0).Id,
				timezonesidkey = 'America/Los_Angeles', username = 'tester@noemail.com.niran',
				IsActive = false, FederationIdentifier = 'tester@noemail.com.niran');

		insert newUser;
	}*/
}