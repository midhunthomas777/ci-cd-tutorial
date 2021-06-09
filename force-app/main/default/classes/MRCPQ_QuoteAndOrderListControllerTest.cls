@isTest
public class MRCPQ_QuoteAndOrderListControllerTest {
    @isTest
    public static void quoteAndOrderListTest(){
        TestDataSetUpUtils.insertCustomSettings();
        BypassPartnerOpptyIncludeProduct__c bps = new BypassPartnerOpptyIncludeProduct__c();
        bps.Value__c = false;
        insert bps;
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User partneruser= TestDataSetUpUtils.createPortalUser();
        system.runAs(partneruser){
            Test.startTest();
            Pricebook2 standardPricebook = new Pricebook2(Name='Standard Price Book',IsActive = true,CurrencyIsoCode='USD');
            insert standardPricebook;
            Id pricebookId = Test.getStandardPricebookId();
            List<Account> lstAccount = TestDataSetUpUtils.createAccounts(1, accrectypeID);
            // List<Opportunity> lstOpportunity = TestDataSetUpUtils.createProjectOpportunity();
             Id OppectypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();//Akhil
            List<Opportunity> lstOpportunity =new List<Opportunity>();
            for(integer i=0;i<20 ;i++){
                Opportunity opp = new Opportunity(); 
                opp.Pricebook2Id = pricebookId;
                opp.Name='test opp'+i;
                opp.AccountId=lstAccount.get(0).Id; 
                opp.CloseDate = Date.today()+30;
                opp.StageName='Design & Validate';
                 opp.Region__c='NA'; //Akhil
                 opp.RecordTypeId=OppectypeID;//Akhil
                lstOpportunity.add(opp);
            }
            insert lstOpportunity;
            
            BigMachines__Quote__c objQuote = new BigMachines__Quote__c();
            objQuote.BigMachines__Opportunity__c=lstOpportunity.get(0).Id;
            objQuote.BigMachines__Account__c=lstAccount.get(0).Id;
            objQuote.Name='testQuote';
            objQuote.BigMachines__Site__c=TestDataSetUpUtils.createSite();
            insert objQuote;
            
           /* BigMachines__Quote__share execShare = new BigMachines__Quote__share();
            execShare.ParentID = objQuote.ID;
                        execShare.UserOrGroupId = partneruser.Id;
                        execShare.AccessLevel = 'Edit';
                        execShare.RowCause='Manual';
                        insert execShare;*/
            
            
            List<UserRecordAccess> accessList = [SELECT HasEditAccess, RecordId FROM UserRecordAccess WHERE RecordId =:objQuote.Id AND UserId = :UserInfo.getUserId()];

            system.debug('accessList******'+accessList);
            
            List<Product2> pdtList = new List<Product2>();
            Product2 prd1 = new Product2 (ECW_shortcut__c=true,Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
            Product2 prd2 = new Product2 (SPSS_shortcut__c=true,Name='Test Product Entry 2',Description='Test Product Entry 2',productCode = 'ABC2', isActive = true);
            Product2 prd3 = new Product2 (ILPS_shortcut__c=true,Name='Test Product Entry 3',Description='Test Product Entry 3',productCode = 'ABC3', isActive = true);
            Product2 prd4 = new Product2 (ILPS_shortcut__c=true,Name='Services - Non-Traditional Systems Integration',Description='Test Product Entry 4',productCode = 'ABC4', isActive = true);
            pdtList.add(prd1);
            pdtList.add(prd2);
            pdtList.add(prd3);
            pdtList.add(prd4);
            insert pdtList;
            
            List<PricebookEntry> priceBkList = new List<PricebookEntry>();
            PricebookEntry pbe1 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
            PricebookEntry pbe2 = new PricebookEntry (Product2ID=pdtList[1].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
            PricebookEntry pbe3 = new PricebookEntry (Product2ID=pdtList[2].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
            PricebookEntry pbe4 = new PricebookEntry (Product2ID=pdtList[3].id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
            priceBkList.add(pbe1);
            priceBkList.add(pbe2);
            priceBkList.add(pbe3);
            priceBkList.add(pbe4);
            insert priceBkList;
            
            List<OpportunityLineItem> OLIlst = new List<OpportunityLineItem>();
            for(Opportunity op : lstOpportunity) {
                OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=4, totalprice=200);
                OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[1].id, quantity=4, totalprice=200);
                OpportunityLineItem lineItem3 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[2].id, quantity=4, totalprice=200);
                OpportunityLineItem lineItem4 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[3].id, quantity=5, totalprice=300);
                OLIlst.add(lineItem1);
                OLIlst.add(lineItem2);
                OLIlst.add(lineItem3);
                OLIlst.add(lineItem4);
            }
            Insert OLIlst;
            Test.stopTest();
            List<MRCPQ_QuoteAndOrderListController.WrapperClass> lstQuoteOrdersResult=  MRCPQ_QuoteAndOrderListController.getCPQQuoteOrders(lstOpportunity.get(0).Id);
            String addProductToOpp =  MRCPQ_QuoteAndOrderListController.addProductsToOppo(String.valueof(objQuote.Id),String.valueof(lstOpportunity.get(0).Id));
            String removeProductToOpp = MRCPQ_QuoteAndOrderListController.removeProductsToOppo(String.valueof(objQuote.Id),String.valueof(lstOpportunity.get(0).Id));
            MRCPQ_QuoteAndOrderListController.WrapperClass lstqtwrp = new MRCPQ_QuoteAndOrderListController.WrapperClass();
            lstqtwrp.quoteId=objQuote.Id;
            lstqtwrp.createdBy='test';
            lstqtwrp.createdDate=Date.today();
            lstqtwrp.isPrimary=true;
            lstqtwrp.name='test';
            lstqtwrp.netAmount=22.52;
            lstqtwrp.ownerName='test';
            lstQuoteOrdersResult.sort();
            lstqtwrp.compareTo(lstqtwrp);
        }

    }
}