/**
 * @author: WGVR43 
 * @date: 07.01.2021
 * @group: DTSFPART
 * @description: 
 */
@IsTest
private class DTSFPART_ChatRoutingControllerTest {

	@IsTest
	private static void testFallbackValue(){
		User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		Locale_Region_Mapping_for_LiveAgent__mdt chatConfig;
		System.runAs(currentUser){
			chatConfig = DTSFPART_ChatRoutingController.getChatRouting('NAPC');
		}
		List<Locale_Region_Mapping_for_LiveAgent__mdt> chatConfigTest = [SELECT
				Button_Id__c,
				Is_Display_Chat_Button__c,
				Site_Language__c
		FROM Locale_Region_Mapping_for_LiveAgent__mdt WHERE DeveloperName = 'NAPC'];

		if(chatConfigTest.isEmpty()){
			System.assertEquals(null, chatConfig);
		} else {
			System.assertNotEquals(null, chatConfig, 'There should be chat configuration');
			System.assertNotEquals(null, chatConfig.Button_Id__c, 'Configuration should have Button Id field');
		}
	}
}