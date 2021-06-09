@isTest
public class APIPartnerApplicationTriggerHandlerTest {
    @isTest
    public static void TestMethod1(){
        TestDataSetUpUtils.insertCustomSettings();
        Test.startTest();
        USer u = TestDataSetUpUtils.createGuestUser();
        System.RunAs(u){
        API_Partner_Application__c apiPartner = TestDataSetUpUtils.createAPIPartnerAppl();
        API_Partner_Application__c apiPartnerNew = [SELECT Id, Name, Application_Status__c 
                                                    FROM API_Partner_Application__c WHERE Id =: apiPartner.id];
        system.assertEquals('Partner Submitted',apiPartnerNew.Application_Status__c);
        }
        Test.stopTest();
    }
    
}