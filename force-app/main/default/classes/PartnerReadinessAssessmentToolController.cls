/*  
* File Name  : PartnerReadinessAssessmentToolController
* Description: This Code is the controller class for the Visualforce page "PartnerReadinessAssessmentTool". 
               In this class, the scores are calculated and published. 
* Author     : Vishal Rao Jujaray - Infosys Technologies Limited
* Modification Log 
* ============================================================================= 
* Ver   Date        Author                         Modification 
* -----------------------------------------------------------------------------------------------------------------------------------------
* 1.0   17-Dec-12   Vishal Rao Jujaray              Initial Code
* 2.0   02-Jul-13   Vishal Rao Jujaray              Modification of code as per SalesWay 2.0b     
* 
*/

//public with sharing class PartnerReadinessAssessmentToolController{
public class PartnerReadinessAssessmentToolController{
    id currentPgId = ApexPages.currentPage().getParameters().get('AreaOfFocusRecordid');
    public decimal totalRevenue = 0;
    public boolean MarketConversationGuideCheck = false;
    
    public Focus_Area__c areaOfFocusRecord = [select id, Createdby.NAME, name,Market_Score__c,Offer_Score__c,Price_Score__c,Promotion_Score__c 
,Supply_Chain_Score__c, Account__c FROM Focus_Area__c WHERE id=:currentPgId limit 1];
        public string AreaOfFocusName = areaOfFocusRecord.name;

        
        public Account acctsName =  [select id, name, OWNER.NAME FROM Account WHERE id=:areaOfFocusRecord.Account__c limit 1];

        public string AcctName = acctsName.name;             
        public string OwnerName = acctsName.OWNER.NAME;    
        public Integer marketScore =0;
        public Integer offerScore = 0;
        public Integer priceScore = 0;
        public Integer promotionScore = 0;
       public Integer supplyChainScore = 0;
        public Partner_Readiness_Assessment__c PRARecord ;
        public Boolean RecordAlreadyExistsFlag = false;
        public Id PRAId=null;
        public string UserCurrencyISOCode = UserInfo.getDefaultCurrency(); 
        public boolean insertPRARecordSuccessCheck = true;
        public boolean updatePRARecordSuccessCheck = true;

