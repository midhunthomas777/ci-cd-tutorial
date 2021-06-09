/*************************************************************************************************
 * File Name  : AssignPermissionSet_test
 * Description: Test class for AssignPermissionSet class
 * Modification Log
 * =============================================================================
 *   Date               Author                         Modification
 * ---------------------------------------------------------------------------------------
 * 13-Aug-2018     Satish Maddhi(TCS)                Initial development
 *
 *************************************************************************************************/
@isTest
public class AssignPermissionSet_test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }

    static testMethod void test_assignpermissionset() {
        Map<Id, Id> usersId = new Map<Id, Id>();
        Map<Id, String> usersVal = new Map<Id, String>();

        User owner = [SELECT Id FROM User WHERE isActive = TRUE AND Isportalenabled = FALSE LIMIT 1];
        Id accrtdType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id rtPartner = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        List<Account> Acts = TestdatasetupUtils.createAccounts(3, accrtdType);
        List<Account> partnracct = TestdatasetupUtils.createAccounts(3, rtPartner);

        Id partnerRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'MPE_Partner_Contact');
        Id standardRecordTypeId = DTSFPART_Utils.getRecordTypeId('Contact', 'EMS_Standard_Contact');

        Contact[] Conts = new Contact[6];
        Conts[0] = new Contact(
            FirstName = 'NAMR',
            LastName = 'Partner',
            email = 'NAMR@partner.com',
            accountId = Acts[0].Id,
            ownerId = owner.Id,
            RecordTypeId = standardRecordTypeId
        );
        Conts[1] = new Contact(
            FirstName = 'LACR',
            LastName = 'Partner',
            email = 'LACR@partner.com',
            accountId = Acts[0].Id,
            ownerId = owner.Id,
            RecordTypeId = standardRecordTypeId
        );
        Conts[2] = new Contact(
            FirstName = 'Hank',
            LastName = 'Customer',
            email = 'last@systems.com',
            accountId = partnracct[1].Id,
            ownerId = owner.Id,
            RecordTypeId = partnerRecordTypeId
        );
        Conts[3] = new Contact(
            FirstName = 'APAC',
            LastName = 'Partner',
            email = 'APAC@partner.com',
            accountId = Acts[0].Id,
            ownerId = owner.Id,
            RecordTypeId = standardRecordTypeId
        );
        Conts[4] = new Contact(
            FirstName = 'EMEA',
            LastName = 'Partner',
            email = 'EMEA@partner.com',
            accountId = Acts[0].Id,
            ownerId = owner.Id,
            RecordTypeId = standardRecordTypeId
        );
        Conts[5] = new Contact(
            FirstName = 'NAMR2',
            LastName = 'Partner',
            email = 'NAMR2@partner.com',
            accountId = Acts[0].Id,
            ownerId = owner.Id,
            RecordTypeId = standardRecordTypeId
        );
        insert Conts;
        //Runs as 3 different Partner Users
        String NAMRP;
        String LACRp;
        String APACp;
        //String EMEAp;
        Profile[] partnerPrf = [
            SELECT Id, Name
            FROM Profile
            WHERE Name IN ('EMS Partner Profile NAMR', 'EMS Partner Profile LACR', 'EMS Partner Profile APAC', 'EMS Partner Profile EMEA')
        ];
        for (integer i = 0; i < partnerPrf.size(); i++) {
            if (partnerPrf[i].Name == 'EMS Partner Profile NAMR') {
                NAMRP = partnerPrf[i].id;
            }
            if (partnerPrf[i].Name == 'EMS Partner Profile LACR') {
                LACRp = partnerPrf[i].id;
            }
            if (partnerPrf[i].Name == 'EMS Partner Profile APAC') {
                APACp = partnerPrf[i].id;
            }
        }

        User[] PUsers = new User[3];
        PUsers[0] = new User(
            ContactId = Conts[0].Id,
            FirstName = 'NAMR',
            LastName = 'Partner',
            alias = 'abcd',
            email = 'NAMR@partner.com',
            username = 'DRNAMR@partner.com',
            communityNickname = 'testGuy',
            profileId = NAMRp,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Theater__c = 'NAMR',
            Primary_Business_Group__c = 'Enterprise'
        );
        PUsers[1] = new User(
            ContactId = Conts[1].Id,
            FirstName = 'LACR',
            LastName = 'Partner',
            alias = 'wxyz',
            email = 'LACR@partner.com',
            username = 'DRLACR@partner.com',
            communityNickname = 'testGuy1',
            profileId = LACRp,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Theater__c = 'LACR',
            Primary_Business_Group__c = 'Enterprise'
        );
        PUsers[2] = new User(
            ContactId = Conts[2].Id,
            FirstName = 'APAC',
            LastName = 'Partner',
            alias = 'wxyz',
            email = 'APAC@partner.com',
            username = 'DRAPAC@partner.com',
            communityNickname = 'testGuy6',
            profileId = APACp,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Theater__c = 'APAC',
            Primary_Business_Group__c = 'Enterprise'
        );
        insert PUsers;

        System.runAs(PUsers[2]) {
            List<PermissionSetAssignment> PSAs = new List<PermissionSetAssignment>();
            PSAs.add(new PermissionSetAssignment(AssigneeId = PUsers[0].id, PermissionSetId = '0PS34000000LK8t'));
            PSAs.add(new PermissionSetAssignment(AssigneeId = PUsers[1].id, PermissionSetId = '0PS34000000LK8o'));
            //PSAs.add(new PermissionSetAssignment(AssigneeId=PUsers[2].id,PermissionSetId='0PSg0000000DwRD'));

            database.insert(PSAs, false);
        }
        for (User eachUsr : PUsers) {
            usersId.put(eachUsr.id, eachUsr.id);
            usersVal.put(eachUsr.id, String.valueOf(eachUsr.id));
        }

        TagBasedPermissionSets.assignBulkIndividualsPS(usersId.keySet(), 'MR');
        AssignPermissionSet.AssignPermissionSetToUsers(usersId, usersVal);
        AssignPermissionSet.removepermission(usersId, usersVal);
    }
}