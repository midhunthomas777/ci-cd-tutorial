@istest
public class OpportunityActivityLastModifiedDateTest {

    public static Boolean didRun = false;
    public static String oppPrefix =  Opportunity.sObjectType.getDescribe().getKeyPrefix();

        public static testMethod void testCountTask() {
        //Setup
        TestDataSetUpUtils.insertCustomSettings();
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(); 
		Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> Acclist = TestDataSetUpUtils.createAccounts(1, prospectId);
        List<opportunity> opplist = TestDataSetUpUtils.createopportunities(2,ProjectRTId,Acclist);
        //Insert our first task
        Task t = new Task(subject='Test Activity', whatId = opplist[0].id);
        insert t;

        test.starttest();
        
        //Disconnect task from the opportunity
        didRun = false; //Reset
        t.whatId = null;
        update t;
       
        didRun = false; //Reset
        //Add an event
        Event e = new Event(subject='Test Event', whatId = opplist[0].id, startDateTime = System.Now(), endDateTime = System.now());
        insert e;

        
        didRun = false; //Reset
        t.whatId = opplist[0].id;
        update t;

        
        didRun = false; //Reset
        e.whatId = null;
        update e;

        
        didRun = false; //reset
        delete t;
       
        test.stoptest();      
    }

}