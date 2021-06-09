/**
 * @author		Jan Sledziewski
 * @created		2021-01-22
 * @updated		2021-01-28
 * @description	Helper for methods that don't need sharing
 */

public without sharing class DTSFPART_DashboardComponentsHelper {

	public static void saveCurrentUserSettings(String settings){
			ContactTriggerHandler.TriggerDisabled = true;
			DTSFPART_ContactTriggerHandler.TriggerDisabled = true;
			User currentUser = [SELECT Contact.DTSFPART_Dashboard_Settings__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].get(0);
			currentUser.Contact.DTSFPART_Dashboard_Settings__c = settings;
			update currentUser.Contact;
	}

	public static void updatePartnerPortalFlag(){
		ContactTriggerHandler.TriggerDisabled = true;
		DTSFPART_ContactTriggerHandler.TriggerDisabled = true;
		User currentUser = [SELECT Contact.DTSFPART_Partner_Portal_Logged__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1].get(0);
		currentUser.Contact.DTSFPART_Partner_Portal_Logged__c = true;
		update currentUser.Contact;
	}	

	public static boolean isMRCommunityTypeAssignedForUserAccount() {
		boolean hasMRCommunityType = false;
		List<User> users = [SELECT Contact.Account.Has_MR_Community_Type__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

		if (!users.isEmpty()) {
			hasMRCommunityType = users[0]?.Contact?.Account?.Has_MR_Community_Type__c;
		}

		return hasMRCommunityType != null ? hasMRCommunityType : false;
	}
}