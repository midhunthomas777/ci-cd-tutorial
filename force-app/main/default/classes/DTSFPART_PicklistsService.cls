public class DTSFPART_PicklistsService {
  public static String platformCacheKey = null;

  public static DTSFPART_PicklistsWrapper.PicklistWrapper getObjectFieldPicklistValuesBasedOnRTAndCacheIt(
    String objectName,
    String fieldName,
    Id recordTypeId
  ) {
    try {
      createAndSetCacheKey(objectName, fieldName, recordTypeId);

      DTSFPART_PicklistsWrapper.PicklistWrapper picklistValues = getPicklistValuesFromCache();

      if (picklistValues != null) {
        return picklistValues;
      }

      picklistValues = getPicklistValuesByUiObjectInfoApi(
        objectName,
        fieldName,
        recordTypeId
      );

      cachePicklistWrapper(JSON.serialize(picklistValues));

      return picklistValues;
    } catch (Exception e) {
      return null;
    }
  }

  private static void createAndSetCacheKey(
    String objectName,
    String fieldName,
    Id recordTypeId
  ) {
    platformCacheKey = (objectName + fieldName + recordTypeId).remove('_');
  }

  private static DTSFPART_PicklistsWrapper.PicklistWrapper getPicklistValuesFromCache() {
    String picklistValuesFromCacheJSON = (String) Cache.Org.getPartition(
        'local.PicklistValues'
      )
      .get(platformCacheKey);

    if (!String.isBlank(picklistValuesFromCacheJSON)) {
      return (DTSFPART_PicklistsWrapper.PicklistWrapper) JSON.deserialize(
        picklistValuesFromCacheJSON,
        DTSFPART_PicklistsWrapper.PicklistWrapper.class
      );
    }

    return null;
  }

  private static DTSFPART_PicklistsWrapper.PicklistWrapper getPicklistValuesByUiObjectInfoApi(
    String objectName,
    String fieldName,
    Id recordTypeId
  ) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();

    request.setEndpoint(
      URL.getOrgDomainUrl().toExternalForm() +
      '/services/data/v51.0/ui-api/object-info/' +
      objectName +
      '/picklist-values/' +
      recordTypeId +
      '/' +
      fieldName
    );
    request.setMethod('GET');
    request.setHeader(
      'Authorization',
      'Bearer ' + DTSFPART_Utils.fetchUserSessionId()
    );

    try {
      HttpResponse response = http.send(request);
      System.debug('response' + response.getStatusCode());
      if (response.getStatusCode() == 200) {
        System.debug('response' + response.getBody());
        return (DTSFPART_PicklistsWrapper.PicklistWrapper) JSON.deserialize(
          response.getBody(),
          DTSFPART_PicklistsWrapper.PicklistWrapper.class
        );
      }
    } catch (System.CalloutException ex) {
      System.debug('Error:' + ex.getMessage());
    }

    return null;
  }

  private static void cachePicklistWrapper(String picklistValuesJSON) {
    Cache.Org.getPartition('local.PicklistValues')
      .put(platformCacheKey, picklistValuesJSON, 86400);
  }
}