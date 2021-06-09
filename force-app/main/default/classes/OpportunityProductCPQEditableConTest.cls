@isTest
public with sharing class OpportunityProductCPQEditableConTest {
    @isTest
    public static void OpportunityProductCPQEditableTest(){
        TestDataSetUpUtils.insertCustomSettings();
        MRCPQ_EditQuotePackageController editQuotePackageCon = new MRCPQ_EditQuotePackageController();
        BypassPartnerOpptyIncludeProduct__c bps = new BypassPartnerOpptyIncludeProduct__c();
        bps.Value__c = false;
        insert bps;
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        User partUser = TestDataSetUpUtils.createPortalUser();
        system.runAs(partUser){
            Test.startTest();
            Pricebook2 pBook = new Pricebook2(Name='Standard Price Book',IsActive=true,CurrencyIsoCode='USD');
            insert pBook;
            Id pBookId = Test.getStandardPricebookId();
            List<Account> accList = TestDataSetUpUtils.createAccounts(2, accRecTypeId);
            system.debug('accList: ' +accList);
            Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordtypeInfosByName().get('Project').getRecordTypeId();
            List<Opportunity> oppList = new List<Opportunity>();
            for(Integer i=0; i<2; i++){
                Opportunity opp = new Opportunity();
                opp.Pricebook2Id = pBookId;
                opp.name='My new Opportunity' + i;
                opp.AccountId=accList.get(0).Id;
                opp.CloseDate = Date.today()+360;
                opp.StageName='Prospect';
                opp.Region__c='NA';
                opp.RecordTypeId=oppRecTypeId;
                oppList.add(opp);
            }
            insert oppList;
                        
            for(Opportunity oppy : oppList){
                oppy.Pricebook2Id = Test.getStandardPricebookId();
            }
            update oppList;
            
            List<Product2> prodList = createProducts();
            system.debug('prodList: ' + prodList);
            List<PricebookEntry> priceBkList = createPBkList(prodList, pBookId);
            system.debug('priceBKList: ' + priceBkList);
            List<OpportunityLineItem> oppItemList = createOppLineItems(oppList, priceBkList);
            system.debug('oppItemList: ' + oppItemList);
            
            for(integer i=0; i<oppItemList.size(); i++){
                system.debug('Opp[' + i +']: ' + oppItemList.get(i));
            }
            system.debug('OppId: ' + oppList.get(0).Id);
            List<MRCPQ_EditQuotePackageController.WrapperClass> quotePackageList = MRCPQ_EditQuotePackageController.getQuotePackages(oppList.get(0).Id);
            system.debug('quotePackageList: ' + quotePackageList);
            
            String returnMsg = OpportunityProductCPQEditableController.initLineItems(oppList[0].Id);
            system.debug(returnMsg);
            returnMsg = OpportunityProductCPQEditableController.initLineItems('');
            system.debug(returnMsg);
            List<OpportunityProductCPQEditableController.WrapperClass> returnItems =OpportunityProductCPQEditableController.getProducts(oppList[0].id);

            for(OpportunityLineItem oItem : [SELECT  OpportunityID,PriceBookEntryID, quantity, totalprice
                                            FROM OpportunityLineItem
                                            WHERE OpportunityId = :oppList.get(0).Id]){
                                                system.debug('Opp Line Item: ' + oItem);
                                                oItem.CPQ_Updatable2__c = 'No';
                } 
            returnMsg = OpportunityProductCPQEditableController.updateProducts(returnItems);
            system.debug('Return Msg: ' + returnMsg);
            
            Test.stopTest();
        }
    }

    
    private static List<Product2> createProducts(){
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2 (ECW_shortcut__c=true,Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true, Manual_Update__c='Bid Scrub Only');
        Product2 prod2 = new Product2 (SPSS_shortcut__c=true,Name='Test Product Entry 2',Description='Test Product Entry 2',productCode = 'ABC2', isActive = true, Manual_Update__c='CPQ Only');
        Product2 prod3 = new Product2 (ILPS_shortcut__c=true,Name='Test Product Entry 3',Description='Test Product Entry 3',productCode = 'ABC3', isActive = true, Manual_Update__c='CPQ & Bid Scrub');
        Product2 prod4 = new Product2 (ILPS_shortcut__c=true,Name='Services - Non-Traditional Systems Integration',Description='Test Product Entry 4',productCode = 'ABC4', isActive = true);
        prodList.add(prod1);
        prodList.add(prod2);
        prodList.add(prod3);
        prodList.add(prod4);
        insert prodList;
        return prodList;
    }
    private static List<PricebookEntry> createPBkList(List<Product2> pdtList, Id pBookId){
        List<PricebookEntry> priceBkList = new List<PricebookEntry>();
            PricebookEntry pbe1 = new PricebookEntry (Product2ID=pdtList[0].id,Pricebook2ID=pBookId,UnitPrice=50, isActive=true);
            PricebookEntry pbe2 = new PricebookEntry (Product2ID=pdtList[1].id,Pricebook2ID=pBookId,UnitPrice=50, isActive=true);
            PricebookEntry pbe3 = new PricebookEntry (Product2ID=pdtList[2].id,Pricebook2ID=pBookId,UnitPrice=50, isActive=true);
            PricebookEntry pbe4 = new PricebookEntry (Product2ID=pdtList[3].id,Pricebook2ID=pBookId,UnitPrice=50, isActive=true);
            priceBkList.add(pbe1);
            priceBkList.add(pbe2);
            priceBkList.add(pbe3);
            priceBkList.add(pbe4);
            insert priceBkList;
            return priceBkList;
    }
    private static List<OpportunityLineItem> createOppLineItems(List<Opportunity> oppList, List<PricebookEntry> priceBkList){
        List<OpportunityLineItem> oppItemList = new List<OpportunityLineItem>();
            for(Opportunity op : oppList) {
                OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=4, totalprice=200);
                OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[1].id, quantity=4, totalprice=200, CPQ_Updatable2__c='Yes');
                OpportunityLineItem lineItem3 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[2].id, quantity=4, totalprice=200, CPQ_Updatable2__c='No');
                OpportunityLineItem lineItem4 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[3].id, quantity=5, totalprice=300);
                oppItemList.add(lineItem1);
                oppItemList.add(lineItem2);
                oppItemList.add(lineItem3);
                oppItemList.add(lineItem4);
                system.debug('oppItemList-Loop: ' + oppItemList );
            }
            Insert oppItemList;
        return oppItemList;
    }
}