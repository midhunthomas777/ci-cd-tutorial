/*    
Class Name      : BatchJobs
Purpose         : BatchJobs Class is for calculating the completion percentage of Batch Jobs
Author          : Arunraj Radhakrishnan
Test Class      : 
Change History  : -
*/

public class BatchJobs{
 
    public List<BatchJob> batchJobs;
    public Integer numberOfJobs {get; set;}
    public String currentBatchId{public get; public set;}
    public String strFileType{get; set;}
    public String jobStatus {get;set;}
    public List<id> successIdList {public get; public set;}
 
    public List<BatchJob> getBatchJobs(){
        //successCountOnBatch = 0;
        //Create new list of BatchJobs, a wrapper class that includes the job and percent complete.
        batchJobs = new List<BatchJob>();
 
        //If number of jobs was not defined, default to 20
        if(numberOfJobs== null || numberofJobs <= 0){
            numberofJobs = 20;
        }
 
        //Query the Batch apex jobs
        for(AsyncApexJob a : [select TotalJobItems, Status, NumberOfErrors, MethodName, JobType, JobItemsProcessed, Id, CreatedDate, CreatedById, CompletedDate, ApexClassId, ApexClass.Name From AsyncApexJob 
                                where id= :currentBatchId  and ApexClass.name='BatchProcessor' order by CreatedDate desc limit :numberOfJobs]){
            Double itemsProcessed = a.JobItemsProcessed;
            Double totalItems = a.TotalJobItems;
            jobStatus = a.status;
            BatchJob j = new BatchJob();
            j.job = a;
 
            //Determine the pecent complete based on the number of batches complete
            if(totalItems == 0){
                j.percentComplete = 0;
            }else{
                j.percentComplete = ((itemsProcessed  / totalItems) * 100.0).intValue();
            }                        
 
            batchJobs.add(j);
        }
         
        return batchJobs;
    }
    
    public Integer getSuccessCountOnBatchCompletion(){
        successIdList = new List<id>();
        Integer successCount = 0;
        System.debug('currentBatchId:::::::::::::'+currentBatchId);
        String batchIdStr;
        if(currentBatchId!=null)
        batchIdStr = currentBatchId.subString(0,15) + '%';
        String queryStr = 'Select id from SDS_Graphs_Data__c where Apex_Job_ID__c like \''+ batchIdStr +'\'';
        System.debug('query'+queryStr);
        if(jobStatus == 'Completed') {
            for(SDS_Graphs_Data__c  sds:Database.query(queryStr)){ 
                successIdList.add(sds.id);               
            }
            successCount = successIdList.size();
            System.debug('successCount:::'+successIdList.size());
        }            
        return successCount;
    } 
 
    //This is the wrapper class the includes the job itself and a value for the percent complete
    public Class BatchJob{
        public AsyncApexJob job {get; set;}
        public Integer percentComplete {get; set;}
    }
    
}