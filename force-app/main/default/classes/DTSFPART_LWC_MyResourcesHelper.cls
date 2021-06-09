/**
* @author		Jan Sledziewski
* @created		2021-01-22
* @updated		2021-01-22
* @description	Helper for methods that don't need sharing
*/

public without sharing class DTSFPART_LWC_MyResourcesHelper {

	public static void saveUserLinks(String links) {
		ContactTriggerHandler.TriggerDisabled = true;
		DTSFPART_ContactTriggerHandler.TriggerDisabled = true;
		User currentUser = [
				SELECT Contact.DTSFPART_Dashboard_My_Resources_Links__c
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		]
				.get(0);
		currentUser.Contact.DTSFPART_Dashboard_My_Resources_Links__c = links;
		update currentUser.Contact;
	}
}