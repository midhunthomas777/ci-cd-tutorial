/**
* @author Gurditta Garg
* @date Nov 2019
*
* @group Middleware
* @group-content ../../Mulesoft/mulesoft.htm
*
* @description Controller for hitting Mulesoft APIs, has different flavours of methods as per the needs. Uses Mulesoft Custom Metadata for API end points with
* combination of Named Credentials and Auth. Provider in case of Oauth
*/
public without sharing class MulesoftHelper {
    
    /*******************************************************************************************************
    * @description Returns response from Mulesoft API, using Mulesoft Metadata
    * @param params parameters to append in the URL if any, mostly being used for GET request but can be used for POST request too 
    * e.g. molorderhistory/v3.0?oam_session=b2b_sit@mailinator.com
    * @param payload payload param which contains payload of the request
    * @param metaAPIName Custom Metadata API name which has config of the End Point
    * @param namedCredentialName Connection detail with Mulesoft, has only two options 1. Mulesoft (uses Basic AUth) 2. Mulesoft_Oauth
    * @return response from API
    */
    public static HTTPAPIResponse callMuleByMetadata(String params, String payload, String metaAPIName, String namedCredentialName) {
        HttpResponse res ;
        HTTPAPIResponse serResponse = new HTTPAPIResponse();
        try {
            List<Mulesoft__mdt> metadatas = [Select Id,Content_Type__c,Endpoint__c,Method_Type__c from Mulesoft__mdt where DeveloperName =: metaAPIName];
            HttpRequest request = new HttpRequest();
            if(!metadatas.isEmpty()) {
                Mulesoft__mdt metadata = metadatas.get(0);
                if(params != NULL && String.isNotBlank(params)) {
                    request.setEndpoint('callout:' + namedCredentialName + '/' + metadata.Endpoint__c + params);   
                } else {
                    request.setEndpoint('callout:' + namedCredentialName + '/' + metadata.Endpoint__c);
                }
                request.setMethod(metadata.Method_Type__c);
                request.setHeader('Content-Type', metadata.Content_Type__c);
                if(payload != NULL && String.isNotBlank(payload)) {
                    request.setBody(payload);   
                }
                request.setTimeout(120000);
            } else {
                System.debug('Metadata of the API does not exist => ' + metaAPIName);
                serResponse.errorMsg = 'ERROR';
            }
            Http http = new Http();
            System.debug('#####request######## => ' + request);
            res = http.send(request);
            serResponse.response = res;
            serResponse.responseStatus = res.getStatusCode();
            serResponse.errorMsg = '';
        } catch (Exception ex){
            serResponse.response = res;
            serResponse.responseStatus = (res!=NULL ? res.getStatusCode() : 400);
            serResponse.errorMsg = ex.getMessage();
        }
        System.debug('#####serResponse######## => ' + serResponse);
        return serResponse;
    }
}