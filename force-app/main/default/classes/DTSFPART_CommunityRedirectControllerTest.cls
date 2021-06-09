@IsTest(SeeAllData=true) //ConnectApi in Apex methods require access to real organization data, and fail unless used in test methods marked @IsTest(SeeAllData=true).
public class DTSFPART_CommunityRedirectControllerTest {

    private static final String ACCOUNT_NAME = 'DTSFPART_CommunityRedirectControllerTest Account';

    private static void setup() {
        UserTriggerHandler.TriggerDisabled = true;
        User admin = DTSFPART_TestDataSetUpUtils.createAdminUser();
        System.runAs(admin) {
            User partner = createPartnerPortalUser();
        }
    }

    private static User createPartnerPortalUser() {
        
        Account account = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();
        account.Partner_Hub_Enabled__c = true;
        account.Name = ACCOUNT_NAME;
        update account;

        Id contactRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        List<Contact> contacts = DTSFPART_TestDataSetUpUtils.createContacts(1, contactRecordTypeId, new List<Account>{account});

        User user = DTSFPART_TestDataSetUpUtils.createPartnerPortalUser(contacts[0].Id);
        
        AccountShare shareAccountWithUser = new AccountShare();

        shareAccountWithUser.AccountId = account.Id;
        shareAccountWithUser.UserOrGroupId = user.Id;
        shareAccountWithUser.AccountAccessLevel = 'Read';
        shareAccountWithUser.OpportunityAccessLevel = 'Read';
        shareAccountWithUser.RowCause = 'Manual';

        insert shareAccountWithUser;
        return user;
    }

    @IsTest
    private static void getCommunityUrlWhenPartnerHubIsEnabledAndIsRedirectPageTest() {
        setup();
        User admin = [
            SELECT Id
            FROM User
            WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_ADMIN
            LIMIT 1
        ];
        System.runAs(admin) {
            User partnerUser = [
                SELECT Id
                FROM User
                WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_PARTNER
                LIMIT 1
            ];

            Account account = [ SELECT Id, Partner_Hub_Enabled__c
                                FROM Account 
                                WHERE Name = :ACCOUNT_NAME 
                                LIMIT 1 ];

            account.Partner_Hub_Enabled__c = true;
            update account;

            DTSFPART_CommunityRedirectController.RedirectResponse redirectResponse = null;

            Test.startTest();
                Id partnerHubNetworkId = [ SELECT Id, Name, UrlPathPrefix
                                        FROM Network
                                        WHERE Name = 'Partner Hub' ]?.Id;
                System.runAs(partnerUser) {
                    redirectResponse = DTSFPART_CommunityRedirectController.getCommunityBasedUrl(partnerHubNetworkId, true, 'Partner Hub', 'NA Partner Engagement Center', 'System Administrator');
                }
            Test.stopTest();

            // System.assertEquals(false, redirectResponse.isSuccess, 'Unexpected error');
            // System.assertEquals(true, redirectResponse.redirectUser, 'User should be redirect');
        }
    }

    @IsTest
    private static void getCommunityUrlWhenPartnerHubIsEnabledAndIsNotRedirectPageTest() {
        setup();
        User admin = [
            SELECT Id
            FROM User
            WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_ADMIN
            LIMIT 1
        ];
        System.runAs(admin) {
            User partnerUser = [
                SELECT Id
                FROM User
                WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_PARTNER
                LIMIT 1
            ];
            Account account = [ SELECT Id, Partner_Hub_Enabled__c
                                FROM Account 
                                WHERE Name = :ACCOUNT_NAME 
                                LIMIT 1 ];

            account.Partner_Hub_Enabled__c = true;
            update account;

            DTSFPART_CommunityRedirectController.RedirectResponse redirectResponse = null;

            Test.startTest();
                Id legacyPartnerHubNetworkId = [ SELECT Id, Name, UrlPathPrefix
                                                 FROM Network
                                                 WHERE Name = 'NA Partner Engagement Center' ]?.Id;

                System.runAs(partnerUser) {
                    redirectResponse = DTSFPART_CommunityRedirectController.getCommunityBasedUrl(legacyPartnerHubNetworkId, false, 'Partner Hub', 'NA Partner Engagement Center', 'System Administrator');
                }
            Test.stopTest();

            // System.assertEquals(false, redirectResponse.isSuccess, 'Unexpected error');
            // System.assertEquals(false, redirectResponse.redirectUser, 'User should not be redirect');
        }
    }

    @IsTest
    private static void getCommunityUrlWhenPartnerHubIsEnabledAndIsOnLegacyTest() {
        setup();
        User admin = [
            SELECT Id
            FROM User
            WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_ADMIN
            LIMIT 1
        ];
        System.runAs(admin) {
            User partnerUser = [
                SELECT Id
                FROM User
                WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_PARTNER
                LIMIT 1
            ];
            Account account = [ SELECT Id, Partner_Hub_Enabled__c
                                FROM Account 
                                WHERE Name = :ACCOUNT_NAME 
                                LIMIT 1 ];

            account.Partner_Hub_Enabled__c = true;
            update account;

            DTSFPART_CommunityRedirectController.RedirectResponse redirectResponse = null;

            Test.startTest();
                Id partnerHubNetworkId = [ SELECT Id, Name, UrlPathPrefix
                                        FROM Network
                                        WHERE Name = 'Partner Hub' ]?.Id;

                System.runAs(partnerUser) {
                    redirectResponse = DTSFPART_CommunityRedirectController.getCommunityBasedUrl(partnerHubNetworkId, false, 'Partner Hub', 'NA Partner Engagement Center', 'System Administrator');
                }
            Test.stopTest();

            // System.assertEquals(false, redirectResponse.isSuccess, 'Unexpected error');
            // System.assertEquals(false, redirectResponse.redirectUser, 'User should not be redirect');
        }
    }

    @IsTest
    private static void getCommunityUrlWhenPartnerHubIsDisabledTest() {
        setup();
        User admin = [
            SELECT Id
            FROM User
            WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_ADMIN
            LIMIT 1
        ];
        System.runAs(admin) {
            User partnerUser = [
                SELECT Id
                FROM User
                WHERE Username = :DTSFPART_TestDataSetUpUtils.USERNAME_PARTNER
                LIMIT 1
            ];

            Account account = [ SELECT Id, Partner_Hub_Enabled__c
                                FROM Account 
                                WHERE Name = :ACCOUNT_NAME 
                                LIMIT 1 ];

            account.Partner_Hub_Enabled__c = false;
            update account;

        

            DTSFPART_CommunityRedirectController.RedirectResponse redirectResponse = null;

            Test.startTest();
                Id partnerHubNetworkId = [ SELECT Id, Name, UrlPathPrefix
                                        FROM Network
                                        WHERE Name = 'Partner Hub' ]?.Id;

                System.runAs(partnerUser) {
                    redirectResponse = DTSFPART_CommunityRedirectController.getCommunityBasedUrl(partnerHubNetworkId, false, 'Partner Hub', 'NA Partner Engagement Center', 'System Administrator');
                }
            Test.stopTest();

            System.assertEquals(true, redirectResponse.isSuccess, 'Unexpected error');
            System.assertEquals(true, redirectResponse.redirectUser, 'User should be redirect to legacy community');
        }
    }

}