@isTest
public class NewCAPPControllerMock  implements HttpCalloutMock {
    
    
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        //System.assertEquals('callout:Connect_to_Salesforce/services/data/v48.0/ui-api/object-info/Customer_Portfolio_Presence__c/picklist-values/012e0000000E8KBAA0/BROADBAND_CARRIER__c', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"controllerValues" : { },"defaultValue" : null,"eTag" : "fcf09f41a4c73655d672924d8e54b473","url" : "/services/data/v48.0/ui-api/object-info/Customer_Portfolio_Presence__c/picklist-values/012e0000000E8KBAA0/BROADBAND_CARRIER__c","values" : [ {  "attributes" : null,  "label" : "FirstNet",  "validFor" : [ ],  "value" : "FirstNet"}, {  "attributes" : null,  "label" : "AT&amp;T",  "validFor" : [ ],  "value" : "AT&amp;T"}, {  "attributes" : null,  "label" : "Verizon",  "validFor" : [ ],  "value" : "Verizon"}, {  "attributes" : null,  "label" : "Sprint",  "validFor" : [ ],  "value" : "Sprint"}, {  "attributes" : null,  "label" : "Other",  "validFor" : [ ],  "value" : "Other"} ]}');
        res.setStatusCode(200);
        return res;
    }
}