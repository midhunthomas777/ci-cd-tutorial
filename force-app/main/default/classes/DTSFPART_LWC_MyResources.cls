public with sharing class DTSFPART_LWC_MyResources {
  @AuraEnabled
  public static List<Dashboard_My_Resources_Important_Links__mdt> getImportantLinks(String communityMode, String countryCode, String partnerRegion) {
    try {
      return [
        SELECT Link_Name__c, Url__c, Order__c
        FROM Dashboard_My_Resources_Important_Links__mdt
        WHERE (Partner_Region__c =: partnerRegion OR Partner_Region__c = '') AND 
              (Community_Hub__c =: communityMode OR Community_Hub__c = '') AND
              (Country_Code__c =: countryCode OR Country_Code__c = '')
        ORDER BY Order__c ASC
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String getUserLinks() {
    try {
      return [
          SELECT Contact.DTSFPART_Dashboard_My_Resources_Links__c
          FROM User
          WHERE Id = :UserInfo.getUserId()
          LIMIT 1
        ]
        .get(0)
        .Contact.DTSFPART_Dashboard_My_Resources_Links__c;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static void saveUserLinks(String links) {
    try {
      DTSFPART_LWC_MyResourcesHelper.saveUserLinks(links);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}