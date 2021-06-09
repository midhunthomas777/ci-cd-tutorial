@isTest
global class LMSMockResponseCompletedWS implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        //res.setBody('{"items":[{"bndl_title": "EWWTP0001 - WLAN Technical Professional","crsw_course_title": "WEL2307 - Design a WLAN Solution (EMEA)","bndlcnt_required": "T","crsw_number": "WEL2307","bndl_bundle_id": "0B0E70BD94E443CC80A28EE9E543A202","bndlcnt_content_id": "182F01BB91F64DA28D844CEB7A0FF219","bndlcnt_optional_order": 3,"usr_login_id": "JLGRANDE@MOINSA.ES","bundle_status": "NotStarted","usr_lms_user_id": "55393F52B4214C598EA251800A032DAD","bundle_active": "1","bndl_req_optional_content": 1}]}');
        res.setBody('{"items":[{"bndl_title": "EMFTC0002 - Product Access Mobility Solutions Platform","bndl_bundle_id": "F9B2C967FA114928A6BAEA6B1C654D9A","usr_lms_user_id": "55393F52B4214C598EA251800A032DAD","bundle_status": "Completed","bundle_complete_date": "2013-06-06T13:09:15Z","usr_login_id": "JLGRANDE@MOINSA.ES","bundle_active": "1","certificate_code": "EMFTC0002","segment_designator": "RFID","audience_designator": "Technical","level_designator": "Product Access"}]}');
        res.setStatusCode(200);
        return res;
    }
}