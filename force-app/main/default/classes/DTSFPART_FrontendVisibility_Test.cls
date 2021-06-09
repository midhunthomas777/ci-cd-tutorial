/**
 * @author      Paweł Woźniak
 * @created     2020-07-28
 * @updated     2020-12-04
 * @isTesting   DTSFPART_FrontendVisibility
 * @description
 */
@isTest
private class DTSFPART_FrontendVisibility_Test {

    @testSetup
    static void testSetup(){
        DTSFPART_TestDataSetUpUtils.insertCustomSettings();
    }

    @isTest
    private static void testGettingVisibleMenuItems() {

        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();

        Contact cnt = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        cnt.Persona__c = 'SalesManager';
        cnt.Partner_Region__c = 'NAMR';
        cnt.Tag__c = 'LeadAdmin'; // Modified value as per DTPART-87
        insert cnt;

        User partnerUser = DTSFPART_TestDataSetUpUtils.createPartnerUser(cnt);

        System.runAs (partnerUser) {
            String NavigationLinkSetDevName = 'Default_Navigation6';

            List<DTSFPART_FrontendVisibility.menuItemWrapper> miVisibility = DTSFPART_FrontendVisibility.getVisibleMenuItems(NavigationLinkSetDevName, new List<String>());
            System.debug('miVisibility size: ' + miVisibility.size());
            System.assertEquals(false, miVisibility.isEmpty(), 'List should not be empty until there are menu items available for "NAMR Lead Admin" in Custom Metadata "Tags with Permission Set"');
        }
    }

    @IsTest
    private static void testisEmpowerToolsCardVisible() {
        // Preapre data
        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();

        Contact cnt = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        cnt.Persona__c = 'SalesManager';
        cnt.Partner_Region__c = 'NAMR';
        cnt.Tag__c = 'LeadAdmin'; // Modified value as per DTPART-87
        insert cnt;

        User partnerUser = DTSFPART_TestDataSetUpUtils.createPartnerUser(cnt);

        // Account to Group mapping
        Account_to_Group_Mapping__c accToGroup = new Account_to_Group_Mapping__c();
        accToGroup.Account_Id__c = acc.Id;
        accToGroup.Groups__c = 'PC-NAMR-VAR-CORA-XXXXX-XXXX-X-XX;PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX';
        insert accToGroup;

        Test.startTest();
        System.runAs (partnerUser) {
            Boolean isVisible = false;
            // True
            isVisible = DTSFPART_FrontendVisibility.isEmpowerToolsCardVisible('PC-NAMR-VAR-CORA-XXXXX-XXXX-X-XX;PC-NAMR-XXX-XXXX-XXXXX-XXXX-X-XX');
            System.assertEquals(true, isVisible, 'Should be true');

            // False
            isVisible = DTSFPART_FrontendVisibility.isEmpowerToolsCardVisible('PC-NONE-VAR-CORA-XXXXX-XXXX-X-XX;PC-NONE-XXX-XXXX-XXXXX-XXXX-X-XX');
            System.assertEquals(false, isVisible, 'Should be false');

            // One group match - true
            isVisible = DTSFPART_FrontendVisibility.isEmpowerToolsCardVisible('PC-NAMR-VAR-CORA-XXXXX-XXXX-X-XX;PC-NONE-XXX-XXXX-XXXXX-XXXX-X-XX');
            System.assertEquals(true, isVisible, 'Should be true');

            // Empty input - true
            isVisible = DTSFPART_FrontendVisibility.isEmpowerToolsCardVisible('');
            System.assertEquals(true, isVisible, 'Should be true');
        }
        Test.stopTest();

    }

    @isTest
    private static void getCurrentUserTagsTest() {
        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();

        Contact cnt = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        cnt.Persona__c = 'SalesManager';
        cnt.Partner_Region__c = 'NAMR';
        cnt.Tag__c = 'LeadAdmin'; // Modified value as per DTPART-87
        insert cnt;

        User partnerUser = DTSFPART_TestDataSetUpUtils.createPartnerUser(cnt);

        Test.startTest();

        System.runAs (partnerUser) {
            List<String> tags = DTSFPART_FrontendVisibility.getCurrentUserTags();
        }
        Test.stopTest();
    }

    @isTest
    private static void getAllPermissionedSettingsTest() {
        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();

        Contact cnt = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        cnt.Persona__c = 'SalesManager';
        cnt.Partner_Region__c = 'NAMR';
        cnt.Tag__c = 'LeadAdmin'; // Modified value as per DTPART-87
        insert cnt;

        User partnerUser = DTSFPART_TestDataSetUpUtils.createPartnerUser(cnt);

        Test.startTest();

        System.runAs (partnerUser) {
            DTSFPART_FrontendVisibility.getAllPermissionedSettings('Default_Navigation6', 'Partner Hub');
        }
        Test.stopTest();
        
    }

    @isTest
    private static void getCurrentUserTagsWithUserTest() {
        Account acc = DTSFPART_TestDataSetUpUtils.createPartnerAccountWithTechSpec();

        Contact cnt = DTSFPART_TestDataSetUpUtils.createPartnerContact(acc, false);
        cnt.Persona__c = 'SalesManager';
        cnt.Partner_Region__c = 'NAMR';
        cnt.Tag__c = 'LeadAdmin'; // Modified value as per DTPART-87
        insert cnt;

        User partnerUser = DTSFPART_TestDataSetUpUtils.createPartnerUser(cnt);

        Test.startTest();

        System.runAs (partnerUser) {
            List<String> tags = DTSFPART_FrontendVisibility.getCurrentUserTags(partnerUser);
        }
        Test.stopTest();
    }
}