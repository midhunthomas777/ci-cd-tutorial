global class CloneAgreementEntschedularcalingbatch implements Schedulable
{ 
      global String  soqlQuery{get; set;} 
      global void execute(SchedulableContext sc)  
      {
         CloneAgreementEntBatch b = new CloneAgreementEntBatch(); 
         soqlQuery ='SELECT id,TobeClonedEnterprise__c FROM Apttus__APTS_Agreement__c where TobeClonedEnterprise__c=true and tobeprocessed__c=false';
        //soqlQuery ='SELECT id,TobeClonedEnterprise__c FROM Apttus__APTS_Agreement__c where TobeClonedEnterprise__c=true and tobeprocessed__c=true and lastmodifieddate=today';
        b.query = soqlQuery;  
        database.executebatch(b,1);
      }
      
}