        //public boolean launchMrktAssessQsts =0;
        
        
        public PartnerReadinessAssessmentToolController(ApexPages.StandardController controller) {
        
            Partner_Readiness_Assessment__c [] PRATempRecord = [SELECT Id, MarketQuestion1__c, MarketQuestion2__c, 
MarketQuestion3__c, MarketQuestion4__c, MarketQuestion5__c, MarketQuestion6__c, MarketQuestion7__c, 
MarketQuestion8__c, MarketQuestion9__c, MarketQuestion10__c, A1_Market_Assessment1__c, 
A1_Market_Assessment2__c, A1_Market_Assessment3__c, A1_Market_Assessment4__c, A1_Market_Assessment5__c, 
                            OfferQuestion1__c, OfferQuestion2__c, OfferQuestion3__c, OfferQuestion4__c, 
OfferQuestion5__c, OfferQuestion6__c, OfferQuestion7__c, OfferQuestion8__c, 
OfferQuestion9__c, OfferQuestion10__c, A1_Offer_Assessment1__c, A1_Offer_Assessment2__c, 
A1_Offer_Assessment3__c, A1_Offer_Assessment4__c, A1_Offer_Assessment5__c, 
A1_Offer_Assessment6__c, A1_Offer_Assessment7__c, 
                            
                            PriceQuestion1__c, PriceQuestion2__c, PriceQuestion3__c, PriceQuestion4__c, 
PriceQuestion5__c, PriceQuestion6__c, PriceQuestion7__c, PriceQuestion8__c, 
PriceQuestion9__c, PriceQuestion10__c, A1_Price_Assessment1__c, A1_Price_Assessment2__c, 
A1_Price_Assessment3__c, A1_Price_Assessment4__c, A1_Price_Assessment5__c, 
A1_Price_Assessment6__c, A1_Price_Assessment7__c, 
                            
                            PromotionQuestion1__c, PromotionQuestion2__c, PromotionQuestion3__c, 
PromotionQuestion4__c, PromotionQuestion5__c, PromotionQuestion6__c, 
PromotionQuestion7__c, PromotionQuestion8__c, PromotionQuestion9__c, 
PromotionQuestion10__c, A1_Promotion_Assessment1__c, A1_Promotion_Assessment2__c, 
A1_Promotion_Assessment3__c, A1_Promotion_Assessment4__c, A1_Promotion_Assessment5__c, 
A1_Promotion_Assessment6__c, A1_Promotion_Assessment7__c, A1_Promotion_Assessment8__c, 
                            
                            SupplyChainQuestion1__c, SupplyChainQuestion2__c, SupplyChainQuestion3__c, 
SupplyChainQuestion4__c, SupplyChainQuestion5__c, SupplyChainQuestion6__c, 
SupplyChainQuestion7__c, SupplyChainQuestion8__c, SupplyChainQuestion9__c, 
SupplyChainQuestion10__c, A1_SupplyChain_Assessment1__c, A1_SupplyChain_Assessment2__c, 
A1_SupplyChain_Assessment3__c, A1_SupplyChain_Assessment4__c, 
A1_SupplyChain_Assessment5__c, A1_SupplyChain_Assessment6__c, 
                            
                            PriceScore__c,MarketScore__c,OfferScore__c,PromotionScore__c,SupplyChainScore__c,
                            
                            Acct_DecMat_Market2__c, Acct_DecMat_Market3__c, Acct_DecMat_Market4__c, 
Acct_DecMat_Market5__c, Acct_DecMat_Offer2__c, Acct_DecMat_Offer3__c, 
Acct_DecMat_Offer4__c, Acct_DecMat_Offer5__c, Acct_DecMat_Price2__c, 
Acct_DecMat_Price3__c, Acct_DecMat_Price4__c, Acct_DecMat_Price5__c, 
Acct_DecMat_Promotion2__c, Acct_DecMat_Promotion3__c, Acct_DecMat_Promotion4__c, 
Acct_DecMat_Promotion5__c, Acct_DecMat_SupplyChain2__c, Acct_DecMat_SupplyChain3__c, 
Acct_DecMat_SupplyChain4__c, Acct_DecMat_SupplyChain5__c
                          
                        FROM Partner_Readiness_Assessment__c WHERE Area_of_Focus__c =: areaOfFocusRecord.id ];
        
            PRARecord = (Partner_Readiness_Assessment__c)controller.getRecord();
    
            if(PRATempRecord.isEmpty()){
                RecordAlreadyExistsFlag = false;
            }               
            else {
                RecordAlreadyExistsFlag = true;
                PRAId = PRATempRecord[0].Id;
                PRARecord.MarketQuestion1__c = PRATempRecord[0].MarketQuestion1__c;
                PRARecord.MarketQuestion2__c = PRATempRecord[0].MarketQuestion2__c;
                PRARecord.MarketQuestion3__c = PRATempRecord[0].MarketQuestion3__c;
                PRARecord.MarketQuestion4__c = PRATempRecord[0].MarketQuestion4__c;
                PRARecord.MarketQuestion5__c = PRATempRecord[0].MarketQuestion5__c;
                PRARecord.MarketQuestion6__c = PRATempRecord[0].MarketQuestion6__c;
                PRARecord.MarketQuestion7__c = PRATempRecord[0].MarketQuestion7__c; 
                PRARecord.MarketQuestion8__c = PRATempRecord[0].MarketQuestion8__c;
                PRARecord.MarketQuestion9__c = PRATempRecord[0].MarketQuestion9__c;
                PRARecord.MarketQuestion10__c = PRATempRecord[0].MarketQuestion10__c;
                PRARecord.A1_Market_Assessment1__c = PRATempRecord[0].A1_Market_Assessment1__c;
                PRARecord.A1_Market_Assessment2__c = PRATempRecord[0].A1_Market_Assessment2__c;
                PRARecord.A1_Market_Assessment3__c = PRATempRecord[0].A1_Market_Assessment3__c;
                PRARecord.A1_Market_Assessment4__c = PRATempRecord[0].A1_Market_Assessment4__c;
                PRARecord.A1_Market_Assessment5__c = PRATempRecord[0].A1_Market_Assessment5__c;
                PRARecord.MarketScore__c = PRATempRecord[0].MarketScore__c;
                marketScore = (integer)PRATempRecord[0].MarketScore__c;
                
                PRARecord.OfferQuestion1__c = PRATempRecord[0].OfferQuestion1__c;
                PRARecord.OfferQuestion2__c = PRATempRecord[0].OfferQuestion2__c;
                PRARecord.OfferQuestion3__c = PRATempRecord[0].OfferQuestion3__c;
                PRARecord.OfferQuestion4__c = PRATempRecord[0].OfferQuestion4__c;
                PRARecord.OfferQuestion5__c = PRATempRecord[0].OfferQuestion5__c;
                PRARecord.OfferQuestion6__c = PRATempRecord[0].OfferQuestion6__c;
                PRARecord.OfferQuestion7__c = PRATempRecord[0].OfferQuestion7__c; 
                PRARecord.OfferQuestion8__c = PRATempRecord[0].OfferQuestion8__c;
                PRARecord.OfferQuestion9__c = PRATempRecord[0].OfferQuestion9__c;
                PRARecord.OfferQuestion10__c = PRATempRecord[0].OfferQuestion10__c;
                PRARecord.A1_Offer_Assessment1__c = PRATempRecord[0].A1_Offer_Assessment1__c;
                PRARecord.A1_Offer_Assessment2__c = PRATempRecord[0].A1_Offer_Assessment2__c;
                PRARecord.A1_Offer_Assessment3__c = PRATempRecord[0].A1_Offer_Assessment3__c;
                PRARecord.A1_Offer_Assessment4__c = PRATempRecord[0].A1_Offer_Assessment4__c;
                PRARecord.A1_Offer_Assessment5__c = PRATempRecord[0].A1_Offer_Assessment5__c;
                PRARecord.A1_Offer_Assessment6__c = PRATempRecord[0].A1_Offer_Assessment6__c;
                PRARecord.A1_Offer_Assessment7__c = PRATempRecord[0].A1_Offer_Assessment7__c;
                PRARecord.OfferScore__c = PRATempRecord[0].OfferScore__c;
                offerScore =  (integer)PRATempRecord[0].OfferScore__c;
     
                PRARecord.PriceQuestion1__c = PRATempRecord[0].PriceQuestion1__c;
                PRARecord.PriceQuestion2__c = PRATempRecord[0].PriceQuestion2__c;
                PRARecord.PriceQuestion3__c = PRATempRecord[0].PriceQuestion3__c;
                PRARecord.PriceQuestion4__c = PRATempRecord[0].PriceQuestion4__c;
                PRARecord.PriceQuestion5__c = PRATempRecord[0].PriceQuestion5__c;
                PRARecord.PriceQuestion6__c = PRATempRecord[0].PriceQuestion6__c;
                PRARecord.PriceQuestion7__c = PRATempRecord[0].PriceQuestion7__c; 
                PRARecord.PriceQuestion8__c = PRATempRecord[0].PriceQuestion8__c;
                PRARecord.PriceQuestion9__c = PRATempRecord[0].PriceQuestion9__c;
                PRARecord.PriceQuestion10__c = PRATempRecord[0].PriceQuestion10__c;
                PRARecord.A1_Price_Assessment1__c = PRATempRecord[0].A1_Price_Assessment1__c;
                PRARecord.A1_Price_Assessment2__c = PRATempRecord[0].A1_Price_Assessment2__c;
                PRARecord.A1_Price_Assessment3__c = PRATempRecord[0].A1_Price_Assessment3__c;
                PRARecord.A1_Price_Assessment4__c = PRATempRecord[0].A1_Price_Assessment4__c;
                PRARecord.A1_Price_Assessment5__c = PRATempRecord[0].A1_Price_Assessment5__c;
                PRARecord.A1_Price_Assessment6__c = PRATempRecord[0].A1_Price_Assessment6__c;
                PRARecord.A1_Price_Assessment7__c = PRATempRecord[0].A1_Price_Assessment7__c;
                PRARecord.PriceScore__c = PRATempRecord[0].PriceScore__c ;
                priceScore = (integer)PRATempRecord[0].PriceScore__c;
   
                PRARecord.PromotionQuestion1__c = PRATempRecord[0].PromotionQuestion1__c;
                PRARecord.PromotionQuestion2__c = PRATempRecord[0].PromotionQuestion2__c;
                PRARecord.PromotionQuestion3__c = PRATempRecord[0].PromotionQuestion3__c;
                PRARecord.PromotionQuestion4__c = PRATempRecord[0].PromotionQuestion4__c;
                PRARecord.PromotionQuestion5__c = PRATempRecord[0].PromotionQuestion5__c;
                PRARecord.PromotionQuestion6__c = PRATempRecord[0].PromotionQuestion6__c;
                PRARecord.PromotionQuestion7__c = PRATempRecord[0].PromotionQuestion7__c; 
                PRARecord.PromotionQuestion8__c = PRATempRecord[0].PromotionQuestion8__c;
                PRARecord.PromotionQuestion9__c = PRATempRecord[0].PromotionQuestion9__c;
                PRARecord.PromotionQuestion10__c = PRATempRecord[0].PromotionQuestion10__c;
                PRARecord.A1_Promotion_Assessment1__c = PRATempRecord[0].A1_Promotion_Assessment1__c;
                PRARecord.A1_Promotion_Assessment2__c = PRATempRecord[0].A1_Promotion_Assessment2__c;
                PRARecord.A1_Promotion_Assessment3__c = PRATempRecord[0].A1_Promotion_Assessment3__c;
                PRARecord.A1_Promotion_Assessment4__c = PRATempRecord[0].A1_Promotion_Assessment4__c;
                PRARecord.A1_Promotion_Assessment5__c = PRATempRecord[0].A1_Promotion_Assessment5__c;
                PRARecord.A1_Promotion_Assessment6__c = PRATempRecord[0].A1_Promotion_Assessment6__c;
                PRARecord.A1_Promotion_Assessment7__c = PRATempRecord[0].A1_Promotion_Assessment7__c;
                PRARecord.A1_Promotion_Assessment8__c = PRATempRecord[0].A1_Promotion_Assessment8__c;
                PRARecord.PromotionScore__c = PRATempRecord[0].PromotionScore__c;
                promotionScore = (integer)PRATempRecord[0].PromotionScore__c;
    
                PRARecord.SupplyChainQuestion1__c = PRATempRecord[0].SupplyChainQuestion1__c;
                PRARecord.SupplyChainQuestion2__c = PRATempRecord[0].SupplyChainQuestion2__c;
                PRARecord.SupplyChainQuestion3__c = PRATempRecord[0].SupplyChainQuestion3__c;
                PRARecord.SupplyChainQuestion4__c = PRATempRecord[0].SupplyChainQuestion4__c;
                PRARecord.SupplyChainQuestion5__c = PRATempRecord[0].SupplyChainQuestion5__c;
                PRARecord.SupplyChainQuestion6__c = PRATempRecord[0].SupplyChainQuestion6__c;
                PRARecord.SupplyChainQuestion7__c = PRATempRecord[0].SupplyChainQuestion7__c; 
                PRARecord.SupplyChainQuestion8__c = PRATempRecord[0].SupplyChainQuestion8__c;
                PRARecord.SupplyChainQuestion9__c = PRATempRecord[0].SupplyChainQuestion9__c;
                PRARecord.SupplyChainQuestion10__c = PRATempRecord[0].SupplyChainQuestion10__c;
                PRARecord.A1_SupplyChain_Assessment1__c = PRATempRecord[0].A1_SupplyChain_Assessment1__c;
                PRARecord.A1_SupplyChain_Assessment2__c = PRATempRecord[0].A1_SupplyChain_Assessment2__c;
                PRARecord.A1_SupplyChain_Assessment3__c = PRATempRecord[0].A1_SupplyChain_Assessment3__c;
                PRARecord.A1_SupplyChain_Assessment4__c = PRATempRecord[0].A1_SupplyChain_Assessment4__c;
                PRARecord.A1_SupplyChain_Assessment5__c = PRATempRecord[0].A1_SupplyChain_Assessment5__c;
                PRARecord.A1_SupplyChain_Assessment6__c = PRATempRecord[0].A1_SupplyChain_Assessment6__c;
                PRARecord.SupplyChainScore__c = PRATempRecord[0].SupplyChainScore__c;
                supplyChainScore = (integer)PRATempRecord[0].SupplyChainScore__c;
                
                PRARecord.Acct_DecMat_Market2__c = PRATempRecord[0].Acct_DecMat_Market2__c;
                PRARecord.Acct_DecMat_Market3__c = PRATempRecord[0].Acct_DecMat_Market3__c;
                PRARecord.Acct_DecMat_Market4__c = PRATempRecord[0].Acct_DecMat_Market4__c;
                PRARecord.Acct_DecMat_Market5__c = PRATempRecord[0].Acct_DecMat_Market5__c;
                
                PRARecord.Acct_DecMat_Offer2__c = PRATempRecord[0].Acct_DecMat_Offer2__c;
                PRARecord.Acct_DecMat_Offer3__c = PRATempRecord[0].Acct_DecMat_Offer3__c;
                PRARecord.Acct_DecMat_Offer4__c = PRATempRecord[0].Acct_DecMat_Offer4__c;
                PRARecord.Acct_DecMat_Offer5__c = PRATempRecord[0].Acct_DecMat_Offer5__c;
                
                PRARecord.Acct_DecMat_Price2__c = PRATempRecord[0].Acct_DecMat_Price2__c;
                PRARecord.Acct_DecMat_Price3__c = PRATempRecord[0].Acct_DecMat_Price3__c;
                PRARecord.Acct_DecMat_Price4__c = PRATempRecord[0].Acct_DecMat_Price4__c;
                PRARecord.Acct_DecMat_Price5__c = PRATempRecord[0].Acct_DecMat_Price5__c;
    
                PRARecord.Acct_DecMat_Promotion2__c = PRATempRecord[0].Acct_DecMat_Promotion2__c;
                PRARecord.Acct_DecMat_Promotion3__c = PRATempRecord[0].Acct_DecMat_Promotion3__c;
                PRARecord.Acct_DecMat_Promotion4__c = PRATempRecord[0].Acct_DecMat_Promotion4__c;
                PRARecord.Acct_DecMat_Promotion5__c = PRATempRecord[0].Acct_DecMat_Promotion5__c;
                
                PRARecord.Acct_DecMat_SupplyChain2__c = PRATempRecord[0].Acct_DecMat_SupplyChain2__c;
                PRARecord.Acct_DecMat_SupplyChain3__c = PRATempRecord[0].Acct_DecMat_SupplyChain3__c;
                PRARecord.Acct_DecMat_SupplyChain4__c = PRATempRecord[0].Acct_DecMat_SupplyChain4__c;
                PRARecord.Acct_DecMat_SupplyChain5__c = PRATempRecord[0].Acct_DecMat_SupplyChain5__c;
                
            }
        }

