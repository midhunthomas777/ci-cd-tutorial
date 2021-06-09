@isTest
public class MRCPQ_MoveQuoteControllerTest {
    @isTest 
    static void movequoteOpportunitytest(){        
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        MetadataCoverageTest.setMetadata('SELECT MasterLabel,DeveloperName FROM FedTerritories__mdt'
                                         , (List<FedTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"DOD-West"}]', List<FedTerritories__mdt>.class));
        MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM SLTerritories__mdt'
                                         , (List<SLTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"T8"}]', List<SLTerritories__mdt>.class));
        MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM MR_Order_Types_for_CPQ__mdt'
                                         , (List<MR_Order_Types_for_CPQ__mdt>) JSON.deserialize('[{"MasterLabel":"Box","Is_Available_for_MRs__c":"true"}]', List<MR_Order_Types_for_CPQ__mdt>.class));
        
        String partnerAccountId= [select id,accountId from User where id=:partnerUsr.Id and isActive=true].accountId;
        String partnerContactId= [select contactId  from User where id=:partnerUsr.Id and isActive=true].contactId;
        system.debug('partnerAccountId==>'+partnerAccountId);
        system.debug('partnerContactId==>'+partnerContactId);
        Partner_Identifier__c pI = new Partner_Identifier__c();
        pI.ID_Number__c='965432';
        pI.ID_Type__c='Federal Manufacturer Representative ID';
        pI.Account__c=partnerAccountId;
        insert pI;
        
        Partner_Identifier__c partnerIdentifier = new Partner_Identifier__c();
        partnerIdentifier.ID_Number__c='9654432';
        partnerIdentifier.ID_Type__c='State and Local Manufacturer Representative ID';
        partnerIdentifier.Account__c=partnerAccountId;
        insert partnerIdentifier;
        
        Partner_Type__c pgminfo = new Partner_Type__c();
        pgminfo.Account__c = partnerAccountId;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active'; 
        pgminfo.Purchasing_Method__c='Tier 16';
        pgminfo.US_Federal__c=True;
        pgminfo.RHO__c=True;
        insert pgminfo;
        
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = partnerAccountId;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'State/Local Manufacturer Representative';
        insert techspec;
        
        Test.startTest();
        List<Account> lstCustomerAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);        
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstCustomerAccount);
        
        lstMCNAccount[0].Motorola_Customer_Number__c = '1036065276';
        lstMCNAccount[0].Assigned_MR__c	= partnerAccountId;
        lstMCNAccount[0].Assigned_MR_Sales_Person__c = partnerContactId;
        update lstMCNAccount;
        
        System.debug('lstCustomerAccount.get(0).Id' + lstCustomerAccount.get(0).Id );
        System.debug('lstMCNAccount.get(0).ParentId' + lstMCNAccount.get(0).ParentId );
        System.debug('lstMCNAccount.get(0).Motorola_Customer_Number__c' + lstMCNAccount.get(0).Motorola_Customer_Number__c );
        
        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();       
        lstOpportunity.get(0).AccountId=lstCustomerAccount.get(0).Id;
        lstOpportunity.get(0).CDH_Account__c=lstMCNAccount.get(0).Id;
        update lstOpportunity;
        System.debug('lstOpportunity==>' + lstOpportunity);
        System.debug('lstOpportunity.get(0).CDH_Account__r.Motorola_Customer_Number__c==>' + lstOpportunity.get(0).CDH_Account__r.Motorola_Customer_Number__c);
        
        //insert new OpportunityTeamMember(OpportunityId=lstOpportunity.get(0).Id,UserId=partnerUsr.Id,TeamMemberRole='CAM',OpportunityAccessLevel = 'Edit');
        OpportunityShare osh = new OpportunityShare(OpportunityId = lstOpportunity.get(0).id, UserOrGroupId = partnerUsr.Id,OpportunityAccessLevel = 'Edit');
        insert osh;
        
        //system.runas(partnerUsr){           
            Set<String> fedter= CPQUtility.fetchFedTerritories();
            Set<String> slter= CPQUtility.fetchSLTerritories();         
            system.debug('partnerUsrAccountId'+partnerUsr.AccountId);
            BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
            objQuote.BigMachines__Account__c=lstCustomerAccount.get(0).Id;
            objQuote.AccountOnlyQuotes__c=lstCustomerAccount.get(0).Id;
            objQuote.Name='testQuote';
            objQuote.BigMachines__Site__c=siteID;
            objQuote.BigMachines__Opportunity__c=null;
            objQuote.BigMachines__Transaction_Id__c='12345';
            objQuote.Motorola_Customer_Number__c = lstMCNAccount.get(0).Motorola_Customer_Number__c;
            objQuote.MR_ID__c='1234';
            objQuote.IsFinalizedQuoteSubmitted__c=true;
            objQuote.QuotePDFFile__c='true';
            objQuote.SendFilestoFinancialFolder__c=true;
            insert objQuote;     
            System.debug('objQuote.id==>' +  objQuote.id);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            ApexPages.StandardController sc = new ApexPages.standardController(objQuote);            
            MRCPQ_MoveQuoteToOpportunityCtrl.fetchSitePrefix();      
            MRCPQ_MoveQuoteToOpportunityCtrl.isLoggedinPartnerUser();           
            MRCPQ_MoveQuoteToOpportunityCtrl.moveQuoteToOpportunity(lstOpportunity.get(0).Id, objQuote.id);            
            MRCPQ_MoveQuoteToOpportunityCtrl.search('test',lstCustomerAccount.get(0).Id);
            MRCPQ_MoveQuoteToOpportunityCtrl.canMoveQuote(objQuote.id);           
            Test.stopTest();             
        //}
    }
    
    @isTest 
    static void movequoteAccounttest(){        
        TestDataSetUpUtils.insertCustomSettings();
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Id prospectAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id MCNrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        User partnerUsr = TestDataSetUpUtils.createPortalUser();
        Id siteID = TestDataSetUpUtils.createSite();
        MetadataCoverageTest.setMetadata('SELECT MasterLabel,DeveloperName FROM FedTerritories__mdt'
                                         , (List<FedTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"DOD-West"}]', List<FedTerritories__mdt>.class));
        MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM SLTerritories__mdt'
                                         , (List<SLTerritories__mdt>) JSON.deserialize('[{"MasterLabel":"T8"}]', List<SLTerritories__mdt>.class));
        MetadataCoverageTest.setMetadata('MasterLabel,DeveloperName FROM MR_Order_Types_for_CPQ__mdt'
                                         , (List<MR_Order_Types_for_CPQ__mdt>) JSON.deserialize('[{"MasterLabel":"Box","Is_Available_for_MRs__c":"true"}]', List<MR_Order_Types_for_CPQ__mdt>.class));
        
        String partnerAccountId= [select id,accountId from User where id=:partnerUsr.Id and isActive=true].accountId;
        String partnerContactId= [select contactId  from User where id=:partnerUsr.Id and isActive=true].contactId;
        system.debug('partnerAccountId==>'+partnerAccountId);
        system.debug('partnerContactId==>'+partnerContactId);
        Partner_Identifier__c pI = new Partner_Identifier__c();
        pI.ID_Number__c='965432';
        pI.ID_Type__c='Federal Manufacturer Representative ID';
        pI.Account__c=partnerAccountId;
        insert pI;
        
        Partner_Identifier__c partnerIdentifier = new Partner_Identifier__c();
        partnerIdentifier.ID_Number__c='9654432';
        partnerIdentifier.ID_Type__c='State and Local Manufacturer Representative ID';
        partnerIdentifier.Account__c=partnerAccountId;
        insert partnerIdentifier;
        
        Partner_Type__c pgminfo = new Partner_Type__c();
        pgminfo.Account__c = partnerAccountId;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active'; 
        pgminfo.Purchasing_Method__c='Tier 16';
        pgminfo.US_Federal__c=True;
        pgminfo.RHO__c=True;
        insert pgminfo;
        
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = partnerAccountId;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Mission Critical Radio Systems';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'State/Local Manufacturer Representative';
        insert techspec;
        
        Test.startTest();
        List<Account> lstCustomerAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);        
        List<Account> lstMCNAccount=TestDataSetUpUtils.createMCNAccounts(1, MCNrectypeID, lstCustomerAccount);
        
        lstMCNAccount[0].Motorola_Customer_Number__c = '1036065276';
        lstMCNAccount[0].Assigned_MR__c	= partnerAccountId;
        lstMCNAccount[0].Assigned_MR_Sales_Person__c = partnerContactId;
        update lstMCNAccount;
        
        System.debug('lstCustomerAccount.get(0).Id' + lstCustomerAccount.get(0).Id );
        System.debug('lstMCNAccount.get(0).ParentId' + lstMCNAccount.get(0).ParentId );
        System.debug('lstMCNAccount.get(0).Motorola_Customer_Number__c' + lstMCNAccount.get(0).Motorola_Customer_Number__c );

        List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();       
        lstOpportunity.get(0).AccountId=lstCustomerAccount.get(0).Id;
        lstOpportunity.get(0).CDH_Account__c=lstMCNAccount.get(0).Id;
        update lstOpportunity;
        System.debug('lstOpportunity==>' + lstOpportunity);
        System.debug('lstOpportunity.get(0).CDH_Account__r.Motorola_Customer_Number__c==>' + lstOpportunity.get(0).CDH_Account__r.Motorola_Customer_Number__c);
       
        OpportunityShare osh = new OpportunityShare(OpportunityId = lstOpportunity.get(0).id, UserOrGroupId = partnerUsr.Id,OpportunityAccessLevel = 'Edit');
        insert osh;
        
        //system.runas(partnerUsr){           
            Set<String> fedter= CPQUtility.fetchFedTerritories();
            Set<String> slter= CPQUtility.fetchSLTerritories();         
            system.debug('partnerUsrAccountId'+partnerUsr.AccountId);
            BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
            objQuote.BigMachines__Account__c=lstCustomerAccount.get(0).Id;
            objQuote.AccountOnlyQuotes__c=lstCustomerAccount.get(0).Id;
            objQuote.Name='testQuote';
            objQuote.BigMachines__Site__c=siteID;
            objQuote.BigMachines__Opportunity__c=null;
            objQuote.BigMachines__Transaction_Id__c='12345';
            objQuote.Motorola_Customer_Number__c = lstMCNAccount.get(0).Motorola_Customer_Number__c;
            objQuote.MR_ID__c='1234';
            objQuote.IsFinalizedQuoteSubmitted__c=true;
            objQuote.QuotePDFFile__c='true';
            objQuote.SendFilestoFinancialFolder__c=true;
            insert objQuote;     
            System.debug('objQuote.id==>' +  objQuote.id);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            ApexPages.StandardController sc = new ApexPages.standardController(objQuote);            
            MRCPQ_MoveQuoteToAccountCtrl.fetchAccount('test');
            MRCPQ_MoveQuoteToAccountCtrl.fetchMCNAccount('test');
            MRCPQ_MoveQuoteToAccountCtrl.updateQuote(objQuote.id,lstCustomerAccount.get(0).Id,lstMCNAccount.get(0).Motorola_Customer_Number__c);
            MRCPQ_MoveQuoteToAccountCtrl.isValidated(objQuote.id);
            MoveQuotePDFController cntrl = new MoveQuotePDFController(sc);
            MoveQuotePDFController.moveToDrive();          
            Test.stopTest();
        //}
    }
    }