public class OpportunityLineItemTableCtrl{
    
    public class OLIWrapper{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String rowId{get;set;}
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public Decimal unitPrice{get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
        @AuraEnabled
        public Boolean isSubscriptionBased{get;set;}
        @AuraEnabled
        public String PricebookEntryId{get;set;}
    }
    
    @AuraEnabled
    public static Map<String, Alerts_And_Messages__mdt> getMetaMessages(String metaName){
        return GlobalUtility.metaMessagesMap(NULL, metaName);
    }
    
    @AuraEnabled
    public static String validateOpportunityAccess(){     
        if(!Schema.sObjectType.Opportunity.isCreateable()){
            return 'NO_ACCESS';
        }else{
            return '';
        }
    }
    
    @AuraEnabled
    public static List<OLIWrapper> getOpportunityLineitems(String orignalOppId){
        try {
            List<OpportunityLineitem> newOpptyLineItmes = new List<OpportunityLineitem>();
            List<OLIWrapper> finalResponse = new List<OLIWrapper>();
            List<Opportunity> newOppty = new List<Opportunity>();
            Integer rowNumber = 0;
            for(OpportunityLineitem oppyLineItem : [SELECT Id, Product2.Name, UnitPrice, Description, Contract_Subscription_End_Date__c, 
                                                    Contract_Subscription_Start_Date__c, Product2.Contract_Subscription_based__c,
                                                    PricebookEntryId from OpportunityLineitem where OpportunityId = :orignalOppId 
                                                    AND Contract_Subscription_End_Date__c != null AND Contract_Subscription_Start_Date__c != null 
                                                    Order by Contract_Subscription_End_Date__c])
            {
                Integer numberOfDaysDue = oppyLineItem.Contract_Subscription_Start_Date__c.daysBetween(oppyLineItem.Contract_Subscription_End_Date__c);
                OLIWrapper oli = new OLIWrapper();
                oli.name = oppyLineItem.Product2.Name;
                oli.description = oppyLineItem.Description;
                oli.unitPrice = oppyLineItem.UnitPrice;
                oli.startDate = oppyLineItem.Contract_Subscription_End_Date__c+1;
                oli.endDate = oppyLineItem.Contract_Subscription_End_Date__c+1+numberOfDaysDue;
                oli.isSubscriptionBased = oppyLineItem.Product2.Contract_Subscription_based__c;
                oli.rowId = 'row-'+String.valueOf(rowNumber);
                oli.PricebookEntryId = oppyLineItem.PricebookEntryId;
                finalResponse.add(oli);
                rowNumber++;
            }
            return finalResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createRenewalOpportunity(String opportunityProducts, List<String> childObjectsNames, String orignalOpportunityId){
        List<String> fields = new List<String>();
        List<OpportunityLineitem> oliList = new List<OpportunityLineitem>();
        Set<String> opportunitySE = new Set<String>();
        Map<String, Alerts_And_Messages__mdt> metaMessages = new Map<String, Alerts_And_Messages__mdt>();
        Savepoint sp;
        try{
            metaMessages = OpportunityLineItemTableCtrl.getMetaMessages('New_Opportunity');
            opportunitySE.add('Account_Management');
            opportunitySE.add('New_Business_Development');
            opportunitySE.add('Channel_Partner_Sales');
            
            List<OpportunityLineItemTableCtrl.OLIWrapper> parseData = (List<OpportunityLineItemTableCtrl.OLIWrapper>)System.JSON.deserialize(opportunityProducts, List<OpportunityLineItemTableCtrl.OLIWrapper>.class);
            List<Clone_Framework__mdt> renewalFieldsMetaData = [Select Id, Clone_Fields__c from Clone_Framework__mdt where DeveloperName = 'Renewal_Clone' AND Object_APi_Name__c = 'Opportunity' LIMIT 1];
            fields = renewalFieldsMetaData.get(0).Clone_Fields__c.split(',');
            String queryString = 'SELECT ' + String.join(fields, ',') +' FROM Opportunity WHERE Id =: orignalOpportunityId';
            Opportunity orignalOpportunity = Database.query(queryString);
            Opportunity newOpportunity = orignalOpportunity.clone(false, false, false, false);
            newOpportunity.Secondary_Owner__c = UserInfo.getUserId();            
            newOpportunity.CloseDate = parseData[0].startDate.addMonths(-6);
            system.debug('parseData[0].startDate.addMonths==>' + parseData[0].startDate.addMonths(-6));
            if(parseData[0].startDate != null){
                newOpportunity.Name = newOpportunity.Name+' Renewal '+String.valueOf(parseData[0].startDate).removeEnd(' 00:00:00');    
            }else{
                newOpportunity.Name = newOpportunity.Name+' Renewal';
            }
            newOpportunity.Type = 'Renewal';
            newOpportunity.StageName = 'Prospect';
            newOpportunity.ForecastCategoryName='Non Commit';
            /*if(String.isNotBlank(newOpportunity.Sales_Process__c) && opportunitySE.contains(newOpportunity.Sales_Process__c)){
                newOpportunity.Product_Forecast_Commitment__c = 'Non Commit';
            }/*
            
            /*validate opportunity fields*/
            if(String.isBlank(newOpportunity.CDH_Account__c) && newOpportunity.Account_Record_Type_Formula__c.equals('Customer')){
                return 'Error '+metaMessages.get('Single_MCN_Validation').Message__c;
            }else if(String.isBlank(newOpportunity.Region__c)){
                return 'Error '+metaMessages.get('Region_Not_Blank').Message__c;
            }else if(!newOpportunity.Region__c.equals('AP') && String.isBlank(newOpportunity.Territory__c)){
                return 'Error '+metaMessages.get('Territory_Check').Message__c;
            }else if(String.isBlank(newOpportunity.Country__c)){
                return 'Error '+metaMessages.get('Country_Check').Message__c;
            }else if((newOpportunity.Country__c.equals('United States') || newOpportunity.Country__c.equals('Canada')) && String.isBlank(newOpportunity.State__c)){
                return 'Error '+metaMessages.get('State_Check').Message__c;      
            }else if(String.isBlank(newOpportunity.Channel_Opportunity__c)){
                return 'Error '+metaMessages.get('Route_To_Market_Validation').Message__c;          
            }else if(String.isBlank(newOpportunity.CurrencyIsoCode)){
                return 'Error '+metaMessages.get('Currency_Check').Message__c;          
            }else if(newOpportunity.StageName.equals('Lost') || newOpportunity.StageName.equals('No Pursuit') || newOpportunity.StageName.equals('Execute & Expand / Won')){
                return 'Error '+metaMessages.get('Stage_Validation').Message__c;          
            }else if(String.isBlank(newOpportunity.Industry__c)){
                return 'Error '+metaMessages.get('Industry_Check').Message__c;          
            }
            sp = Database.setSavepoint(); // creating a savepoint for rollback if any exception came
            
            insert newOpportunity;
            UtilsDeeperClone.cloneFuture(ID.valueOf(orignalOpportunityId),newOpportunity.Id, childObjectsNames);
            for(OpportunityLineItemTableCtrl.OLIWrapper lineItems : parseData){
                OpportunityLineitem oliInstance = new OpportunityLineitem();
                oliInstance.PricebookEntryId = lineItems.PricebookEntryId;
                oliInstance.Description = lineItems.description;
                oliInstance.UnitPrice = lineItems.unitPrice;
                oliInstance.Contract_Subscription_Start_Date__c = lineItems.startDate;
                oliInstance.Contract_Subscription_End_Date__c = lineItems.endDate;
                oliInstance.OpportunityId = newOpportunity.Id;
                oliList.add(oliInstance);
            }
            if(!oliList.isEmpty()){
                insert oliList;
            }
            return newOpportunity.Id;
        }catch(Exception ex){
            Database.rollback(sp);
            if(ex.getMessage().contains('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, To add this user to the team')){
                return 'Error '+metaMessages.get('MNA_No_Opportunity_Team_Access').Message__c;
            }else{
                return 'Error '+ex.getMessage().unescapeHtml4();
            }
        }
    }
}