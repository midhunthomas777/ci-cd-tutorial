global with sharing class AccListController {
//0015C000003Uji6QAC State1__c,  
public Account account {get;set;}
public static String SelectedMCN1;
public String strAccountID1= System.currentPagereference().getParameters().get('id');

//@AuraEnabled    public String strAccountID {get; set;}

public static string callfunc{get;set;}    

    public  AccListController (ApexPages.StandardController controller) {
    account= new Account(); 
      system.debug('strAccountID1' + strAccountID1);
    } 
        
    @AuraEnabled
    public static List<Account> getAccounts(String accountId) {
    System.debug('Account ID - ' + accountId);  
    
    List<Account> accounts=[Select a.Id, 
                            a.Name,
                            a.Motorola_Customer_Number__c,
                            a.Price_List_Name__c,                            
                            a.Payment_Term__c,
                            a.Freight_Term__c,
                            a.CDH_Account_Name__c,
                            a.ERP_Active__c,
                            a.BillingStreet, 
                            a.BillingCity, 
                            a.BillingState, 
                            a.BillingCountry,
                            a.BillingPostalCode,
                            a.ShippingStreet, 
                            a.ShippingCity, 
                            a.ShippingState, 
                            a.ShippingCountry, 
                            a.ShippingPostalCode,
                            a.Primary_Route_to_Market__c
                            From Account a where a.Customer_or_Prospect_Account__c =:accountId and 
                            a.RecordTypeid IN (Select id from Recordtype where name ='Motorola Customer Number') and a.ERP_Active__c =True Order by name desc];
    return accounts;
    }
    
     @AuraEnabled
    global static String sessionId() {
        return UserInfo.getSessionId();
    }
    
    @AuraEnabled      
    public static String LtnSelectedMCN(String MCNId) {
        
    List<Account> acclis = new List<account>();
    String strAccountId;
    String strSuccess;
    acclis = [SELECT Parentid from Account where Id=:MCNId  LIMIT 1];
            for(account acc: acclis)
                strAccountId=acc.Parentid;
    System.debug('LtnSelectedMCN Select MCN - '+ MCNId); 
    System.debug('LtnSelectedMCN Account Id - '+ strAccountId) ; 
    System.debug('LtnSelectedMCN UserInfo.getUserId - '+ UserInfo.getUserId()); 
    //System.debug('LtnSelectedMCN UserInfo.Session- '+ UserInfo.getSessionId());       
    System.debug(UserInfo.getOrganizationId().substring(0, 15) + ' ' +  UserInfo.getSessionId().substring(15));  
    //UserSession Object
    List<UserSessionCPQ__c> USLisinsert = new List<UserSessionCPQ__c> ();
    UserSessionCPQ__c USCPQ = new UserSessionCPQ__c();        
    USCPQ.User_Id__c =UserInfo.getUserId();
    USCPQ.Session_id__c = UserInfo.getSessionId();
    USCPQ.Account_ID__c =strAccountId;
    USCPQ.CDH_Account_ID__c =MCNId;
    
    if((strAccountId!=null &&  strAccountId!='') && (MCNId!=null &&  MCNId!=''))
        {
            USLisinsert.add(USCPQ);
            if(USLisinsert.size()>0)
            Insert USLisinsert;
            System.debug('Successfully inserted'+ USLisinsert); 
            strSuccess='Success';           
        }    
    return 'Success';
    }
    
     @AuraEnabled
    public Static String updateOpp(String oppId, String MCNId){
        system.debug('Debug MCN ID '+ MCNId+'Opp ID000'+oppId);
            String strSuccess;

         List<Opportunity> opUpdate = new List<Opportunity>();
         List<Opportunity> updateOppRec = new List<Opportunity>();
        
        opUpdate = [Select Id,Name,CDH_Account__c from Opportunity where id=:oppId limit 1];
        
        for(Opportunity opp: opUpdate){
            opp.CDH_Account__c = MCNId;
            //opp.CDH_Account__c = '0011b000005BBrO';
            System.debug('$%@@%@$@^'+ opp.CDH_Account__c );
            updateOppRec.add(opp);
            strSuccess = 'Success';
          }
        if(updateOppRec.Size()>0){
              update updateOppRec;
        }
        
        System.debug('Updated $$$$$$$'+updateOppRec);
        return 'Success';
    }
}