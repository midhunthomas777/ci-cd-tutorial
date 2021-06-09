public with sharing class DTSFPART_LWC_Attachments {
  @AuraEnabled
  public static List<Attachment_File_Extensions__mdt> getFileExtensionsDefaults() {
      return [
        SELECT
          HEX_Signature__c,
          Is_Active__c,
          Extensions__c,
          Max_File_Size__c,
          Max_Number_Of_Files__c
        FROM Attachment_File_Extensions__mdt
        WHERE Is_Active__c = :true
        LIMIT 1
      ];
  }

  // @AuraEnabled
  // public static Boolean isValidFile(String hexBody) {
  //   Boolean isValid = false;
  //   Attachment_File_Extensions__mdt settings = [
  //       SELECT
  //         HEX_Signature__c,
  //         Is_Active__c,
  //         Extensions__c,
  //         Max_File_Size__c,
  //         Max_Number_Of_Files__c
  //       FROM Attachment_File_Extensions__mdt
  //       WHERE Is_Active__c = :true
  //       LIMIT 1
  //   ];
  //   // String hexBody = EncodingUtil.convertToHex(EncodingUtil.base64Decode(fileContent));
  //   for(String signature : settings.HEX_Signature__c.split(', ')) {
  //     if(hexBody.tolowerCase().startsWith(signature.tolowerCase())) {
  //       isValid = true;                 
  //     }
  //   }
  //   return isValid;
  // }
}