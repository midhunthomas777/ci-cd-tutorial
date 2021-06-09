@isTest
public class MRCPQ_EditQuotePackageControllerTest {
    @isTest
    public static void editQuotePackageTest(){
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

            List<BigMachines__Quote__c> myQuotes = createQuotes(oppList, accList);
            system.debug('myquotes: ' + myQuotes);
            
            List<UserRecordAccess> accessList = [SELECT HasEditAccess, RecordId FROM UserRecordAccess WHERE RecordId =:myQuotes[0].Id AND UserId =:UserInfo.getUserId()];
            system.debug('accessList: ' + accessList);

            
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
            List<Id> quoteIds = new List<Id>();
            for(integer i=0; i< myQuotes.size(); ++i){
                quoteIds.add(myQuotes[i].Id);
            }
            String msg = MRCPQ_EditQuotePackageController.UpdateOppQuoteProducts(quoteIds, oppList[0].Id);
            for(BigMachines__Quote__c quote : [SELECT Id, Name, BigMachines__Account__c, owner.Name, CreatedBy.Name, Is_Primary__c, 
                                                CreatedDate, BigMachines__Total_Amount__c, Motorola_Customer_Number__c,  
                                                BigMachines__Opportunity__c,
                                                Quote_Host__r.Id, Quote_Host__r.Name, Quote_Host__r.Motorola_Customer_Number__c,  
                                                Quote_Host__r.BigMachines__Opportunity__c
                                            FROM BigMachines__Quote__c 
                                            WHERE BigMachines__Opportunity__c=:oppList.get(0).Id
                                            ORDER BY Quote_Host__c, Name Desc]){
                                                system.debug('Quote result: ' + quote);
            }
            for(OpportunityLineItem oItem : [SELECT  OpportunityID,PriceBookEntryID, quantity, totalprice
                                            FROM OpportunityLineItem
                                            WHERE OpportunityId = :oppList.get(0).Id]){
                                                system.debug('Opp Line Item: ' + oItem);
                } 
            system.debug('Return Msg: ' + msg);
            List<MR_Digitization_Settings__mdt> msg2 = MRCPQ_EditQuotePackageController.fetchSuccessMsg();
            system.debug('Return Msg: ' + msg2);
            String retmsg = MRCPQ_EditQuotePackageController.removeAllProducts(oppList[0].Id);
            system.debug('Return Msg: ' + retmsg);
            Test.stopTest();
        }
    }

    
    private static List<Product2> createProducts(){
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2 (ECW_shortcut__c=true,Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        Product2 prod2 = new Product2 (SPSS_shortcut__c=true,Name='Test Product Entry 2',Description='Test Product Entry 2',productCode = 'ABC2', isActive = true);
        Product2 prod3 = new Product2 (ILPS_shortcut__c=true,Name='Test Product Entry 3',Description='Test Product Entry 3',productCode = 'ABC3', isActive = true);
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
                OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[0].id, quantity=4, totalprice=200, CPQ_Updatable2__c='Yes');
                OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[1].id, quantity=4, totalprice=200, CPQ_Updatable2__c='No');
                OpportunityLineItem lineItem3 = new OpportunityLineItem (OpportunityID=op.id,PriceBookEntryID=priceBkList[2].id, quantity=4, totalprice=200, CPQ_Updatable2__c='Yes');
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

    private static List<BigMachines__Quote__c> createQuotes(List<Opportunity> oppList, List<Account> accList){
        List<BigMachines__Quote__c> quotes = new List<BigMachines__Quote__c>();

        for(integer i=0; i<accList.size(); ++i){
            BigMachines__Quote__c q = new BigMachines__Quote__c (BigMachines__Description__c= 'Quote' + i,
                                                                    BigMachines__Account__c=accList.get(0).Id,
                                                                    BigMachines__Opportunity__c=oppList.get(0).Id,
                                                                    Name='My Quote' + i);
            quotes.add(q);
        }
        Insert quotes;
        return quotes;
    }
}