    public PageReference CalculatePriceScore(){
        priceScore = 0;
            if(PRARecord.PriceQuestion1__c != null ){
                priceScore = priceScore + Integer.valueof(PRARecord.PriceQuestion1__c);
            }
            if(PRARecord.PriceQuestion2__c != null ){
                priceScore = priceScore + Integer.valueof(PRARecord.PriceQuestion2__c);
            }
            if(PRARecord.PriceQuestion3__c != null ){
                priceScore = priceScore + Integer.valueof(PRARecord.PriceQuestion3__c);
            }
            if(PRARecord.PriceQuestion4__c != null ){
                priceScore = priceScore  + Integer.valueof(PRARecord.PriceQuestion4__c);
            }
            if(PRARecord.PriceQuestion5__c != null ){
                priceScore = priceScore + Integer.valueof(PRARecord.PriceQuestion5__c);
            }
            if(PRARecord.PriceQuestion6__c != null ){
                priceScore = priceScore + Integer.valueof(PRARecord.PriceQuestion6__c);
            }
            if(PRARecord.PriceQuestion7__c != null ){
                priceScore = priceScore  + Integer.valueof(PRARecord.PriceQuestion7__c);
            }
            if(PRARecord.PriceQuestion8__c != null ){
                priceScore = priceScore + Integer.valueof(PRARecord.PriceQuestion8__c);
            }
            if(PRARecord.PriceQuestion9__c != null ){
                priceScore = priceScore + Integer.valueof(PRARecord.PriceQuestion9__c);
            }
            if(PRARecord.PriceQuestion10__c != null ){
                priceScore = priceScore + Integer.valueof(PRARecord.PriceQuestion10__c);
            }
            system.debug('Check Price Score:'+priceScore );
            PRARecord.PriceScore__c= priceScore;
        return null;    
    }   
    
