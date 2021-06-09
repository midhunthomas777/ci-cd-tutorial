/**
 * @author: WGVR43 
 * @date: 28.09.2020
 * @group: DTSFPART
 * @description: 
 */

public with sharing class DTSFPART_DynatraceEntryController {

	@AuraEnabled
	public static User getUserInfo(){
		return [SELECT Username, Core_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
	}
}