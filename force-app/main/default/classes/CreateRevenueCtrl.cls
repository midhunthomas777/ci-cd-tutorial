public class CreateRevenueCtrl {
    
    @AuraEnabled
    public static string insertRevenues(String oppLineItemId, String jsonRevenue){
        List<OpportunityLineItem> lstOppLineItems = [SELECT Id,Name,Description,Product2.Id,Product2.name,Product_Family_Name__c,Opportunity_Product_Mirror__c,
                                                     Opportunity.CloseDate,Opportunity.CurrencyIsoCode,OpportunityId 
                                                     FROM OpportunityLineItem WHERE Id = :oppLineItemId];
        List<Revenue__c> lstRevenue= new List<Revenue__c>();
        List<Revenue__c> lstRevenueToInsert= new List<Revenue__c>();
        lstRevenueToInsert = (List<Revenue__c>) JSON.deserialize(jsonRevenue,List<Revenue__c>.class);
        //system.debug('lstRevenueToInsert'+lstRevenueToInsert);
        //system.debug('lstOppLineItems'+lstOppLineItems);
        if((!lstOppLineItems.isEmpty() && !lstRevenueToInsert.isEmpty())) {
            for(Revenue__c jsonRev : lstRevenueToInsert ){
                lstRevenue.add(new Revenue__c(Opportunity__c = lstOppLineItems.get(0).OpportunityID,
                                              Product_Family__c = oppLineItemId,
                                              //Opportunity_Line_Item_Id__c = oppLineItemId,
                                              ProductFamily__c = lstOppLineItems.get(0).Product2.Id,
                                              CurrencyIsoCode=  lstOppLineItems.get(0).Opportunity.CurrencyIsoCode,
                                              Revenue_Month__c=jsonRev.Revenue_Month__c,                   
                                              Revenue_Year__c=jsonRev.Revenue_Year__c,
                                              Opportunity_Product_Mirror__c = lstOppLineItems.get(0).Opportunity_Product_Mirror__c,
                                              Revenue_Amount__c = jsonRev.Revenue_Amount__c
                                             ));
            }
        } 
        if(!lstRevenue.isEmpty()) {
            try {
                insert lstRevenue;
                return 'Success';
            } catch(Exception exp) {
                return 'Error'+exp.getDMLMessage(0);
            }
        }
        return 'Error'; 
    }
    @AuraEnabled
    public static List<OpportunityLineItem> getOLIDetails(String recordId){
        //SF-2176
        return [SELECT Id,OpportunityId,Opportunity.CloseDate,Opportunity.CurrencyIsoCode,Opportunity.RecordType.DeveloperName,
                UnitPrice
                FROM OpportunityLineItem WHERE Id =: recordId LIMIT 1];
    }
    @AuraEnabled
    public static List<OpportunityLineItem> getAllRevenuesPerOppo(String oppoId){
        return [Select Id,Fiscal_Month__c,Product2.Name,Opportunity.CurrencyIsoCode,TotalPrice,Product_Description__c,Opportunity.CloseDate,Revenue_Delta_New__c
                from OpportunityLineItem where OpportunityId =: oppoId Order by Product2.Name];
    }
    @AuraEnabled
    public static List<String> getRevenuesmonth(){
        return GlobalUtility.fetchPicklistsByObjectAndField('Revenue__c','Revenue_Month__c');
    }
    @AuraEnabled
    public static String updateOLI(String recordId ,OpportunityLineItem oli){
        OpportunityLineItem opplineItem = new OpportunityLineItem(
            Id = recordId,
            UnitPrice = oli.UnitPrice,
            Description = oli.Description,
            Product_Segment__c=oli.Product_Segment__c
        );
        try{
            update opplineItem;
            return 'Success';
        }catch(Exception ex){
            return 'Error'+ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityDetails(String recordId){
        //SF-2176
        return [SELECT Id,Opportunity.CloseDate,Opportunity.Fiscal_Month__c,UnitPrice FROM OpportunityLineItem WHERE Id = : recordId];
    }
    @AuraEnabled
    public static List<String> getExistingRevenueYears(String recordId){
        //return [SELECT Id,Revenue_Year__c FROM Revenue__c WHERE Id = : recordId];
        List<String> lstRevYears = new List<String>();
        for(Revenue__c rev : [SELECT Id,Revenue_Year__c FROM Revenue__c WHERE Product_Family__c = : recordId]){
            lstRevYears.add(rev.Revenue_Year__c);
        }
        return lstRevYears;
    }
    @AuraEnabled
    public static List<Revenue__c> getRevenueOldYear(String recordId){
        return [SELECT Id,Revenue_Year__c FROM Revenue__c WHERE Id = : recordId];
    }
    
}