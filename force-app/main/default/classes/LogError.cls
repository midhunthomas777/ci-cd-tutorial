/**
 * @author		Paweł Woźniak
 * @created		2020-10-07
 * @updated		2021-03-21
 * Class for easier errors saving to LogForAllErrors__c.
 * It was updated to use platform Events instead of Future method but old method names was keept for compatibility. 
 */

public without sharing class LogError {

    // Values for picklist Type__c
    public static final String TYPE_INFO = 'Info';
    public static final String TYPE_ERROR = 'Error';
    public static final String TYPE_EXCEPTION = 'Exception';

    /** 
     *  Save Info.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     *  @return recordId of saved LogForAllErrors__c record. May be used in error message visible to user.
     */
    
    public static Id saveInfo(String moduleName, String shortDescription, String fullDescription) {
        return saveToErrorLog(TYPE_INFO, moduleName, shortDescription, fullDescription, null, null);
    }

    /** 
     *  Save Info Async.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     */
    @future
    public static void saveInfoFuture(String moduleName, String shortDescription, String fullDescription) {
        saveToErrorLog(TYPE_INFO, moduleName, shortDescription, fullDescription, null, null);
    }

    /** 
     *  Save Info with Platform event.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     *  @return PlatformEvent Request Id which is also saved in LogForAllErrors__c.RequestId__c. Ask user to pass this id to support for easier error tracking.
     */
    public static String saveInfoPEvent(String moduleName, String shortDescription, String fullDescription) {
        return saveToErrorLogPE(TYPE_INFO, moduleName, shortDescription, fullDescription, null, null);
    }

    /** 
     *  Save Error.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     *  @return recordId of saved LogForAllErrors__c record. May be used in error message visible to user.
     */
    public static Id saveError(String moduleName, String shortDescription, String fullDescription) {
        return saveToErrorLog(TYPE_ERROR, moduleName, shortDescription, fullDescription, null, null);
    }

    /** 
     *  Save Error Async.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     */
    @future
    public static void saveErrorFuture(String moduleName, String shortDescription, String fullDescription) {
        saveToErrorLog(TYPE_ERROR, moduleName, shortDescription, fullDescription, null, null);
    }

    /** 
     *  Save Error with Platform Event.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     *  @return PlatformEvent Request Id which is also saved in LogForAllErrors__c.RequestId__c. Ask user to pass this id to support for easier error tracking.
     */
    public static String saveErrorPEvent(String moduleName, String shortDescription, String fullDescription) {
        return saveToErrorLogPE(TYPE_ERROR, moduleName, shortDescription, fullDescription, null, null);
    }

    /**
     *  Save Http request error. It will extract the most important information for you and save it to a full description field.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 200 characters. At the end of string there will be status added. Example: 404 Not Found.
     *  @param httpRequest pass here HttpRequest type vriable.
     *  @param httpResponse pass here HttpResponse type variable.
     *  @return recordId of saved LogForAllErrors__c record. May be used in error message visible to user.
     */
    public static Id saveHttpError(String moduleName, String shortDescription, HttpRequest httpRequest, HttpResponse httpResponse) {
        if(httpResponse != null) {
            shortDescription += ' Status: ' + httpResponse.getStatusCode() + ' ' + httpResponse.getStatus();
        }
        String fullDescription = parseHttpRequests(httpRequest, httpResponse);

        return saveToErrorLog(TYPE_ERROR, moduleName, shortDescription, fullDescription, null, null);
    }

    /** 
     *  Save Exception.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     *  @param exc catched exception from try-catch
     *  @return recordId of saved LogForAllErrors__c record. May be used in error message visible to user.
     */
    public static Id saveException(String moduleName, String shortDescription, String fullDescription, Exception exc) {
        String exceptionType = exc == null ? '*Exception was null*' : exc.getTypeName();
        String exceptionAsString = exc == null ? '*Exception was null*' : formatException(exc);
        return saveToErrorLog(TYPE_EXCEPTION, moduleName, shortDescription, fullDescription, exceptionType, exceptionAsString);
    }

    /** 
     *  Save Exception Async.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     *  @param exc catched exception from try-catch
     */
    public static void saveExceptionFuture(String moduleName, String shortDescription, String fullDescription, Exception exc) {
        String exceptionType = exc == null ? '*Exception was null*' : exc.getTypeName();
        String exceptionAsString = exc == null ? '*Exception was null*' : formatException(exc);
        saveToErrorLogFuture(TYPE_EXCEPTION, moduleName, shortDescription, fullDescription, exceptionType, exceptionAsString);
    }

    /** 
     *  Save Exception with Platform Event.
     *  @param moduleName name of class and method like: myClass.method()
     *  @param shortDescription describe issue in maximum 255 characters. Used in ListView for filtering.
     *  @param fullDescription up to 131072 characters. Put here all usefull information that will help during debugging.
     *  @param exc catched exception from try-catch
     *  @return PlatformEvent Request Id which is also saved in LogForAllErrors__c.RequestId__c. Ask user to pass this id to support for easier error tracking.
     */
    public static String saveExceptionPEvent(String moduleName, String shortDescription, String fullDescription, Exception exc) {
        String exceptionType = exc == null ? '*Exception was null*' : exc.getTypeName();
        String exceptionAsString = exc == null ? '*Exception was null*' : formatException(exc);
        return saveToErrorLogPE(TYPE_EXCEPTION, moduleName, shortDescription, fullDescription, exceptionType, exceptionAsString);
    }

    /** Helpers **/

    // Save Error record

    @future
    private static void saveToErrorLogFuture(String eventType, String moduleName, String shortDescription, String fullDescription, String excType, String excBody) {
        saveToErrorLog(eventType, moduleName, shortDescription, fullDescription, excType, excBody);
    }

    private static Id saveToErrorLog(String eventType, String moduleName, String shortDescription, String fullDescription, String excType, String excBody) {

        LogForAllErrors__c errorLogRecord = new LogForAllErrors__c();
        errorLogRecord.Type__c = eventType;
        errorLogRecord.ModuleCreatingError__c = moduleName?.left(250);
        errorLogRecord.Short_Error_Description__c = String.isBlank(shortDescription) ? '*Short Desciption was empty*' : shortDescription?.left(250);
        errorLogRecord.ErrorString__c = String.isBlank(fullDescription) ? '*Full Description was empty*' : fullDescription;
        errorLogRecord.OwnerId = UserInfo.getUserId();

        if (eventType == TYPE_EXCEPTION) {
            errorLogRecord.Exception_Type_Name__c = excType?.left(100);
            errorLogRecord.Exception_Details__c = excBody;
        }

        errorLogRecord.quiddity__c = Request.getCurrent().getQuiddity().name();
        errorLogRecord.Request_Id__c = Request.getCurrent().getRequestId();

        Database.SaveResult sr = Database.insert(errorLogRecord);
        if (sr.isSuccess()) {
            System.debug(Logginglevel.ERROR, '## LogError.cls >>> Saved in LogForAllErrors__c with Id: ' + errorLogRecord.Id + ', Request ID: ' + errorLogRecord.Request_Id__c);
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug(Logginglevel.ERROR, '## LogError.cls >>> Error in saving record: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        }  

        System.debug(Logginglevel.ERROR, '## LogError.cls >>> Module: ' + errorLogRecord.ModuleCreatingError__c + ' \r\nShort description: ' + errorLogRecord.Short_Error_Description__c);
        System.debug(Logginglevel.ERROR, '## LogError.cls >>> Full description:\r\n' + errorLogRecord.ErrorString__c);
        System.debug(Logginglevel.ERROR, '## LogError.cls >>> Exception details:\r\n' + errorLogRecord.Exception_Details__c);
        return errorLogRecord.Id;
    }

    // Save using platform event
    private static String saveToErrorLogPE(String eventType, String moduleName, String shortDescription, String fullDescription, String excType, String excBody) {

        LogEvent__e errorLogEvent = new LogEvent__e();
        errorLogEvent.Type__c = eventType;
        errorLogEvent.ModuleCreatingError__c = moduleName?.left(250);
        errorLogEvent.Short_Error_Description__c = String.isBlank(shortDescription) ? '*Short Desciption was empty*' : shortDescription?.left(250);
        errorLogEvent.ErrorString__c = String.isBlank(fullDescription) ? '*Full Description was empty*' : fullDescription;
        errorLogEvent.OwnerId__c = UserInfo.getUserId();
        
        if (eventType == TYPE_EXCEPTION) {
            errorLogEvent.Exception_Type_Name__c = excType?.left(100);
            errorLogEvent.Exception_Details__c = excBody;
        }

        errorLogEvent.quiddity__c = Request.getCurrent().getQuiddity().name();
        errorLogEvent.Request_Id__c = Request.getCurrent().getRequestId();

        Database.SaveResult sr = EventBus.publish(errorLogEvent);
        if (sr.isSuccess()) {
            System.debug(Logginglevel.ERROR, '## LogError.cls >>> Published Platform Event, Request ID: ' + errorLogEvent.Request_Id__c);
        } else {
            for(Database.Error err : sr.getErrors()) {
                System.debug(Logginglevel.ERROR, '## LogError.cls >>> Error during event publishing: ' + err.getStatusCode() + ' - ' + err.getMessage());
            }
        }

        System.debug(Logginglevel.ERROR, '## LogError.cls >>> Module: ' + errorLogEvent.ModuleCreatingError__c + ' \r\nShort description: ' + errorLogEvent.Short_Error_Description__c);
        System.debug(Logginglevel.ERROR, '## LogError.cls >>> Full description:\r\n' + errorLogEvent.ErrorString__c);
        System.debug(Logginglevel.ERROR, '## LogError.cls >>> Exception details:\r\n' + errorLogEvent.Exception_Details__c);
        return errorLogEvent.Request_Id__c;

    }

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_exception_methods.htm
    private static String formatException(Exception e) {
        if (e == null) {
            return null;
        }

        String exceptionDetails = '';
        exceptionDetails = exceptionDetails + 'Type: ' + e.getTypeName();
        exceptionDetails = exceptionDetails + '\r\nCause: ' + e.getCause();
        exceptionDetails = exceptionDetails + '\r\nStackTrace: ' + e.getStackTraceString();
        exceptionDetails = exceptionDetails + '\r\nMessage: ' + e.getMessage();

        if (e.getTypeName() == 'System.DmlException' || e.getTypeName() == 'System.EmailException') {
            for (Integer i = 0; i<e.getNumDml(); i++) {
                exceptionDetails += '\r\n\r\n### Record number: ' + i + ' ###';
                exceptionDetails += '\r\nDmlFieldNames: ' + e.getDmlFieldNames(i);
                exceptionDetails += '\r\nDmlFields: ' + e.getDmlFields(i);
                exceptionDetails += '\r\nDmlId: ' + e.getDmlId(i);
                exceptionDetails += '\r\nDmlIndex: ' + e.getDmlIndex(i);
                exceptionDetails += '\r\nDmlMessage: ' + e.getDmlMessage(i);
                exceptionDetails += '\r\nDmlStatusCode: ' + e.getDmlStatusCode(i);
                exceptionDetails += '\r\nDmlType: ' + e.getDmlType(i);
            }
        }
        return exceptionDetails;
    }

    /**
     *  @param request pass here HttpRequest type vriable.
     *  @param response pass here HttpResponse type variable.
     *
     * @return Parsed request and response values in form of full description
     */
    public static String parseHttpRequests(HttpRequest request, HttpResponse response){
        String responseStatus = '';
        String httpRequestFormatted = '';
        String httpResponseFormatted = '';

        if (request != null) {
            httpRequestFormatted += 'Endpoint: ' + request.getEndpoint() + ', Method: ' + request.getMethod();
            httpRequestFormatted += '\r\nContent-Type: ' + request?.getHeader('Content-Type');
            httpRequestFormatted += '\r\nRequest body: ' + request?.getBody();
        } else {
            httpRequestFormatted = '*Request argument was null*';
        }

        if (response != null) {
            responseStatus = 'Status: ' + response.getStatusCode() + ' ' + response.getStatus();
            httpResponseFormatted += responseStatus;

            if(!response.getHeaderKeys().isEmpty()){
                httpResponseFormatted += '\r\n Response Headers:';
                for(String key: response.getHeaderKeys()){
                    httpResponseFormatted += '\r\n' + key + ' = ' + response.getHeader(key);
                }
            }

            if(response?.getBody()?.length() > 131072){ // fix maximum line width
                httpResponseFormatted += '\r\nResponse body: ' + response?.getBody()?.substring(0, 131055);
            } else {
                httpResponseFormatted += '\r\nResponse body: ' + response?.getBody();
            }
        } else {
            httpResponseFormatted = '*Response argument was null*';
        }

        return  '### Request ###\r\n' + httpRequestFormatted + '\r\n### Response ###\r\n' + httpResponseFormatted;
    }

}