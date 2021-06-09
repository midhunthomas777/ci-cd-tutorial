public class DeletefromCompetitveDB {
  @InvocableMethod // Delete the Competitive DB Record if the Status is back to being Active from Lost
    public static void DeleteRecord(List<Id> OpportunityId)
    {
        system.debug('OpportunityId '+OpportunityId);
       List<CompetitiveDB__c> DeleteNewArr = [SELECT Id from CompetitiveDB__c where Related_Opportunity__c = : OpportunityId];
       List <JunctionforAccountCompetitior__c> junc = new List<JunctionforAccountCompetitior__c>();   
   		for(CompetitiveDB__c DeleteObj : DeleteNewArr)
        {
        	JunctionforAccountCompetitior__c RowJunc = [SELECT Id from JunctionforAccountCompetitior__c where CompetitiveId__c  = :DeleteObj.Id];
			junc.add(RowJunc); 				
        }
            if (junc.size() > 0)
            {
                system.debug('JunctionObject '+junc);
                delete junc;
            }
     	if(DeleteNewArr.size() > 0)
        {
            system.debug('DeleteNewArr '+DeleteNewArr);
            delete DeleteNewArr;
        }
    }
  
}