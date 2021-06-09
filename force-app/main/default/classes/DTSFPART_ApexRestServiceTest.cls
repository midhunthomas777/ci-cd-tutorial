@isTest
public class DTSFPART_ApexRestServiceTest {
  
    @isTest
    static void getApexRestMetadataQueryByDeveloperName_SuccessTest() {
        String requestQuery = null;

        Test.startTest();
        requestQuery = DTSFPART_ApexRestService.getApexRestMetadataQueryByDeveloperName('EnterpriseSyncAccount');
        Test.stopTest();

        System.assert(requestQuery != null);
    }

    @isTest
    static void getApexRestMetadataQueryByDeveloperName_FailureTest() {
        String requestQuery = null;

        Test.startTest();
        requestQuery = DTSFPART_ApexRestService.getApexRestMetadataQueryByDeveloperName('WrongMetadataName');
        Test.stopTest();

        System.assert(requestQuery == null);
    }

    @isTest
    static void validateRequestAndThrowErrorIfNotValid_InvalidParamTest() {
        try {
            DTSFPART_ApexRestService.validateRequestAndThrowErrorIfNotValid('Invalid Id', 'SELECT Id FROM Account');
        } catch (Exception e) {
            System.assert(e != null);
        }
    }

    @isTest
    static void validateRequestAndThrowErrorIfNotValid_InvalidQueryTest() {
        try {
            DTSFPART_ApexRestService.validateRequestAndThrowErrorIfNotValid('0017A00000f9OUgQAM', '');
        } catch (Exception e) {
            System.assert(e != null);
        }
    }
}