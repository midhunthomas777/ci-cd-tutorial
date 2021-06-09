/************************************************************************************************
* Description: MR Commission Calculation Engine
* Author : Anitha Mohankumar
* Date :  1st Jan 2019
* Modification: Implemented New StepWise Calculation according to SF-2032
* Date: 14th Dec 2019
**********************************************************************************************/
public class MRCommissionCalculatorCtrl {    
    public static Map<String, List<String>> picklistQuestions;
    
    public static String commissionPercentRecalCPQ(String cpqQuoteNumber, Decimal cpqTotalOrderAmount, Decimal cpqPEDiscount, Boolean serviceFlag,String cpqOrderType){        
        Map<String, Map<String, String>> orderTypes = new Map<String, Map<String, String>>();        
        Map<String, String> orderTypesCPQ = new Map<String, String>();                    
        List<BigMachines__Quote__c> dbQuotes = [SELECT Id,Name,BigMachines__Account__c,Motorola_Customer_Number__c,
                                                CreatedBy.AccountId FROM BigMachines__Quote__c 
                                                WHERE Name=: cpqQuoteNumber AND CreatedBy.AccountId != NULL LIMIT 1];        
        BigMachines__Quote__c quote;       
        String returnVal;         
        if(!dbQuotes.isEmpty()){
            quote = dbQuotes.get(0);
            orderTypesCPQ.put('Box_Order_Amount__c', String.valueOf(cpqTotalOrderAmount)); 
            orderTypesCPQ.put('Box_Base_Selling_Percentage__c', '0');
            String serviceFlagStr = 'No';
            if(serviceFlag) {
                serviceFlagStr = 'Yes';
            }
            orderTypesCPQ.put('Box_Service_Product__c', serviceFlagStr);
            orderTypesCPQ.put('Box_PE_Discount_Percentage__c', String.valueOf(cpqPEDiscount));             
            orderTypes.put(cpqOrderType, orderTypesCPQ);                       
            Map<String, Map<String, Decimal>> returnorderTypesMap = commissionCalculationAllOrderTypes(quote.Motorola_Customer_Number__c,quote.CreatedBy.AccountId,
                                                                                                       quote.BigMachines__Account__c,orderTypes);   
            Decimal effectiveCommPercentage;
            Decimal effectiveCommDollars;            
            for(String orderType : returnorderTypesMap.keySet()) {            
                for(String incoming : returnorderTypesMap.get(orderType).keySet()){                                       
                    if(orderType=='Box'){                         
                        if(incoming.contains('Effective_Commission_Percentage')){
                            effectiveCommPercentage = returnorderTypesMap.get(orderType).get(incoming);
                        }
                        if(incoming.contains('Effective_Commission_Dollars')){
                            effectiveCommDollars = returnorderTypesMap.get(orderType).get(incoming);
                        }
                    }                                    
                }
            }
            returnVal='ECP:' + effectiveCommPercentage + ';ECD:' + effectiveCommDollars;
        }        
        return returnVal; 
    }
    