    public PageReference CalculatemarketScore(){
        marketScore=0;
            if(PRARecord.MarketQuestion1__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion1__c);
            }
            if(PRARecord.MarketQuestion2__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion2__c);
            }
            if(PRARecord.MarketQuestion3__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion3__c);
            }
            if(PRARecord.MarketQuestion4__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion4__c);
            }
            if(PRARecord.MarketQuestion5__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion5__c);
            }
            if(PRARecord.MarketQuestion6__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion6__c);
            }
            if(PRARecord.MarketQuestion7__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion7__c);
            }
            if(PRARecord.MarketQuestion8__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion8__c);
            }
            if(PRARecord.MarketQuestion9__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion9__c);
            }
            if(PRARecord.MarketQuestion10__c != null ){
                marketScore = marketScore + Integer.valueof(PRARecord.MarketQuestion10__c);
            }
            system.debug('Check MarketScore :'+marketScore);
            PRARecord.MarketScore__c= marketScore;
        return null;    
    }
    
    public PageReference CalculateOfferScore(){
        offerScore = 0;
            if(PRARecord.OfferQuestion1__c != null ){
                offerScore = offerScore + Integer.valueof(PRARecord.OfferQuestion1__c);
            }
            if(PRARecord.OfferQuestion2__c != null ){
                offerScore = offerScore + Integer.valueof(PRARecord.OfferQuestion2__c);
            }
            if(PRARecord.OfferQuestion3__c != null ){
                offerScore  = offerScore + Integer.valueof(PRARecord.OfferQuestion3__c);
            }
            if(PRARecord.OfferQuestion4__c != null ){
                offerScore = offerScore + Integer.valueof(PRARecord.OfferQuestion4__c);
            }
            if(PRARecord.OfferQuestion5__c != null ){
                offerScore = offerScore + Integer.valueof(PRARecord.OfferQuestion5__c);
            }
            if(PRARecord.OfferQuestion6__c != null ){
                offerScore = offerScore + Integer.valueof(PRARecord.OfferQuestion6__c);
            }
            if(PRARecord.OfferQuestion7__c != null ){
                offerScore = offerScore + Integer.valueof(PRARecord.OfferQuestion7__c);
            }
            if(PRARecord.OfferQuestion8__c != null ){
                offerScore = offerScore  + Integer.valueof(PRARecord.OfferQuestion8__c);
            }
            if(PRARecord.OfferQuestion9__c != null ){
                offerScore = offerScore + Integer.valueof(PRARecord.OfferQuestion9__c);
           }
            if(PRARecord.OfferQuestion10__c != null ){
                offerScore = offerScore + Integer.valueof(PRARecord.OfferQuestion10__c);
            }
            system.debug('Check Offer Score:'+offerScore);
            PRARecord.OfferScore__c= offerScore;
        return null;    
    }
    
    public PageReference CalculatePromotionScore(){
        promotionScore = 0;
            if(PRARecord.PromotionQuestion1__c != null ){
                promotionScore = promotionScore+ Integer.valueof(PRARecord.PromotionQuestion1__c);
            }
            if(PRARecord.PromotionQuestion2__c != null ){
                promotionScore = promotionScore + Integer.valueof(PRARecord.PromotionQuestion2__c);
            }
            if(PRARecord.PromotionQuestion3__c != null ){
                promotionScore = promotionScore+ Integer.valueof(PRARecord.PromotionQuestion3__c);
            }
            if(PRARecord.PromotionQuestion4__c != null ){
                promotionScore = promotionScore + Integer.valueof(PRARecord.PromotionQuestion4__c);
            }
            if(PRARecord.PromotionQuestion5__c != null ){
                promotionScore = promotionScore + Integer.valueof(PRARecord.PromotionQuestion5__c);
            }
            if(PRARecord.PromotionQuestion6__c != null ){
                promotionScore = promotionScore + Integer.valueof(PRARecord.PromotionQuestion6__c);
            }
            if(PRARecord.PromotionQuestion7__c != null ){
                promotionScore = promotionScore + Integer.valueof(PRARecord.PromotionQuestion7__c);
            }
            if(PRARecord.PromotionQuestion8__c != null ){
                promotionScore = promotionScore + Integer.valueof(PRARecord.PromotionQuestion8__c);
            }
            if(PRARecord.PromotionQuestion9__c != null ){
                promotionScore = promotionScore + Integer.valueof(PRARecord.PromotionQuestion9__c);
            }
            if(PRARecord.PromotionQuestion10__c != null ){
                promotionScore = promotionScore + Integer.valueof(PRARecord.PromotionQuestion10__c);
            }
            system.debug('Check Promotion Score:'+promotionScore);
            PRARecord.PromotionScore__c= promotionScore;
        return null;    
    }
    
    public PageReference CalculateSupplyChainScore(){
        supplyChainScore = 0;
            if(PRARecord.SupplyChainQuestion1__c != null ){
                supplyChainScore = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion1__c);
            }
            if(PRARecord.SupplyChainQuestion2__c != null ){
                supplyChainScore = supplyChainScore  + Integer.valueof(PRARecord.SupplyChainQuestion2__c);
            }
            if(PRARecord.SupplyChainQuestion3__c != null ){
                supplyChainScore = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion3__c);
            }
            if(PRARecord.SupplyChainQuestion4__c != null ){
                supplyChainScore  = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion4__c);
            }
            if(PRARecord.SupplyChainQuestion5__c != null ){
                supplyChainScore = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion5__c);
            }
            if(PRARecord.SupplyChainQuestion6__c != null ){
                supplyChainScore = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion6__c);
            }
            if(PRARecord.SupplyChainQuestion7__c != null ){
                supplyChainScore = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion7__c);
            }
            if(PRARecord.SupplyChainQuestion8__c != null ){
                supplyChainScore = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion8__c);
            }
            if(PRARecord.SupplyChainQuestion9__c != null ){
                supplyChainScore = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion9__c);
            }
            if(PRARecord.SupplyChainQuestion10__c != null ){
                supplyChainScore = supplyChainScore + Integer.valueof(PRARecord.SupplyChainQuestion10__c);
            }
            system.debug('Check SupplyChainScore :'+supplyChainScore );
            PRARecord.SupplyChainScore__c= supplyChainScore;    
        return null;    
    }
    
    public Integer getcallMarketScore(){
        return marketScore;
    }
    public Integer getcallPriceScore(){
        return priceScore;
    }
    public Integer getcallOfferScore(){
        return offerScore;
    }
    public Integer getcallPromotionScore(){
        return promotionScore;
    }
    public Integer getcallSupplyChainScore(){
        return supplyChainScore ;
    }
    
    public PageReference Cancel(){
        String OpenPageUrl = '/'+ areaOfFocusRecord.id;
        PageReference newPage = new PageReference(OpenPageUrl);
        newPage.setRedirect(true);
        return newPage; 
    }
    
    public pagereference saveScoreCardAndContinue(){ 
       try {
        CalculatePriceScore();
        CalculateMarketScore();
        CalculateOfferScore();
        CalculatePromotionScore();
        CalculateSupplyChainScore();
        if(RecordAlreadyExistsFlag == false){
            PRARecord.SupplyChainScore__c = supplyChainScore;
            PRARecord.PromotionScore__c = promotionScore; 
            PRARecord.PriceScore__c = priceScore; 
            PRARecord.OfferScore__c = offerScore; 
            PRARecord.MarketScore__c = marketScore;
            //PRARecord.Account__c = acnt.Id;
            PRARecord.Area_of_Focus__c = areaOfFocusRecord.id;
            /*insert PRARecord;
            RecordAlreadyExistsFlag = true;
            PRAId = PRARecord.id;*/
            database.Saveresult PRARecordInsertResult = database.insert(PRARecord, false);
            
            if(PRARecordInsertResult.isSuccess() == true){
            insertPRARecordSuccessCheck = true;          
            RecordAlreadyExistsFlag = true;
            PRAId = PRARecord.id;
            }
            else 
            {
            insertPRARecordSuccessCheck = false;    
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'INSUFFICIENT PRIVILEGES - You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');  
            ApexPages.addMessage(myMsg);  
            return null;
            }
            
        }
        else{
            
            Partner_Readiness_Assessment__c [] PRARecordForUpdate = [SELECT Id, MarketQuestion1__c, MarketQuestion2__c, 
MarketQuestion3__c, MarketQuestion4__c, MarketQuestion5__c, MarketQuestion6__c, MarketQuestion7__c, 
MarketQuestion8__c, MarketQuestion9__c, MarketQuestion10__c, A1_Market_Assessment1__c, 
A1_Market_Assessment2__c, A1_Market_Assessment3__c, A1_Market_Assessment4__c, A1_Market_Assessment5__c, 
                            OfferQuestion1__c, OfferQuestion2__c, OfferQuestion3__c, OfferQuestion4__c, 
OfferQuestion5__c, OfferQuestion6__c, OfferQuestion7__c, OfferQuestion8__c, 
OfferQuestion9__c, OfferQuestion10__c, A1_Offer_Assessment1__c, A1_Offer_Assessment2__c, 
A1_Offer_Assessment3__c, A1_Offer_Assessment4__c, A1_Offer_Assessment5__c, 
A1_Offer_Assessment6__c, A1_Offer_Assessment7__c, 
                            
                            PriceQuestion1__c, PriceQuestion2__c, PriceQuestion3__c, PriceQuestion4__c, 
PriceQuestion5__c, PriceQuestion6__c, PriceQuestion7__c, PriceQuestion8__c, 
PriceQuestion9__c, PriceQuestion10__c, A1_Price_Assessment1__c, A1_Price_Assessment2__c, 
A1_Price_Assessment3__c, A1_Price_Assessment4__c, A1_Price_Assessment5__c, 
A1_Price_Assessment6__c, A1_Price_Assessment7__c, 
                            
                            PromotionQuestion1__c, PromotionQuestion2__c, PromotionQuestion3__c, 
PromotionQuestion4__c, PromotionQuestion5__c, PromotionQuestion6__c, 
PromotionQuestion7__c, PromotionQuestion8__c, PromotionQuestion9__c, 
PromotionQuestion10__c, A1_Promotion_Assessment1__c, A1_Promotion_Assessment2__c, 
A1_Promotion_Assessment3__c, A1_Promotion_Assessment4__c, A1_Promotion_Assessment5__c, 
A1_Promotion_Assessment6__c, A1_Promotion_Assessment7__c, A1_Promotion_Assessment8__c, 
                            
                            SupplyChainQuestion1__c, SupplyChainQuestion2__c, SupplyChainQuestion3__c, 
SupplyChainQuestion4__c, SupplyChainQuestion5__c, SupplyChainQuestion6__c, 
SupplyChainQuestion7__c, SupplyChainQuestion8__c, SupplyChainQuestion9__c, 
SupplyChainQuestion10__c, A1_SupplyChain_Assessment1__c, A1_SupplyChain_Assessment2__c, 
A1_SupplyChain_Assessment3__c, A1_SupplyChain_Assessment4__c, 
A1_SupplyChain_Assessment5__c, A1_SupplyChain_Assessment6__c, 
                            
                            PriceScore__c,MarketScore__c,OfferScore__c,PromotionScore__c,SupplyChainScore__c,
                            
                            Acct_DecMat_Market2__c, Acct_DecMat_Market3__c, Acct_DecMat_Market4__c, 
Acct_DecMat_Market5__c, Acct_DecMat_Offer2__c, Acct_DecMat_Offer3__c, 
Acct_DecMat_Offer4__c, Acct_DecMat_Offer5__c, Acct_DecMat_Price2__c, 
Acct_DecMat_Price3__c, Acct_DecMat_Price4__c, Acct_DecMat_Price5__c, 
Acct_DecMat_Promotion2__c, Acct_DecMat_Promotion3__c, Acct_DecMat_Promotion4__c, 
Acct_DecMat_Promotion5__c, Acct_DecMat_SupplyChain2__c, Acct_DecMat_SupplyChain3__c, 
Acct_DecMat_SupplyChain4__c, Acct_DecMat_SupplyChain5__c 
                        FROM Partner_Readiness_Assessment__c 
                                          WHERE Id =: PRAId ];
                                          
            PRARecordForUpdate[0].MarketQuestion1__c = PRARecord.MarketQuestion1__c;  
            PRARecordForUpdate[0].MarketQuestion2__c = PRARecord.MarketQuestion2__c; 
            PRARecordForUpdate[0].MarketQuestion3__c = PRARecord.MarketQuestion3__c; 
            PRARecordForUpdate[0].MarketQuestion4__c = PRARecord.MarketQuestion4__c; 
            PRARecordForUpdate[0].MarketQuestion5__c = PRARecord.MarketQuestion5__c; 
            PRARecordForUpdate[0].MarketQuestion6__c = PRARecord.MarketQuestion6__c; 
            PRARecordForUpdate[0].MarketQuestion7__c = PRARecord.MarketQuestion7__c;  
            PRARecordForUpdate[0].MarketQuestion8__c = PRARecord.MarketQuestion8__c; 
            PRARecordForUpdate[0].MarketQuestion9__c = PRARecord.MarketQuestion9__c; 
            PRARecordForUpdate[0].MarketQuestion10__c = PRARecord.MarketQuestion10__c; 
            PRARecordForUpdate[0].A1_Market_Assessment1__c = PRARecord.A1_Market_Assessment1__c;
            PRARecordForUpdate[0].A1_Market_Assessment2__c = PRARecord.A1_Market_Assessment2__c;
            PRARecordForUpdate[0].A1_Market_Assessment3__c = PRARecord.A1_Market_Assessment3__c;
            PRARecordForUpdate[0].A1_Market_Assessment4__c = PRARecord.A1_Market_Assessment4__c;
            PRARecordForUpdate[0].A1_Market_Assessment5__c = PRARecord.A1_Market_Assessment5__c;
            
            PRARecordForUpdate[0].MarketScore__c = PRARecord.MarketScore__c;

            PRARecordForUpdate[0].PriceQuestion1__c = PRARecord.PriceQuestion1__c; 
            PRARecordForUpdate[0].PriceQuestion2__c = PRARecord.PriceQuestion2__c ;
            PRARecordForUpdate[0].PriceQuestion3__c = PRARecord.PriceQuestion3__c ;
            PRARecordForUpdate[0].PriceQuestion4__c = PRARecord.PriceQuestion4__c ;
            PRARecordForUpdate[0].PriceQuestion5__c = PRARecord.PriceQuestion5__c ;
            PRARecordForUpdate[0].PriceQuestion6__c = PRARecord.PriceQuestion6__c ;
            PRARecordForUpdate[0].PriceQuestion7__c = PRARecord.PriceQuestion7__c ; 
            PRARecordForUpdate[0].PriceQuestion8__c = PRARecord.PriceQuestion8__c ;
            PRARecordForUpdate[0].PriceQuestion9__c = PRARecord.PriceQuestion9__c ;
            PRARecordForUpdate[0].PriceQuestion10__c = PRARecord.PriceQuestion10__c ;
            PRARecordForUpdate[0].A1_Price_Assessment1__c = PRARecord.A1_Price_Assessment1__c;
            PRARecordForUpdate[0].A1_Price_Assessment2__c = PRARecord.A1_Price_Assessment2__c;
            PRARecordForUpdate[0].A1_Price_Assessment3__c = PRARecord.A1_Price_Assessment3__c;
            PRARecordForUpdate[0].A1_Price_Assessment4__c = PRARecord.A1_Price_Assessment4__c;
            PRARecordForUpdate[0].A1_Price_Assessment5__c = PRARecord.A1_Price_Assessment5__c;
            PRARecordForUpdate[0].A1_Price_Assessment6__c = PRARecord.A1_Price_Assessment6__c;
            PRARecordForUpdate[0].A1_Price_Assessment7__c = PRARecord.A1_Price_Assessment7__c;

            PRARecordForUpdate[0].PriceScore__c = PRARecord.PriceScore__c ;
            
            PRARecordForUpdate[0].PromotionQuestion1__c = PRARecord.PromotionQuestion1__c ;
            PRARecordForUpdate[0].PromotionQuestion2__c =  PRARecord.PromotionQuestion2__c ;
            PRARecordForUpdate[0].PromotionQuestion3__c = PRARecord.PromotionQuestion3__c ;
            PRARecordForUpdate[0].PromotionQuestion4__c = PRARecord.PromotionQuestion4__c ;
            PRARecordForUpdate[0].PromotionQuestion5__c = PRARecord.PromotionQuestion5__c ;
            PRARecordForUpdate[0].PromotionQuestion6__c = PRARecord.PromotionQuestion6__c ;
            PRARecordForUpdate[0].PromotionQuestion7__c = PRARecord.PromotionQuestion7__c ; 
            PRARecordForUpdate[0].PromotionQuestion8__c = PRARecord.PromotionQuestion8__c ;
            PRARecordForUpdate[0].PromotionQuestion9__c = PRARecord.PromotionQuestion9__c ;
            PRARecordForUpdate[0].PromotionQuestion10__c = PRARecord.PromotionQuestion10__c;
            PRARecordForUpdate[0].A1_Promotion_Assessment1__c = PRARecord.A1_Promotion_Assessment1__c;
            PRARecordForUpdate[0].A1_Promotion_Assessment2__c = PRARecord.A1_Promotion_Assessment2__c;
            PRARecordForUpdate[0].A1_Promotion_Assessment3__c = PRARecord.A1_Promotion_Assessment3__c;
            PRARecordForUpdate[0].A1_Promotion_Assessment4__c = PRARecord.A1_Promotion_Assessment4__c;
            PRARecordForUpdate[0].A1_Promotion_Assessment5__c = PRARecord.A1_Promotion_Assessment5__c;
            PRARecordForUpdate[0].A1_Promotion_Assessment6__c = PRARecord.A1_Promotion_Assessment6__c;
            PRARecordForUpdate[0].A1_Promotion_Assessment7__c = PRARecord.A1_Promotion_Assessment7__c;
            PRARecordForUpdate[0].A1_Promotion_Assessment8__c = PRARecord.A1_Promotion_Assessment8__c;
            PRARecordForUpdate[0].PromotionScore__c = PRARecord.PromotionScore__c ;
            
            PRARecordForUpdate[0].OfferQuestion1__c = PRARecord.OfferQuestion1__c;
            PRARecordForUpdate[0].OfferQuestion2__c = PRARecord.OfferQuestion2__c;
            PRARecordForUpdate[0].OfferQuestion3__c = PRARecord.OfferQuestion3__c;
            PRARecordForUpdate[0].OfferQuestion4__c = PRARecord.OfferQuestion4__c;
            PRARecordForUpdate[0].OfferQuestion5__c = PRARecord.OfferQuestion5__c;
            PRARecordForUpdate[0].OfferQuestion6__c = PRARecord.OfferQuestion6__c;
            PRARecordForUpdate[0].OfferQuestion7__c = PRARecord.OfferQuestion7__c; 
            PRARecordForUpdate[0].OfferQuestion8__c = PRARecord.OfferQuestion8__c;
            PRARecordForUpdate[0].OfferQuestion9__c = PRARecord.OfferQuestion9__c;
            PRARecordForUpdate[0].OfferQuestion10__c = PRARecord.OfferQuestion10__c;
            PRARecordForUpdate[0].A1_Offer_Assessment1__c = PRARecord.A1_Offer_Assessment1__c;
            PRARecordForUpdate[0].A1_Offer_Assessment2__c = PRARecord.A1_Offer_Assessment2__c;
            PRARecordForUpdate[0].A1_Offer_Assessment3__c = PRARecord.A1_Offer_Assessment3__c;
            PRARecordForUpdate[0].A1_Offer_Assessment4__c = PRARecord.A1_Offer_Assessment4__c;
            PRARecordForUpdate[0].A1_Offer_Assessment5__c = PRARecord.A1_Offer_Assessment5__c;
            PRARecordForUpdate[0].A1_Offer_Assessment6__c = PRARecord.A1_Offer_Assessment6__c;
            PRARecordForUpdate[0].A1_Offer_Assessment7__c = PRARecord.A1_Offer_Assessment7__c;
            
            PRARecordForUpdate[0].OfferScore__c = PRARecord.OfferScore__c ;  
            
            PRARecordForUpdate[0].SupplyChainQuestion1__c = PRARecord.SupplyChainQuestion1__c;
            PRARecordForUpdate[0].SupplyChainQuestion2__c = PRARecord.SupplyChainQuestion2__c;
            PRARecordForUpdate[0].SupplyChainQuestion3__c = PRARecord.SupplyChainQuestion3__c;
            PRARecordForUpdate[0].SupplyChainQuestion4__c = PRARecord.SupplyChainQuestion4__c;
            PRARecordForUpdate[0].SupplyChainQuestion5__c = PRARecord.SupplyChainQuestion5__c;
            PRARecordForUpdate[0].SupplyChainQuestion6__c = PRARecord.SupplyChainQuestion6__c;
            PRARecordForUpdate[0].SupplyChainQuestion7__c = PRARecord.SupplyChainQuestion7__c; 
            PRARecordForUpdate[0].SupplyChainQuestion8__c = PRARecord.SupplyChainQuestion8__c;
            PRARecordForUpdate[0].SupplyChainQuestion9__c = PRARecord.SupplyChainQuestion9__c;
            PRARecordForUpdate[0].SupplyChainQuestion10__c = PRARecord.SupplyChainQuestion10__c;
            PRARecordForUpdate[0].A1_SupplyChain_Assessment1__c = PRARecord.A1_SupplyChain_Assessment1__c;
            PRARecordForUpdate[0].A1_SupplyChain_Assessment2__c = PRARecord.A1_SupplyChain_Assessment2__c;
            PRARecordForUpdate[0].A1_SupplyChain_Assessment3__c = PRARecord.A1_SupplyChain_Assessment3__c;
            PRARecordForUpdate[0].A1_SupplyChain_Assessment4__c = PRARecord.A1_SupplyChain_Assessment4__c;
            PRARecordForUpdate[0].A1_SupplyChain_Assessment5__c = PRARecord.A1_SupplyChain_Assessment5__c;
            PRARecordForUpdate[0].A1_SupplyChain_Assessment6__c = PRARecord.A1_SupplyChain_Assessment6__c;

            PRARecordForUpdate[0].SupplyChainScore__c = PRARecord.SupplyChainScore__c;
            
            PRARecordForUpdate[0].Acct_DecMat_Market2__c = PRARecord.Acct_DecMat_Market2__c;
            PRARecordForUpdate[0].Acct_DecMat_Market3__c = PRARecord.Acct_DecMat_Market3__c;
            PRARecordForUpdate[0].Acct_DecMat_Market4__c = PRARecord.Acct_DecMat_Market4__c;
            PRARecordForUpdate[0].Acct_DecMat_Market5__c = PRARecord.Acct_DecMat_Market5__c;
            
            PRARecordForUpdate[0].Acct_DecMat_Offer2__c = PRARecord.Acct_DecMat_Offer2__c;
            PRARecordForUpdate[0].Acct_DecMat_Offer3__c = PRARecord.Acct_DecMat_Offer3__c;
            PRARecordForUpdate[0].Acct_DecMat_Offer4__c = PRARecord.Acct_DecMat_Offer4__c;
            PRARecordForUpdate[0].Acct_DecMat_Offer5__c = PRARecord.Acct_DecMat_Offer5__c;
            
            PRARecordForUpdate[0].Acct_DecMat_Price2__c = PRARecord.Acct_DecMat_Price2__c;
            PRARecordForUpdate[0].Acct_DecMat_Price3__c = PRARecord.Acct_DecMat_Price3__c;
            PRARecordForUpdate[0].Acct_DecMat_Price4__c = PRARecord.Acct_DecMat_Price4__c;
            PRARecordForUpdate[0].Acct_DecMat_Price5__c = PRARecord.Acct_DecMat_Price5__c;

            PRARecordForUpdate[0].Acct_DecMat_Promotion2__c = PRARecord.Acct_DecMat_Promotion2__c;
            PRARecordForUpdate[0].Acct_DecMat_Promotion3__c = PRARecord.Acct_DecMat_Promotion3__c;
            PRARecordForUpdate[0].Acct_DecMat_Promotion4__c = PRARecord.Acct_DecMat_Promotion4__c;
            PRARecordForUpdate[0].Acct_DecMat_Promotion5__c = PRARecord.Acct_DecMat_Promotion5__c;
            
            PRARecordForUpdate[0].Acct_DecMat_SupplyChain2__c = PRARecord.Acct_DecMat_SupplyChain2__c;
            PRARecordForUpdate[0].Acct_DecMat_SupplyChain3__c = PRARecord.Acct_DecMat_SupplyChain3__c;
            PRARecordForUpdate[0].Acct_DecMat_SupplyChain4__c = PRARecord.Acct_DecMat_SupplyChain4__c;
            PRARecordForUpdate[0].Acct_DecMat_SupplyChain5__c = PRARecord.Acct_DecMat_SupplyChain5__c;
            
            //update PRARecordForUpdate;
            database.Saveresult[] PRARecordUpdateResult = database.update(PRARecordForUpdate, false);
            
            if(PRARecordUpdateResult[0].isSuccess() == false){
                updatePRARecordSuccessCheck = false;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'INSUFFICIENT PRIVILEGES - You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');  
                ApexPages.addMessage(myMsg);  
                return null;
            }
            
            
        }

        areaOfFocusRecord.Market_Score__c = marketScore;
        areaOfFocusRecord.Offer_Score__c = offerScore;
        areaOfFocusRecord.Price_Score__c = priceScore;
        areaOfFocusRecord.Promotion_Score__c = promotionScore;
        areaOfFocusRecord.Supply_Chain_Score__c = supplyChainScore;
        
        update areaOfFocusRecord;
        return null;
    }
    catch(System.DMLException e){
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error While saving the Record : ' + e.getMessage());
        ApexPages.addMessage(myMsg);
        System.debug('Error is======'+e.getMessage());
        return null;
    }   
    
        
    }
  /*    public PageReference saveScoreandReturnToAccount(){
    return null;
    } */
    
    //public PageReference saveScoreandReturnToAccount(){
     public PageReference saveScoreandReturnToAreaOfFocus(){
        /*saveScoreCardAndContinue(); 
        String OpenPageUrl = '/'+ acnt.id;
        PageReference newPage = new PageReference(OpenPageUrl);
        newPage.setRedirect(true);
        return newPage; */
        
        try {
        saveScoreCardAndContinue();
        if(updatePRARecordSuccessCheck == false || insertPRARecordSuccessCheck == false) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'INSUFFICIENT PRIVILEGES - You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');  
            ApexPages.addMessage(myMsg);
            return null;
        }
               
        else{
            String OpenPageUrl = '/'+ areaOfFocusRecord.id;
            PageReference newPage = new PageReference(OpenPageUrl);
            newPage.setRedirect(true);
            return newPage;
        }         
      }
        catch(System.DMLException e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error While saving the Record : ' + e.getMessage());
        ApexPages.addMessage(myMsg);
        System.debug('Error is======'+e.getMessage());
        return null;
        }
     
    }

    public PageReference saveSLDM(){
       /*saveScoreCardAndContinue(); 
       return null;  */
       
       
        try {
        saveScoreCardAndContinue();
        if(updatePRARecordSuccessCheck == false || insertPRARecordSuccessCheck == false) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'INSUFFICIENT PRIVILEGES - You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');  
            ApexPages.addMessage(myMsg);
            return null;
        }
               
        else{
            return null;
        }         
      }
        catch(System.DMLException e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error While saving the Record : ' + e.getMessage());
        ApexPages.addMessage(myMsg);
        System.debug('Error is======'+e.getMessage());
        return null;
        }
    
    }
    
   /* public PageReference saveSLDMReturnAccts(){
    return null;
    } */
    public PageReference saveSLDMReturnAreaOfFocus(){
        /*saveSLDM();
        String OpenPageUrl = '/'+ acnt.id;
        PageReference newPage = new PageReference(OpenPageUrl);
        newPage.setRedirect(true);
        return newPage;  */
        
        try {
        saveSLDM();
        if(updatePRARecordSuccessCheck == false || insertPRARecordSuccessCheck == false) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'INSUFFICIENT PRIVILEGES - You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.');  
            ApexPages.addMessage(myMsg);
            return null;
        }
               
        else{
            String OpenPageUrl = '/'+ areaOfFocusRecord.id;
            PageReference newPage = new PageReference(OpenPageUrl);
            newPage.setRedirect(true);
            return newPage; 
        }         
      }
        catch(System.DMLException e){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR,'Error While saving the Record : ' + e.getMessage());
        ApexPages.addMessage(myMsg);
        System.debug('Error is======'+e.getMessage());
        return null;
        }         
        }
        
    
    public pagereference launchMrktAssessQsts(){ 
        launchMrktAssessQsts = true;
        return null;
        }
     
    
    public boolean launchMrktAssessQsts{
        get{
        if(launchMrktAssessQsts == null){
            launchMrktAssessQsts= false;
        }

        return launchMrktAssessQsts;
        }
        set;
        }
    
  
   /* public id getAccountId(){
               return null;
    } */
    public id getAreaOfFocusId(){
               return currentPgId;
    } 
    
 
    public string getAccountName() {
    return AcctName;
    }
     public string getAreaOfFocusName() {
    return AreaOfFocusName;
    }

    public string getAccountOwner() {
    return OwnerName ;
    }
  
    public Boolean market_CheckBox { get; set; }
    public Boolean price_CheckBox { get; set; }
    public Boolean offer_CheckBox { get; set; }
    public Boolean promotion_CheckBox { get; set; }
    public Boolean supChain_CheckBox { get; set; }

  public Boolean check {get; set;}

}