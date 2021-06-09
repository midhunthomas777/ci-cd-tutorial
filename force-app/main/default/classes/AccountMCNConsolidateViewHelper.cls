/*******************************************************************************
* Description : Helper class for showing Consolidated MCN details on Customer Account
* Author : Sai Harish Thammana
* Date : 29th Aug 2018
* 9/24/2019  Anitha Mohankumar  SF-1927  - MCN account number update on Parent customer for Archived MCN accounts 
******************************************************************************/
public class AccountMCNConsolidateViewHelper {
    Id mcnRecordtypeId = GlobalUtility.getRecordTypeIdByDeveloperName('Account', 'Motorola_Customer_Number');
    public void populateMCNonCustomer(Set<Id> customerAccIds){
        //Modified the below query to include RecordtypeID criteria for SF-1927 
        List<Account> allAccounts = [SELECT Id,MCN_Account_Number__c,(SELECT Id,Assigned_MR_Sales_Person__c,Motorola_Customer_Number__c,ERP_Active__c,Primary_Route_to_Market__c 
                                                              FROM ChildAccounts WHERE Motorola_Customer_Number__c!= NULL and recordtypeId =: mcnRecordtypeId  ) FROM Account WHERE Id IN :customerAccIds];
        
        Set<Id> mrSalesRepIds = new Set<Id>();
        
        for(Account acc:allAccounts){
            for(Account mcnAcc:acc.ChildAccounts){
                if(String.isNotBlank(mcnAcc.Assigned_MR_Sales_Person__c)){
                    mrSalesRepIds.add(mcnAcc.Assigned_MR_Sales_Person__c);
                }
            }
        }
        
        Map<Id,Contact> saleRepNameMap = new Map<Id,Contact>([SELECT Id,Name FROM Contact WHERE Id IN:mrSalesRepIds]);
        List<Account> toBeUpdatedCustomers = new List<Account>();
        
        for(Account toBeUpdated:allAccounts){
            String tempMCNNumber = '';
            String tempMCNConcatenation = '';
            for(Account mcnAcc:toBeUpdated.ChildAccounts){
                System.debug('tempMCNNumber###1=>'+tempMCNNumber);
                String erpActive = '';
                String saleRepName = ''; 
                
                if(mcnAcc.ERP_Active__c){
                    erpActive='Active';
                } else{
                    erpActive='Inactive';  
                }
                
                if(String.isNotBlank(mcnAcc.Assigned_MR_Sales_Person__c)){
                    saleRepName = saleRepNameMap.get(mcnAcc.Assigned_MR_Sales_Person__c).Name;
                }
                
                if(String.isNotBlank(mcnAcc.Motorola_Customer_Number__c)){
                    tempMCNNumber = tempMCNNumber+mcnAcc.Motorola_Customer_Number__c+' '+'('+erpActive+')';
                    if(String.isNotBlank(mcnAcc.Primary_Route_to_Market__c)){
                        tempMCNNumber = tempMCNNumber+' '+'|'+' '+mcnAcc.Primary_Route_to_Market__c;
                    }
                    
                    if(String.isNotBlank(saleRepName)){
                        tempMCNNumber = tempMCNNumber+' '+'|'+' '+saleRepName;
                    }
                    
                    tempMCNNumber = tempMCNNumber+'\n';
                    tempMCNConcatenation = tempMCNConcatenation + ',' + mcnAcc.Motorola_Customer_Number__c ;//SF-2647
                }   
            }
            
            //System.debug('toBeUpdated###FINAL=>'+tempMCNNumber);
            System.debug('toBeUpdated###tempMCNConcatenation=>'+tempMCNConcatenation);
            toBeUpdated.MCN_Account_Number__c = tempMCNNumber;
            //System.debug('Remove Comma###tempMCNConcatenation=>'+tempMCNConcatenation.substring(1,tempMCNConcatenation.length()));
            if(tempMCNConcatenation.length() > 0){
              toBeUpdated.MCN_Concatenation__c = tempMCNConcatenation.substring(1,tempMCNConcatenation.length());//SF-2647  
            }
            
            toBeUpdatedCustomers.add(toBeUpdated);
        }
        
        if(!toBeUpdatedCustomers.isEmpty()){
            Database.update(toBeUpdatedCustomers,false);
        }
    }
}