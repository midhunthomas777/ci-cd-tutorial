@isTest
public class DTSFPART_CustomListViewCompCtrlTest {
   
    class ListViewMock implements HttpCalloutMock {
        public Integer code;
        public String requestBody;
        
        public ListViewMock(Integer code, String requestBody) {
            this.code = code;
            this.requestBody = requestBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type', 'application/json');
            resp.setStatusCode(code);
            resp.setBody(requestBody);
    
            return resp;
        }
    }

    @isTest
    private static void fetchUserSessionIdTest() { 
        Test.startTest();
        String sessionId = DTSFPART_Utils.fetchUserSessionId();
        Test.stopTest();

        System.assertNotEquals(null, sessionId);
    }

    @isTest
    private static void getListViewsTest() {
        Test.startTest();
        List<ListView> listView = DTSFPART_CustomListViewCompController.getListViews('Case', new List<String>{'All'});
        Test.stopTest();

        System.assertNotEquals(null, listView);
    }

    @isTest
    private static void getListViewMetadataTest() {
        Test.setMock(HttpCalloutMock.class, new ListViewMock(200, '{ "test": "test" }'));
        Test.startTest();
        String listViewMetadata = DTSFPART_CustomListViewCompController.getListViewMetadata('Case', 'All');
        Test.stopTest();
    }

    @isTest
    private static void getCustomListViewsTest() {
        Test.startTest();
        List<Custom_ListView__mdt> customListViews = DTSFPART_CustomListViewCompController.getCustomListViews(new List<String>{'All_Technical_Cases'});
        Test.stopTest();

        System.assertNotEquals(0, customListViews.size());
    }
}