    public static Map<String, Map<String, Decimal>> commissionCalculationAllOrderTypes(String mcn, String partnerId, String custOrProsId, Map<String, Map<String, String>> orderTypesResponsesMap )
    {
        Map<String, String> questionsresponse;
        Map<String, Map<String, Decimal>> returnOrderTypeComm =  new Map<String, Map<String, Decimal>>();
        for(String orderType : orderTypesResponsesMap.keySet()) {           
            questionsresponse = orderTypesResponsesMap.get(orderType);  
            system.debug('orderType is'+orderType);
            system.debug('questionsresponse'+questionsresponse);
            CommissionWrapper CommWrapper = new CommissionWrapper();
            Map<String, Decimal> returnCommissionMap;            
            returnCommissionMap = commissionCalculation(mcn, partnerId, custOrProsId, 
                                                        orderTypesResponsesMap.get(orderType),orderType); 
            System.debug('returnCommissionMap###########=>' + returnCommissionMap);
            returnOrderTypeComm.put(orderType,returnCommissionMap);             
        } 
        System.debug('returnOrderTypeComm###########=>' + returnOrderTypeComm);        
        return returnOrderTypeComm;        
    }     
    public static Map<String, Decimal> commissionCalculation(String mcn, String partnerId, String custOrProsId, Map<String, String> questionsResponses,String orderType) {      
        CommissionCalculationWrapper CCWrapper = new CommissionCalculationWrapper();
        CCWrapper.overrideCommissionDollars = 0;
        CCWrapper.totalOrderAmount = 0;
        CCWrapper.basePercentage = 0;
        CCWrapper.totalCommissionPercentage = 0;
        CCWrapper.effectivePercentage = 0;
        CCWrapper.effectiveDollars = 0;              
        //SF-1803 - Modified the below query to inlcude IsOderType__c
        for(MR_Commission_Calculator_Questions__mdt question : [Select MasterLabel,Execution_Order__c,MR_Order_Types_for_CPQ__r.DeveloperName,MR_Order_Types_for_CPQ__r.IsOderType__c,DeveloperName,
                                                                Question_Type__c,Is_Recal__c,Commission_Percentage__c,ReCal__c,Is_Active_Question__c
                                                                FROM MR_Commission_Calculator_Questions__mdt 
                                                                where Is_Active_Question__c = TRUE AND 
                                                                MR_Order_Types_for_CPQ__r.DeveloperName =:orderType AND 
                                                                Question_Type__c LIKE :'%Input%' order by Execution_Order__c Asc]) 
        {           
            switch on Integer.valueOf(question.Execution_Order__c) {
                when 1 {
                    //Override Commission Dollars
                    System.debug('Execusion Order #########'+ question.Execution_Order__c);
                    for(String incoming : questionsResponses.keyset()){
                        if(incoming ==question.MasterLabel){
                            if(!question.Is_Recal__c ){                                                              
                                System.debug('incoming#########'+ incoming + 'incoming Response#########'+ questionsResponses.get(incoming));
                                CCWrapper.overrideCommissionDollars = Decimal.valueOf(questionsResponses.get(incoming)); 
                                System.debug('CCWrapper#########'+ CCWrapper);
                            }
                        }
                    }
                }
                when 2 {
                    //Territory Commission 
                    System.debug('Execusion Order #########'+ question.Execution_Order__c);                            
                    for(String incoming : questionsResponses.keyset()){
                        if(incoming ==question.MasterLabel){
                            System.debug('incoming#########'+ incoming + 'incoming Response#########'+ questionsResponses.get(incoming));
                            System.debug('question.Commission_Percentage__c########'+ question.Commission_Percentage__c);                          
                            CPQUtility.SpecAndCTypeWrapper specTypeWrapper = CPQUtility.fetchSpecAndCType(mcn, partnerId, custOrProsId);
                            CCWrapper.basePercentage = CPQUtility.fetchPartnerTerritoryCommission(partnerId,question.MR_Order_Types_for_CPQ__r.DeveloperName,specTypeWrapper.mrTierLevel,specTypeWrapper.mrCommunityType);    
                            CCWrapper.effectivePercentage = CCWrapper.basePercentage;
                            CCWrapper.totalCommissionPercentage = CCWrapper.effectivePercentage.setScale(2,RoundingMode.HALF_UP);
                            CCWrapper.mrCommunityType = specTypeWrapper.mrCommunityType;
                            System.debug('CCWrapper#########'+ CCWrapper);
                        }
                    }                    
                }
                when 3 {
                    //Service Product
                    System.debug('Execusion Order #########'+ question.Execution_Order__c);
                    System.debug('CCWrapper.mrCommunityType #########'+  CCWrapper.mrCommunityType);
                    for(String incoming : questionsResponses.keyset()){
                        if(incoming ==question.MasterLabel){
                            if(questionsResponses.get(incoming) == 'Yes' && CCWrapper.mrCommunityType == Label.State_and_Local_Manufacturer_Representative){
                                if(!question.Is_Recal__c ){  
                                    System.debug('incoming#########'+ incoming + 'incoming Response#########'+ questionsResponses.get(incoming));
                                    System.debug('question.Commission_Percentage__c########'+ question.Commission_Percentage__c);                                                                    
                                    CCWrapper.effectivePercentage=CCWrapper.effectivePercentage + question.Commission_Percentage__c;
                                    CCWrapper.totalCommissionPercentage = CCWrapper.effectivePercentage.setScale(2,RoundingMode.HALF_UP);
                                    System.debug('CCWrapper#########'+ CCWrapper);
                                }
                            }
                        }
                    }
                }
                when 4 {
                    //Questions answer 'Yes'
                    System.debug('Execusion Order #########'+ question.Execution_Order__c);
                    for(String incoming : questionsResponses.keyset()){
                        if(incoming ==question.MasterLabel){
                            if(questionsResponses.get(incoming) !='No' ){
                                if(!question.Is_Recal__c){           
                                    System.debug('incoming No Recaclc#########'+ incoming + 'incoming Response#########'+ questionsResponses.get(incoming));
                                    System.debug('question.Commission_Percentage__c########'+ question.Commission_Percentage__c);                     
                                    System.debug('question.MR_Order_Types_for_CPQ__r.IsOderType__c########'+ question.MR_Order_Types_for_CPQ__r.IsOderType__c);
                                    //SF-1803 - Check IsOderType__c to handle Internal user MSI/Inside Sales Calculation                                    
                                    if(!question.MR_Order_Types_for_CPQ__r.IsOderType__c){
                                        CCWrapper.effectivePercentage = CCWrapper.effectivePercentage + Decimal.valueOf(questionsResponses.get(incoming));
                                    }else{
                                        CCWrapper.effectivePercentage = CCWrapper.effectivePercentage + question.Commission_Percentage__c;
                                    }
                                    CCWrapper.totalCommissionPercentage = CCWrapper.effectivePercentage.setScale(2,RoundingMode.HALF_UP);                                    
                                }else{
                                    System.debug('incoming Yes Recaclc#########'+ incoming + 'incoming Response#########'+ Decimal.valueOf(questionsResponses.get(incoming)));
                                    System.debug('question.Commission_Percentage__c########'+ question.ReCal__c);
                                    //SF-1780 - Enhancements to MR Commission Calculator Max Payout SE
                                    Decimal recalcDiscountPercen = discountRecalc(question.ReCal__c,Decimal.valueOf(questionsResponses.get(incoming)),orderType,null);
                                    CCWrapper.effectivePercentage = CCWrapper.effectivePercentage + (CCWrapper.effectivePercentage * (recalcDiscountPercen/100)).setScale(2,RoundingMode.HALF_UP);
                                    CCWrapper.totalCommissionPercentage = CCWrapper.effectivePercentage.setScale(2,RoundingMode.HALF_UP);
                                }  
                                System.debug('CCWrapper#########'+ CCWrapper);
                            }
                        }
                    }
                }
                when 5 {
                    //TOA Check
                    System.debug('TOA Check Execusion Order #########'+ question.Execution_Order__c);
                    System.debug('TOA Check questionsResponses #########'+ questionsResponses);
                    Decimal recalcDiscountPercen;
                    for(String incoming : questionsResponses.keyset()){
                        if(incoming ==question.MasterLabel){
                            If(question.Is_Recal__c){
                                System.debug('incoming TOA #########'+ incoming + 'incoming Response#########'+ questionsResponses.get(incoming)); 
                                System.debug('question.Commission_Percentage__c########'+ question.ReCal__c); 
                                
                                CCWrapper.totalOrderAmount = Decimal.valueOf(questionsResponses.get(incoming));
                                
                                System.debug('CCWrapper.overrideCommissionDollars########'+ CCWrapper.overrideCommissionDollars); 
                                System.debug('CCWrapper.totalOrderAmount########'+ CCWrapper.totalOrderAmount); 
                                if(CCWrapper.totalOrderAmount > 0){
                                    if(CCWrapper.overrideCommissionDollars > 0){
                                        CCWrapper.effectivePercentage = ((CCWrapper.overrideCommissionDollars/CCWrapper.totalOrderAmount) * 100).setScale(2,RoundingMode.HALF_UP);                                         
                                        CCWrapper.effectiveDollars = CCWrapper.overrideCommissionDollars.setScale(2,RoundingMode.HALF_UP);
                                        CCWrapper.basePercentage = 0;
                                        CCWrapper.totalCommissionPercentage = 0;
                                    }else{//SF-2462 - Added the else block
                                       	recalcDiscountPercen = discountRecalc(question.ReCal__c,CCWrapper.totalOrderAmount,orderType,CCWrapper.effectivePercentage); 
                                    }
                                    //TOA Check     
                                    System.debug('TOA Check######## question.ReCal__c'+ incoming + ' - ' + question.ReCal__c);  
                                    System.debug('TOA Check######## CCWrapper.totalOrderAmount'+ incoming + ' - ' + CCWrapper.totalOrderAmount);
                                    System.debug('TOA Check######## CCWrapper.effectivePercentage'+ CCWrapper.effectivePercentage);
                                    //SF-1780 - Enhancements to MR Commission Calculator Max Payout SE
                                    //SF-2462 - Commented the below line
                                    //Decimal recalcDiscountPercen = discountRecalc(question.ReCal__c,CCWrapper.totalOrderAmount,orderType,CCWrapper.effectivePercentage);                                       
                                    if(recalcDiscountPercen > 0){
                                        //CCWrapper.effectivePercentage = CCWrapper.effectivePercentage + (CCWrapper.effectivePercentage * (recalcDiscountPercen/100)).setScale(2,RoundingMode.HALF_UP);    
                                        CCWrapper.effectiveDollars = CCWrapper.totalOrderAmount * recalcDiscountPercen;
                                        CCWrapper.effectivePercentage = (recalcDiscountPercen*100).setScale(2,RoundingMode.HALF_UP);
                                        //CCWrapper.effectivePercentage = recalcDiscountPercen.setScale(2,RoundingMode.HALF_UP);                                       
                                    } else if(recalcDiscountPercen <= 0){
                                        CCWrapper.effectiveDollars = 0;
                                        CCWrapper.effectivePercentage =0;
                                    }                                    
                                    //Max CAP Check                                        
                                    //CCWrapper.effectiveDollars = CCWrapper.totalOrderAmount * (CCWrapper.effectivePercentage/100);
                                    System.debug('Max CAP Check######## CCWrapper.effectivePercentage'+ CCWrapper.effectivePercentage);                                        
                                    System.debug('Max CAP Check########  CCWrapper.effectiveDollars'+ CCWrapper.effectiveDollars);                                        
                                    //SF-1780 - Enhancements to MR Commission Calculator Max Payout SE
                                    Decimal recalcDiscountCommission = discountRecalc('Max Cap',CCWrapper.effectiveDollars,orderType,null);
                                    if(recalcDiscountCommission > 0 ){
                                        CCWrapper.effectiveDollars = recalcDiscountCommission.setScale(2,RoundingMode.HALF_UP);                                                      
                                        CCWrapper.effectivePercentage = ((CCWrapper.effectiveDollars/CCWrapper.totalOrderAmount) * 100).setScale(2,RoundingMode.HALF_UP);
                                    }   
                                }              
                            }
                            System.debug('CCWrapper#########'+ CCWrapper);
                        }
                    }                    
                }
            }            
        }        
        System.debug('CCWrapper#########'+ CCWrapper);
        Map<String, Decimal> returnCommissionMap = new Map<String, Decimal>(); 
        for(MR_Commission_Calculator_Questions__mdt question : [Select MasterLabel,Question_Type__c,Is_Active_Question__c,
                                                                Execution_Order__c FROM MR_Commission_Calculator_Questions__mdt 
                                                                where Is_Active_Question__c = TRUE AND 
                                                                MR_Order_Types_for_CPQ__r.DeveloperName =:orderType AND 
                                                                Question_Type__c LIKE :'%Output%' order by Execution_Order__c Asc]) 
        {
            if (CCWrapper.totalOrderAmount > 0){
                switch on Integer.valueOf(question.Execution_Order__c) {
                    when 2 {
                        System.debug('Output CCWrapper.basePercentage##########' + CCWrapper.basePercentage);
                        System.debug('Output question.MasterLabel##########' + question.MasterLabel);
                        returnCommissionMap.put(question.MasterLabel,CCWrapper.basePercentage);
                    }
                    when 5{
                        returnCommissionMap.put(question.MasterLabel,CCWrapper.totalOrderAmount);
                    }
                    
                    when 6 {
                        returnCommissionMap.put(question.MasterLabel,CCWrapper.totalCommissionPercentage);
                    }
                    when 7 {
                        returnCommissionMap.put(question.MasterLabel,CCWrapper.effectivePercentage);
                    }
                    when 8 {
                        returnCommissionMap.put(question.MasterLabel,CCWrapper.effectiveDollars);
                    }            
                }
            }
        }
        System.debug('returnCommissionMap#########'+ returnCommissionMap);
        return returnCommissionMap;
    }    
    private static Decimal discountRecalc(String recalcQuestion,Decimal recalcValue,String orderType,Decimal effectiveCommPercentage){      
        Decimal recalPercenDiscount = 0;
        Decimal recalCommission = 0;
        Boolean isTOA =false;
        System.Debug('###########recalcQuestion########### - ' + recalcQuestion);   
        System.Debug('###########recalcValue########### - ' + recalcValue); 
        System.Debug('###########recalcOrderType########### - ' + orderType); 
        System.Debug('###########effectiveCommPercentage########### - ' + effectiveCommPercentage); 
        for(NAMR_Commission_Calculator__mdt CommCalc : [Select Id,DeveloperName,MasterLabel,Order__c,Discount_Type__c,
                                                        Lower_Threshold__c,Upper_Threshold__c,Values__c,Order_Type__c,Order_Type__r.DeveloperName,TOA_Execution_Order__c
                                                        From NAMR_Commission_Calculator__mdt where MasterLabel =:recalcQuestion order by TOA_Execution_Order__c, Order_Type__c asc NULLS LAST])
        {   
            System.Debug('###########CommCalc.Lower_Threshold__c########### - ' +CommCalc.Lower_Threshold__c);  
            System.Debug('###########CommCalc.Upper_Threshold__c########### - ' +CommCalc.Upper_Threshold__c);  
            System.Debug('###########CommCalc.Order_Type__c########### - ' +CommCalc.Order_Type__c);
            //SF-1780 - Enhancements to MR Commission Calculator Max Payout SE
            If(String.isNotBlank(CommCalc.Order_Type__c)){
                If((recalcValue >= CommCalc.Lower_Threshold__c && recalcValue < CommCalc.Upper_Threshold__c) || 
                   (recalcValue >= CommCalc.Lower_Threshold__c && CommCalc.Upper_Threshold__c ==null) && (CommCalc.Order_Type__r.DeveloperName  == orderType) ){                                                               
                       recalPercenDiscount = CommCalc.Values__c;                                                                                  
                       System.Debug('###########Software Enterprise########### - ' + CommCalc.Values__c);
                       break;
                   }   
            }else {
                If(effectiveCommPercentage == null){
                    If((recalcValue >= CommCalc.Lower_Threshold__c && recalcValue < CommCalc.Upper_Threshold__c) || (recalcValue >= CommCalc.Lower_Threshold__c && CommCalc.Upper_Threshold__c ==null) ){                                                               
                        recalPercenDiscount = CommCalc.Values__c;
                        System.Debug('###########CommCalc.Values__c########### - ' + CommCalc.Values__c);
                        break;
                    }
                }else if(effectiveCommPercentage > 0){                    
                    System.Debug('###########CommCalc.TOA_Execution_Order__c########### - ' + CommCalc.TOA_Execution_Order__c);
                    isTOA =true;
                    switch on Integer.valueOf(CommCalc.TOA_Execution_Order__c) {
                        when 1 {
                            If(recalcValue <= CommCalc.Upper_Threshold__c){
                                recalCommission = recalcValue * effectiveCommPercentage * 0.01;
                                System.Debug('###########recalCommission 1########### - ' + recalCommission);  
                            }else{
                                recalCommission = CommCalc.Upper_Threshold__c * effectiveCommPercentage * 0.01;
                                System.Debug('###########else recalCommission 1########### - ' + recalCommission);  
                            }                          
                        }
                        when 2 {
                            If(recalcValue > CommCalc.Lower_Threshold__c && recalcValue <= CommCalc.Upper_Threshold__c) {
                                recalCommission = recalCommission + ((recalcValue - CommCalc.Lower_Threshold__c) * (effectiveCommPercentage + CommCalc.Values__c) * 0.01);
                                System.Debug('###########recalCommission2########### - ' + recalCommission);  
                            }else If(recalcValue > CommCalc.Upper_Threshold__c){
                                recalCommission = recalCommission + ((CommCalc.Lower_Threshold__c) * (effectiveCommPercentage + CommCalc.Values__c) * 0.01);
                                System.Debug('###########else recalCommission2########### - ' + recalCommission); 
                            }                   
                        }
                        when 3 {
                            If(recalcValue > CommCalc.Lower_Threshold__c && recalcValue <= CommCalc.Upper_Threshold__c){
                                recalCommission = recalCommission + ((recalcValue - CommCalc.Lower_Threshold__c) * (effectiveCommPercentage + CommCalc.Values__c) * 0.01);
                                System.Debug('###########recalCommission3########### - ' + recalCommission);  
                            }else If(recalcValue > CommCalc.Upper_Threshold__c){
                                recalCommission = recalCommission + ((CommCalc.Lower_Threshold__c) * (effectiveCommPercentage + CommCalc.Values__c) * 0.01);
                                System.Debug('###########else recalCommission2########### - ' + recalCommission); 
                            }                     
                        }
                        when 4 {
                            If(recalcValue > CommCalc.Lower_Threshold__c){
                                recalCommission = recalCommission + ((recalcValue - CommCalc.Lower_Threshold__c) * (effectiveCommPercentage-3) * 0.01);
                                System.Debug('###########recalCommission4########### - ' + recalCommission);  
                            }                    
                        }                        
                    }                    
                }                
            }
        }
        if(isTOA && recalcValue > 0){
            recalPercenDiscount = (recalCommission/recalcValue);            
        }
        System.Debug('###########recalCommission########### - ' + recalCommission);        
        System.Debug('###########recalPercenDiscount########### - ' + recalPercenDiscount);
        return recalPercenDiscount;
    }  
    public class CommissionCalculationWrapper{
        Decimal overrideCommissionDollars{get;set;}
        Decimal totalOrderAmount{get;set;}
        Decimal basePercentage{get;set;}
        Decimal totalCommissionPercentage{get;set;}
        Decimal effectivePercentage{get;set;}
        Decimal effectiveDollars{get;set;} 
        String mrCommunityType{get;set;} 
    } 
    public class CommissionWrapper{       
        @AuraEnabled public Decimal effPercentage{get;set;}
        @AuraEnabled public Decimal effDollars{get;set;}
        @AuraEnabled public String orderType{get;set;}         
    }
}