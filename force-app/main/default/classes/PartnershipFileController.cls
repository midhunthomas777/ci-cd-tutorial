public with sharing class PartnershipFileController {
   
   @AuraEnabled
   public static List<Partnership_Record__c> getRecentlyViewedPartnershipRecords() {
      try {
         List<Id> recentlyViewedPartnerships = new List<Id>();

         for (RecentlyViewed recentlyViewed : [ SELECT Id
                                                FROM RecentlyViewed
                                                WHERE Type IN ('Partnership_Record__c') 
                                                ORDER BY LastViewedDate DESC
                                                LIMIT 10 ]) {

            recentlyViewedPartnerships.add(recentlyViewed.Id);                                     
         }
    
         return [ SELECT Id, Name, Account__c,  Content_Type__c, File_Type__c, File_URL__c, Mime_Type__c, Month__c, Year__c
                  FROM Partnership_Record__c
                  WHERE Id IN :recentlyViewedPartnerships ];

      } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
      }
   }

   @AuraEnabled
   public static List<Partnership_Record__c> getAccountRelatedPartnershipRecords(Id accountId){
      try {
         return [ SELECT Id, Name, Account__c, Content_Type__c, File_Type__c, File_URL__c, Mime_Type__c, Month__c, Year__c
                  FROM Partnership_Record__c
                  WHERE Account__c = :accountId ];
      } catch (Exception e) {
         throw new AuraHandledException(e.getMessage());
      }
   }
}