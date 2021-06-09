/**
 * @author		Paweł Woźniak
 * @created		2020-10-07
 * @updated		2021-03-22
 * @isTesting   LogError
 * @description
 */

@IsTest
public class LogError_Test {

    public static final String TOO_LONG = 'afsssssssssssssssssssssssrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr110' +
                                          'afsssssssssssssssssssssssrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr110tttdttttttttttttttttttttttttttttttttt150';

    @IsTest
    private static void test_saveInfo() {
        Test.startTest();
        LogError.saveInfo('ErrorLog_Test.test_saveInfo()', 'Short desc for info', 'Long desc for info');
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals(LogError.TYPE_INFO, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveInfo()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Short desc for info', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for info', errorLogRecords[0].ErrorString__c);
    }

    @IsTest
    private static void test_saveInfoFuture() {
        Test.startTest();
        LogError.saveInfoFuture('ErrorLog_Test.test_saveInfoFuture()', 'Short desc for info Future', 'Long desc for info Future');
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals(LogError.TYPE_INFO, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveInfoFuture()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Short desc for info Future', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for info Future', errorLogRecords[0].ErrorString__c);
    }

    @IsTest
    private static void test_saveInfoPEvent() {
        Test.startTest();
        LogError.saveInfoPEvent('ErrorLog_Test.test_saveInfoPEvent()', 'Short desc for info PEvent', 'Long desc for info PEvent');
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c, quiddity__c, Request_Id__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals(LogError.TYPE_INFO, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveInfoPEvent()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Short desc for info PEvent', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for info PEvent', errorLogRecords[0].ErrorString__c);
        System.assert(!String.isBlank(errorLogRecords[0].quiddity__c), 'Quiddity should not be empty!');
        System.assert(!String.isBlank(errorLogRecords[0].Request_Id__c), 'Request Id should not be empty!');
    }

    @IsTest
    private static void test_saveError() {
        Test.startTest();
        LogError.saveError('ErrorLog_Test.test_saveError()', 'Short desc for error', 'Long desc for error');
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals(LogError.TYPE_ERROR, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveError()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Short desc for error', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for error', errorLogRecords[0].ErrorString__c);
    }

    @IsTest
    private static void test_saveErrorFuture() {
        Test.startTest();
        LogError.saveErrorFuture('ErrorLog_Test.test_saveErrorFuture()', 'Short desc for error Future', 'Long desc for error Future');
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals(LogError.TYPE_ERROR, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveErrorFuture()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Short desc for error Future', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for error Future', errorLogRecords[0].ErrorString__c);
    }

    @IsTest
    private static void saveErrorPEvent() {
        Test.startTest();
        LogError.saveErrorPEvent('ErrorLog_Test.test_saveErrorPEvent', 'Short desc for error PEvent', 'Long desc for error PEvent');
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c, quiddity__c, Request_Id__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals(LogError.TYPE_ERROR, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveErrorPEvent()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Short desc for error PEvent', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for error PEvent', errorLogRecords[0].ErrorString__c);
        System.assert(!String.isBlank(errorLogRecords[0].quiddity__c), 'Quiddity should not be empty!');
        System.assert(!String.isBlank(errorLogRecords[0].Request_Id__c), 'Request Id should not be empty!');
    }

