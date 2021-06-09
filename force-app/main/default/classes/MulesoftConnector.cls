public class MulesoftConnector {
    public static Boolean useFederationId = false;

    // TODO: Remove this method after usage is removed from DTSFPART_CommonComponentsController
    public static Map<String, Object> callMulesoft(String requestBody, String metaAPIName, String namedCredentials) {
        DTSFPART_RequestBuilder builder = new DTSFPART_RequestBuilder(metaAPIName)
                .customCredentials(namedCredentials)
                .withTimeout(60000)
                .withOamSession();

        HttpRequest request = builder.build();
        if (!request.getMethod().equals('GET')){
            request.setBody(requestBody);
        } else {
            if(request.getEndpoint().contains('<recordId>')) {
                request.setEndpoint(request.getEndpoint().replace('<recordId>', requestBody));
            } else if(request.getEndpoint().contains('<userId>')) {
                request.setEndpoint(request.getEndpoint().replace('<userId>', DTSFPART_Utils.getCurrentUserFederationId('', true)) + '&' + requestBody);
            } else {
                request.setEndpoint(request.getEndpoint() + '&' + requestBody);
            }
        }

        return callMulesoft(request);
    }

    public static Map<String, Object> callMulesoft(HttpRequest request){
        System.debug('--callMule: ' + request);
        HttpResponse response;
        Map<String, Object> responseMapping = new Map<String, Object>{
                'ok' => false,
                'body' => 'Exception during callout!'
        }; // allow frontend to throw aura exception

        try {
            response = new Http().send(request);
            responseMapping = handleMulesoftResponse(response);
            if(!(Boolean) responseMapping.get('ok')){
                handleException(request, response);
            }

            return responseMapping;
        }   catch(Exception e) {
            handleException(e, request, response);
        }

        return responseMapping;
    }

    private static Map<String, Object> handleMulesoftResponse(HttpResponse response){
        Integer statusCode = response.getStatusCode();
        String contentTypeHeader = response.getHeader('Content-Type') == null? '': response.getHeader('Content-Type');

        Map<String, String> headers = new Map<String, String>();
        for(String key: response.getHeaderKeys()){
            headers.put(key, response.getHeader(key));
        }

        return new Map<String, Object> {
            'body' => convertToHex(contentTypeHeader)? EncodingUtil.convertToHex(response.getBodyAsBlob()) : response.getBody(),
            'status' => statusCode,
            'statusText' => response.getStatus(),
            'ok' => statusCode >= 200 && statusCode < 300? true: false,
            'location' => response.getHeader('location'),
            'headers' => headers
        };
    }

    private static Boolean convertToHex(String contentType){
        return (contentType.startsWith('application/') && !contentType.startsWith('application/json')) ||
               (contentType.startsWith('image/') && !contentType.startsWith('image/svg+xml'));
    }

    private static void handleException(HttpRequest request, HttpResponse response){
        handleException(null, request, response);
    }

    private static void handleException(Exception e, HttpRequest request, HttpResponse response){
        String shortDescription;
        if(e != null){
            shortDescription = 'Exception during callout, endpoint: ' + request.getEndpoint() + '\r\nMessage: ' + e.getMessage();
        } else {
            shortDescription = 'Error during callout, endpoint: ' + request.getEndpoint();
        }
        shortDescription += '\r\nUser: ' + UserInfo.getUserName() + ' - ' + UserInfo.getUserId();
        if(response != null){
            shortDescription += ' Status: ' + response.getStatusCode() + ' ' + response.getStatus();
        }

        String longDescription = LogError.parseHttpRequests(request, response);
        LogError.saveErrorFuture('Mulesoft', shortDescription, longDescription);
    }
}