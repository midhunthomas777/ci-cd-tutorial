/************************************************************************************************
 * Purpose: To fetch MCN records while creating "New Quote" from Account layout
* Author : Adilraza Shaikh
* Date :  29th Aug 2018
**********************************************************************************************/
public with sharing class MRCPQ_MCNListController {
    @AuraEnabled
    public static List<Account> getLimitedAccounts(String accountId) {
        System.debug('Account ID - ' + accountId);  
        
        List<Account> accounts=[SELECT Id,Name,ParentId,Motorola_Customer_Number__c,Price_List_Name__c,
                                Payment_Term__c,Freight_Term__c,CDH_Account_Name__c, ERP_Active__c,BillingStreet, 
                                BillingCity, BillingState,BillingCountry,BillingPostalCode,ShippingStreet,
                                Assigned_MR__c,ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, Primary_Route_to_Market__c
                                From Account  WHERE ParentId =:accountId AND RecordTypeid IN (SELECT id FROM Recordtype WHERE name ='Motorola Customer Number') AND ERP_Active__c =True];
        return accounts;
    }
}