    @IsTest
    private static void test_saveHttpError() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LogError_Test.httpErrorMock(404));
        Id logId = null;

        String endPoint_URL = 'www.example.com/API/v1/account';
        String method = 'POST';

        Http httpCallout = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint_URL);
        request.setMethod(method);

        HttpResponse response = httpCallout.send(request);

        if (response.getStatusCode() == 200) {
            // Process response
        } else {
            logId = LogError.saveHttpError('ErrorLog_Test.test_saveHttpError()', 'Log for failed request.', request, response);
        }

        Test.stopTest();

        LogForAllErrors__c logRecord = [SELECT Id, Short_Error_Description__c, ErrorString__c FROM LogForAllErrors__c WHERE Id = :logId];
        System.assertEquals('Log for failed request. Status: 404 Bad Request', logRecord.Short_Error_Description__c);
        System.assert (logRecord.ErrorString__c.contains('### Request ###'));
        System.assert (logRecord.ErrorString__c.contains('### Response ###'));
    }

    @isTest
    private static void test_saveHttpError_nullValues() {
        Test.startTest();
        Id logId = LogError.saveHttpError('ErrorLog_Test.test_saveHttpError_nullValues()', 'Log for failed request.', null, null);
        Test.stopTest();

        LogForAllErrors__c logRecord = [SELECT Id, Short_Error_Description__c, ErrorString__c FROM LogForAllErrors__c WHERE Id = :logId];
        System.assertEquals('Log for failed request.', logRecord.Short_Error_Description__c);
        System.assert (logRecord.ErrorString__c.contains('### Request ###'));
        System.assert (logRecord.ErrorString__c.contains('*Request argument was null*'));
        System.assert (logRecord.ErrorString__c.contains('### Response ###'));
        System.assert (logRecord.ErrorString__c.contains('*Response argument was null*'));
    }

    @IsTest
    private static void test_saveException() {
        Test.startTest();
        try {
            Account a = new Account();
            a.Name = TOO_LONG;
            insert a;
        }
        catch (Exception e) {
            LogError.saveException('ErrorLog_Test.test_saveException()', 'Testing for too long name error', 'Long desc for exception', e);
        }
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c, Exception_Type_Name__c, Exception_Details__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Should save');
        System.assertEquals(LogError.TYPE_EXCEPTION, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveException()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Testing for too long name error', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for exception', errorLogRecords[0].ErrorString__c);
        System.assertEquals('System.DmlException', errorLogRecords[0].Exception_Type_Name__c);
        System.assert (errorLogRecords[0].Exception_Details__c.contains('DmlStatusCode: STRING_TOO_LONG'));
    }

    @IsTest
    private static void test_saveExceptionFuture() {
        Test.startTest();
        try {
            Account a = new Account();
            a.Name = TOO_LONG;
            insert a;
        }
        catch (Exception e) {
            LogError.saveExceptionFuture('ErrorLog_Test.test_saveExceptionFuture()', 'Testing for too long name error Future', 'Long desc for exception Future', e);
        }
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c, Exception_Type_Name__c, Exception_Details__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Should save');
        System.assertEquals(LogError.TYPE_EXCEPTION, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveExceptionFuture()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Testing for too long name error Future', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for exception Future', errorLogRecords[0].ErrorString__c);
        System.assertEquals('System.DmlException', errorLogRecords[0].Exception_Type_Name__c);
        System.assert (errorLogRecords[0].Exception_Details__c.contains('DmlStatusCode: STRING_TOO_LONG'));
    }

    @IsTest
    private static void test_saveExceptionPEvent() {
        Test.startTest();
        try {
            Account a = new Account();
            a.Name = TOO_LONG;
            insert a;
        }
        catch (Exception e) {
            LogError.saveExceptionPEvent('ErrorLog_Test.test_saveExceptionPEvent()', 'Testing for too long name error PEvent', 'Long desc for exception PEvent', e);
        }
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c, quiddity__c, Request_Id__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals(LogError.TYPE_EXCEPTION, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveErrorPEvent()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('Testing for too long name error PEvent', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('Long desc for exception PEvent', errorLogRecords[0].ErrorString__c);
        System.assert(!String.isBlank(errorLogRecords[0].quiddity__c), 'Quiddity should not be empty!');
        System.assert(!String.isBlank(errorLogRecords[0].Request_Id__c), 'Request Id should not be empty!');
    }

    @IsTest
    private static void test_saveNullException() {
        Test.startTest();
        LogError.saveException('ErrorLog_Test.test_saveException()', null, null, null);
        Test.stopTest();

        List<LogForAllErrors__c> errorLogRecords = [SELECT Id, Type__c, ModuleCreatingError__c, Short_Error_Description__c, ErrorString__c, Exception_Type_Name__c, Exception_Details__c FROM LogForAllErrors__c];
        System.assertEquals(1, errorLogRecords.size(), 'Missing record');
        System.assertEquals(LogError.TYPE_EXCEPTION, errorLogRecords[0].Type__c);
        System.assertEquals('ErrorLog_Test.test_saveException()', errorLogRecords[0].ModuleCreatingError__c);
        System.assertEquals('*Short Desciption was empty*', errorLogRecords[0].Short_Error_Description__c);
        System.assertEquals('*Full Description was empty*', errorLogRecords[0].ErrorString__c);
        System.assertEquals('*Exception was null*', errorLogRecords[0].Exception_Type_Name__c);
        System.assertEquals('*Exception was null*', errorLogRecords[0].Exception_Details__c);
    }

    // Not in a separate class to keep it as an independent module resistant for other changes.
    public class httpErrorMock implements HttpCalloutMock {

        Integer returnCode;

        public httpErrorMock(Integer returnCode) {
            this.returnCode = returnCode;
        }

        // 404 Not Found
        public HTTPResponse respond(HTTPRequest req) {
            if (returnCode == 404) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"error":{"message":"Not Found"},"success":false}');
                res.setStatusCode(returnCode);
                res.setStatus('Bad Request');
                return res;
            }

            System.debug('##### ^^^ Returning null from mock class. Something went wrong, check your code. ^^^ ######');
            return null;
        }

    }
}