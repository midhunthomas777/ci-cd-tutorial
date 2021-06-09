@isTest
public class DTSFPART_SubscriptionsControllerTest {
    
    static final String USERNAME = 'test123asdfresdf@noemail.com';

    @TestSetup
    static void setup(){
        TestDataSetUpUtils.insertCustomSettings();
        TestDataSetUpUtils.createLdapSetting();

        UserTriggerHandler.TriggerDisabled = true;
        DTSFPART_ProgramDetailTriggerHandler.TriggerDisabled = true;
        ProgramDetailTriggerHandler.TriggerDisabled = true;

        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();

        Contact cnt = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        cnt.Persona__c = 'SalesManager';
        cnt.Partner_Region__c = 'NAMR';
        cnt.Tag__c = 'LeadAdmin';

        insert cnt;

        Id mcnRecordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Motorola_Customer_Number');
		TestDataSetUpUtils.createMCNAccounts(1, mcnRecordTypeId, new List<Account>{acc});

        User partnerUser = DTSFPART_TestDataSetUpUtils.createPartnerUser(cnt);

        Technology_Specialization__c techspec = [ SELECT Account__c, Technology_Specialization__c 
                                                  FROM Technology_Specialization__c 
                                                  WHERE Account__c = :acc.Id ];

        techspec.Technology_Specialization__c = 'Professional and Commercial Radio';    
        techspec.Technology_Specialization_Status__c = 'Active';
        techspec.Community_Type__c = DTSFPART_SubscriptionsController.SOFTWARE_AND_SOLUTIONS;

        update techspec;

        insert new Technology_SubSegment__c(
            Program_Detail__c = techspec.Id,
            Account__c = acc.Id,
            Segment__c = 'Professional and Commercial Radio',
            Sub_Segment__c = DTSFPART_SubscriptionsController.ION
        );
    }

    @isTest
    static void hasCurrentUserAccountValidProgramDetailTest() {
        User user = [SELECT Id FROM User WHERE username = :USERNAME LIMIT 1];

        Boolean hasUserValidProgramDetail = false;

        System.runAs(user) {
            Test.startTest();
                hasUserValidProgramDetail = DTSFPART_SubscriptionsController.hasCurrentUserAccountValidProgramDetail();
            Test.stopTest();
        }
  
        System.assert(!hasUserValidProgramDetail);
    }

    @isTest
    static void hasCurrentUserAccountValidTechnologySubSegmentTest() {
        User user = [SELECT Id FROM User WHERE username = :USERNAME LIMIT 1];

        Boolean hasUserValidTechnologySubSegment = false;

        System.runAs(user) {
            Test.startTest();
                hasUserValidTechnologySubSegment = DTSFPART_SubscriptionsController.hasCurrentUserAccountValidTechnologySubSegment();
            Test.stopTest();
        }

        System.assert(hasUserValidTechnologySubSegment);
    }

    @isTest
    static void getSubscriptionIdsListWithAccessToDetailPageTest() {
        Map<String, List<String>> customerNumberToSubscriptionsIds = new Map<String, List<String>>{
            '214341241' => new List<String>{ '12345678' }
        };
        Test.startTest();
         DTSFPART_SubscriptionsController.getSubscriptionIdsListWithAccessToDetailPage(customerNumberToSubscriptionsIds);
        Test.stopTest();
    }
}