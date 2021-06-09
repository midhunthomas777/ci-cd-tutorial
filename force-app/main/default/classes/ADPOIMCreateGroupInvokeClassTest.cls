/*  
* File Name     : ADPOIMCreateGroupInvokeClassTest
* Description   : Test class for ADPOIMCreateGroupInvokeClass
* Modification Log
* =============================================================================
*   Ver     Date         Author                      Modification
*------------------------------------------------------------------------------
*   1.0     1-Jan-17    Poongodi V                  Initial Creation
*/
@isTest
public class ADPOIMCreateGroupInvokeClassTest{

@testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
public class MockHttpResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest request) 
        {   
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
          //  if(request.getbody().contains('{"name":"dev-TestClass7","path":"dev-TestClass7","description":"ok","visibility_level":"10"}'))
                response.setBody('{"id":7}');
            response.setStatusCode(200);
            return response;
        }
    }
    
     

private static testMethod void doTest() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();  
       
        ADP_Global_Account_Name__c l = new ADP_Global_Account_Name__c (Name = 'TestClass7');
        insert l;

        ADPOIMCreateGroupInvokeClass.InsertRecord(New Id[]{l.id});
        ADPOIMCreateGroupInvokeClass.ParserMethodCreateGroup('{"id":7}');
        
    Test.stopTest();
}
    
private static testMethod void doTest1() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();  
       
        ADP_Global_Account_Name__c l = new ADP_Global_Account_Name__c (Name = 'TestClass7');
        insert l;
        ADPOIMCreateGroupInvokeClass.callCreateGroup('',String.valueOf(l.id));
        
    Test.stopTest();
}
}