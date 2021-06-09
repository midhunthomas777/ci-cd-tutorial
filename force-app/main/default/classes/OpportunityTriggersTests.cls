/*============================================================================================
Name : OpportunityTriggerTests
Modification History:  
Modified By: Anitha Mohankumar
Description: Increased the code Coverage as per Story SF-2022 - 85%
===============================================================================================*/
@isTest
public class OpportunityTriggersTests {
    
    @testSetup
    static void testSetUp() {   
        TestDataSetUpUtils.insertCustomSettings();
        TestDataSetUpUtils.loadGoogleDriveTestData(); 
        TestDataSetUpUtils.createGeoMapRecords();
        Id competitorId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> accsToUpdate = new List<Account>();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId); 
        AccountList[0].Allowed_for_Run_Rate__c = True;
        accsToUpdate.add(AccountList[0]);
        Test.startTest();
        List<Account> AccountListcompetitor = TestDataSetUpUtils.createAccounts(1, competitorId);
        AccountListcompetitor.get(0).MSI_Competitor_Account__c = false;
        accsToUpdate.add(AccountListcompetitor[0]);
        Database.update(accsToUpdate,false);
        Test.stopTest();
        //update AccountListcompetitor[0];
    }     
    @isTest
    public static void testRunner(){        
        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1]; // Added by Harish
        String RTStr=rt.Id;
        Pricebook2 PB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert PB;            
        User owner = [select Id from User where isActive=true And Theater__c='NAMR' limit 1];
        RecordType rtop1 = [select Id from RecordType where SObjectType='Opportunity' and DeveloperName='Government_Standard' limit 1];
        Opportunity opp1 = new Opportunity(Region__c = 'NA',Type='Standard',StageName='Prospect',OwnerId=owner.Id,Name='Dupe2',SBL_Fulfillment__c='Tier 1 - New Paper',CloseDate=System.Today(),Industry__c ='Education', recordtypeid=rtop1.id,Country__c='United States',State__c='Alaska',Territory__c = 'T2');
        Test.startTest();
        Insert opp1;      
        Id oppId = opp1.Id;                
        Account Acts = new Account(Name='TestAcc',Territory__c = 'T6',Region__c='NA',BillingState= 'Texas',BillingCountry = 'United States',RecordTypeId=rt.Id);
        Insert Acts;      
        Id userId = [Select Id from User where isActive=true limit 1].Id;
        
        insert new OpportunityTeamMember(OpportunityId=oppId,UserId=userId,TeamMemberRole='CAM');
        insert new Partners2__c(Opportunity__c=oppId, Account__c=Acts.Id, Role__c='Primary Channel Partner');
        
        /*Clone_Queue__c cq = new Clone_Queue__c(opportunity__c=oppId, partners__c=true, sales_team__c=true);
        insert cq;*/
        Test.stopTest();
        // Commented below code for salesstage changes --Abhilash Govinda 16-May-13  
        //Opportunity opp = new Opportunity(name='testopp', stagename='pipeline',closedate=System.today(), ownerid=UserInfo.getUserId(), first_ship_date__c=System.today()+1, pull_forward_date__c=System.today()-1);
        Opportunity opp = new Opportunity(name='testopp1', stagename='Secure',closedate=System.today(),Account =Acts, ownerid=UserInfo.getUserId(), first_ship_date__c=System.today()+1, pull_forward_date__c=System.today()-1);
        insert opp;
        opp.Name='Test';        
        update opp;
    } 
    @isTest
    public static void populateFXrateonOpp(){      
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        Id fedRegistrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Federal Reseller Deal Registration').getRecordTypeId();
        Id runRateRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Run Rate').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id pricebookId = Test.getStandardPricebookId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);
        AccountList[0].Allowed_for_Run_Rate__c = True;
        Update AccountList[0];
        
        Fiscal_Metadata__c fiscalMeta = new Fiscal_Metadata__c();
        fiscalMeta.Fiscal_Period__c='January';
        fiscalMeta.Week_Start_Date__c= Date.newInstance(2019,01,01);
        fiscalMeta.Week_End_Date__c= Date.newInstance(2019,01,05);
        fiscalMeta.Year__c='2019';
        fiscalMeta.Yearly_Week__c='1';
        insert fiscalMeta;  
        //Id cusAccrectypeID = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        //List<Account> lstCustAccount = TestDataSetUpUtils.createAccounts(2, cusAccrectypeID);
        //List<opportunity> opportunityList = TestDataSetUpUtils.createopportunities(2,ProjectRTId,AccountList);
        //List<Opportunity> opportunityList = TestDataSetUpUtils.createProjectOpportunity();
        
        Id cusRecordTypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account','SoldToAccount');
        Id mcnRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();  
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(1,cusRecordTypeId);  
        Test.startTest();
        List<Account> mcnList = TestDataSetUpUtils.createMCNAccounts(1, mcnRecordTypeId, customerAccounts);
        List<Opportunity> opportunityList = TestDataSetUpUtils.createOpportunities(1,ProjectRTId,customerAccounts);
        opportunityList[0].CurrencyIsoCode = 'INR';
        opportunityList[0].closeDate = System.today().addYears(3);
        opportunityList[0].Region__c='NA';
        opportunityList[0].Territory__c='T2';
        opportunityList[0].Country__c='United States';
        opportunityList[0].State__c='Illinois';
        Update opportunityList[0];
        
        //Inserting FX Rate
        FX_Rate__c FXRateNewRecord = new FX_Rate__c();
        FXRateNewRecord.Conversion_Rate__c = 33;
        FXRateNewRecord.CurrencyIsoCode = 'INR';
        FXRateNewRecord.Year__c = System.today().addYears(3).year();
        Insert FXRateNewRecord;
        OpportunityFxRateFlow.populateFxRate(new List<Id>{opportunityList[0].Id});
        
        //Inserting Non USD Opportunities
        //Test.startTest();
        List<Product2> pdtList = new List<Product2>();
        Product2 prd1 = new Product2 (ECW_shortcut__c=true,Personal_Information__c='Yes',Name='Test Product Entry 1',Run_Rate_Product_Group__c = 'EMEA Business Light & Channel',Description='Test Product Entry 1',productCode = 'ABC', isActive = true );
        pdtList.add(prd1);
        insert pdtList;
        List<PricebookEntry> priceBkList = new List<PricebookEntry>();
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=80000, isActive=true,CurrencyIsoCode='EUR');
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=80000, isActive=true,CurrencyIsoCode='USD');
        PricebookEntry pbe3 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=560, isActive=true,CurrencyIsoCode='CAD');
        priceBkList.add(pbe1);
        priceBkList.add(pbe2);
        priceBkList.add(pbe3);
        insert priceBkList;
        
        Opportunity oppty = new Opportunity();
        oppty.recordtypeid = registrationRecTypeId;
        oppty.Name = 'testNonUSDOppty';
        oppty.StageName = 'Prospect';
        oppty.CurrencyIsoCode = 'EUR';
        //oppty.CurrencyIsoCode = 'USD';
        oppty.closedate = System.Today().addYears(3);
        oppty.AccountId = AccountList[0].Id;
        
        oppty.Status__c = 'Active';
        oppty.Region__c = AccountList[0].Region__c;
        oppty.Territory__c= AccountList[0].Territory__c;
        oppty.Country__c = AccountList[0].BillingCountry;
        oppty.State__c = AccountList[0].BillingState;
        insert oppty;
        oppty.Pricebook2Id =pricebookId;
        update oppty;
        system.debug('Standard pb > '+Test.getStandardPricebookId());
        system.debug('opp  pb > '+oppty.Pricebook2ID);
        system.debug('pbe1  pb > '+pbe1.Pricebook2ID);
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=oppty.id,PriceBookEntryID=pbe1.Id,UnitPrice=80000, quantity=4);
        system.debug('lineItem1  pb > '+lineItem1.PriceBookEntryID);
        
        insert lineItem1;
        //system.debug('Num_Product_Families__c'+oppty.Num_Product_Families__c);
       
        
        oppty.Territory__c='EMEA Without UN';
        oppty.Approval_Status__c = 'Approved';
        oppty.Country__c='Benin';
        oppty.Region__c='EA';
        oppty.State__c=NULL;
        oppty.RCAM_ASL__c=UserInfo.getUserId();
        oppty.StageName = 'Design & Validate';
        update oppty;
        oppty.Approval_Status__c = 'Rejected';
        update oppty;
        oppty.Approval_Status__c = 'Waiting Approval';
        update oppty;
        Test.stopTest();
        try{
            oppty.Approval_Status__c = 'Draft';        
            oppty.New_Currency__c = 'CAD';
            update oppty;
        }catch(exception ex){
            system.debug('ex***************'+ex.getMessage());
        }
        
    } 
    @isTest public static void testProjectOpp1(){    
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        Id fedRegistrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Federal Reseller Deal Registration').getRecordTypeId();
        Id runRateRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Run Rate').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(2, prospectId);
        AccountList[0].Allowed_for_Run_Rate__c = True;
        AccountList[1].Allowed_for_Run_Rate__c = True;
        Test.startTest();
        Update AccountList[0];Update AccountList[1];
        Opportunity oppty1 = new Opportunity();
        oppty1.Name = 'testNonUSDOppty';
        oppty1.recordtypeid = ProjectRTId;
        oppty1.StageName = 'Prospect';
        oppty1.CurrencyIsoCode = 'INR';
        oppty1.closedate = System.Today().addYears(3);
        oppty1.AccountId = AccountList[0].Id;
        oppty1.Status__c = 'Active';
        oppty1.Country__c='Afghanistan';
        oppty1.Region__c = 'EA';
        oppty1.Territory__c='United nations';
        oppty1.Extend_Expiry_Date__c = TRUE;
        insert oppty1;
        Test.stopTest();    
        oppty1.Extend_Expiry_Date__c = FALSE;  
        update oppty1;
        delete oppty1;
    } 
    @isTest
    public static void testProjectOpp3(){
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        Id fedRegistrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Federal Reseller Deal Registration').getRecordTypeId();
        Id runRateRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Run Rate').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id competitorId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id ADPLicense = Schema.Sobjecttype.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('ADP License').getRecordTypeId();
        Id Presales = Schema.Sobjecttype.Presales__C.getRecordTypeInfosByName().get('NA Presales Resource').getRecordTypeId();
        
        Fiscal_Metadata__c fiscalMeta = new Fiscal_Metadata__c();
        fiscalMeta.Fiscal_Period__c='January';
        fiscalMeta.Week_Start_Date__c= Date.newInstance(2019,01,01);
        fiscalMeta.Week_End_Date__c= Date.newInstance(2019,01,05);
        fiscalMeta.Year__c='2019';
        fiscalMeta.Yearly_Week__c='1';
        insert fiscalMeta;  
        
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);
        List<Account> AccountListcompetitor = TestDataSetUpUtils.createAccounts(2, competitorId);

        AccountList[0].Allowed_for_Run_Rate__c = True;
        Update AccountList[0];

        List<Opportunity> lstopptyFerdralregis = new  List<Opportunity>();
        Opportunity runrateOpp = new Opportunity();
        runrateOpp.Name = 'testNonUSDOppty4';
        runrateOpp.recordtypeid = registrationRecTypeId;
        runrateOpp.StageName = 'Design & Validate';
        runrateOpp.closedate = System.Today();
        runrateOpp.AccountId = AccountList[0].Id;
        runrateOpp.Status__c = 'Active';
        runrateOpp.Region__c = AccountList[0].Region__c;
        runrateOpp.Territory__c= AccountList[0].Territory__c;
        runrateOpp.Country__c = AccountList[0].BillingCountry;
        runrateOpp.State__c = AccountList[0].BillingState;
        lstopptyFerdralregis.add(runrateOpp);
        Opportunity opptyFerdralregis = new Opportunity();
        opptyFerdralregis.Name = 'testNonUSDOppty3';
        opptyFerdralregis.recordtypeid = fedRegistrationRecTypeId;
        opptyFerdralregis.StageName = 'Design & Validate';
        opptyFerdralregis.Approval_Status__c='APPROVAL IN PROCESS- ADMIN APPROVED';
        opptyFerdralregis.CurrencyIsoCode = 'INR';
        opptyFerdralregis.closedate = Date.Today()+35;
        opptyFerdralregis.AccountId = AccountList[0].Id;
        opptyFerdralregis.Status__c = 'Active';
        opptyFerdralregis.Primary_Competitor__c='3Com';
        opptyFerdralregis.Competition__c='ACS';
        opptyFerdralregis.Region__c='NA';
        opptyFerdralregis.Territory__c='Civil LEA';
        opptyFerdralregis.Country__c='United States';
        opptyFerdralregis.State__c='Illinois';
        lstopptyFerdralregis.add(opptyFerdralregis);

        insert lstopptyFerdralregis;
        Test.startTest();
        
        lstopptyFerdralregis.get(0).closedate = System.Today().addYears(3);
        
        update lstopptyFerdralregis;
        lstopptyFerdralregis.get(0).recordtypeid = ProjectRTId;
        lstopptyFerdralregis.get(0).Approval_Status__c='Rejected';
        lstopptyFerdralregis.get(0).Region__c='NA';
        update lstopptyFerdralregis;
        
        lstopptyFerdralregis.get(1).Approval_Status__c='CAM Approved';

        update lstopptyFerdralregis;

        lstopptyFerdralregis.get(1).Approval_Status__c='Approved';
        update lstopptyFerdralregis;
        system.debug('SOQL LIMIT'+LIMITS.getQueries());
				
		
        Presales__c psrr = new Presales__c(opportunity__c = lstopptyFerdralregis[1].id,RecordTypeId = Presales,Project_Description__c = 'Testing',
                                           Proposal_Type_N__c = 'Federal ROM',System_Integration_PBM_Resource_Needed__c = 'NO',
                                           Engineering_Resource_Needed__c = 'NO',SPSS_Resource_Needed__c = 'NO',//Solution_Architect_Resource_Needed__c='NO',
                                           Pricing_Profitability_Resources_Needed__c = 'NO',Proposal_Resource_Needed__c = 'NO',
                                           Service_Resource_Needed__c = 'NO',Project_Specialist_Resource_Needed__c   = 'NO',
                                           Proposal_Kick_off_Date__c = Date.TODAY() , RFx_Proposal_Due_Date__c = Date.TODAY(),Presale_Resource_Request_Status__c ='No-Bid');

        insert psrr;

        List<Apttus__APTS_Agreement__c> Apptus = TestDataSetUpUtils.createAgreement(1,ADPLicense,AccountList,psrr,lstopptyFerdralregis);

        Opportunity opptyFiscal = new Opportunity();
        opptyFiscal.Name = 'testNonUSDOppty1';
        opptyFiscal.recordtypeid = ProjectRTId;
        opptyFiscal.StageName = 'Design & Validate';
        opptyFiscal.CurrencyIsoCode = 'INR';
        opptyFiscal.closedate = Date.newInstance(2019,01,03);
        opptyFiscal.AccountId = AccountList[0].Id;
        opptyFiscal.Status__c = 'Active';
        opptyFiscal.Primary_Competitor__c='3Com';
        opptyFiscal.Competition__c='ACS';
        opptyFiscal.ForecastCategoryName='Commit';
        opptyFiscal.Region__c='NA';
        opptyFiscal.MIP_Agreement__c=Apptus.get(0).Id;
        opptyFiscal.Project_Status__c='Postsale SI Projects';
        insert opptyFiscal;
        

        List<Product2> pdtList = new List<Product2>();
        Product2 prd1 = new Product2 (ECW_shortcut__c=true,Personal_Information__c='Yes',Name='Test Product Entry 2',Run_Rate_Product_Group__c = 'EMEA Business Light & Channel',Description='Test Product Entry 1',productCode = 'ABC', isActive = true );
        pdtList.add(prd1);
        insert pdtList;
                Test.stopTest();

    }  
    @isTest
    static void UpdateOppApproval_PSRR(){          
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();  
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id PSRRRTId = Schema.Sobjecttype.Presales__c.getRecordTypeInfosByName().get('NA Presales Resource').getRecordTypeId();
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, ProjectRTId, accList);
        OppList[0].Region__c = 'NA'; 
        OppList[0].Approval_Status__c ='Rejected'; 
        update OppList;
        Test.startTest();
        List<presales__c> PSRList = TestDataSetUpUtils.CreatepreSaleRecords(1, PSRRRTId, oppList);           
        //OppList[0].Approval_Status__c ='Rejected'; 
        PSRList[0].Proposal_Type_N__c ='Non Proposal Project Support';
        //update OppList;
        update PSRList;
        Test.stopTest(); 
    }  
    @isTest
    static void InsertRegOpp(){          
        Id customerRTId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        Id mcnRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();  
        Id regRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,customerRTId);
        Test.startTest();
        List<Account> mcnList = TestDataSetUpUtils.createMCNAccounts(1, mcnRecordTypeId, accList);
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, regRTId, accList);
        Test.stopTest();      
        OppList[0].Region__c = 'NA';              
        update OppList;      
    }  
    @isTest
    public static void testProjectOpp31(){              
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
        Id runRateRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Run Rate').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id competitorId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id ADPLicense = Schema.Sobjecttype.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('ADP License').getRecordTypeId();
        Id Presales = Schema.Sobjecttype.Presales__C.getRecordTypeInfosByName().get('NA Presales Resource').getRecordTypeId();
        
        /*List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);
            
        AccountList[0].Allowed_for_Run_Rate__c = True;
        Update AccountList[0];*/
        List<Account> AccountList = [SELECT ID,Recordtype.name from Account where name like 'Test %' and recordtype.name = 'Prospect'];
        System.debug('Prospect acc..'+AccountList[0].Id + '***'+ AccountList[0].recordtype.name);
        List<Opportunity> lstopptyFerdralregis = new  List<Opportunity>();
        Opportunity runrateOpp = new Opportunity();
        runrateOpp.Name = 'testNonUSDOppty4';
        runrateOpp.recordtypeid = registrationRecTypeId;
        runrateOpp.StageName = 'Design & Validate';
        runrateOpp.closedate = System.Today();
        runrateOpp.AccountId = AccountList[0].Id;
        runrateOpp.Status__c = 'Active';
        
        Test.startTest();
        List<Account> AccountListcompetitor = [SELECT Id,MSI_Competitor_Account__c,recordtype.name from account where name like 'Test %' and recordtype.name = 'Competitor'];
        System.debug('Test Competitor acc..'+AccountListcompetitor[0].Id+'****'+AccountListcompetitor[0].recordtype.name+'***'+AccountListcompetitor[0].MSI_Competitor_Account__c);
        runrateOpp.Primary_Competitor_Account__c=AccountListcompetitor[0].Id; // added by sagar
        lstopptyFerdralregis.add(runrateOpp); 
        //insert lstopptyFerdralregis;        
        lstopptyFerdralregis.get(0).closedate = System.Today().addYears(3);      
        lstopptyFerdralregis.get(0).recordtypeid = ProjectRTId;
        lstopptyFerdralregis.get(0).Region__c='NA';        
        lstopptyFerdralregis.get(0).Award_Date__c= Date.newInstance(2019,01,03);
        lstopptyFerdralregis.get(0).mh_Place_in_Sales_Funnel__c='No Pursuit';    
        lstopptyFerdralregis.get(0).Region__c='NA';
        lstopptyFerdralregis.get(0).Territory__c='T1';
        lstopptyFerdralregis.get(0).Country__c='Canada';
        lstopptyFerdralregis.get(0).State__c='Alberta';
        insert lstopptyFerdralregis;
        //update lstopptyFerdralregis;
        
        Presales__c psrr = new Presales__c(opportunity__c = lstopptyFerdralregis[0].id,RecordTypeId = Presales,Project_Description__c = 'Testing',
                                           Proposal_Type_N__c = 'Federal ROM',System_Integration_PBM_Resource_Needed__c = 'NO',
                                           Engineering_Resource_Needed__c = 'NO',SPSS_Resource_Needed__c = 'NO',//Solution_Architect_Resource_Needed__c='NO',
                                           Pricing_Profitability_Resources_Needed__c = 'NO',Proposal_Resource_Needed__c = 'NO',
                                           Service_Resource_Needed__c = 'NO',Project_Specialist_Resource_Needed__c   = 'NO',
                                           Proposal_Kick_off_Date__c = Date.TODAY() , RFx_Proposal_Due_Date__c = Date.TODAY(),Presale_Resource_Request_Status__c ='Active');        
        insert psrr;
        List<Apttus__APTS_Agreement__c> apptusAgree = TestDataSetUpUtils.createAgreement(1,ADPLicense,AccountList,psrr,lstopptyFerdralregis);
        Test.stopTest();
        apptusAgree.get(0).m_GTM_Region__c = 'EMEA';
        List<Sobject> sobjectsToUpdate = new List<Sobject>();
        sobjectsToUpdate.add(apptusAgree[0]);
        //update apptusAgree;
        lstopptyFerdralregis.get(0).StageName = 'Execute & Expand / Won';
        //lstopptyFerdralregis.get(0).StageName = 'Execute & Expand / Won';
        lstopptyFerdralregis.get(0).Sales_Process__c='Account_Management';
        lstopptyFerdralregis.get(0).Reason_for_Win_or_Loss__c='MSI as the provider';
        sobjectsToUpdate.add(lstopptyFerdralregis[0]);
        Database.update(sobjectsToUpdate,false);
        //update lstopptyFerdralregis;
    }
    /*@isTest
    public static void testProjectOpp31_PartTwo(){              
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id competitorId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id ADPLicense = Schema.Sobjecttype.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('ADP License').getRecordTypeId();
        Id Presales = Schema.Sobjecttype.Presales__C.getRecordTypeInfosByName().get('NA Presales Resource').getRecordTypeId();
        
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);
        List<Account> AccountListcompetitor = TestDataSetUpUtils.createAccounts(1, competitorId);      
        List<Opportunity> opportunityList = TestDataSetUpUtils.createOpportunities(1,ProjectRTId,AccountList);
        Test.startTest();
        Presales__c psrr = new Presales__c(opportunity__c = opportunityList[0].id,RecordTypeId = Presales,Project_Description__c = 'Testing',
                                           Proposal_Type_N__c = 'Federal ROM',System_Integration_PBM_Resource_Needed__c = 'NO',
                                           Engineering_Resource_Needed__c = 'NO',SPSS_Resource_Needed__c = 'NO',//Solution_Architect_Resource_Needed__c='NO',
                                           Pricing_Profitability_Resources_Needed__c = 'NO',Proposal_Resource_Needed__c = 'NO',
                                           Service_Resource_Needed__c = 'NO',Project_Specialist_Resource_Needed__c   = 'NO',
                                           Proposal_Kick_off_Date__c = Date.TODAY() , RFx_Proposal_Due_Date__c = Date.TODAY(),Presale_Resource_Request_Status__c ='Active');
        insert psrr;
        List<Apttus__APTS_Agreement__c> apptusAgree = TestDataSetUpUtils.createAgreement(1,ADPLicense,AccountList,psrr,opportunityList);
        apptusAgree.get(0).m_GTM_Region__c = 'EMEA';
        update apptusAgree;
        Test.stopTest();
        opportunityList.get(0).StageName = 'Lost';
        opportunityList.get(0).Sales_Process__c='Account_Management';
        opportunityList.get(0).Detailed_Sales_Process__c='Lost';
        opportunityList.get(0).Award_Date__c = System.today()-4;
        opportunityList.get(0).Reason_for_Win_or_Loss__c='Field of Play Strategy';
        opportunityList.get(0).ForecastCategoryName='Omitted';
        opportunityList.get(0).Primary_Competitor_Account__c=AccountListcompetitor[0].Id; //VESTA_SPILLMAN_INT-903      
        opportunityList.get(0).Pull_Forward_Date__c= Date.newInstance(2019,01,02);
        opportunityList.get(0).MIP_Agreement__c=apptusAgree.get(0).Id;
        update opportunityList;
        
    }*/
    /*@isTest
    public static void callPartnerSharing(){
        PartnerSharingHelper_Test.test_partnerSharingHelper();      
    }*/
    @isTest
    public static void callPartnerSharing1(){
        PartnerSharingHelper_Test.test_partnerSharingHelper1();
    }
    @isTest
    public static void fiscalweekUpdateBRR(){
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> AccountList = TestDataSetUpUtils.createAccounts(1, prospectId);
        List<Briefing_Room_Report__c> lstBRR = new List<Briefing_Room_Report__c>();
        
        //Briefing_Room_Report__c
        List<Fiscal_Metadata__c> lstFiscalWeek = new List<Fiscal_Metadata__c>();
        Fiscal_Metadata__c fiscalMeta = new Fiscal_Metadata__c();
        fiscalMeta.Fiscal_Period__c='January';
        fiscalMeta.Week_Start_Date__c= Date.newInstance(2019,01,01);
        fiscalMeta.Week_End_Date__c= Date.newInstance(2019,01,05);
        fiscalMeta.Year__c='2019';
        fiscalMeta.Yearly_Week__c='1';
        lstFiscalWeek.add(fiscalMeta);
        
        Fiscal_Metadata__c fiscalMeta1 = new Fiscal_Metadata__c();
        fiscalMeta1.Fiscal_Period__c='April';
        fiscalMeta1.Week_Start_Date__c= Date.newInstance(2020,03,29);
        fiscalMeta1.Week_End_Date__c= Date.newInstance(2020,04,04);
        fiscalMeta1.Year__c='2020';
        fiscalMeta1.Yearly_Week__c='14';
        lstFiscalWeek.add(fiscalMeta1);
        
        Fiscal_Metadata__c fiscalMeta2 = new Fiscal_Metadata__c();
        fiscalMeta2.Fiscal_Period__c='April';
        fiscalMeta2.Week_Start_Date__c= Date.newInstance(2020,04,05);
        fiscalMeta2.Week_End_Date__c= Date.newInstance(2020,04,11);
        fiscalMeta2.Year__c='2020';
        fiscalMeta2.Yearly_Week__c='15';
        lstFiscalWeek.add(fiscalMeta2);
        
        Fiscal_Metadata__c fiscalMeta3 = new Fiscal_Metadata__c();
        fiscalMeta3.Fiscal_Period__c='April';
        fiscalMeta3.Week_Start_Date__c= Date.newInstance(2020,04,12);
        fiscalMeta3.Week_End_Date__c= Date.newInstance(2020,04,18);
        fiscalMeta3.Year__c='2020';
        fiscalMeta3.Yearly_Week__c='16';
        lstFiscalWeek.add(fiscalMeta3);
        
        Fiscal_Metadata__c fiscalMeta4 = new Fiscal_Metadata__c();
        fiscalMeta4.Fiscal_Period__c='April';
        fiscalMeta4.Week_Start_Date__c= Date.newInstance(2020,04,19);
        fiscalMeta4.Week_End_Date__c= Date.newInstance(2020,04,24);
        fiscalMeta4.Year__c='2020';
        fiscalMeta4.Yearly_Week__c='17';
        lstFiscalWeek.add(fiscalMeta4);
        
        Fiscal_Metadata__c fiscalMeta5 = new Fiscal_Metadata__c();
        fiscalMeta5.Fiscal_Period__c='May';
        fiscalMeta5.Week_Start_Date__c= Date.newInstance(2020,04,25);
        fiscalMeta5.Week_End_Date__c= Date.newInstance(2020,05,02);
        fiscalMeta5.Year__c='2020';
        fiscalMeta5.Yearly_Week__c='18';
        lstFiscalWeek.add(fiscalMeta5);
        
        Fiscal_Metadata__c fiscalMeta6 = new Fiscal_Metadata__c();
        fiscalMeta6.Fiscal_Period__c='May';
        fiscalMeta6.Week_Start_Date__c= Date.newInstance(2020,05,03);
        fiscalMeta6.Week_End_Date__c= Date.newInstance(2020,05,09);
        fiscalMeta6.Year__c='2020';
        fiscalMeta6.Yearly_Week__c='19';
        lstFiscalWeek.add(fiscalMeta6);
        
        Fiscal_Metadata__c fiscalMeta7 = new Fiscal_Metadata__c();
        fiscalMeta7.Fiscal_Period__c='January';
        fiscalMeta7.Week_Start_Date__c= Date.newInstance(2021,01,03);
        fiscalMeta7.Week_End_Date__c= Date.newInstance(2021,01,09);
        fiscalMeta7.Year__c='2021';
        fiscalMeta7.Yearly_Week__c='2';
        lstFiscalWeek.add(fiscalMeta7);
        
        Fiscal_Metadata__c fiscalMeta8 = new Fiscal_Metadata__c();
        fiscalMeta8.Fiscal_Period__c='January';
        fiscalMeta8.Week_Start_Date__c= Date.newInstance(2021,01,10);
        fiscalMeta8.Week_End_Date__c= Date.newInstance(2021,01,16);
        fiscalMeta8.Year__c='2021';
        fiscalMeta8.Yearly_Week__c='3';
        lstFiscalWeek.add(fiscalMeta8);
        
        
        Fiscal_Metadata__c fiscalMeta9 = new Fiscal_Metadata__c();
        fiscalMeta9.Fiscal_Period__c='February';
        //fiscalMeta9.Week_Start_Date__c= Date.newInstance(2020,01,17);
        //fiscalMeta9.Week_End_Date__c= Date.newInstance(2020,01,23);
        fiscalMeta9.Week_Start_Date__c= Date.newInstance(2021,01,30);
        fiscalMeta9.Week_End_Date__c= Date.newInstance(2021,02,06);
        fiscalMeta9.Year__c='2021';
        fiscalMeta9.Yearly_Week__c='5';
        lstFiscalWeek.add(fiscalMeta9);
        
        
        Fiscal_Metadata__c fiscalMeta10 = new Fiscal_Metadata__c();
        fiscalMeta10.Fiscal_Period__c='February';
        //fiscalMeta9.Week_Start_Date__c= Date.newInstance(2020,01,17);
       // fiscalMeta9.Week_End_Date__c= Date.newInstance(2020,01,23);
        fiscalMeta10.Week_Start_Date__c= Date.newInstance(2021,02,07);
        fiscalMeta10.Week_End_Date__c= Date.newInstance(2021,02,13);
        fiscalMeta10.Year__c='2021';
        fiscalMeta10.Yearly_Week__c='7';
        lstFiscalWeek.add(fiscalMeta10);
        
        Test.startTest();
        insert lstFiscalWeek;
        
        
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending April 24 2020',Fiscal_Week__c = lstFiscalWeek.get(0).Id));
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending April 11 2020',Fiscal_Week__c = lstFiscalWeek.get(1).Id));
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending April 18 2020',Fiscal_Week__c = lstFiscalWeek.get(2).Id));
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending April 04 2020',Fiscal_Week__c = lstFiscalWeek.get(3).Id));
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending May 02 2020',Fiscal_Week__c = lstFiscalWeek.get(4).Id));
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending May 09 2020',Fiscal_Week__c = lstFiscalWeek.get(5).Id));
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending May 16 2020',Fiscal_Week__c = lstFiscalWeek.get(6).Id));
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending May 22 2020',Fiscal_Week__c = lstFiscalWeek.get(7).Id));  
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending September 29 2020',Fiscal_Week__c = lstFiscalWeek.get(8).Id)); 
        lstBRR.add(new Briefing_Room_Report__c(name='Week Ending September lstFiscalWeek 9 2020',Fiscal_Week__c = lstFiscalWeek.get(9).Id));  
         lstBRR.add(new Briefing_Room_Report__c(name='Week Ending September lstFiscalWeek 9 2021',Fiscal_Week__c = lstFiscalWeek.get(10).Id));  
        insert lstBRR;
        
         List<Briefing_Room_Report__c> lstBRRUpdate = new List<Briefing_Room_Report__c>();
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(0).Id,Previous_Week_s_BRR__c=NULL,Next_Week_s_BRR__c=lstBRR.get(1).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(1).Id,Previous_Week_s_BRR__c=lstBRR.get(0).Id,Next_Week_s_BRR__c=lstBRR.get(2).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(2).Id,Previous_Week_s_BRR__c=lstBRR.get(1).Id,Next_Week_s_BRR__c=lstBRR.get(3).Id));
		lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(3).Id,Previous_Week_s_BRR__c=lstBRR.get(2).Id,Next_Week_s_BRR__c=lstBRR.get(4).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(4).Id,Previous_Week_s_BRR__c=lstBRR.get(3).Id,Next_Week_s_BRR__c=lstBRR.get(5).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(5).Id,Previous_Week_s_BRR__c=lstBRR.get(4).Id,Next_Week_s_BRR__c=lstBRR.get(6).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(6).Id,Previous_Week_s_BRR__c=lstBRR.get(5).Id,Next_Week_s_BRR__c=lstBRR.get(7).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(7).Id,Previous_Week_s_BRR__c=lstBRR.get(6).Id,Next_Week_s_BRR__c=lstBRR.get(8).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(8).Id,Previous_Week_s_BRR__c=lstBRR.get(7).Id,Next_Week_s_BRR__c=lstBRR.get(9).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(9).Id,Previous_Week_s_BRR__c=lstBRR.get(8).Id,Next_Week_s_BRR__c=lstBRR.get(10).Id));
        lstBRRUpdate.add(new Briefing_Room_Report__c(Id= lstBRR.get(10).Id,Previous_Week_s_BRR__c=lstBRR.get(9).Id,Next_Week_s_BRR__c=NULL));
        update lstBRRUpdate;
        List<Opportunity> lstOpp = new List<Opportunity>();
        //OpportunityTriggerHandler.TriggerDisabled =true;
        Opportunity opptyFiscal = new Opportunity();
        opptyFiscal.Name = 'testNonUSDOppty1';
        opptyFiscal.recordtypeid = ProjectRTId;
        opptyFiscal.StageName = 'Design & Validate';
        opptyFiscal.CurrencyIsoCode = 'INR';
        opptyFiscal.closedate = Date.newInstance(2019,01,03);
        opptyFiscal.AccountId = AccountList[0].Id;
        opptyFiscal.Status__c = 'Active';
        opptyFiscal.Primary_Competitor__c='3Com';
        opptyFiscal.Competition__c='ACS';
        opptyFiscal.ForecastCategoryName='Commit';
        opptyFiscal.Region__c='NA';
        opptyFiscal.Project_Status__c='Postsale SI Projects';
        // insert opptyFiscal;
        opptyFiscal.Is_Created_From_Conversion__c =true;
        opptyFiscal.Fiscal_Metadata__c = NULL;
        opptyFiscal.Pull_Forward_Date__c = Date.newInstance(2019, 01, 02);
        opptyFiscal.Forecast_Notes__c='test';
        lstOpp.add(opptyFiscal);
        insert lstOpp;
        Opportunity oppUp = new Opportunity();
        oppUp.Id=lstOpp.get(0).Id;
        oppUp.Forecast_Notes__c='testm';
        //Test.stopTest();
        update oppUp;
        system.debug('lstBRRUpdate.get(7).Id'+lstBRRUpdate.get(7).Id);
        Opportunity oppUp1 = new Opportunity();
        oppUp1.Id=lstOpp.get(0).Id;
        oppUp1.Forecast_Notes__c='testm1';
        oppUp1.New_Currency__c = 'EUR';
        update oppUp1;
        oppUp1.Forecast_Notes__c='testm234';
        oppUp1.StageName ='Execute & Expand / Won';
        oppUp1.Award_Date__c = system.today();
        oppUp1.Reason_for_Win_or_Loss__c = 'Significant strengths in our solution';
       // oppUp1.Briefing_Room_Report__c =lstBRRUpdate.get(7).Id;
        //update oppUp1;
        OpportunityTriggerHandler.TriggerDisabled =false;
        OpportunityTriggerHelper opphelper = new OpportunityTriggerHelper();
        opphelper.calculateFiscalFields(lstOpp,false,true);
        Test.stopTest();
        opphelper.calculateFiscalFields(lstOpp,false,false);
    }  
    @isTest
    public static void revenuemethod(){
        Id AccRegId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> acclist = TestDataSetUpUtils.createaccounts(1,AccRegId);
        Id OppRegId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        OpportunityTriggerHandler.TriggerDisabled = true;
        OpportunityLineItemTriggerHandler.TriggerDisabled = true;
        List<opportunity> opplist = TestDataSetUpUtils.createOpportunities(1, OppRegId, acclist);
        ProductTriggerHandler.TriggerDisabled = true;
        Product2 prod = new Product2 (ECW_shortcut__c=true,Personal_Information__c='Yes',Name='Test Product Entry 1',
                                      Run_Rate_Product_Group__c = 'EMEA Business Light & Channel',
                                      Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prod;
        ProductTriggerHandler.TriggerDisabled = false;
        List<OpportunityLineItem> oliList = TestDataSetUpUtils.createOLIs(opplist);
        oliList[0].TotalPrice = 1000;
        oliList[0].quantity = 10;
        Test.startTest();
        update oliList[0];
        OpportunityLineItemTriggerHandler.TriggerDisabled = false;
        List<Opportunity_Product_Mirror__c> lstOppproductmirror =new List<Opportunity_Product_Mirror__c>();
        Opportunity_Product_Mirror__c opm = new Opportunity_Product_Mirror__c();
        opm.Opportunity__c=opplist.get(0).Id;
        lstOppproductmirror.add(opm);
        insert lstOppproductmirror;
        //OpportunityTriggerHandler.TriggerDisabled = false;
        Revenue__c rev1 = new Revenue__c();
        rev1.Opportunity__c = opplist[0].id;
        rev1.Product_Family__c = oliList[0].id;
        rev1.ProductFamily__c = prod.id;
        rev1.Revenue_Month__c = 'January';
        rev1.Revenue_Year__c = '2021';
        rev1.CurrencyIsoCode = 'USD';
        rev1.Revenue_Amount__c = 2500;
        rev1.Opportunity_Product_Mirror__c = lstOppproductmirror.get(0).Id;
        insert rev1;
        
        Test.stopTest();
        OpportunityTriggerHandler.TriggerDisabled = false;
        Opportunity opp = new Opportunity();
        opp.Id= opplist.get(0).Id;
        opp.Aging_Type__c ='Relative';
        opp.CloseDate = opplist.get(0).CloseDate.addDays(90);
        //opp.New_Currency__c = 'EUR';
        //update opp;
        
        //OpportunityTriggerHandler oh = new OpportunityTriggerHandler();
        //Set<String> oppIds = new Set<String>{opp.Id};
        //oh.insertGoogleDriveAfterInsert(oppIds);
    }
    @isTest
    public static void opportunityTest_newMethod(){  
        Id projectRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id prospectRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id cusRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id mcnRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();  
        List<Account> prospectAccounts = TestDataSetUpUtils.createAccounts(1,prospectRecordTypeId);
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(1,cusRecordTypeId);  
        Test.startTest();
        List<Account> mcnList = TestDataSetUpUtils.createMCNAccounts(1, mcnRecordTypeId, customerAccounts);
        List<Opportunity> opportunityList = TestDataSetUpUtils.createOpportunities(1,projectRecTypeId,prospectAccounts);
        //List<Opportunity> opportunityList = TestDataSetUpUtils.createOpportunities(1,projectRecTypeId,customerAccounts);
        //Test.startTest();
        opportunityList.get(0).Sales_Process__c = 'Account_Management';
        opportunityList.get(0).StageName = 'Position & Align';
        //opportunityList.get(0).Detailed_Sales_Process__c = 'Interest';
        opportunityList.get(0).Detailed_Sales_Process__c = 'Position & Align';
        opportunityList.get(0).Product_Forecast_Commitment__c = 'Non Commit';
        opportunityList.get(0).Pricebook2Id =Test.getStandardPricebookId();
        
        update opportunityList;


        Product2 prod = new Product2(ECW_shortcut__c=true,Personal_Information__c='Yes',Name='Test Product',
                                      Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prod;
        List<OpportunityLineItem> oliList = TestDataSetUpUtils.createOLIs(opportunityList);
        
        
        oliList[0].TotalPrice = 350000;
        oliList[0].quantity = 10;
        update oliList;
        opportunityList.get(0).AccountId = customerAccounts.get(0).Id;
        update opportunityList;
        Test.stopTest();       
    }
    @isTest static void opportunityGoogleDriveTest(){
        GoogleDriveTest.opportunityGoogleDriveTest();
    }
    @isTest static void opportunityTeamMemberGoogleDriveTest(){
        GoogleDriveTest.opportunityTeamMemberGoogleDriveTest();
    }
    @isTest static void updateCurrencyTest(){
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();  
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id PSRRRTId = Schema.Sobjecttype.Presales__c.getRecordTypeInfosByName().get('NA Presales Resource').getRecordTypeId();
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, ProjectRTId, accList);
        Set<String> newCurrencyList = new Set<String>();
        Set<String> oldCurrencyList = new Set<String>();
        newCurrencyList.add('USD');
        oldCurrencyList.add('CAD');
        
        OppList.get(0).New_Currency__c = 'EUR';
        //OppList.get(0).Num_Product_Families__c = 0;
        OpportunityTriggerHelper.changeCurrency = False;
        OpportunityTriggerHelper opphelper = new OpportunityTriggerHelper();
        system.debug('Num_Product_Families__c+*****'+OppList.get(0).Num_Product_Families__c);
        opphelper.updateNewCurrency(OppList);
        try{
           opphelper.createOpportunityProduct(newCurrencyList,oldCurrencyList);
        }catch(Exception ex){
            
        }
        
    }
    @isTest static void apptusTest(){
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();  
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        Id PSRRRTId = Schema.Sobjecttype.Presales__c.getRecordTypeInfosByName().get('NA Presales Resource').getRecordTypeId();
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        List<Opportunity> OppList = TestDataSetUpUtils.createOpportunities(1, ProjectRTId, accList);
        OpportunityTriggerHelper opphelper = new OpportunityTriggerHelper();
        opphelper.updateInheritedMIPonAgreements(OppList);
    }
    public static testMethod void partnerOpportunityTriggerHandlerTest(){
        Try{
            Id registrationRecTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Registration').getRecordTypeId();
            Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
            List<Account> AccountList = TestDataSetUpUtils.createAccounts(2, prospectId);
            AccountList[0].Allowed_for_Run_Rate__c = True;
            AccountList[1].Allowed_for_Run_Rate__c = True;
            Test.startTest();
            Update AccountList[0];
            Update AccountList[1];
            //Inserting Non USD Opportunities 
            //User u123 = [SELECT id,name FROM User WHERE Profile.name = 'EA Partner Profile' and ISactive = TRUE LIMIT 1];
            User u123 = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            //User usr = [SELECT id,name FROM user WHERE profile.name = 'EMEA Motorola Government Systems User' LIMIT 1];
            OpportunityTriggerHandler.TriggerDisabled = true;
            Opportunity oppty = new Opportunity();
            oppty.Name = 'testNonUSDOppty';
            oppty.recordtypeid = registrationRecTypeId;
            oppty.StageName = 'Prospect';
            oppty.CurrencyIsoCode = 'INR';
            oppty.closedate = System.Today().addYears(3);
            oppty.AccountId = AccountList[0].Id;
            oppty.Status__c = 'Active';
            oppty.Approval_Status__c = 'Waiting Approval';
            oppty.region__c = 'NA';
            oppty.Country__c = 'United states';
            oppty.State__c = 'Alaska';
            oppty.Territory__c = 'T2';
            //oppty.RCAM_ASL__c = usr.id;
            oppty.ownerId = u123.Id;
            oppty.Is_the_end_user_an_existing_MSI_Customer__c = 'YES';
            insert oppty;
            oppty.Approval_Status__c = 'Waiting Approval';
            update oppty;
            system.debug('oppty.Approval_Status__c '+oppty.Approval_Status__c );
            oppty.Approval_Status__c = 'PIC Approved';
            oppty.Is_the_end_user_an_existing_MSI_Customer__c = '';
            oppty.Assigned_CAM__c = NULL;
            update oppty;
            system.debug('oppty.Approval_Status__c '+oppty.Approval_Status__c);
            system.debug('oppty.Assigned_CAM__c '+oppty.Assigned_CAM__c );
        }
        catch(System.DmlException e) {
            System.debug('Message:Please update Internal questionnaire section before approval');
        }
        Test.stopTest();
        
    }  
//Test method for Auto Create CAPP records (createCAPPRecords) SF-2461
    @isTest
    public static void testAutoCreateCAPP(){    
        
        //Create Customer Account
        Id customerRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        TestDataSetUpUtils.activateAccTrigger();
        List<Account> customerAccounts = TestDataSetUpUtils.createAccounts(1, customerRecordTypeId);
        //Create Opportuities
        List<Opportunity> lstOpps = TestDataSetUpUtils.createOpportunities(2,Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(),customerAccounts);
        lstOpps[0].Auto_Create_CAPP_Record__c = 'Yes, update top CAPP Vendor & Purchase Year';
        lstOpps[1].Auto_Create_CAPP_Record__c = 'Yes, update top CAPP Vendor & Purchase Year';
        //Create OpportunityLinItems
        PricebookEntry instOfPBE = TestDataSetUpUtils.createPriceBookEntry();
        Pricebook2 PB = new Pricebook2(Name='Standard Price Book', isActive=true);
        insert PB;
        Pricebook2 PB1 = new Pricebook2(Name='Run Rate', isActive=true);
        insert PB1; 
        system.debug(instOfPBE.Product2Id);
        TestDataSetUpUtils.activateOpplineItemTrigger();
        for(Opportunity oppy : lstOpps){
            oppy.Pricebook2Id = Test.getStandardPricebookId();
        }
        update lstOpps;
        TestDataSetUpUtils.createOpportunityLineItems(1,lstOpps[0].Id,instOfPBE);
        //Create CAPP Rule Records
        TestDataSetUpUtils.createCAPPRulerecord(instOfPBE.Product2Id, 'Land Mobile Radio (LMR) Mobiles');
        
        //Create Competitor Account
        Id accCompRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        Id cappRecordTypeId = Schema.getGlobalDescribe().get('Customer_Portfolio_Presence__c').getDescribe().getRecordTypeInfosByName().get('Emergency Call Taking (911)').getRecordTypeId();   
        TestDataSetUpUtils.activateAccTrigger();
        Id VendorId = TestDataSetUpUtils.createAccounts(1, accCompRecordTypeId)[0].Id;
        
        //Create CAPP Record
        List<Customer_Portfolio_Presence__c> CAPPRecords = TestDataSetUpUtils.createCAPPs(1, VendorId, cappRecordTypeId);
        //Create System RelationShip Record
        List<System_Relationship__c> systemRecords = TestDataSetUpUtils.createSystemRelations(1, CAPPRecords[0].Id, customerAccounts[0].Id, null, null );
        
        Test.startTest();
        lstOpps[0].StageName = 'Execute & Expand / Won';
        lstOpps[0].Award_Date__c= Date.newInstance(2021,01,03);
        lstOpps[0].Reason_for_Win_or_Loss__c='MSI as the provider';
        Database.update(lstOpps[0],false);
        
        TestDataSetUpUtils.createOpportunityLineItems(1,lstOpps[1].Id,instOfPBE);
        TestDataSetUpUtils.createCAPPRulerecord(instOfPBE.Product2Id, 'Land Mobile Radio (LMR) Mobiles');
        lstOpps[1].StageName = 'Execute & Expand / Won';
        lstOpps[1].Award_Date__c= Date.newInstance(2021,01,03);
        lstOpps[1].Reason_for_Win_or_Loss__c='MSI as the provider';
        Database.update(lstOpps[1],false);
        Test.stopTest();
        
    }
}