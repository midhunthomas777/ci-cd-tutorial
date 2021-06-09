@isTest
public class DTSFPART_EditUserPermissionCtrlTest {

    public static final String TAG_FIELD = Schema.Contact.Tag__c.getDescribe().getName();
    public static final Id RECORDTYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MPE_Partner_Contact').getRecordTypeId();

    @isTest
    private static void getObjectFieldPicklistValuesBasedOnRTAndCacheItSuccessTest() {
        Map<String,DTSFPART_PicklistsWrapper.PicklistWrapper> responseMap = null;

        DTSFPART_PicklistsWrapper.PicklistWrapper response = new DTSFPART_PicklistsWrapper.PicklistWrapper();
        DTSFPART_PicklistsWrapper.Values responsePicklistValues = new DTSFPART_PicklistsWrapper.Values();

        responsePicklistValues.label = 'Test';
        responsePicklistValues.value = 'Test';

        response.values = new List<DTSFPART_PicklistsWrapper.Values>{responsePicklistValues};

        Test.setMock(HttpCalloutMock.class, new DTSFPART_PicklistsServiceMock(200, JSON.serialize(response)));
        Test.startTest();
            responseMap = DTSFPART_EditUserPermissionController.getContactPicklistsValuesBasedOnRecordTypeId(RECORDTYPE_ID, new List<String>{TAG_FIELD});
        Test.stopTest();

        System.assert(responseMap.get(TAG_FIELD) != null);
    }

    @isTest
    private static void getObjectFieldPicklistValuesBasedOnRTAndCacheItFailureTest() {
        Map<String,DTSFPART_PicklistsWrapper.PicklistWrapper> responseMap = null;

        DTSFPART_PicklistsWrapper.PicklistWrapper response; //bad response

        Test.setMock(HttpCalloutMock.class, new DTSFPART_PicklistsServiceMock(200, JSON.serialize(response)));
        Test.startTest();
            responseMap = DTSFPART_EditUserPermissionController.getContactPicklistsValuesBasedOnRecordTypeId(RECORDTYPE_ID, new List<String>{TAG_FIELD});
        Test.stopTest();

        System.assert(responseMap.get(TAG_FIELD) == null);
    }
}