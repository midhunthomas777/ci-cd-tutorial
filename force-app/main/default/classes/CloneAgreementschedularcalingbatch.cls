global class CloneAgreementschedularcalingbatch implements Schedulable
{ 
      global String  soqlQuery{get; set;} 
      global void execute(SchedulableContext sc)  
      {
         CloneAgreementBatch b = new CloneAgreementBatch(); 
         soqlQuery ='SELECT id,TobeCloned__c FROM Apttus__APTS_Agreement__c where TobeCloned__c=true and Tobeprocessed__c=false';
         b.query = soqlQuery;  
         database.executebatch(b,1);
      }
      
}