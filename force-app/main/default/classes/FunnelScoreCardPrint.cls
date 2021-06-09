public class FunnelScoreCardPrint {
    
    Id currentPgId = ApexPages.currentPage().getParameters().get('oppid'); 
    //SF-1804 - -Miller Heiman legacy Fields Replacement
    public Opportunity Oppty = [select id, name,CurrencyIsoCode, Amount,AccountId,Project_Name__c,OwnerId, Owner.Name, CloseDate, Account.Name, mh_Place_In_Sales_Funnel__c,mh_Business_Score__c,mh_Opportunity_Score__c,mh_Scorecard_Total__c, StageName from Opportunity where id=:currentPgId limit 1];
    
    public decimal OpptyAmount = 0;
        
      public string OpptyName = Oppty.name; 
     // public decimal OpptyAmount = Oppty.Amount;
      public string OpptyStageName = Oppty.StageName;
      public string OpptyProjectName= Oppty.Project_Name__c;
      public string OpptyOwnerName= Oppty.Owner.Name;
      public Date OpptyCloseDate = Oppty.CloseDate;
      public string OpptyAccountName = Oppty.Account.Name;
      public string OpptyPlaceInSalesFunnel = Oppty.mh_Place_In_Sales_Funnel__c;
      public string OpptyCurrencyISOCode = Oppty.CurrencyIsoCode;
     
    public Integer BusinessScore=0 ;
    public Integer OpportunityScore=0 ;
    public Integer TotalScore=0 ;    
                 
    public Funnel_ScoreCard__c FSCRecord;   
    
    
    public FunnelScoreCardPrint(ApexPages.StandardController controller) {
    
     OpptyAmount = Oppty.Amount;
    
     Funnel_ScoreCard__c[] FSCardRecord = [select Id,F1_BQ1__c,F1_BQ2__c,F1_BQ3__c,F1_BQ4__c,F1_BQ5__c,F1_BQ6__c,F1_BQ7__c,F1_BQ8__c,F1_BQ9__c,F1_BQ10__c,
                                            F1_OQ1__c,F1_OQ2__c,F1_OQ3__c,F1_OQ4__c,F1_OQ5__c,F1_OQ6__c,F1_OQ7__c,F1_OQ8__c,F1_OQ9__c,F1_OQ10__c,
                                            F1_Business_Score__c,F1_Opportunity_Score__c, F1_Total_Score__c from Funnel_ScoreCard__c where Opportunity__c =: Oppty.id ];            
     fscRecord = (Funnel_ScoreCard__c)controller.getRecord();
    
      if(!FSCardRecord.isEmpty()){
    
            //fscRecord.Opportunity__c = Oppty.id;
    
               system.debug('FSC details are :' + FSCardRecord );   
                fscRecord.F1_BQ1__c = FSCardRecord[0].F1_BQ1__c;
                fscRecord.F1_BQ2__c = FSCardRecord[0].F1_BQ2__c;
                fscRecord.F1_BQ3__c = FSCardRecord[0].F1_BQ3__c;
                fscRecord.F1_BQ4__c = FSCardRecord[0].F1_BQ4__c;
                fscRecord.F1_BQ5__c = FSCardRecord[0].F1_BQ5__c;
                fscRecord.F1_BQ6__c = FSCardRecord[0].F1_BQ6__c;
                fscRecord.F1_BQ7__c = FSCardRecord[0].F1_BQ7__c;
                fscRecord.F1_BQ8__c = FSCardRecord[0].F1_BQ8__c;
                fscRecord.F1_BQ9__c = FSCardRecord[0].F1_BQ9__c;
                fscRecord.F1_BQ10__c = FSCardRecord[0].F1_BQ10__c;
                fscRecord.F1_Business_Score__c = FSCardRecord[0].F1_Business_Score__c;
                      
                
                fscRecord.F1_OQ1__c = FSCardRecord[0].F1_OQ1__c;
                fscRecord.F1_OQ2__c = FSCardRecord[0].F1_OQ2__c;
                fscRecord.F1_OQ3__c = FSCardRecord[0].F1_OQ3__c;
                fscRecord.F1_OQ4__c = FSCardRecord[0].F1_OQ4__c;
                fscRecord.F1_OQ5__c = FSCardRecord[0].F1_OQ5__c;
                fscRecord.F1_OQ6__c = FSCardRecord[0].F1_OQ6__c;
                fscRecord.F1_OQ7__c = FSCardRecord[0].F1_OQ7__c;
                fscRecord.F1_OQ8__c = FSCardRecord[0].F1_OQ8__c;
                fscRecord.F1_OQ9__c = FSCardRecord[0].F1_OQ9__c;
                fscRecord.F1_OQ10__c = FSCardRecord[0].F1_OQ10__c;
                fscRecord.F1_Opportunity_Score__c = FSCardRecord[0].F1_Opportunity_Score__c;
                fscRecord.F1_Total_Score__c = FSCardRecord[0].F1_Total_Score__c;
                        
                system.debug('FSC AFTER details are :' + fscRecord); 
       }   
       
       if(FSCardRecord.isEmpty()){
          fscRecord.F1_Business_Score__c=BusinessScore;
          fscRecord.F1_Opportunity_Score__c=OpportunityScore;
          fscRecord.F1_Total_Score__c=TotalScore;  
       }   
       
    }
    
    
    public string getcallOpptyName() {
    return OpptyName;
    }
    public decimal getcallOpptyAmount() {
    return OpptyAmount;
    }
    public string getcallOpptyStageName() {
    return OpptyStageName;
    }
    public string getcallOpptyProjectName() {
    return OpptyProjectName;
    }
    public string getcallOpptyOwnerName() {
    return OpptyOwnerName;
    }
    public date getcallOpptyCloseDate() {
    return OpptyCloseDate;
    }
    public string getcallOpptyAccountName() {
    return OpptyAccountName;
    }
    public string getcallOpptyPlaceInSalesFunnel() {
    return OpptyPlaceInSalesFunnel;
    }
    public string getOptyCurrencyISOCode() {
    return OpptyCurrencyISOCode;
    }
    
}