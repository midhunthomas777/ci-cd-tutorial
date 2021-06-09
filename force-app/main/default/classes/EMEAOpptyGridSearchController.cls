public with sharing class EMEAOpptyGridSearchController {
List<opportunity> opportunityList;    
List<opportunity> accountListsearch;
Id guyId = UserInfo.getUserID();
Public String search {get;set;} 
public String Message {get;set;}

Public EMEAOpptyGridSearchController(){    
    search = ApexPages.currentPage().getParameters().get('searchText');
    runsearch() ;         
 }               

// fired when the search or reset button is clicked 
public PageReference runsearch() {  
//Commented the below code for Sales Stage Changes --Abhilash Govinda 16-May-13  ///////
//opportunityList= [select accountid,Account.Name, name, closedate,Amount,stagename ,First_Ship_Date__c, SBL_Fulfillment__c, Primary_Reason__c, Type,Primary_Competitor__c,Pull_Forward_Date__c,mh_Place_in_Sales_Funnel__c  from opportunity  
//where  (OwnerID=:guyID)  and ((name like:('%' +search+'%')) or (Account.Name like:('%' +search+'%')))and (stagename = 'Upside' or stagename = 'Pipeline' or stagename = 'commit') order by  closedate asc limit 100 ];          
 //Commented part of the query for Salesstage changes-23-May-2013//
 opportunityList= [select accountid,Account.Name, name, closedate,Amount,stagename ,First_Ship_Date__c, SBL_Fulfillment__c, Type,Primary_Competitor__c,Pull_Forward_Date__c,Reason_for_Win_or_Loss__c,Opportunity_Forecast__c,Status__c  from opportunity   where  (OwnerID=:guyID) and ((name like:('%' +search+'%')) or (Account.Name like:('%' +search+'%'))) and (Status__c='Active') order by  closedate asc limit 100 ];          
 return null;  
}

public PageReference reset() 
{
  //Commented the below code for Sales Stage Changes  --Abhilash Govinda 16-May-13  ///////   
       // opportunityList= [select accountid,Account.Name,name, closedate,Amount, stagename ,First_Ship_Date__c, SBL_Fulfillment__c, Primary_Reason__c, Type,Primary_Competitor__c,Pull_Forward_Date__c,mh_Place_in_Sales_Funnel__c  from opportunity     
      //where (OwnerID=:guyID)  and (stagename = 'Upside' or stagename = 'Pipeline' or stagename = 'commit') order by  closedate asc limit 100 ];      
    opportunityList= [select accountid,Account.Name,name, closedate,Amount, stagename ,First_Ship_Date__c, SBL_Fulfillment__c, Primary_Reason__c,Primary_Competitor__c, Type,Pull_Forward_Date__c,mh_Place_in_Sales_Funnel__c,Reason_for_Win_or_Loss__c,Opportunity_Forecast__c,Status__c  from opportunity     
    where (OwnerID=:guyID)  and (Status__c='Active') order by  closedate asc limit 100 ];  
    search = ''; 
return null;   
}  
public List<opportunity> getAccounts() {         
if(opportunityList== null) runsearch();
return opportunityList;      
}        
public PageReference save() { 
    try
        { 
        upsert opportunityList; 
        Message = 'Your opportunities have been saved Successfully!';
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, Message );    
        ApexPages.AddMessage(myMsg);                                                     
    return null;         }        
    Catch (DmlException ex){
         ApexPages.AddMessages(ex);
         return null;         
    }    
   }
}