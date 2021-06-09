public without sharing class LogEventTriggerHandler {

    // If you need to debug this trigger turn on Debug logs for 'Automated Process' entity.
    public static void afterInsert(List<LogEvent__e> newRecords) {
        List<LogForAllErrors__c> errorLogRecords = new List<LogForAllErrors__c>();

        for (LogEvent__e event : newRecords) {
            errorLogRecords.add(
                new LogForAllErrors__c(
                    Type__c = event.Type__c,
                    ModuleCreatingError__c = event.ModuleCreatingError__c,
                    Short_Error_Description__c = event.Short_Error_Description__c,
                    ErrorString__c = event.ErrorString__c,
                    OwnerId = event.OwnerId__c,
                    Exception_Type_Name__c = event.Exception_Type_Name__c,
                    Exception_Details__c = event.Exception_Details__c,
                    Quiddity__c = event.Quiddity__c,
                    Request_Id__c = event.Request_Id__c
                )
            );
        }
        List<Database.SaveResult> res = Database.insert(errorLogRecords);
    }
}