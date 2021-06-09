/*  
* File Name  : PartnerReadinessAssessToolTest
* Description: This is a test class for the Controller Class PartnerReadinessAssessmentToolController  
* Author     : Vishal Rao Jujaray - Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   17-Dec-12   Vishal Rao Jujaray              Initial Code
* 2.0   17-Dec-12   Vishal Rao Jujaray              Modified the Test Class to meet the Salesway 2.0B requirements 
*/
@isTest
public class PartnerReadinessAssessToolTest{
 @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

    static testMethod void testPRATCont(){
        List<Account> acnts = new List<Account>();
        Account acnts1 = new Account(Name='TestAcnt1',Country_Listing__c='India',Type='Prospect',BillingCity='San Mateo',BILLINGSTATE='Texas',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States');
        acnts.add(acnts1);
        Account acnts2 = new Account(Name='TestAcnt2',Country_Listing__c='Fiji',Type='Partner',BillingCity='San Mateo',BILLINGSTATE='Texas',BILLINGPOSTALCODE='1010',BILLINGCOUNTRY='United States');
        acnts.add(acnts2);
     insert acnts;
     
     List<Focus_Area__c> FA = new List<Focus_Area__c>();
         Focus_Area__c FA1 = new Focus_Area__c(Name='TestAOF1', Account__c=acnts1.id);
         FA.add(FA1);
         Focus_Area__c FA2 = new Focus_Area__c(Name='TestAOF2', Account__c=acnts2.id);
         FA.add(FA2);
     insert FA;
        
     
     List<Partner_Readiness_Assessment__c> pra = new List<Partner_Readiness_Assessment__c>();
         Partner_Readiness_Assessment__c pra1 = new Partner_Readiness_Assessment__c(Name='TestPRA1', Area_of_Focus__c=FA1.id);
         pra.add(pra1);
         Partner_Readiness_Assessment__c pra2 = new Partner_Readiness_Assessment__c(Name='TestPRA2',Area_of_Focus__c=FA2.id);
         pra.add(pra2);
     insert pra;
     
     ApexPages.currentPage().getParameters().put('AreaOfFocusRecordid',FA1.id);
     ApexPages.StandardController stdController1 = new ApexPages.StandardController(pra1);
     PartnerReadinessAssessmentToolController testPRAT = new PartnerReadinessAssessmentToolController(stdController1);
         pra1.MarketQuestion1__c = '5';
         pra1.MarketQuestion2__c = '5';
         pra1.MarketQuestion3__c = '5';
         pra1.MarketQuestion4__c = '5';
         pra1.MarketQuestion4__c = '5';
         pra1.MarketQuestion5__c = '5';
         pra1.MarketQuestion6__c = '5';
         pra1.MarketQuestion7__c = '5';
         pra1.MarketQuestion8__c = '5';
         pra1.MarketQuestion9__c = '5';
         pra1.MarketQuestion10__c = '5'; 
         
         pra1.OfferQuestion1__c = '5';
         pra1.OfferQuestion2__c = '5';
         pra1.OfferQuestion3__c = '5';
         pra1.OfferQuestion4__c = '5';
         pra1.OfferQuestion5__c = '5';
         pra1.OfferQuestion6__c = '5';
         pra1.OfferQuestion7__c = '5';
         pra1.OfferQuestion8__c = '5';
         pra1.OfferQuestion9__c = '5';
         pra1.OfferQuestion10__c = '5';
             
         pra1.PriceQuestion1__c = '5';
         pra1.PriceQuestion2__c = '5';
         pra1.PriceQuestion3__c = '5';
         pra1.PriceQuestion4__c = '5';
         pra1.PriceQuestion5__c = '5';
         pra1.PriceQuestion6__c = '5';
         pra1.PriceQuestion7__c = '5';
         pra1.PriceQuestion8__c = '5';
         pra1.PriceQuestion9__c = '5';
         pra1.PriceQuestion10__c = '5';
             
         pra1.PromotionQuestion1__c = '5';
         pra1.PromotionQuestion2__c = '5';
         pra1.PromotionQuestion3__c = '5';
         pra1.PromotionQuestion4__c = '5';
         pra1.PromotionQuestion5__c = '5';
         pra1.PromotionQuestion6__c = '5';
         pra1.PromotionQuestion7__c = '5';
         pra1.PromotionQuestion8__c = '5';
         pra1.PromotionQuestion9__c = '5';
         pra1.PromotionQuestion10__c = '5';
             
         pra1.SupplyChainQuestion1__c = '5';
         pra1.SupplyChainQuestion2__c = '5';
         pra1.SupplyChainQuestion3__c = '5';
         pra1.SupplyChainQuestion4__c = '5';
         pra1.SupplyChainQuestion5__c = '5';  
         pra1.SupplyChainQuestion6__c = '5';
         pra1.SupplyChainQuestion7__c = '5';
         pra1.SupplyChainQuestion8__c = '5';
         pra1.SupplyChainQuestion9__c = '5';
         pra1.SupplyChainQuestion10__c = '5';
         
         testPRAT.CalculatePriceScore();
         testPRAT.CalculatemarketScore();
         testPRAT.CalculateOfferScore();
         testPRAT.CalculatePromotionScore();
         testPRAT.CalculateSupplyChainScore();
         testPRAT.getcallMarketScore();
         testPRAT.getcallPriceScore();
         testPRAT.getcallOfferScore();
         testPRAT.getcallPromotionScore();
         testPRAT.getcallSupplyChainScore();
         testPRAT.Cancel();
         testPRAT.saveScoreCardAndContinue();
         //testPRAT.saveScoreandReturnToAccount(); 
         testPRAT.saveScoreandReturnToAreaOfFocus();
         testPRAT.saveSLDM();
        //testPRAT.saveSLDMReturnAccts(); 
         testPRAT.saveSLDMReturnAreaOfFocus(); 
         testPRAT.launchMrktAssessQsts();
         //testPRAT.getAccountId(); 
         testPRAT.getAreaOfFocusId();
         testPRAT.getAccountName();
         testPRAT.getAreaOfFocusName();
         testPRAT.getAccountOwner();
       
         
}
}