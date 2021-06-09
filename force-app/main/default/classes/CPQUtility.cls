/************************************************************************************************
* Description: Frequently used function to get community base url, Site url, EditPage
* Author : Adilraza Shaikh, Afzal Wasi
* Date :  13th Aug 2018
**********************************************************************************************/
global class CPQUtility {

    public static String fetchSitePrefix(){
        if(!Test.isRunningTest() && GlobalUtility.isLoggedinPartnerUser()){
            return URL.getSalesforceBaseUrl().toExternalForm() + '/' + [SELECT UrlPathPrefix FROM Network WHERE Id =: Network.getNetworkId()].UrlPathPrefix;   
        } else {
            return URL.getSalesforceBaseUrl().toExternalForm();
        }
    }
    
    public static String fetchCPQSiteId(){ 
        return [SELECT Id,BigMachines__bm_site__c,BigMachines__Is_Active__c FROM BigMachines__Configuration_Record__c WHERE BigMachines__Is_Active__c = True].Id;
    }
    
    public static String getPageUrl(String parentAccID){
        List<BigMachines__Quote__c> lstQuote = [SELECT Id, BigMachines__Account__c, BigMachines__Opportunity__c FROM BigMachines__Quote__c WHERE Id =: parentAccID];
        String theme = UserInfo.getUiThemeDisplayed();
        String internalBaseUrl=URL.getSalesforceBaseUrl().toExternalForm();
        if(lstQuote.size()>0 && lstQuote.get(0).BigMachines__Opportunity__c != NULL ){
            if(theme == 'Theme4d'){
                return internalBaseUrl+'/apex/BigMachines__QuoteEdit?oppId='+lstQuote.get(0).BigMachines__Opportunity__c;
            }else{
                return fetchSitePrefix()+'/apex/BigMachines__QuoteEdit?oppId='+lstQuote.get(0).BigMachines__Opportunity__c;  
            }
        } else {
            if(theme == 'Theme4d'){
                return internalBaseUrl+'/apex/BigMachines__QuoteEdit?actId='+lstQuote.get(0).BigMachines__Account__c;
            }else{
                return fetchSitePrefix()+'/apex/BigMachines__QuoteEdit?actId='+lstQuote.get(0).BigMachines__Account__c;
            }
        }
    } 
    
    public static String createCPQSession(String custId, String MCNId, Decimal eligiblePer, String MRId, String orderType, String oppoId, String partnerSoftwareQuote, String recordId) {
        //UserSession Object
        if(String.isNotBlank(custId) && String.isNotBlank(MCNId)) {
            UserSessionCPQ__c userSessionObject = new UserSessionCPQ__c();
            userSessionObject.User_Id__c = UserInfo.getUserId();
            userSessionObject.Account_ID__c = custId;
            userSessionObject.CDH_Account_ID__c = MCNId;
            userSessionObject.Eligible_Percentage__c=eligiblePer;
            userSessionObject.Order_Type__c = orderType;
            userSessionObject.MR_ID__c = MRId;
            userSessionObject.Opportunity_Id__c = oppoId;	
            userSessionObject.Type_of_Quote__c = partnerSoftwareQuote;
            userSessionObject.recordId__c = recordId;
            if(userSessionObject != NULL) {
                try{
                    Insert userSessionObject;
                    system.debug('UserSession Inserted===>');
                }
                catch(DMLException ex){
                    system.debug('Exception is...'+ex.getMessage());
                }
            }
        }
        return 'Success';
    }
    
    public static AccountDetailsWrapper fetchAccDetailsForMSILED(String motoCustNum){
        System.debug('##motoCustNum##' + motoCustNum);
        AccountDetailsWrapper ADWrapper = new AccountDetailsWrapper();
        if(!String.isBlank(motoCustNum)){
            //Get Customer Details for Internal User
            List<Account> CustDetails = [SELECT Parent.Name,Motorola_Customer_Number__c,Primary_Route_to_Market__c,
                                         Recordtype.DeveloperName FROM Account
                                         WHERE Motorola_Customer_Number__c =:motoCustNum AND 
                                         Recordtype.DeveloperName = 'Motorola_Customer_Number' LIMIT 1];
            //SF-1803 - Removed "AND Primary_Route_to_Market__c = 'MSI LED'" from above query
            if(!CustDetails.isEmpty()) {
                ADWrapper.customerAccount = CustDetails.get(0);
            }
        }
        if(ADWrapper.customerAccount!=null){
            return ADWrapper;
        }else{
            return null;
        }
        
    }
    public static AccountDetailsWrapper fetchAccountDetails(String motoCustNum, String partnerAccountId, String custorProsId){
        System.debug('##motoCustNum##' + motoCustNum);
        System.debug('##partnerAccountId##' + partnerAccountId);
        System.debug('##custorProsId##' + custorProsId);
        AccountDetailsWrapper ADWrapper = new AccountDetailsWrapper();
        if(!String.isBlank(partnerAccountId)){
            //Get Partner Details for Partner/Internal User
            List<Account> partnerAccounts = [SELECT Id,Name,Partner_Membership_Id__c,BillingCity,BillingState,BillingCountry 
                                             FROM Account WHERE Id =: partnerAccountId LIMIT 1];   
            if(!partnerAccounts.isEmpty()) {
                ADWrapper.partnerAccount = partnerAccounts.get(0);
            }
        }
        if(String.isBlank(motoCustNum)){
            //Get Prospect Details for Partner/Internal User
            List<Account> prospectDetails = [SELECT Prospect_Sales_Channel__c,Name,Territory__c,Recordtype.DeveloperName FROM Account
                                             WHERE Id =: custorProsId AND Recordtype.DeveloperName='Prospect' LIMIT 1];
            if(!prospectDetails.isEmpty()) {
                ADWrapper.prospectAccount = prospectDetails.get(0);
            }
        }else if(!String.isBlank(motoCustNum) ){
            //Get Customer Details for Internal/Partner User
            List<Account> CustDetails = [SELECT Parent.Name,Motorola_Customer_Number__c,Primary_Route_to_Market__c,Assigned_MR__c,
                                         Recordtype.DeveloperName FROM Account
                                         WHERE Motorola_Customer_Number__c =:motoCustNum 
                                         AND Recordtype.DeveloperName = 'Motorola_Customer_Number' LIMIT 1];
            if(!CustDetails.isEmpty()) {
                ADWrapper.customerAccount = CustDetails.get(0);
                if(CustDetails.get(0).Assigned_MR__c != null){
                    ADWrapper.mrAssignedMR='Yes';
                }else{
                    ADWrapper.mrAssignedMR='No';
                }
            }
        } 
        SpecAndCTypeWrapper wrapper = fetchSpecAndCType(motoCustNum,partnerAccountId,custorProsId);
        //Get Partner Identifier Number
        ADWrapper.mrTierLevel = wrapper.mrTierLevel;
        ADWrapper.mrCommunityType = wrapper.mrCommunityType;
        ADWrapper.mrId = fetchPartnerIdentifierNumber(wrapper.territory, wrapper.salesChannel, partnerAccountId);
        return ADWrapper;
    }   
    
    public static SpecAndCTypeWrapper fetchSpecAndCType(String motoCustNum, String partnerAccountId, String custorProsId) {
        System.debug('##motoCustNum## in spec' + motoCustNum);
        System.debug('##partnerAccountId## in spec' + partnerAccountId);
        System.debug('##custorProsId## in spec' + custorProsId);
        SpecAndCTypeWrapper wrapper = new SpecAndCTypeWrapper();
        List<Account> parentAccount = new List<Account>();
        if(String.isNotBlank(motoCustNum)) {
            parentAccount = [SELECT Prospect_Sales_Channel__c,Territory__c,Parent.Territory__c,Recordtype.DeveloperName,
                                       Name,Motorola_Customer_Number__c,Customer_or_Prospect_Account__r.Name,Primary_Route_to_Market__c FROM Account
                                       WHERE (Motorola_Customer_Number__c =:motoCustNum AND Recordtype.DeveloperName = 'Motorola_Customer_Number') LIMIT 1];
        } else if(String.isNotBlank(custorProsId)) {
            parentAccount = [SELECT Prospect_Sales_Channel__c,Territory__c,Parent.Territory__c,Recordtype.DeveloperName,
                                       Name,Motorola_Customer_Number__c,Customer_or_Prospect_Account__r.Name,Primary_Route_to_Market__c FROM Account
                                       WHERE Id =: custorProsId AND Recordtype.DeveloperName='Prospect' LIMIT 1];
        }
        String territory;
        String salesChannel;
        if(!parentAccount.isEmpty()) {
            if(parentAccount.get(0).Recordtype.DeveloperName == 'Prospect') {
                territory = parentAccount.get(0).Territory__c;
                if(String.isBlank(territory) && parentAccount.get(0).Prospect_Sales_Channel__c =='Federal'){
                    salesChannel = 'Federal';
                }else if(String.isBlank(territory) && parentAccount.get(0).Prospect_Sales_Channel__c =='State and Local'){
                    salesChannel = 'State and Local';
                }
            } else {
                territory = parentAccount.get(0).Parent.Territory__c;
            }
        }
        wrapper.territory = territory;
        wrapper.salesChannel = salesChannel;
        //Get Partner's specializaion Level
        Set<String> validFedTerritories = fetchFedTerritories();
        Set<String> validSLTerritories = fetchSLTerritories(); 
        List<Technology_Specialization__c> tecSpecsLevel= new List<Technology_Specialization__c>();
        if(validFedTerritories.contains(territory) || salesChannel =='Federal'){
            tecSpecsLevel = [SELECT Technology_Specialization_Level__c,Community_Type__c FROM Technology_Specialization__c WHERE Account__c = :partnerAccountId 
                             AND Technology_Specialization__c = 'Mission Critical Radio Systems' AND Program__c = 'RADIO' 
                             AND Technology_Specialization_Status__c = 'Active' 
                             AND (Community_Type__c='Federal Manufacturer Representative')];  
            System.debug('Fed Community Type ####' + tecSpecsLevel.get(0).Community_Type__c);
        }
        if(validSLTerritories.contains(territory) || salesChannel == 'State and Local'){
            tecSpecsLevel = [SELECT Technology_Specialization_Level__c,Community_Type__c FROM Technology_Specialization__c WHERE Account__c = :partnerAccountId 
                             AND Technology_Specialization__c = 'Mission Critical Radio Systems' AND Program__c = 'RADIO' 
                             AND Technology_Specialization_Status__c = 'Active' 
                             AND (Community_Type__c =:Label.State_and_Local_Manufacturer_Representative)];        
            //or Community_Type__c='Federal Manufacturer Representative'
            system.debug('tecSpecsLevel'+tecSpecsLevel);
            //System.debug('S&L Community Type ####' + tecSpecsLevel.get(0).Community_Type__c);
        }
        if(!tecSpecsLevel.isEmpty()) {
            wrapper.mrTierLevel = tecSpecsLevel.get(0).Technology_Specialization_Level__c;
            wrapper.mrCommunityType = tecSpecsLevel.get(0).Community_Type__c;
        }
        return wrapper;
    }    
    
    @TestVisible 
    private static String fetchPartnerIdentifierNumber(String custorProsTerritory, String salesChannel, String partnerAccountId) {
        Set<String> validFedTerritories = fetchFedTerritories();
        Set<String> validSLTerritories = fetchSLTerritories();
        String partnerIdetifierNumber = '';
        if(String.isNotBlank(partnerAccountId) && (validFedTerritories.contains(custorProsTerritory) || salesChannel =='Federal') ) {
            List<Partner_Identifier__c> fedPartnerIdentifiers = [Select ID_Number__c From Partner_Identifier__c where Account__c =: partnerAccountId and ID_Type__c='Federal Manufacturer Representative ID'];
            if(fedPartnerIdentifiers != NULL && fedPartnerIdentifiers.size() > 0) {
                partnerIdetifierNumber = fedPartnerIdentifiers[0].ID_Number__c;
            }
        } else if(String.isNotBlank(partnerAccountId) && (validSLTerritories.contains(custorProsTerritory) || salesChannel =='State and Local')) {
            List<Partner_Identifier__c> SLPartnerIdentifiers = [Select ID_Number__c From Partner_Identifier__c where Account__c =: partnerAccountId and ID_Type__c='State and Local Manufacturer Representative ID'];
            if(SLPartnerIdentifiers != NULL && SLPartnerIdentifiers.size() > 0) {
                partnerIdetifierNumber = SLPartnerIdentifiers[0].ID_Number__c;
            }              
        }
        system.debug('partnerIdetifierNumber'+partnerIdetifierNumber);
        return partnerIdetifierNumber;
    }    
    
    public static Decimal fetchPartnerTerritoryCommission(String partnerAccountId, String orderType, String techSpecLevel, String communityType){               
        System.Debug('###orderType###' + orderType +'###techSpecLevel###' + techSpecLevel + '###communityType###' + communityType);
        Decimal totalEligiblePercentage = 0;
        Map<String, MR_Territories_Commission__mdt> commissionMap = new Map<String, MR_Territories_Commission__mdt>();
        for(MR_Territories_Commission__mdt territoryCom : [Select MasterLabel,Territory_Commission__c,MR_Tech_Specialization_Level__r.MasterLabel,
                                                           MR_Tech_Specialization_Level__r.Percentage__c,MR_Order_Types_for_CPQ__r.Values__c from 
                                                           MR_Territories_Commission__mdt where MR_Order_Types_for_CPQ__r.MasterLabel =: orderType 
                                                           AND MasterLabel =:communityType AND MR_Tech_Specialization_Level__r.MasterLabel =: techSpecLevel]) 
        {            
            commissionMap.put(territoryCom.MR_Tech_Specialization_Level__r.MasterLabel, territoryCom);
        }       
        //System.Debug('***commissionMap.get(techSpecLevel)***' + commissionMap);
        if(commissionMap.get(techSpecLevel) != NULL) {
            MR_Territories_Commission__mdt commissionMeta = commissionMap.get(techSpecLevel);
			System.Debug('***commissionMeta***' + commissionMeta);
            if(communityType == Label.State_and_Local_Manufacturer_Representative ){
                totalEligiblePercentage = commissionMeta.Territory_Commission__c 
                    + commissionMeta.MR_Tech_Specialization_Level__r.Percentage__c 
                    + commissionMeta.MR_Order_Types_for_CPQ__r.Values__c;                
            }else if(communityType=='Federal Manufacturer Representative'){
                totalEligiblePercentage = commissionMeta.Territory_Commission__c ;                                
            }            
            System.Debug('***TEP***' + totalEligiblePercentage);
        }
        return totalEligiblePercentage;
    }  
    
    public Static Set<String> fetchFedTerritories(){
        Map<String,FedTerritories__mdt> mapFedTerritories= new Map<String,FedTerritories__mdt>();
        for(FedTerritories__mdt FedTerritories : [SELECT MasterLabel,DeveloperName FROM FedTerritories__mdt]){
            mapFedTerritories.put(FedTerritories.MasterLabel,null);
        }
        return mapFedTerritories.keySet();
    }  
    
    public Static Set<String> fetchSLTerritories(){
        Map<String,SLTerritories__mdt> mapSLTerritories= new Map<String,SLTerritories__mdt>();
        for(SLTerritories__mdt SLTerritories : [SELECT MasterLabel,DeveloperName FROM SLTerritories__mdt]){
            mapSLTerritories.put(SLTerritories.MasterLabel,null);
        }
        return mapSLTerritories.keySet();
    } 
    
  
    
    public static List<String> fetchOrderType(Boolean isPopUp, String partnerAccountId) {
        system.debug('#####partnerAccountId###### => ' + partnerAccountId);
        Boolean partnerCommunityType = false;
        if(String.isNotBlank(partnerAccountId)) {
            List<Account> pAccounts = [SELECT Partner_Community_Types__c FROM Account WHERE Id =: partnerAccountId and Program_Level_Community__c LIKE '%Command Central NG911%'];
            system.debug('pAccounts###########'+pAccounts);
            if(!pAccounts.isEmpty()) {
                partnerCommunityType = true;
            }
        }
        List<String> orderList = new List<String>();
        System.debug('partnerCommunityType#####=>' +partnerCommunityType);
        if(isPopUp) {
            for(MR_Order_Types_for_CPQ__mdt mrOrderType : [SELECT MasterLabel,DeveloperName FROM MR_Order_Types_for_CPQ__mdt WHERE Is_Available_for_MRs__c=true AND Is_Popup__c =: isPopUp]){
                orderList.add(mrOrderType.MasterLabel);
            }
        } else {
            for(MR_Order_Types_for_CPQ__mdt mrOrderType : [SELECT MasterLabel,DeveloperName FROM MR_Order_Types_for_CPQ__mdt WHERE Is_Available_for_MRs__c=true]){
                if(mrOrderType.DeveloperName != 'Command_Center_MR_CCMR'){
                    orderList.add(mrOrderType.MasterLabel);
                } else if(mrOrderType.DeveloperName == 'Command_Center_MR_CCMR' && partnerCommunityType){
                    orderList.add(mrOrderType.MasterLabel);
                    System.debug('orderList#####=>' +orderList);
                }                
            }
        }
        return orderList;
    }
    
    public class AccountDetailsWrapper {
        @AuraEnabled public Account partnerAccount{get;set;}
        @AuraEnabled public Account customerAccount{get;set;}
        @AuraEnabled public Account prospectAccount{get;set;}
        @AuraEnabled public String mrId{get;set;}
        @AuraEnabled public String mrTierLevel{get;set;}
        @AuraEnabled public String mrCommunityType{get;set;}
        @AuraEnabled public String mrAssignedMR{get;set;}
    } 
    
    public class SpecAndCTypeWrapper {
        @AuraEnabled public String mrTierLevel{get;set;}
        @AuraEnabled  public String mrCommunityType{get;set;}
        @AuraEnabled public String territory{get;set;}
        @AuraEnabled public String salesChannel{get;set;}
    } 
    
    /*
* Name : populateProductFamily
* @Param 1 : List of QuoteProduct records
* @Param 2 : List of BidScrub records
* Description : Update WWAPC_APC_Mapping__c value
* Created By : Satish M
*/
    public Static void populateProductFamily(List<BigMachines__Quote_Product__c> cpqQuoteProductLst, List<Bid_Scrub__c> bidScrubProductLst){
        //Getting Case recordtypeid
        Id supportCaseRecTypeId = GlobalUtility.recordTypeId('Case','Support Request'); // need to change it to Developer Name - Guru
        //Below List holds BigMachines__Quote_Product__c records which are required to create new QuoteToForecastMapping records
        List<BigMachines__Quote_Product__c> quoteProductsLstWithoutMatchingCodes = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> quoteProductsLstWithoutMatchingUniqueCodes = new List<BigMachines__Quote_Product__c>();
        //Below Map holds APC code and QuoteToForecastMapping record
        Map<String,Forecasting_Product_Family__c> APCCodeMap = new Map<String,Forecasting_Product_Family__c>();
        //Below Map holds WWAPC code and QuoteToForecastMapping record
        Map<String,Forecasting_Product_Family__c> WWAPCCodeMap = new Map<String,Forecasting_Product_Family__c>();
        //Querying all QuoteToForecastMapping records and preparing maps
        //FILTER THE SOQL based on WWAPAC OR APC CODES
        for(Forecasting_Product_Family__c eachRec : [SELECT Name,Product_Family__r.Id,Product_Family__r.Name,Forecast_Rollup_WWAPC_Code__c,APC__c 
                                                     FROM Forecasting_Product_Family__c]) {
                                                         if(String.isNotBlank(eachRec.APC__c)) {
                                                             APCCodeMap.put(eachRec.APC__c,eachRec);   
                                                         }
                                                         if(String.isNotBlank(eachRec.Forecast_Rollup_WWAPC_Code__c)) {
                                                             WWAPCCodeMap.put(eachRec.Forecast_Rollup_WWAPC_Code__c,eachRec);
                                                         }            
                                                     }
        /**************CPQ Quote Product**********************************/
        //Updating WWAPC_APC_Mapping__c field on Quote Product object
        Set<String> quoteProductCode = new Set<String>(); //SF-1971        
        if(!cpqQuoteProductLst.isEmpty()) {
            for(BigMachines__Quote_Product__c eachQP : cpqQuoteProductLst) {
                //If matching APC code found, update it
                if(String.isNotBlank(eachQP.APC__c) && APCCodeMap.containsKey(eachQP.APC__c)) {
                    eachQP.WWAPC_APC_Mapping__c = APCCodeMap.get(eachQP.APC__c).id;                    
                }
                //If matching WWAPC code found, update it
                else if(String.isNotBlank(eachQP.WWAPC__c) && WWAPCCodeMap.containsKey(eachQP.WWAPC__c)) {
                    eachQP.WWAPC_APC_Mapping__c = WWAPCCodeMap.get(eachQP.WWAPC__c).id;                    
                } 
                //If no matching APC and WWAPC values found, preparing QuoteProducts list to create new QuoteToForeCasting records
                else if((String.isNotBlank(eachQP.APC__c) && !APCCodeMap.containsKey(eachQP.APC__c)) || 
                        (String.isNotBlank(eachQP.WWAPC__c) && !WWAPCCodeMap.containsKey(eachQP.WWAPC__c))) {
                            //quoteProductsLstWithoutMatchingCodes.add(eachQP);
                            //SF-1971 - Removing the duplicate codes --start
                            quoteProductsLstWithoutMatchingCodes.add(eachQP); 
                            system.debug('quoteProductCode===>' + quoteProductCode);
                            if(String.isNotBlank(eachQP.WWAPC__c) && !quoteProductCode.contains(eachQP.WWAPC__c)){
                                quoteProductsLstWithoutMatchingUniqueCodes.add(eachQP);  
                                quoteProductCode.add(eachQP.WWAPC__c);                                
                            }/*else if(String.isBlank(eachQP.WWAPC__c) && String.isNotBlank(eachQP.APC__c) && !quoteProductCode.contains(eachQP.APC__c)){
                                quoteProductsLstWithoutMatchingUniqueCodes.add(eachQP);  
                                quoteProductCode.add(eachQP.APC__c);                                 
                            }*///Commented this block as part of SF-2217-APCs being auto-created with Bid Scrub  loads
                        }            
             //SF-1971 - Removing the duplicate codes --end
            }            
            system.debug('quoteProductsLstWithoutMatchingCodes===>' + quoteProductsLstWithoutMatchingCodes);
            system.debug('quoteProductsLstWithoutMatchingUniqueCodes===>' + quoteProductsLstWithoutMatchingUniqueCodes);
        }        
        //To create new QuoteToForeCastMapping records - CPQ Quote Products
        if(!quoteProductsLstWithoutMatchingUniqueCodes.isEmpty()) {
            List<Forecasting_Product_Family__c> newQFCMappingRecords = createQuoteProductQTFMapRecs(quoteProductsLstWithoutMatchingUniqueCodes);
            if(newQFCMappingRecords != null){
                //Description: Creating support request cases for all newly created QuoteToForecastMapping records
                createSupportReqCases(newQFCMappingRecords,supportCaseRecTypeId);                
                //Description: Updating QuoteProduct's WWAPC_APC_Mapping__c value with newly created QuoteToForecastMapping's id
                updateQuoteProducts(quoteProductsLstWithoutMatchingCodes,newQFCMappingRecords);
            }            
        }        
        
        /**************Bid Scrub Product**********************************/
        //Below List holds BigMachines__Quote_Product__c records which are required to create new QuoteToForecastMapping records
        List<Bid_Scrub__c> bidScrubProductsLstWithoutMatchingCodes = new List<Bid_Scrub__c>();
        List<Bid_Scrub__c> bidScrubProductsLstWithoutMatchingUniqueCodes = new List<Bid_Scrub__c>();
        Set<String> productCode = new Set<String>(); //SF-1971 
        if(!bidScrubProductLst.isEmpty()) {
            //Todo : Add BidScrub logic here
            for(Bid_Scrub__c  eachQP : bidScrubProductLst) {
                //If matching APC code found, update it
                if(String.isNotBlank(eachQP.Product_APC__c) && APCCodeMap.containsKey(eachQP.Product_APC__c)) {
                    eachQP.WWAPC_APC_Mapping__c = APCCodeMap.get(eachQP.Product_APC__c).id;                     
                }
                //If matching WWAPC code found, update it
                else if(String.isNotBlank(eachQP.Product_WWAPC__c) && WWAPCCodeMap.containsKey(eachQP.Product_WWAPC__c)) {
                    eachQP.WWAPC_APC_Mapping__c = WWAPCCodeMap.get(eachQP.Product_WWAPC__c).id;                       
                } 
                //If no matching APC and WWAPC values found, preparing QuoteProducts list to create new QuoteToForeCasting records
                else if((String.isNotBlank(eachQP.Product_APC__c) && !APCCodeMap.containsKey(eachQP.Product_APC__c)) || 
                        (String.isNotBlank(eachQP.Product_WWAPC__c) && !WWAPCCodeMap.containsKey(eachQP.Product_WWAPC__c))) {
                            //SF-1971 - Removing the duplicate codes --start
                            system.debug('productCode===>' + productCode);
                            bidScrubProductsLstWithoutMatchingCodes.add(eachQP);
                            if(String.isNotBlank(eachQP.Product_WWAPC__c) && !productCode.contains(eachQP.Product_WWAPC__c)){
                                bidScrubProductsLstWithoutMatchingUniqueCodes.add(eachQP);  
                                productCode.add(eachQP.Product_WWAPC__c);                                
                            }/*else if(String.isBlank(eachQP.Product_WWAPC__c) && String.isNotBlank(eachQP.Product_APC__c) && !productCode.contains(eachQP.Product_APC__c)){
                                bidScrubProductsLstWithoutMatchingUniqueCodes.add(eachQP);  
                                productCode.add(eachQP.Product_APC__c);                                 
                            }*///Commented this block as part of SF-2217-APCs being auto-created with Bid Scrub  loads     
                        }
                //SF-1971 - Removing the duplicate codes --end
            }            
            system.debug('bidScrubProductsLstWithoutMatchingCodes===>' + bidScrubProductsLstWithoutMatchingCodes);
            system.debug('bidScrubProductsLstWithoutMatchingUniqueCodes===>' + bidScrubProductsLstWithoutMatchingUniqueCodes);
        }        
        //To create new QuoteToForeCastMapping records - Bid Scrub Products
        if(!bidScrubProductsLstWithoutMatchingUniqueCodes.isEmpty()) {
            List<Forecasting_Product_Family__c> newQFCMappingRecords = createBidScrubQTFMapRecs(bidScrubProductsLstWithoutMatchingUniqueCodes);
            if(newQFCMappingRecords != null){
                //Description: Creating support request cases for all newly created QuoteToForecastMapping records
                createSupportReqCases(newQFCMappingRecords,supportCaseRecTypeId);   
                //Description: Updating BidScrubProduct's WWAPC_APC_Mapping__c value with newly created QuoteToForecastMapping's id
                updateBidScrubProducts(bidScrubProductsLstWithoutMatchingCodes,newQFCMappingRecords);
            }     
        }
    }
    
    /*
* Name : createQuoteToForecastMapRecs
* @Param 1 : List of QuoteProduct records
* Description : This method will create new QuoteToForecastMapping records if associated QuoteToForecastMapping record not found based on APC and WWAPC codes
* Created By : Satish M
*/
    public static List<Forecasting_Product_Family__c> createQuoteProductQTFMapRecs(List<BigMachines__Quote_Product__c> quoteProductLst){
        List<Forecasting_Product_Family__c> newMappingRecords = new List<Forecasting_Product_Family__c>();
        //Iterating QuoteProduct records
        for(BigMachines__Quote_Product__c eachRec : quoteProductLst){
            //Preparing data for new QuoteToForecastMapping record
            Forecasting_Product_Family__c newMappingRec = new Forecasting_Product_Family__c();
            newMappingRec.Name = 'N/A';
            newMappingRec.Comments__c = 'Automatically added due to missing WWAPC';
            //need to check below two statements, if required or not
            //newMappingRec.CreatedById = UserInfo.getUserId();
            //newMappingRec.OwnerId = UserInfo.getUserId();
            
            if(String.isNotBlank(eachRec.WWAPC__c)) {
                newMappingRec.Forecast_Rollup_WWAPC_Code__c = eachRec.WWAPC__c;
            } /*else if(String.isBlank(eachRec.WWAPC__c) && String.isNotBlank(eachRec.APC__c)){
                newMappingRec.APC__c = eachRec.APC__c;
            }*///Commented this block as part of SF-2217-APCs being auto-created with Bid Scrub  loads
            newMappingRecords.add(newMappingRec);
        }
        if(!newMappingRecords.isEmpty()) {
            try {
                //Inserting QuoteToForecastMapping records
                insert newMappingRecords;
            } catch(Exception exp){
                System.debug('Exception occured while inserting QuoteToForecastMapping records-->'+exp.getMessage());
            }
        }
        return newMappingRecords;
    }
    public static List<Forecasting_Product_Family__c> createBidScrubQTFMapRecs(List<Bid_Scrub__c> bidScrubProductLst){
        List<Forecasting_Product_Family__c> newMappingRecords = new List<Forecasting_Product_Family__c>();
        //Iterating QuoteProduct records
        for(Bid_Scrub__c eachRec : bidScrubProductLst){
            //Preparing data for new QuoteToForecastMapping record
            Forecasting_Product_Family__c newMappingRec = new Forecasting_Product_Family__c();
            newMappingRec.Name = 'N/A';
            newMappingRec.Comments__c = 'Automatically added due to missing WWAPC';
            newMappingRec.CreatedById = UserInfo.getUserId();
            newMappingRec.OwnerId = UserInfo.getUserId();
            if(String.isNotBlank(eachRec.Product_WWAPC__c)){
                newMappingRec.Forecast_Rollup_WWAPC_Code__c = eachRec.Product_WWAPC__c;
            }else if(String.isBlank(eachRec.Product_WWAPC__c) && string.isNotBlank(eachRec.Product_APC__c)){
                newMappingRec.APC__c = eachRec.Product_APC__c;
            }            
            newMappingRecords.add(newMappingRec);
        }
        if(!newMappingRecords.isEmpty()) {
            try {
                //Inserting QuoteToForecastMapping records
                insert newMappingRecords;
            } catch(Exception exp){
                System.debug('Exception occured while inserting QuoteToForecastMapping records-->'+exp.getMessage());
            }
        }
        return newMappingRecords;
    }
    /*
* Name : createSupportReqCases
* @Param 1 : List of QuoteToForecastMapping records
* @Param 2 : RecordtypeId
* Description : This method will create support cases whenever a new QuoteToForecastMapping record is created
* Created By : Satish M
*/
    public static void createSupportReqCases(List<Forecasting_Product_Family__c> mappingRecords,Id recordtypeId){
        List<Case> casesToInsert = new List<Case>();
        //Iterating newly created QuoteToForecastMapping records
        for(Forecasting_Product_Family__c eachMapRec : mappingRecords) {
            //Preparing data for Case record
            Case supportReqCase = new Case();
            supportReqCase.Priority = 'Medium';
            supportReqCase.RecordTypeId = recordtypeId;
            supportReqCase.Issue_Type__c = 'Other';
            supportReqCase.Description = 'This WWAPC has not been mapped in the Quote to Forecast Mapping object, so a new record has been created. Please review this record and make any necessary adjustments.';
            supportReqCase.Support_Region__c = 'North America';
            supportReqCase.Preferred_Method_of_Contact__c = 'Email';
            supportReqCase.Status = 'New';
            supportReqCase.CreatedById = UserInfo.getUserId();
            if(String.isNotBlank(eachMapRec.APC__c)) {
                supportReqCase.Subject = 'Map APC '+eachMapRec.APC__c;
            } else if(String.isNotBlank(eachMapRec.Forecast_Rollup_WWAPC_Code__c)){
                supportReqCase.Subject = 'Map WWAPC '+eachMapRec.Forecast_Rollup_WWAPC_Code__c;
            }
            
            supportReqCase.Comments = URL.getSalesforceBaseUrl().toExternalForm()+ '/' +eachMapRec.Id;
            //supportReqCase.Comments = '<a href="' + URL.getSalesforceBaseUrl().toExternalForm()+ '/' +eachMapRec.Id '"/>';
            casesToInsert.add(supportReqCase);
        }
        if(!casesToInsert.isEmpty()) {
            try {
                insert casesToInsert;
            } catch(Exception exp){
                System.debug('Exception occured while inserting Support Case records-->'+exp.getMessage());
            }
        }
    }
    
    /*
* Name : updateQuoteProducts
* @Param 1 : List of QuoteProduct records which are not mapped with existing APC and WWAPC codes
* @Param 2 : List of newly created QuoteToForecastMapping records
* Description : This method will update QuoteProduct's WWAPC_APC_Mapping__c value from newly created QuoteToForecastMapping 
*               record based on APC or WWAPC code values
* Created By : Satish M
*/
    public static void updateQuoteProducts(List<BigMachines__Quote_Product__c> quoteProducts,List<Forecasting_Product_Family__c> mappingRecords){
        List<BigMachines__Quote_Product__c> quoteProductsToUpdate = new List<BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQuotePrdt : quoteProducts) {
            for(Forecasting_Product_Family__c eachMapRec : mappingRecords) {
                //If mapped APC code is found, update associated QuoteToForecastMapping record
                if(String.isNotBlank(eachQuotePrdt.APC__c) && eachQuotePrdt.APC__c == eachMapRec.APC__c) {
                    eachQuotePrdt.WWAPC_APC_Mapping__c = eachMapRec.id;
                } 
                //If mapped WWAPC code is found, update associated QuoteToForecastMapping record
                else if(String.isNotBlank(eachQuotePrdt.WWAPC__c) && eachQuotePrdt.WWAPC__c == eachMapRec.Forecast_Rollup_WWAPC_Code__c) {
                    eachQuotePrdt.WWAPC_APC_Mapping__c = eachMapRec.id;
                }
                quoteProductsToUpdate.add(eachQuotePrdt);
            }
        }
        if(!quoteProductsToUpdate.isEmpty()) {
            try {
                update quoteProductsToUpdate;
            } catch(Exception exp) {
                System.debug('Exception occured while updating QuoteProduct records--> '+exp.getMessage());
            }
        }
    }
    public static void updateBidScrubProducts(List<Bid_Scrub__c> bidScrubProducts,List<Forecasting_Product_Family__c> mappingRecords){
        List<Bid_Scrub__c> bidScrubProductsToUpdate = new List<Bid_Scrub__c>();
        for(Bid_Scrub__c eachBidScrubPrdt : bidScrubProducts) {            
            for(Forecasting_Product_Family__c eachMapRec : mappingRecords) {
                System.debug('eachMapRec.APC__c===>'+eachMapRec.APC__c);
                System.debug('eachBidScrubPrdt.Product_APC__c===>'+eachBidScrubPrdt.Product_APC__c);
                System.debug('eachBidScrubPrdt.Product_WWAPC__c===>'+eachBidScrubPrdt.Product_WWAPC__c);
                System.debug('eachMapRec.Forecast_Rollup_WWAPC_Code__c===>'+eachMapRec.Forecast_Rollup_WWAPC_Code__c);
                //If mapped APC code is found, update associated QuoteToForecastMapping record
                if(String.isNotBlank(eachBidScrubPrdt.Product_APC__c) && eachBidScrubPrdt.Product_APC__c == eachMapRec.APC__c) {
                    eachBidScrubPrdt.WWAPC_APC_Mapping__c = eachMapRec.id;                    
                } 
                //If mapped WWAPC code is found, update associated QuoteToForecastMapping record
                else if(String.isNotBlank(eachBidScrubPrdt.Product_WWAPC__c) && eachBidScrubPrdt.Product_WWAPC__c == eachMapRec.Forecast_Rollup_WWAPC_Code__c) {
                    eachBidScrubPrdt.WWAPC_APC_Mapping__c = eachMapRec.id;                    
                }
                System.debug('eachBidScrubPrdt===>'+eachBidScrubPrdt);                
            }
        }
    }
    
    /* 
* Description : Rollup Logic
*/
    
    webservice static String upsertOpportunityLineItems(String sourceSystem,Id quoteId,Id oppId,String callFrom){
        List<OpportunityLineItem> existingOpportunityLineItems = [SELECT Id,UnitPrice,PricebookEntryId,PricebookEntry.Product2Id,CurrencyIsoCode FROM OpportunityLineItem WHERE OpportunityId=:oppId and PricebookEntry.Product2.Manual_Updates_Only__c=false];
        // String productsIsoCode;
        String responseStr;
        String oppIsoCode = [SELECT CurrencyIsoCode from Opportunity where Id = :oppId].CurrencyIsoCode;
        System.debug('oppIsoCode ==>' + oppIsoCode);
        if(sourceSystem =='BidScrub'){
            List<Bid_Scrub__c> scrubProdList = [SELECT Id, Name, CurrencyIsoCode, Quantity__c,
                                                UnitPrice__c,Product_WWAPC__c,Product_APC__c,WWAPC_APC_Mapping__c,WWAPC_APC_Mapping__r.Product_Family__c,Product_Family_Group_Forecasted__c FROM Bid_Scrub__c WHERE Opportunity__c=:oppId];
            if(!scrubProdList.isEmpty()){                
                System.debug('scrubProdList.get(0).CurrencyIsoCode ==>' + scrubProdList.get(0).CurrencyIsoCode);
                // This aggregate query provides the net price for each product family
                List<AggregateResult> aggregateResultList = [Select SUM(Net_Price__c) netPrice,WWAPC_APC_Mapping__r.Product_Family__c pfName from Bid_Scrub__c where Opportunity__c=:oppId and Product_Family_Group_Forecasted__c != 'N/A' group by WWAPC_APC_Mapping__r.Product_Family__c];   
                system.debug('aggregateResultList ===================>' + aggregateResultList);
                responseStr = genericMethodToUpsertLineItems(oppId, aggregateResultList, oppIsoCode, existingOpportunityLineItems, false);
                
            }            
        }
        /**SF-1933 Allow Multiple quotes requires a list of Id instead of a single Id.  **/
        /**SF-1933 also requires a change in how primary__c is used. There can be more than one quote set as primary*/
        /**SF-1933 CPQ code has been move to a function that can be called directly */
        if(sourceSystem =='CPQ'){ 
            List<Id> quoteIds = new List<Id>();
            quoteIds.add(quoteId);
            responseStr = upsertOpportunityCPQLineItems( quoteIds, oppId);
        }
        return responseStr;
    }

    public static String upsertOpportunityCPQLineItems(List<Id> quoteIds,Id oppId){
        String responseStr;
        Set<Id> manualIds = new Set<Id>();
        for(OpportunityLineItem manualItem : (List<OpportunityLineItem>)[SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId=:oppId  and CPQ_Updatable2__c != 'Yes']){
            manualIds.add(manualItem.Product2Id);
        }
        system.debug('manualIds: ' + manualIds);
        List<OpportunityLineItem> existingOpportunityLineItems = [SELECT Id,UnitPrice,PricebookEntryId,
                                                                    PricebookEntry.Product2Id,CurrencyIsoCode 
                                                                    FROM OpportunityLineItem WHERE OpportunityId=:oppId 
                                                                    and CPQ_Updatable2__c='Yes'];
        List<BigMachines__Quote__c> quoteLst  = [select Id,Is_Primary__c,IsFinalizedQuoteSubmitted__c,BigMachines__Opportunity__r.Id,
                                                    BigMachines__Opportunity__r.Pricebook2Id,BigMachines__Opportunity__r.CurrencyIsoCode,
                                                    CurrencyIsoCode from BigMachines__Quote__c 
                                                    where BigMachines__Opportunity__r.Id =: oppId];
        List<BigMachines__Quote__c> updateQuotes = new List<BigMachines__Quote__c>();
        String oppIsoCode = [SELECT CurrencyIsoCode FROM Opportunity WHERE Id = :oppId].CurrencyIsoCode;
        if(!quoteLst.isEmpty()){
            //for(BigMachines__Quote__c eachQuote : quoteLst)
            //{
            //SF-1931 Commented the below If block --Start
            /*if(eachQuote.Id == quoteId && callFrom == 'Button' && !eachQuote.Represent_Entire_Opportunity__c){
                responseStr = 'Represent Entire Opportunity on Quote should be selected to include in prod families';
                return responseStr;
            }
            // As the Represent Entire Opportunity on Quote is false control 
		    // return success without modifying the Opportunity Line Items
            else if(eachQuote.Id == quoteId && !eachQuote.Represent_Entire_Opportunity__c){ 
                return 'Success';								
            }*///SF-1931 --End 
            /** SF-1933 allow for multiple quotes to be marked as primary  the following code is commented out*/ 
            /*if(eachQuote.Id != quoteId  && eachQuote.Is_Primary__c){
                eachQuote.Is_Primary__c = FALSE;
                updateQuote.add(eachQuote);
            }else if(eachQuote.Id == quoteId && !eachQuote.Is_Primary__c){
                eachQuote.Is_Primary__c = TRUE;                    
                updateQuote.add(eachQuote);
                if(eachQuote.IsFinalizedQuoteSubmitted__c){
                    eachQuote.IsFinalizedQuoteSubmitted__c=False;
                }
            }else if(eachQuote.Id == quoteId && eachQuote.Is_Primary__c){
                if(callFrom == 'Button'){
                    responseStr = 'The Quote that is selected is already set as Primary for the opportunity. Please select different Quote for Primary';
                    return responseStr;
                }else {
                    if(eachQuote.IsFinalizedQuoteSubmitted__c){
                        eachQuote.IsFinalizedQuoteSubmitted__c=False;
                    }
                    eachQuote.Is_Primary__c = TRUE;                        
                    updateQuote.add(eachQuote);
                }                    
            } */ 
            //SF-1933 begin changes to allow multiple primary
            //if the Id is in the quoteIds list set primary to true, otherwise it is false
            if(!quoteLst.isEmpty() && !quoteIds.isEmpty()){
                for(BigMachines__Quote__c qt : quoteLst){
                    if(quoteIds.contains(qt.Id)){
                        qt.Is_Primary__c = TRUE;
                    }else{
                        qt.Is_Primary__c = FALSE;
                    }
                    //System.debug('qt: ' + qt);
                    updateQuotes.add(qt);
                }
                update updateQuotes; 
                //SF-1933 quoteProducts query is modified to work for multiple quotes using "in" instead of "="
                List<BigMachines__Quote_Product__c> quoteProducts = [SELECT Id,BigMachines__Sales_Price__c,CurrencyIsoCode 
                                                        FROM BigMachines__Quote_Product__c 
                                                        WHERE BigMachines__Quote__c IN :quoteIds]; 
                //SF-1933 aggrefateResultList is modified to work for multiple quotes using "in" instead of "=" 
                //SF-1931 -Modified the below query to Remove Represent_Entire_Opportunity__c                                       
                List<AggregateResult> aggregateResultList = [SELECT SUM(BigMachines__Total_Price__c) netPrice,WWAPC_APC_Mapping__r.Product_Family__c pfName 
                                                    FROM BigMachines__Quote_Product__c 
                                                    WHERE BigMachines__Quote__c IN :quoteIds 
                                                    AND Product_Family_Group_Forecasted__c != 'N/A' 
                                                    AND WWAPC_APC_Mapping__r.Product_Family__c NOT IN :manualIds
                                                    GROUP BY WWAPC_APC_Mapping__r.Product_Family__c];
                responseStr = genericMethodToUpsertLineItems(oppId, aggregateResultList, oppIsoCode, existingOpportunityLineItems, true);  
                System.debug('restpnseStr: ' + responseStr);
                if(!updateQuotes.isEmpty() && responseStr == 'Success'){
                    Database.UpsertResult[] finalResult = Database.upsert(updateQuotes,false);
                    for(Database.UpsertResult ds:finalResult){
                        for(Database.Error err:ds.getErrors()){
                            return err.getmessage();
                        }
                    }
                }
            }
        }
        return responseStr;   
    }
    
    public static String genericMethodToUpsertLineItems(Id oppId,List<AggregateResult> aggregateResultList,String oppIsoCode,List<OpportunityLineItem> existingOpportunityLineItems, Boolean isCPQ){
        Map<Id,OpportunityLineItem> prodFamilyOppLineItemMap = new Map<Id,OpportunityLineItem>();
        
        for(OpportunityLineItem eachLineItem:existingOpportunityLineItems){
            prodFamilyOppLineItemMap.put(eachLineItem.PricebookEntry.Product2Id,eachLineItem);
        }
        Double conversionRate = [SELECT conversionrate FROM currencytype WHERE isocode =: oppIsoCode LIMIT 1].conversionRate;
        Map<Id,Id> productPriceBookMap = new Map<Id,Id>();
        
        for(PricebookEntry pbEntry:[SELECT Id,Product2Id FROM PricebookEntry where Pricebook2.isStandard=true and IsActive = true and CurrencyIsoCode=:oppIsoCode]){
            productPriceBookMap.put(pbEntry.Product2Id,pbEntry.Id);
        }
        
        Set<Id> uniqueLineItemsToBeUpdated = new Set<Id>();
        List<OpportunityLineItem> toBeUpserted = new List<OpportunityLineItem>();
        
        //AggregateResult of Quote Products Product Family Group        
        for(AggregateResult eachFamilyResult:aggregateResultList){
            System.debug('WWAPC PF netprice========>' + eachFamilyResult.get('netPrice'));
            System.debug('WWAPC PF pfName========>' + eachFamilyResult.get('pfName'));
            Id scrubQuoteProdFamily = String.valueOf(eachFamilyResult.get('pfName'));
            Decimal netFamilyPrice = 0;
            if(eachFamilyResult.get('netPrice') != null){
                netFamilyPrice = Decimal.valueOf(String.valueOf(eachFamilyResult.get('netPrice')))*conversionRate;  
            }
            System.debug('netFamilyPrice========>' + netFamilyPrice);
            if(!prodFamilyOppLineItemMap.isEmpty() && prodFamilyOppLineItemMap.containsKey(scrubQuoteProdFamily)){
                OpportunityLineItem toBeUpdated = new OpportunityLineItem();
                toBeUpdated = prodFamilyOppLineItemMap.get(scrubQuoteProdFamily);
                toBeUpdated.UnitPrice = netFamilyPrice;
                uniqueLineItemsToBeUpdated.add(toBeUpdated.Id);
                toBeUpserted.add(toBeUpdated);
            }else{
                OpportunityLineItem toBeInserted = new OpportunityLineItem();
                if(!string.isBlank(productPriceBookMap.get(scrubQuoteProdFamily))){
                    toBeInserted.PriceBookEntryId= productPriceBookMap.get(scrubQuoteProdFamily); 
                    toBeInserted.Opportunityid=oppId;
                    toBeInserted.Quantity= 1;  
                    toBeInserted.UnitPrice=netFamilyPrice;
                    if( isCPQ ){
                        toBeInserted.CPQ_Updatable2__c = 'Yes';
                    }
                    toBeUpserted.add(toBeInserted);  
                }
            }
        }        
                
        List<OpportunityLineItem> olisToHaveZeroPrice = new List<OpportunityLineItem>();
        system.debug('existingOpportunityLineItems===>' + existingOpportunityLineItems);        
        for(OpportunityLineItem eachLineItem:existingOpportunityLineItems){
            if(!uniqueLineItemsToBeUpdated.contains(eachLineItem.Id)){
                eachLineItem.UnitPrice = 0;
                olisToHaveZeroPrice.add(eachLineItem);
            }
        }  
        
        if(!olisToHaveZeroPrice.isEmpty()){
            toBeUpserted.addAll(olisToHaveZeroPrice);
        }
        
        BypassPartnerOpptyIncludeProduct__c tempSkipValidation = BypassPartnerOpptyIncludeProduct__c.getOrgDefaults();        
             
        if(!toBeUpserted.isEmpty()){     
            if(Userinfo.getUserType() == 'PowerPartner') {
                if(tempSkipValidation != null) {
                    tempSkipValidation.Value__c = true;
                    update tempSkipValidation;
                }   
            }
            Database.UpsertResult[] finalResult = Database.upsert(toBeUpserted,false);
            for(Database.UpsertResult ds:finalResult){
                for(Database.Error err:ds.getErrors()){
                    return err.getmessage();
                }
            }            
            if(Userinfo.getUserType() == 'PowerPartner') {
                tempSkipValidation.Value__c = false;
                update tempSkipValidation;
            }

        }        
        return 'Success';
    }
    
}