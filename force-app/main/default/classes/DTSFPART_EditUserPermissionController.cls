public class DTSFPART_EditUserPermissionController {
  @AuraEnabled
  public static Map<String, DTSFPART_PicklistsWrapper.PicklistWrapper> getContactPicklistsValuesBasedOnRecordTypeId(
    Id recordTypeId,
    List<String> fieldsNames
  ) {
    try {
      Map<String, DTSFPART_PicklistsWrapper.PicklistWrapper> fieldNameToPicklistValues = new Map<String, DTSFPART_PicklistsWrapper.PicklistWrapper>();
      System.debug('recordTypeId: ' + recordTypeId);
      System.debug('fieldsNames: ' + fieldsNames);
      for (String fieldName : fieldsNames) {
        fieldNameToPicklistValues.put(
          fieldName,
          getContactFieldPicklistValues(fieldName, recordTypeId)
        );
      }
      System.debug('fieldNameToPicklistValues: ' + fieldNameToPicklistValues);
      return fieldNameToPicklistValues;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static DTSFPART_PicklistsWrapper.PicklistWrapper getContactFieldPicklistValues(
    String fieldApi,
    Id recordTypeId
  ) {
    return DTSFPART_PicklistsService.getObjectFieldPicklistValuesBasedOnRTAndCacheIt(
      Contact.sObjectType.getDescribe().getName(),
      fieldApi,
      recordTypeId
    );
  }
}