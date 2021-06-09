/**
 * @author: WGVR43
 * @date: 21.12.2020
 * @group: DTSFPART
 * @description:
 */

public without sharing class DTSFPART_ChatRoutingController {
    @AuraEnabled
    public static Locale_Region_Mapping_for_LiveAgent__mdt getChatRouting(String configName) {
        String userLanguage = UserInfo.getLanguage();

        List<Locale_Region_Mapping_for_LiveAgent__mdt> chatConfig = new List<Locale_Region_Mapping_for_LiveAgent__mdt>();
        try {
            chatConfig = [
                SELECT
                    Button_Id__c,
                    Is_Display_Chat_Button__c,
                    Site_Language__c,
                    Last_Name_ChatT__c,
                    First_Name_ChatT__c,
                    Email_Address_ChatT__c,
                    Contact_Us_Form_Url__c,
                    Is_Banner_Needed__c,
                    Banner_Time__c
                FROM Locale_Region_Mapping_for_LiveAgent__mdt
                WHERE DeveloperName = :configName
            ];
        } catch (System.QueryException qException) {
            LogError.saveExceptionPEvent('Chat Routing', 'Exception during chat configuration read', qException.getMessage(), qException);
			throw new AuraHandledException(qException.getMessage());
        }

        if (chatConfig.isEmpty()) {
            return null;
        }

        chatConfig.get(0).Site_Language__c = userLanguage;
        return chatConfig.get(0);
    }

    @AuraEnabled
    public static User getUser() {
        User user;

        try {
            user = [
                SELECT Id, FirstName, LastName, Email, ContactId, Contact.FirstName, Contact.LastName, Contact.Email
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
        } catch (System.QueryException qException) {
            LogError.saveExceptionPEvent('Chat Routing', 'Exception during user read', qException.getMessage(), qException);
			throw new AuraHandledException(qException.getMessage());
        }

		return user;
    }
}