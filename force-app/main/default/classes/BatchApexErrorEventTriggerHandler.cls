public without sharing class BatchApexErrorEventTriggerHandler {
    
    public static void afterInsert(List<BatchApexErrorEvent> newRecords) {
        List<LogForAllErrors__c> errorLogRecords = new List<LogForAllErrors__c>();

        for (BatchApexErrorEvent event : newRecords) {
            errorLogRecords.add(
                new LogForAllErrors__c(
                    Type__c = 'Error',
                    ModuleCreatingError__c = 'Batch Job: ' + event.AsyncApexJobId,
                    Short_Error_Description__c = event.ExceptionType,
                    ErrorString__c = 'Batch Job failed in phase: ' + event.Phase + ', with message: ' + event.Message,
                    Exception_Type_Name__c = event.ExceptionType,
                    Exception_Details__c = event.StackTrace,
                    Quiddity__c = Request.getCurrent().getQuiddity().name(),
                    Request_Id__c = event.RequestId,
                    OwnerId = UserInfo.getUserId()
                )
            );
        }

        Database.Insert(errorLogRecords);
    }
}