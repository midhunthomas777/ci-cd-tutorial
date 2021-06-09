/*******************************************************************************
* Description : Test class for PartnerLevelLogoCls
* Date : 27th Apr 2018
*******************************************************************************/
@isTest
private class EMEACommConsolidatedTestClassCls {
    @testSetup
    Static void testSetUp(){
        TestDataSetUpUtils.insertCustomSettings();
    }
    private static testMethod void PartnerLevelLogoClsTest(){
        TestDataSetUpUtils.activateContTrigger();
        TestDataSetUpUtils.activateAccTrigger();
        Recordtype rAccType=[SELECT id,developername from recordtype where DeveloperName=: 'Partner' and sobjecttype=:'Account'];
        List<Account> PartnrAcclist = TestDataSetUpUtils.createaccounts(1,rAccType.id);
        Id ConPartId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        List<Contact> Conts1 = TestDataSetUpUtils.createContacts(1,ConPartId,PartnrAcclist);
        Conts1[0].Primary_Contact_Type__c  = 'Key Contact' ;
        update Conts1;
        
        User instOfUsr = TestDataSetUpUtils.createPartnerPortalUser(Conts1[0].Id);
        Folder myfolder = [SELECT Name FROM Folder WHERE Name Like '%Communities%' LIMIT 1];
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId = PartnrAcclist[0].Id;
        accountShare.UserOrGroupId =  instOfUsr.Id;
        accountShare.AccountAccessLevel = 'Edit';
        accountShare.ContactAccessLevel = 'Edit';
        accountShare.CaseAccessLevel = 'Edit';
        accountShare.OpportunityAccessLevel = 'Edit';
        insert accountShare;
        system.runAs(instOfUsr){
            PartnrAcclist[0].Metal_Level__c = 'Platinum';
            PartnrAcclist[0].Partner_Region__c = 'EMEA';
            update PartnrAcclist[0];
            List<Document> dt = [SELECT Id from Document where DeveloperName='Platinum'];
            if(dt.size()>0)
                delete dt;
            
            Document document;
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            // document.DeveloperName = 'PlatinumPartnerLogoImagee';
            document.DeveloperName = 'Platinum';
            
            document.IsPublic = true;
            document.Name = 'Platinum';
            document.FolderId = myfolder.Id;
            Database.insert(document,false);
            
            Document instOfDoc = [SELECT Id,Name FROM Document LIMIT 1];
            //String accLevel = 'Registered';
            PartnerLevelLogoCls.getPartnerLevelLogo();
            PartnerWelcomeMessageCls.getAccountManager();
            EMEAHomePageController.getKeyContacts();
            PartnerLevelLogoCls.LogoWrapper wrapper = new PartnerLevelLogoCls.LogoWrapper('','');
        }
    }
    private static testMethod void PartnerLevelLogoClsTest1(){
        TestDataSetUpUtils.activateContTrigger();
        TestDataSetUpUtils.activateAccTrigger();
        Recordtype rAccType=[SELECT id,developername from recordtype where DeveloperName=: 'Partner' and sobjecttype=:'Account'];
        List<Account> PartnrAcclist = TestDataSetUpUtils.createaccounts(1,rAccType.id);
        Id ConPartId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        List<Contact> Conts1 = TestDataSetUpUtils.createContacts(1,ConPartId,PartnrAcclist);
        Conts1[0].Primary_Contact_Type__c  = 'Key Contact' ;
        update Conts1;
        User instOfUsr = TestDataSetUpUtils.createPartnerPortalUser(Conts1[0].Id);
        Folder myfolder = [SELECT Name FROM Folder WHERE Name Like '%Communities%' LIMIT 1];
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId = PartnrAcclist[0].Id;
        accountShare.UserOrGroupId =  instOfUsr.Id;
        accountShare.AccountAccessLevel = 'Edit';
        accountShare.ContactAccessLevel = 'Edit';
        accountShare.CaseAccessLevel = 'Edit';
        accountShare.OpportunityAccessLevel = 'Edit';
        insert accountShare;
        system.runAs(instOfUsr){
            PartnrAcclist[0].Metal_Level__c = '';
            update PartnrAcclist[0];
            List<Document> dt = [SELECT Id from Document where DeveloperName='EADistributor'];
            if(dt.size()>0)
                delete dt;
            
            Document document;
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'EADistributor';
            document.IsPublic = true;
            document.Name = 'Distributor';
            document.FolderId = myfolder.Id;
            database.insert(document,false);
            Document instOfDoc = [SELECT Id,Name  FROM Document LIMIT 1];
            //String accLevel = 'Registered';
            PartnerLevelLogoCls.getPartnerLevelLogo();
            PartnerLevelLogoCls.LogoWrapper wrapper = new PartnerLevelLogoCls.LogoWrapper('','');
            PartnerWelcomeMessageCls.getAccountManager();
            EMEAHomePageController.getKeyContacts();
        }
    }
    
    private static testMethod void PartnerLevelLogoClsTest2(){
        TestDataSetUpUtils.activateContTrigger();
        TestDataSetUpUtils.activateAccTrigger();
        Recordtype rAccType=[SELECT id,developername from recordtype where DeveloperName=: 'Partner' and sobjecttype=:'Account'];
        List<Account> PartnrAcclist = TestDataSetUpUtils.createaccounts(1,rAccType.id);
        Id ConPartId = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        List<Contact> Conts1 = TestDataSetUpUtils.createContacts(1,ConPartId,PartnrAcclist);
        Conts1[0].Primary_Contact_Type__c  = 'Key Contact' ;
        update Conts1;
        User instOfUsr = TestDataSetUpUtils.createPartnerPortalUser(Conts1[0].Id);
        Folder myfolder = [SELECT Name FROM Folder WHERE Name Like '%Communities%' LIMIT 1];
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId = PartnrAcclist[0].Id;
        accountShare.UserOrGroupId =  instOfUsr.Id;
        accountShare.AccountAccessLevel = 'Edit';
        accountShare.ContactAccessLevel = 'Edit';
        accountShare.CaseAccessLevel = 'Edit';
        accountShare.OpportunityAccessLevel = 'Edit';
        insert accountShare;
        system.runAs(instOfUsr){
            PartnrAcclist[0].Metal_Level__c = 'Registered';
            PartnrAcclist[0].Partner_Region__c = 'NAMR';
            update PartnrAcclist[0];
            List<Document> dt = [SELECT Id from Document where DeveloperName='Registered'];
            if(dt.size()>0)
                delete dt;
            
            Document document;
            document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'Registered';
            document.IsPublic = true;
            document.Name = 'Registered';
            document.FolderId = myfolder.Id;
            database.insert(document,false);
            Document instOfDoc = [SELECT Id,Name  FROM Document LIMIT 1];
            //String accLevel = 'Registered';
            PartnerLevelLogoCls.getPartnerLevelLogo();
            PartnerLevelLogoCls.LogoWrapper wrapper = new PartnerLevelLogoCls.LogoWrapper('','');
            PartnerWelcomeMessageCls.getAccountManager();
            EMEAHomePageController.getKeyContacts();
        }
    }
}