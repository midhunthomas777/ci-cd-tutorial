@isTest
public class PartnershipRecordTriggerTest {   

    @TestSetup
    static void testSetUp() {
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
    }

    @isTest
    static void partnershipRecordTriggerHandlerTest(){

        RecordType partnerAccountRecordType = [ SELECT Id 
                                                FROM RecordType 
                                                WHERE SobjectType = 'Account' 
                                                AND DeveloperName =  'Partner' ];

        Account partnerAccount = DTSFPART_TestDataSetUpUtils.createPartnerAccount(partnerAccountRecordType.Id, true);
        String partnerMembershipId = [ SELECT Partner_Membership_Id__c 
                                       FROM Account 
                                       WHERE Id = :partnerAccount.Id 
                                       LIMIT 1 ].Partner_Membership_Id__c; //query to get updated autonumber field


        Partnership_Record__c newFile = new Partnership_Record__c(
            Name = 'TestFile',
            Partner_Empower_ID__c = partnerMembershipId,
            Account__c = partnerAccount.Id,
            File_Id__c = '15W9puJ8o8qgikAkHMaUYCK6WBAh3yLMN4-SrZIEa6xI',
            File_Type__c = 'Product Access Report',
            Mime_Type__c = 'Google Sheets'
        );
        insert newFile;

        newFile.Name = 'Test2';
        update newFile;

        delete newFile;
    } 
}