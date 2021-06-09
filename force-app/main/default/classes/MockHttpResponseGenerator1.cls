@isTest
global class MockHttpResponseGenerator1 implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/XML');
        res.setBody('<GeocodeResponse><status>OK</status><result><type>street_address</type><formatted_address>1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA</formatted_address><address_component><long_name>1600</long_name><short_name>16</short_name><type>street_number</type></address_component><address_component><long_name>Amphitheatre Pkwy</long_name><short_name>Amphitheatre Pkwy</short_name><type>route</type></address_component><address_component><long_name>Mountain View</long_name><short_name>Mountain View</short_name><type>locality</type><type>political</type></address_component><address_component><long_name>San Jose</long_name><short_name>San Jose</short_name><type>administrative_area_level_3</type><type>political</type></address_component><address_component><long_name>Santa Clara</long_name><short_name>Santa Clara</short_name><type>administrative_area_level_2</type><type>political</type></address_component><address_component><long_name>California</long_name><short_name>CA</short_name><type>administrative_area_level_1</type><type>political</type></address_component><address_component><long_name>United States</long_name><short_name>US</short_name><type>country</type><type>political</type></address_component><address_component><long_name>94043</long_name><short_name>94043</short_name><type>postal_code</type></address_component><geometry><location><lat>37.4217550</lat><lng>-122.0846330</lng></location><location_type>ROOFTOP</location_type><viewport><southwest><lat>37.4188514</lat><lng>-122.0874526</lng></southwest><northeast><lat>37.4251466</lat><lng>-122.0811574</lng></northeast></viewport></geometry><place_id>ChIJ2eUgeAK6j4ARbn5u_wAGqWA</place_id></result></GeocodeResponse>');
        res.setStatusCode(200);
        return res;
    }
}