/**
 * @author: WGVR43 
 * @date: 28.09.2020
 * @group: DTSFPART
 * @description: 
 */
@IsTest
private class DTSFPART_DynatraceEntryControllerTest {

	@TestSetup
	static void makeData(){
		DTSFPART_TestDataSetUpUtils.insertCustomSettings();
		Profile channelProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Channel Public Profile' AND UserType = 'Guest' LIMIT 1];
		User userWithCoreId = new User(
				ProfileId = channelProfile.Id,
				Username = 'DynatraceEntryControllerCore@DTSFPART.moto',
				Email = 'DynatraceEntryControllerCore@DTSFPART.moto',
				EmailEncodingKey = 'UTF-8',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				TimeZoneSidKey = 'America/Los_Angeles',
				Alias='CoreId',
				LastName='Channel Public Site Guest User,',
				Core_ID__c = 'DTSFPART'
		);
		insert userWithCoreId;

		User userWithoutCoreId = new User(
				ProfileId = channelProfile.Id,
				Username = 'DynatraceEntryControllerTest@DTSFPART.moto',
				Email = 'DynatraceEntryControllerTest@DTSFPART.moto',
				EmailEncodingKey = 'UTF-8',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				TimeZoneSidKey = 'America/Los_Angeles',
				Alias='NoCoreId',
				LastName='Channel Public Site Guest User,'
		);
		insert userWithoutCoreId;
	}

	@IsTest
	static void getUserRecord(){
		User currentUser = [SELECT Id, Username, Core_ID__c FROM User WHERE Id = :UserInfo.getUserId()];
		User testUser;

		Test.startTest();
			testUser = DTSFPART_DynatraceEntryController.getUserInfo();
		Test.stopTest();

		System.assertEquals(currentUser.Core_ID__c, testUser.Core_ID__c);
		System.assertEquals(currentUser.Username, testUser.Username);
	}

	@IsTest // test with core Id
	static void testCoreId(){
		User currentUser = [SELECT Id, Username, Core_ID__c FROM User WHERE Username = 'DynatraceEntryControllerTest@DTSFPART.moto' LIMIT 1];
		User testUser;

		Test.startTest();
		System.runAs(currentUser){
			testUser = DTSFPART_DynatraceEntryController.getUserInfo();
		}
		Test.stopTest();

		System.assertEquals(currentUser.Core_ID__c, testUser.Core_ID__c);
		System.assertEquals(currentUser.Username, testUser.Username);
	}

	@IsTest // test without core Id
	static void testWithoutCoreId(){
		User currentUser = [SELECT Id, Username FROM User WHERE Username = 'DynatraceEntryControllerTest@DTSFPART.moto' LIMIT 1];
		User testUser;

		Test.startTest();
			System.runAs(currentUser){
				testUser = DTSFPART_DynatraceEntryController.getUserInfo();
			}
		Test.stopTest();

		System.assertEquals(null, testUser.Core_ID__c);
		System.assertEquals(currentUser.Username, testUser.Username);
	}
}