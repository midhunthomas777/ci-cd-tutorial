@isTest
private class LeadFieldUpdateEvent_Test{
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    static testMethod void updateLeadField(){
        Id profId;
        test.starttest();
        RecordType rt2 = [select Id from RecordType where SObjectType='Lead' and DeveloperName='Global_Lead_Record' limit 1];
        
        Lead Leadrecord = new Lead(lastname ='Test Lead 5635',RecordTypeId =rt2.Id,Company = 'my company');
        insert Leadrecord;
        
        Task LeadTask = new Task(WhoId=Leadrecord.Id,Subject='Test',ActivityDate=Date.Today(),Status = 'Not Started',Priority='Normal');
        insert LeadTask;
        
        Event LeadEvent = new Event(WhoId=Leadrecord.Id,Subject='Test',StartDateTime = DateTime.now(),EndDateTime = DateTime.now());
        insert LeadEvent;
        
        Leadrecord = [SELECT CreatedDate FROM Lead WHERE Id =: Leadrecord.id ORDER BY CreatedDate ASC LIMIT 1];
        LeadTask = [SELECT CreatedDate FROM Task WHERE WhoId =: leadrecord.id ORDER BY CreatedDate ASC LIMIT 1];
        LeadEvent = [SELECT CreatedDate FROM Event WHERE WhoId =: leadrecord.id ORDER BY CreatedDate ASC LIMIT 1];
        
        DateTime TD;
        DateTime ED;
        DateTime LD;
        
        Date TaskDate;
        Date EventDate;
        Date LeadDate;
        
        LD = Leadrecord.CreatedDate;
        TD = LeadTask.CreatedDate;
        ED = LeadEvent.CreatedDate;
        System.debug('Lead Date' + LD);
        System.debug('Task Date' + TD);
        System.debug('Event Date' + ED);
        
        LeadDate = date.newinstance(LD.year(), LD.month(), LD.day());
        EventDate = date.newinstance(ED.year(), ED.month(), ED.day());
        TaskDate = date.newinstance(TD.year(), TD.month(), TD.day());
        
        if (TaskDate > EventDate) {
            Leadrecord.First_Response_Velocity__c = LeadDate.Daysbetween(EventDate);
            update LeadRecord;
        } else {
            Leadrecord.First_Response_Velocity__c = LeadDate.Daysbetween(TaskDate);
            update LeadRecord;
        }
        test.stoptest();
    }
}