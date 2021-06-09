public class MRCommissionCalculatorController {
    
    @AuraEnabled
    public static List<String> fetchStates(String conBillingCountry){
        List<String> lstStates =new List<String>();
        lstStates.add('--None--');
        for(Account_State_and_Country__c state : [SELECT State__c FROM Account_State_and_Country__c WHERE Country__c =: conBillingCountry order by State__c]){
            lstStates.add(state.State__c);
        }
        system.debug('lstStates are'+lstStates);
        return lstStates;
    }
    @AuraEnabled
    public static List<Account> fetchMCN(String conAccountName, String conMCN, String conBillingState, String conBillingCountry, String conCity, String conPostalCode,String routeToMarket){     
        List<Account> returnlist = new List<Account>();
        system.debug('checking class'+'MCN : '+conMCN+'ConAccountName'+conAccountName);
        String searchSOQL = 'SELECT Name,Assigned_MR__c,BillingCity,BillingState,BillingCountry,BillingPostalCode,Motorola_Customer_Number__c,Customer_or_Prospect_Account__r.Name,ParentId,Parent.Name,id,Primary_Route_to_Market__c from Account where (parent.recordtype.name=\'customer\' AND recordtype.Name in (\'Motorola Customer Number\') AND (Primary_Route_to_Market__c =\'MR Led\' OR  Primary_Route_to_Market__c=\'Open\'))';
        system.debug('searchSOQL'+searchSOQL);
        
        if(String.isNotBlank(conAccountName) && String.isBlank(conMCN)){
            searchSOQL= searchSOQL +' AND Customer_or_Prospect_Account__r.Name LIKE \'%'+conAccountName +'%\'';
            system.debug('Search account'+searchSOQL);            
        }
        else if((String.isBlank(conAccountName) && String.isNotBlank(conMCN)) ){
            searchSOQL= searchSOQL +' AND Motorola_Customer_Number__c =:conMCN';
            system.debug('Search mnc'+searchSOQL);
        } 
        if(conCity != null && conCity != ''){
            searchSOQL= searchSOQL +' AND BillingCity LIKE \'%'+conCity+'%\'';
        }
        if(conPostalCode != null && conPostalCode != '' ){
            searchSOQL= searchSOQL +' AND BillingPostalCode LIKE \'%'+conPostalCode+'%\'';
        }
        if(conBillingCountry != null && conBillingCountry != '' && conBillingCountry != '--None--'){
            searchSOQL= searchSOQL +' AND BillingCountry =: conBillingCountry';
        }
        if(conBillingState != null && conBillingState != '' && conBillingState != '--None--'){
            searchSOQL= searchSOQL +' AND BillingState =: conBillingState';
        }
        if(routeToMarket != null && routeToMarket != '' && routeToMarket != '--None--'){
            searchSOQL= searchSOQL +' AND Primary_Route_to_Market__c =: routeToMarket';
        }
        if((String.isNotBlank(conMCN)) && String.isNotBlank(conAccountName)){
            searchSOQL= searchSOQL +' AND ((Motorola_Customer_Number__c =:conMCN)'+ 'OR (Customer_or_Prospect_Account__r.Name LIKE \'%'+conAccountName +'%\'))' ;
        }
        System.debug('Final conMCN###=>'+conMCN);
        System.debug('Final conAccountName###=>'+conAccountName);
        System.debug('Final query###=>'+searchSOQL);
        returnlist = Database.Query(searchSOQL);
        return returnlist;
    }
    
    @AuraEnabled
    public static Boolean isPartnerUser(){
        List<User> usr=[SELECT Id from User WHERE Id=:UserInfo.getUserId() AND AccountID!=null];
        system.debug('usr'+usr);
        if(!usr.isEmpty()){
            return false;
        }else{
            return true;
        }
    }
    
}