@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // String SOAPHeader='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:oasis:names:tc:DSML:2:0:core">   <soapenv:Header>      <urn:soapAuthenticationHeader>         <urn:Username>cn=sfdcprm,ou=Service Accounts,ou=applications,ou=extranet,dc=motorola,dc=com</urn:Username>         <!--Optional:-->         <urn:Password>@SFDCMay2020LDAPService</urn:Password>      </urn:soapAuthenticationHeader>   </soapenv:Header>   ';
       // String  querySoapXML = SOAPHeader + '<soapenv:Body><urn:batchRequest requestID="prm123"><urn:searchRequest requestID="" dn="ou"><urn:attributes><urn:attribute>uid</urn:attribute><urn:attribute>c</urn:attribute><urn:attribute>mail</urn:attribute><urn:attribute>sn</urn:attribute></urn:attributes> <urn:attr name="uid"><urn:value>Y</urn:value></urn:attr></urn:searchRequest></urn:batchRequest></soapenv:Body></soapenv:Envelope>'; 
       // System.assertEquals('http://maps.googleapis.com/maps/api/geocode/xml?address=Test+City%2CIndia&sensor=false', req.getEndpoint());
       // System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        String SOAPHeader='';
        String  querySoapXML = SOAPHeader + ''; 
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(querySoapXML);
        res.setStatusCode(200);
        return res;
    }
}