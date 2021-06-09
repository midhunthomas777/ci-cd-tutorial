public with sharing class DTSFPART_PartnershipFileController {
   
   public static String PARTNERSHIP_RECORD = Partnership_Record__c.sObjectType.getDescribe().getName();

   public static List<String> PARTNERSHIP_RECORD_FIELDS = new List<String>{
      Schema.Partnership_Record__c.Id.getDescribe().getName(),
      Schema.Partnership_Record__c.Name.getDescribe().getName(),
      Schema.Partnership_Record__c.Account__c.getDescribe().getName(),
      Schema.Partnership_Record__c.Content_Type__c.getDescribe().getName(),
      Schema.Partnership_Record__c.File_Type__c.getDescribe().getName(),
      Schema.Partnership_Record__c.File_URL__c.getDescribe().getName(),
      Schema.Partnership_Record__c.Mime_Type__c.getDescribe().getName(),
      Schema.Partnership_Record__c.Month__c.getDescribe().getName(),
      Schema.Partnership_Record__c.Year__c.getDescribe().getName(),
      Schema.Partnership_Record__c.Archive__c.getDescribe().getName()
   };

   @AuraEnabled
   public static List<Partnership_Record__c> getRecentlyViewedPartnershipRecordsByCurrentUser() {
      return buildQueryAndGetPartnershipRecords('LastViewedDate != null', 'LastViewedDate DESC', '10');
   }

   @AuraEnabled
   public static Map<Boolean, List<Partnership_Record__c>> getActivePartnershipRecordsMapForCurrentUserContactAccount() {
      return new Map<Boolean, List<Partnership_Record__c>>{
         false => buildQueryAndGetPartnershipRecords('LastViewedDate != null AND Archive__c = false'),
         true => buildQueryAndGetPartnershipRecords('LastViewedDate = null AND Archive__c = false') //user didn't saw record details - new records
      };
   }

   @AuraEnabled
   public static List<Partnership_Record__c> getArchivedPartnershipRecordsForCurrentUserContactAccount() {
      return buildQueryAndGetPartnershipRecords('Archive__c = true');
   }

   private static List<Partnership_Record__c> buildQueryAndGetPartnershipRecords(String conditions) {
      return buildQueryAndGetPartnershipRecords(conditions, null, null);
   }

   private static List<Partnership_Record__c> buildQueryAndGetPartnershipRecords(String conditions, String orderBy) {
      return buildQueryAndGetPartnershipRecords(conditions, orderBy, null);
   }

   private static List<Partnership_Record__c> buildQueryAndGetPartnershipRecords(String conditions, String orderBy, String recordsLimit) {
      Id accountId = DTSFPART_UserInfoService.getCurrentUserContactAccountId();

      String baseQuery = 'SELECT ' + String.join(PARTNERSHIP_RECORD_FIELDS, ',');
             baseQuery += ' FROM ' + PARTNERSHIP_RECORD;
             baseQuery += ' WHERE Account__c = :accountId';

      if (String.isNotBlank(conditions)) {
         baseQuery += ' AND ' + conditions;
      }
      if (String.isNotBlank(orderBy)) {
         baseQuery += ' ORDER BY ' + orderBy;
      }
      if (String.isNotBlank(recordsLimit)) {
         baseQuery += ' LIMIT ' + recordsLimit;
      }

      return (List<Partnership_Record__c>) Database.query(baseQuery);
   }

   @AuraEnabled(cacheable=true)
   public static Map<String, String> getMimeTypePicklist() {
      Map<String, String> labelToValueMimeType = new Map<String, String>();
      
      labelToValueMimeType.put('All Types', '');
      
      for (Schema.PicklistEntry picklistEntry : Partnership_Record__c.Mime_Type__c.getDescribe().getPicklistValues()) {
         labelToValueMimeType.put(
            picklistEntry.getLabel(), 
            picklistEntry.getValue()
         );
      }     
     
     return labelToValueMimeType;
   }

   @AuraEnabled
   public static DTSFPART_PartnershipFileHelper.FileWrapper downloadFile(String recordId) {
      
      Partnership_Record__c partnerFile = [
         SELECT Id, Name, File_Id__c, Mime_Type__c, No_of_Downloads__c, Download_History__c, Content_Type__c, File_Type__c, Year__c
         FROM Partnership_Record__c
         WHERE Id =: recordId 
         LIMIT 1
      ];

      if (String.isEmpty(partnerFile.File_Id__c)) {
         throw new AuraHandledException('Partnership Record File Id cannot be empty.');
      }

      Http httpCallout = new Http(); 
      HttpRequest request = new HttpRequest(); 

      request.setEndpoint(
         DTSFPART_PartnershipFileHelper.getGoogleDriveRequestUrl(partnerFile)
      ); 
      request.setMethod('GET'); 
      request.setCompressed(true);

      HttpResponse response = httpCallout.send(request);

      if (response.getStatusCode() != 200) {
         throw new AuraHandledException('Unexpected error while downloading.' + response.getBody());
      }

      DTSFPART_PartnershipFileHelper.FileWrapper fileWrapper = new DTSFPART_PartnershipFileHelper.FileWrapper();

      fileWrapper.blobContent = EncodingUtil.base64Encode(response.getBodyasBlob());
      fileWrapper.fileName = partnerFile.Name + '_' +  partnerFile.File_Type__c + '_' + partnerFile.Year__c;
      fileWrapper.contentType = 'data:' + partnerFile.Content_Type__c;
      fileWrapper.extension = DTSFPART_PartnershipFileHelper.getFileExtensionBasedOnMimeType(partnerFile.Mime_Type__c);

      return fileWrapper;
   }
}