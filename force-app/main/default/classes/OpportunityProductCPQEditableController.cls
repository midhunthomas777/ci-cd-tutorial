public with sharing class OpportunityProductCPQEditableController {


    public class WrapperClass {
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String Product_Family_Name{get;set;}
        @AuraEnabled
        public String Description{get;set;}
        @AuraEnabled
        public Boolean CPQ_Updatable{get;set;}
        @AuraEnabled
        public Boolean PreviousValue{get;set;}
    }
    

    @AuraEnabled(cacheable=true)
    public static List<WrapperClass> getProducts(String oppId) {
        List<WrapperClass> oppProdItmes = new List<WrapperClass>();
        for( OpportunityLineItem item :
        [ SELECT Id, Product_Family_Name__c, Product_Description__c, Description, CPQ_Updatable2__c, Opportunity.Name,  Product2.Manual_Update__c
            FROM OpportunityLineItem
            WHERE OpportunityId= :oppId
            ORDER BY Product_Family_Name__c 
        ]){
            WrapperClass newcls = new WrapperClass();
            newcls.Id = item.Id;
            newcls.Product_Family_Name = item.Product_Family_Name__c;
            newcls.Description = item.Description;
            switch on item.CPQ_Updatable2__c {
                when 'Yes' {
                    newcls.CPQ_Updatable = true;
                }
                when 'No' {
                    newcls.CPQ_Updatable = false;
                }
                when else {
                    if( item.Product2.Manual_Update__c == null || item.Product2.Manual_Update__c == '' || item.Product2.Manual_Update__c == 'Bid Scrub Only'){
                        newcls.CPQ_Updatable = true;
                    } else {
                        newcls.CPQ_Updatable = false;
                    }
                }
            }
            system.debug('newcls: ' + newcls);
            oppProdItmes.add(newcls);
        }
        return oppProdItmes;
    }

    @AuraEnabled         
    public static string initLineItems(String oppId){
        system.debug('initLineItems oppId: ' + oppId);
        List<OpportunityLineItem> oppUpdatelist = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppQueryItems = [
            SELECT Id, Product_Family_Name__c, Product_Description__c, Description, CPQ_Updatable2__c, Opportunity.Name,  Product2.Manual_Update__c
            FROM OpportunityLineItem
            WHERE OpportunityId= :oppId
            ORDER BY Product_Family_Name__c 
        ];
        for( OpportunityLineItem l : oppQueryItems) {
            system.debug('l: ' + l);
            if(l.CPQ_Updatable2__c == null || l.CPQ_Updatable2__c == ''){
                OpportunityLineItem newItem = new OpportunityLineItem();
                if( l.Product2.Manual_Update__c == null || l.Product2.Manual_Update__c == '' || l.Product2.Manual_Update__c == 'Bid Scrub Only'){
                    newItem.CPQ_Updatable2__c = 'Yes';
                } else {
                    newItem.CPQ_Updatable2__c = 'No';
                }
                newItem.Id = l.Id;
                system.debug('initLineItems newItem: ' + newItem);
                oppUpdatelist.add(newItem);
            }
        }
        if( !oppUpdatelist.isEmpty() ) {
            try {
                update oppUpdatelist;
                return 'Success: Product Family records initialized successfully';
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        return 'Success';
    }
    
    @AuraEnabled         
    public static string updateProducts(Object data){
        List<OpportunityLineItem> opps = new List<OpportunityLineItem>();
        List<WrapperClass> oppWs = (List<WrapperClass>) JSON.deserialize(
            JSON.serialize(data),
            List<WrapperClass>.class
        );
        system.debug('updateProducts - opps: ' + oppWs);
        for(WrapperClass ow : oppWs){
            OpportunityLineItem l = new OpportunityLineItem();
            l.Id = ow.Id;
            if(ow.Description != null){
                l.Description = ow.Description;
            }
            if( ow.CPQ_Updatable == true ) {
                l.CPQ_Updatable2__c = 'Yes'; 
            }
            else if(ow.CPQ_Updatable ==false){
                l.CPQ_Updatable2__c = 'No';
            }
            opps.add(l);
        }
        try {
            update opps;
            return 'Success: Product Family records updated successfully';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}