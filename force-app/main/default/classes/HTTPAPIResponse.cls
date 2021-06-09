public class HTTPAPIResponse {
    /**
    * @description errorMsg to hold the value error message HTTP/exception message
    */
    @AuraEnabled
    public string errorMsg{get;set;}
    
    /**
    * @description responseStatus to hold status of response
    */
    @AuraEnabled
    public integer responseStatus{get;set;}
    
    /**
    * @description response is to hold the response from HTTPResponse
    */
    @AuraEnabled
    public HTTPResponse response{get;set;}
}