/**
 * @author: WGVR43 
 * @date: 30.01.2021
 * @group: DTSFPART
 * @description: 
 */
@IsTest
public class DTSFPART_LookupFieldControllerTest {
    private static final String USERNAME = 'lookupfield@mot-solutions.com.test';
    private static final String ALIAS = 'LOOFIE';

    @TestSetup
    private static void setupTests(){
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User user = new User(
                FirstName = 'LookupField',
                LastName = 'TestUser',
                Alias = ALIAS,
                Username = USERNAME,
                FederationIdentifier = ALIAS,
                CommunityNickname = ALIAS,
                Core_ID__c = ALIAS,
                EmployeeNumber = ALIAS,
                Email = 'lookupfield@motorolasolutions.com.test',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = profileId,
                LanguageLocaleKey = 'en_US'
        );
        insert user;

        System.runAs(user){
            Id recordTypeId = DTSFPART_Utils.getRecordTypeId('Account', 'Partner');
            DTSFPART_TestDataSetUpUtils.createAccounts(10, recordTypeId);
        }
    }

    @IsTest
    private static void searchRecords(){
        User user = [SELECT Id FROM User WHERE Username = :USERNAME];
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name, OwnerId FROM Account WHERE OwnerId = :user.Id]);
        List<LookupSearchResult> lookupSearchResults;

        System.runAs(user){
            Test.setFixedSearchResults(new List<Id>(accounts.keySet()));
            Test.startTest();
                lookupSearchResults = DTSFPART_LookupFieldController.searchRecords(
                        'Account', 'OwnerId', 'Name', 'Test Account', '', 'test-icon'
                );
            Test.stopTest();
        }

        System.assert(lookupSearchResults != null);
        System.assert(!lookupSearchResults.isEmpty());
        System.assertEquals(10, lookupSearchResults.size());
        for(LookupSearchResult result: lookupSearchResults){
            Account acc = accounts.get(result.getId());
            System.assertEquals(acc.OwnerId, result.getTitle());
            System.assertEquals(acc.Name, result.getSubtitle());
            System.assertEquals('Account', result.getSObjectType());
            System.assertEquals('test-icon', result.getIcon());
        }
    }

    @IsTest
    private static void searchRecordsEmpty(){
        User user = [SELECT Id FROM User WHERE Username = :USERNAME];

        List<LookupSearchResult> lookupSearchResults;
        System.runAs(user){
            Test.startTest();
            lookupSearchResults = DTSFPART_LookupFieldController.searchRecords(
                    'Account', 'OwnerId', 'Name', 'Test Account', '', 'test-icon'
            );
            Test.stopTest();
        }

        System.assert(lookupSearchResults != null);
        System.assert(lookupSearchResults.isEmpty());
    }

    @IsTest
    private static void recentRecords(){
        User user = [SELECT Id FROM User WHERE Username = :USERNAME];

        List<LookupSearchResult> lookupSearchResults;
        System.runAs(user){
            Test.startTest();
            lookupSearchResults = DTSFPART_LookupFieldController.getRecentlyViewed(
                    'Account', 'OwnerId', 'Name','test-icon'
            );
            Test.stopTest();
        }

        System.assert(lookupSearchResults != null);
        //System.assert(!lookupSearchResults.isEmpty()); //PW This make no sense in case of deployment 
        //System.assertEquals(5, lookupSearchResults.size());
    }
}