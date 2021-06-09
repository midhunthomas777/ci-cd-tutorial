@isTest
public class DTSFPART_PicklistsServiceTest {
    
    public static final String TAG_FIELD = Schema.Contact.Tag__c.getDescribe().getName();
    public static final String CONTACT = Schema.Contact.sObjectType.getDescribe().getName();
    public static final Id RECORDTYPE_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MPE_Partner_Contact').getRecordTypeId();

    @isTest
    private static void getObjectFieldPicklistValuesBasedOnRTAndCacheItSuccessTest() {
        DTSFPART_PicklistsWrapper.PicklistWrapper picklistValues = null;

        DTSFPART_PicklistsWrapper.PicklistWrapper response = new DTSFPART_PicklistsWrapper.PicklistWrapper();
        DTSFPART_PicklistsWrapper.Values responsePicklistValues = new DTSFPART_PicklistsWrapper.Values();

        responsePicklistValues.label = 'Test';
        responsePicklistValues.value = 'Test';
        responsePicklistValues.attributes = 'Test';
        responsePicklistValues.validFor = new List<Integer>{1, 2};

        response.values = new List<DTSFPART_PicklistsWrapper.Values>{responsePicklistValues};
        response.eTag = 'Test';
        response.defaultValue = 'Test';
        response.controllerValues = new Map<String, Integer>{ 'Test' => 1 };

        Test.setMock(HttpCalloutMock.class, new DTSFPART_PicklistsServiceMock(200, JSON.serialize(response)));
        Test.startTest();
            picklistValues = DTSFPART_PicklistsService.getObjectFieldPicklistValuesBasedOnRTAndCacheIt(CONTACT, TAG_FIELD, RECORDTYPE_ID);
        Test.stopTest();

        System.assert(picklistValues != null);
    }

    @isTest
    private static void getObjectFieldPicklistValuesBasedOnRTAndCacheItFailureTest() {
        DTSFPART_PicklistsWrapper.PicklistWrapper picklistValues = null;

        DTSFPART_PicklistsWrapper.PicklistWrapper response; //bad response

        Test.setMock(HttpCalloutMock.class, new DTSFPART_PicklistsServiceMock(200, JSON.serialize(response)));
        Test.startTest();
            picklistValues = DTSFPART_PicklistsService.getObjectFieldPicklistValuesBasedOnRTAndCacheIt(CONTACT, TAG_FIELD, RECORDTYPE_ID);
        Test.stopTest();

        System.assert(picklistValues == null);
    }
}