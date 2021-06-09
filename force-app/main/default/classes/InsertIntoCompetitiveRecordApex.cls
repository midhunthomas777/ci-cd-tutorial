/* This class is called from the Process Builder to insert a record into Competitive Record based on
 *  opportunity status = "lost" then forecast category = "omitted" and stage = "closed" */

public class InsertIntoCompetitiveRecordApex {
    @InvocableMethod
    public static void InsertRecord(List<Id> OpportunityId)
    {
        
        List<CompetitiveDB__c> InsertNewArr = new List<CompetitiveDB__c>();
        List<CompetitiveDB__c> UpdateNewArr = new List<CompetitiveDB__c>();
        system.debug('In InsertRecord '+OpportunityId);
        List<Opportunity> Opport = [Select Id,Name,Amount,StageName,Status__c,ForecastCategoryName,Reason_for_Win_or_Loss__c,AccountId,Primary_Competitor_Account__c,CloseDate,OwnerId,CurrencyIsoCode,Award_Date__c,Country__c,State__c from Opportunity where Id = :OpportunityId];
        system.debug(Opport);
        List <Id> OpporList = new List<Id>();
        for (Opportunity Opp : Opport)
        {
            OpporList.add(Opp.Id);
        }
        CompetitiveDB__c InsertNew  ;
        If(Opport.size() == 0)
        {
            system.debug('No Opportunity found');
            return;
        }
        List<CompetitiveDB__c> MyOldCompetitor = [SELECT Id,Related_Opportunity__c from CompetitiveDB__c where Related_Opportunity__c IN :OpporList];
        Map <Id,Id> OldC = new Map<Id,Id>();
        /* Check if the record already exists in Competitive DB. If it so just update the record */
            if (MyOldCompetitor.size() > 0)
              {
                  for(Integer n = 0; n < MyOldCompetitor.size(); n++ )
                  {
                 		 system.debug('Old Record Found '+MyOldCompetitor[n].Id);
                         OldC.put(MyOldCompetitor[n].Related_Opportunity__c,MyOldCompetitor[n].Id);
                  } 
              }
        	 
            
        
        Map<Integer,Decimal> MyPrice = new Map<Integer,Decimal>();
        Map <Integer,Id> PriceBookEntry = new Map<Integer,Id>();
        Integer Counter = 0;
        for ( OpportunityLineItem myResult : [SELECT UnitPrice,PricebookEntry.Product2.Id  FROM OpportunityLineItem  WHERE OpportunityId = :OpporList ])
        {
     			myPrice.put(Counter,myResult.UnitPrice);
            	PriceBookEntry.put(Counter,myResult.PricebookEntry.Product2.Id);
            	Counter++;
        }        
        Counter=0;
        for(Opportunity opp : Opport)
        {
            
          if ((opp.ForecastCategoryName == 'Omitted') && (opp.StageName == 'Lost'))
          {
              Id CompeteId = Oldc.get(Opp.id);
              if(CompeteId == null)
              {
                  system.debug('No matching Opportunity in Map ');
                  InsertNew = new CompetitiveDB__C();
                 
              }	
              else
              {
                  InsertNew = new CompetitiveDB__C();
          		  InsertNew.Id = CompeteId;
                 
              }
              InsertNew.Account_ID__c=opp.AccountId;
            InsertNew.Competitive_Vendor__c = opp.Primary_Competitor_Account__c; 
            InsertNew.Related_Opportunity__c= opp.Id;
            InsertNew.Loss_Notes__c=opp.Reason_for_Win_or_Loss__c;
            InsertNew.Contract_Date__c=opp.Award_Date__c;
            InsertNew.OwnerId=opp.OwnerId;
            InsertNew.CurrencyIsoCode=opp.CurrencyIsoCode;
            InsertNew.Contract_Amount__c=opp.Amount ;
            if(myPrice.size() >0)
            {
                Decimal Family = 0.0;
                Integer IdSel = -1;
                for(Integer i = 0; i < myPrice.size();i++)
                {
                    	Decimal PriceCheck = myPrice.get(i);
                        if(Family < PriceCheck)
                        {
                            Family = PriceCheck;
                            IdSel = i;
                        }
                }
                system.debug('Technology Type '+Family);
                if(Family != NULL)
                {
                    if(IdSel >= 0) //means entry is there
                        InsertNew.TechnologyType__c= PriceBookEntry.get(IdSel);
                    else
                        InsertNew.TechnologyType__c = NULL;
                }
                
            }
            /* Set BillingState and Billing Country from Opportunity as per INC1027063 */
           // Account ParentAccount = [SELECT BillingState,BillingCountry from Account where Id = :opp.AccountId LIMIT 1];
            InsertNew.State__c=opp.State__c;
            InsertNew.Country__c=opp.Country__c;
            system.debug(InsertNew);
             if(CompeteId == null)
             {
           			 InsertNewArr.add(InsertNew);
             }
              else
              {
                  	UpdateNewArr.add(InsertNew);
              }
         }
        }
        try{
            system.debug('InsertNewArr '+InsertNewArr);
            Counter=0;
       		if(InsertNewArr.size() > 0)	
            {
                	system.debug('Inserting new Record ');
                	insert InsertNewArr;
            }
       		if(UpdateNewArr.size() > 0)	
            	{
                	system.debug('Updating the Record');
                	update UpdateNewArr;
            	}
        }
        catch(DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++) {

        // Process exception here

        System.debug(e.getDmlMessage(i));
            }
        }
    }
}