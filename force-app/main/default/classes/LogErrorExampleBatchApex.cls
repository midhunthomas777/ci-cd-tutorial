// Used for testing BatchApexErrorEventTrigger
global with sharing class LogErrorExampleBatchApex implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id, Name FROM User LIMIT 1';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope) {
        for (User u : scope) {

        }
    }

    global void finish(Database.BatchableContext BC) {
        String a;
        a.contains('z'); // Should throw nullpointer
    }
}