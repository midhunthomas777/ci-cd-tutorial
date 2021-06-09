public class MRCustAccController_POC {

    Public List<Account> DownloadAccts{get;set;}
    public MRCustAccController_POC(ApexPages.StandardController controller) {
       id AccId= System.currentPageReference().getParameters().get('id');
        //Removed limit 1000 in query - Niran
        //Commented by Satish as part of SF-512
        /*DownloadAccts=[SELECT id,name,state1__C,Country_new__c,Account__r.Type,
                       Account__r.Customer_or_Prospect_Account__r.Name,
                       Account__r.Customer_or_Prospect_Account__c,
                       Account__r.Customer_or_Prospect_Account__r.OwnerManager__c,
                       Account__r.Customer_or_Prospect_Account__r.Motorola_Customer_Number__C, 
                       ID_Number__c,Account__r.Name,Sales_Representative__r.Name, 
                       Sales_Representative__r.Email,Assigned_MR__c, Account__r.Motorola_Customer_Number__c,
                       Sales_Representative__c 
                       FROM Account_Identifier__c 
                       WHERE Account__r.Customer_or_Prospect_Account__r.recordtype.name='Customer' and Assigned_MR__c=:AccId and Route_to_Market__c = 'MR Led' order by Account__r.Customer_or_Prospect_Account__r.Name]; */
        DownloadAccts=[SELECT Id,Name,Motorola_Customer_Number__c,Customer_or_Prospect_Account__r.OwnerManager__c,
                       		Customer_or_Prospect_Account__c,Customer_or_Prospect_Account__r.Name,
                			Primary_Route_to_Market__c,Assigned_MR__c,Assigned_MR_Sales_Person__c,Assigned_MR_Sales_Person__r.Name,
                			Assigned_MR_Sales_Person__r.Email,Customer_or_Prospect_Account__r.BillingCountry,
                  			Customer_or_Prospect_Account__r.BillingState,Customer_or_Prospect_Account__r.BillingCity
                       FROM Account 
                       WHERE Customer_or_Prospect_Account__r.recordtype.name = 'Customer'
                       AND Assigned_MR__c=:AccId 
                       AND Primary_Route_to_Market__c = 'MR Led' 
                       ORDER BY Customer_or_Prospect_Account__r.Name];
    }

    @AuraEnabled
    public static List<Account> ActualAccts(string AccId){
        System.Debug('Display AccId Harish Lightning***'+AccId);
        //return [SELECT Id,Name,Account__r.Customer_or_Prospect_Account__r.OwnerManager__c,Sales_Representative__c,Sales_Representative__r.Name,Sales_Representative__r.Email,Account__r.Name,Account__c,Address_Line_1__c,Account__r.Customer_or_Prospect_Account__c,Account__r.Customer_or_Prospect_Account__r.Name FROM Account_Identifier__c WHERE Account__r.Customer_or_Prospect_Account__r.recordtype.name='Customer' and Assigned_MR__c=:AccId and Route_to_Market__c = 'MR Led' order by Account__r.Customer_or_Prospect_Account__r.Name];
        return [SELECT Id,Name,Motorola_Customer_Number__c,Customer_or_Prospect_Account__r.OwnerManager__c,
                       	Customer_or_Prospect_Account__c,Customer_or_Prospect_Account__r.Name,
                		Primary_Route_to_Market__c,Assigned_MR__c,Assigned_MR_Sales_Person__c,Assigned_MR_Sales_Person__r.Name,
                		Assigned_MR_Sales_Person__r.Email,Customer_or_Prospect_Account__r.BillingCountry,
                  		Customer_or_Prospect_Account__r.BillingState,Customer_or_Prospect_Account__r.BillingCity
                FROM Account WHERE 
                Customer_or_Prospect_Account__r.recordtype.name='Customer' 
                AND Assigned_MR__c =:AccId 
                AND Primary_Route_to_Market__c = 'MR Led' 
                ORDER BY Customer_or_Prospect_Account__r.Name];
        //return AccIdenList;
    }
    
}