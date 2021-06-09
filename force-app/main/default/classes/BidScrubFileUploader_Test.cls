/*
 * Name : BidScrubFileUploader_Test
 * Description : Test class for BidScrubTriggerHandler and BidScrubFileUploader classes
 * 
 */

@isTest(seeAllData = false)
public class BidScrubFileUploader_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    public static testMethod void testBidScrubFileUploader() {
        Account acc1 = new Account(Name = 'testAccount1', RECORDTYPEID = '012300000000OSh', 
                                   BILLINGSTREET = '24-60 20 CALLE', Billingcity = 'San Mateo',Billingstate = 'Texas',
                                   BillingCountry = 'United States',BillingPostalCode='123',
                                   INDUSTRY = 'Education',
                                   LEVEL__C = 'Authorized Reseller',
                                   Metal_Level__c = 'test',
                                   Partner_Region__c = 'APAC'
                                  );
        insert acc1;
        
        Opportunity opp1 = new Opportunity(name = 'testopp1', Account = acc1, stagename = 'Secure', closedate = System.today(), ownerid = UserInfo.getUserId(), first_ship_date__c = System.today() + 1, pull_forward_date__c = System.today() - 1);
        insert opp1;
        Opportunity opp2 = [select id, SYM_Transaction_Number__c from opportunity where id = : opp1.Id];
        
        Bid_Scrub__c bid = new Bid_Scrub__c();
        bid.Opportunity_Transaction_Number__c = opp2.SYM_Transaction_Number__c;
        bid.Opportunity__c = opp2.Id;
        //bid.Name = 'testbid';
        // bid.Product_Family__c='ASTRO Managed Services';
        bid.Product_APC__c = '567';
        bid.Product_WWAPC__c = '5336';
        bid.Quantity__c = 100;
        bid.UnitPrice__c = 1000;
        bid.CurrencyIsoCode = 'USD';
        insert bid;
        
        Forecasting_Product_Family__c FPF2 = new Forecasting_Product_Family__c();
        FPF2.APC__c = '123';
        FPF2.Forecast_Rollup_WWAPC_Code__c = '456';
        //FPF.Product_Family__c = '';
        insert FPF2;
        
        PageReference pageRef = Page.UploadBidScrub;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('FileName', 'BidScrubUpload');
        BidScrubFileUploader p = new BidScrubFileUploader(new ApexPages.StandardController(new Bid_Scrub__c()));
        String strcsv = opp2.SYM_Transaction_Number__c + ',' + '123,456,20,30,USD';
        strcsv += opp2.SYM_Transaction_Number__c + ',' + '123,456,30,60,USD';
        strcsv += '\n';
        strcsv += '3064667,5336,1234,30,30,USD';
        strcsv += '\n';
        Blob b = Blob.valueOf(strcsv);
        p.contentFile = b;
        p.nameFile = 'BidScrubUpload.csv';
        p.ReadFile();
        p.getuploadedBidScrubs();
    }
    public static testMethod void myUnitTest() {
        test.startTest();
        PageReference pageRef1 = Page.UploadBidScrub;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('FileName', 'BidScrubUpload.cb');
        BidScrubFileUploader p = new BidScrubFileUploader(new ApexPages.StandardController(new Bid_Scrub__c()));
        String strcsv1 = 'na';
        Blob b1 = Blob.valueOf(strcsv1);
        p.contentFile = b1;
        p.nameFile = 'BidScrubUpload.cb';
        p.ReadFile();
        p.getuploadedBidScrubs();
    }
    public static testMethod void myUnitTest1() {
        test.startTest();
        PageReference pageRef1 = Page.UploadBidScrub;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('FileName', 'BidScrubUpload.csv');
        BidScrubFileUploader p = new BidScrubFileUploader(new ApexPages.StandardController(new Bid_Scrub__c()));
        String strcsv1 = '303030 ' + ',' + '444,5366,30,30,USD';
        strcsv1 += '\n';
        strcsv1 += ' ' + ',' + '444,5366,30,30,USD';
        strcsv1 += '\n';
        Blob b1 = Blob.valueOf(strcsv1);
        p.contentFile = b1;
        p.nameFile = 'BidScrubUpload.csv';
        p.ReadFile();
        p.getuploadedBidScrubs();
    }
    public static testMethod void myUnitTest2() {
        Account acc1 = new Account(Name = 'testAccount1', RECORDTYPEID = '012300000000OSh', BILLINGSTREET = '24-60 20 CALLE', Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123',
                                   INDUSTRY = 'Education',
                                   LEVEL__C = 'Authorized Reseller',
                                   Metal_Level__c = 'test',
                                   Partner_Region__c = 'APAC'
                                  );
        insert acc1;
        Opportunity opp1 = new Opportunity(name = 'Opp1', Account = acc1, stagename = 'Secure', closedate = System.today(), ownerid = UserInfo.getUserId(), first_ship_date__c = System.today() + 1, pull_forward_date__c = System.today() - 1);
        insert opp1;
        Opportunity opp2 = [select id, SYM_Transaction_Number__c from opportunity where id =: opp1.Id];
        Bid_Scrub__c bid = new Bid_Scrub__c();
        bid.Opportunity_Transaction_Number__c = opp2.SYM_Transaction_Number__c;
        bid.Opportunity__c = opp1.Id;
        //bid.Name = 'Test Product';
        bid.Product_APC__c = '123';
        bid.Product_WWAPC__c = '456';
        bid.Quantity__c = 100;
        bid.UnitPrice__c = 1000;
        bid.CurrencyIsoCode = 'USD';
        insert bid;
        
        bid.Product_APC__c = '222';
        bid.Product_WWAPC__c = '444';
        update bid;
        
        Product2 prods = new Product2(Name = 'Laptop X200');
        insert prods;                 
        Forecasting_Product_Family__c FPF1 = new Forecasting_Product_Family__c();
        FPF1.APC__c = '123';
        FPF1.Forecast_Rollup_WWAPC_Code__c = '456';
        FPF1.Product_Family__c = prods.id;
        insert FPF1;
        Forecasting_Product_Family__c FPF2 = new Forecasting_Product_Family__c();
        FPF2.APC__c = '';
        FPF2.Forecast_Rollup_WWAPC_Code__c = '4444';
        FPF2.Product_Family__c = prods.id;
        insert FPF2;
        PageReference pageRef = Page.UploadBidScrub;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('FileName', 'BidScrubUpload');
        BidScrubFileUploader p = new BidScrubFileUploader(new ApexPages.StandardController(new Bid_Scrub__c()));
        String strcsv = '\n';
        strcsv += opp2.SYM_Transaction_Number__c + ',' + '123,456,20,30,USD';
        strcsv += '\n';
        strcsv += opp2.SYM_Transaction_Number__c + ',' + '123,4444,30,60,USD';
        strcsv += '\n';
        Blob b = Blob.valueOf(strcsv);
        p.contentFile = b;
        p.nameFile = 'BidScrubUpload.csv';
        p.ReadFile();
        p.getuploadedBidScrubs();
    }
}