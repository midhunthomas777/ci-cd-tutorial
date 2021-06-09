/*============================================================================================ 
Name : AutoCreatedCAPPTableCtrl
Description    : Class which used in AutoCreatedCAPPTable component
Author : Srikanth
Created Date : 12th August 2020
Requirement: SF-2461
Modification History:   
===============================================================================================*/
public class AutoCreatedCAPPTableCtrl {
    
    @AuraEnabled
    public static List<Customer_Portfolio_Presence__c> getCAPPRecords(String fields, String OpptyId){
        String query = 'SELECT ' + fields + ' FROM Customer_Portfolio_Presence__c'; 
        String condition = ' WHERE Opportunity_Auto_Created_or_Modified_Fr__c =: OpptyId AND Reviewed_by_Sales__c = false';
        List<Customer_Portfolio_Presence__c> cappList = Database.query(query + condition);
        return cappList;
    }
    
    @AuraEnabled
    public static void updateCAPPRecords(String fields, String OpptyId){
        String query = 'SELECT ' + fields + ' FROM Customer_Portfolio_Presence__c'; 
        String condition = ' WHERE Opportunity_Auto_Created_or_Modified_Fr__c =: OpptyId AND Reviewed_by_Sales__c = false';
        List<Customer_Portfolio_Presence__c> cappList = Database.query(query + condition);
        for (Customer_Portfolio_Presence__c cappRecord : cappList) {
            cappRecord.Reviewed_by_Sales__c = true;
        }
        if (! cappList.isEmpty()) {
            update cappList;
        }
    }
    
}