@isTest
public without sharing class MRCPQ_CheckoutControllerTest {
    
	@isTest 
    public static void checkOutControllerTest(){
        TestDataSetUpUtils.insertCustomSettings();
        List<MR_Digitization_Settings__mdt> mrd;
        mrd= new MetadataCoverage().getMetadatacoverageRecords('SELECT MasterLabel,DeveloperName FROM MR_Digitization_Settings__mdt');
        
        List<CyberSource__mdt> cybersrc;
        Test.startTest(); 
        cybersrc= new MetadataCoverage().getMetadatacoverageRecords('SELECT MasterLabel,DeveloperName FROM CyberSource__mdt');
        
        MRCPQ_CheckoutController.CheckoutValidation ctrl = new MRCPQ_CheckoutController.CheckoutValidation();
        
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<User> partneruser = [SELECT Id FROM User WHERE id = '0052H00000CRWtA'];
        if (partneruser.size() == 0) {
            System.debug('Empty!');
        }
        System.runAs(partneruser.get(0)){
            Id pricebookId = Test.getStandardPricebookId();
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            List<Opportunity> lstOpportunity =new List<Opportunity>();
			Id OppectypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
            for(integer i=0;i<10 ;i++){
                Opportunity opp = new Opportunity(); 
                opp.Pricebook2Id = pricebookId;
                opp.Name='test opp'+i;
                opp.AccountId=lstAccount.get(0).Id; 
                opp.CloseDate = Date.today()+30;
                opp.StageName='Design & Validate';
                opp.RecordtypeId=OppectypeID;
                lstOpportunity.add(opp);
            }
            insert lstOpportunity;
            
            BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
            objQuote.BigMachines__Opportunity__c=lstOpportunity.get(0).Id;
            objQuote.BigMachines__Account__c=lstAccount.get(0).Id;
            objQuote.Name='testQuote';
            objQuote.BigMachines__Site__c=TestDataSetUpUtils.createSite();
            objQuote.Customer_Bill_To__c='115553';
            objQuote.Validity_Date_Effective_Until_Date__c = Date.parse('12/4/2017');
            objQuote.CurrencyIsoCode='USD';
            objQuote.BigMachines__Status__c='In Progress';
            objQuote.RevisionNumber__c='0';
            insert objQuote;
            
            PageReference myVfPage = Page.CyberSourceFormPage;
            Test.setCurrentPage(myVfPage);
            ApexPages.currentPage().getParameters().put('qid',objQuote.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(objQuote);     
            MRCPQ_CheckoutController chkout= new MRCPQ_CheckoutController(sc);
            chkout.getCartDetails();
            MRCPQ_CheckoutController.getPageURL(objQuote.Id);
            List<NetworkMember> membership = [SELECT network.name, networkId, memberID FROM NetworkMember WHERE memberID in :partneruser];
            MRCPQ_CheckoutController.checkoutValidations(objQuote.id);
            MRCPQ_CheckoutController mainCtrl = new MRCPQ_CheckoutController(sc);
            MRCPQ_CheckoutController.CheckoutValidation chk = new MRCPQ_CheckoutController.CheckoutValidation();     
 			chk.hasCheckoutAccess=true;     
            chk.paymentAlreadyDone=true;
            
            PageReference myVfPage1 = Page.CyberSourceReceipt;
            Test.setCurrentPage(myVfPage1);
            CyberSourceReceiptCtrl csr= new CyberSourceReceiptCtrl();
            
            ApexPages.currentPage().getParameters().put('quoteId',objQuote.Id);
            ApexPages.currentPage().getParameters().put('decision','ACCEPT');
            ApexPages.currentPage().getParameters().put('auth_time',String.valueof(Date.today()));
            ApexPages.currentPage().getParameters().put('payment_token','ABC');
            ApexPages.currentPage().getParameters().put('auth_amount','200');
            ApexPages.currentPage().getParameters().put('auth_code','200');
            ApexPages.currentPage().getParameters().put('req_card_expiry_date',String.valueof(Date.today()+5));
            ApexPages.currentPage().getParameters().put('req_bill_to_forename','test');
            ApexPages.currentPage().getParameters().put('req_bill_to_surname','test');
            ApexPages.currentPage().getParameters().put('req_card_type','VISA');
            ApexPages.currentPage().getParameters().put('req_card_number','4111111111111111');
            ApexPages.currentPage().getParameters().put('transaction_id','ID00001');
            ApexPages.currentPage().getParameters().put('message','Test');
            csr.init();
            csr.processResults(); 
        }
        Test.stopTest(); 
    }
}