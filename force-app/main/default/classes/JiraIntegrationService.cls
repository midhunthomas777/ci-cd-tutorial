/*
 * Class Name- JiraIntegrationService
 * Description - Class created for Salesforce Jira outbound integration
 * Modification log
 * ======================================================
 * Ver   Date          Author        Modification 
 * ----------------------------------------------------------
 * 
 */

public class JiraIntegrationService {
    
     //create dispatch case event list for checking published event in test class
  @testVisible 
  private static final List<Dispatch_Case__e> dispCaseCrPubEvtLst = new List<Dispatch_Case__e>();
  @testVisible 
  private static final List<Dispatch_Case__e> dispCaseUpdPubEvtLst = new List<Dispatch_Case__e>();
    
    //create CreateFeedItem event list for checking published event in test class
    @testVisible
    private static final List<Create_FeedItem__e> CrFeedItmPubEvtLst = new List<Create_FeedItem__e>();

    //method to dispatch create and update case functionality invoked after case update trigger
    public static void createupdJirastory(Map<Id, SObject> newItems,Map<Id, SObject> oldItems){
        String u1 = userInfo.getUserId(); //get user
        System.debug(u1);
        
        //check if not integration user to avoid recursion
        if(u1 != System.label.IntegrationUserId)
        {
            //create dispatch case event list
            List<Dispatch_Case__e> dispCaseCreateEvents = new List<Dispatch_Case__e>();
            List<Dispatch_Case__e> dispCaseUpdateEvents = new List<Dispatch_Case__e>();
            Double crtktcnt=0; //to count create dispatch events
            Double updtktcnt=0; // to count update dispatch events
               for(Case updatedCase:(List<Case>) newItems.values())//checking updated cases
            {
                 Case oldCase = (Case) oldItems.get(updatedCase.Id);
                
                //check if Jira project is updated from null and Jira Story Id is null
                if(oldCase.Jira_Project__c == null && updatedCase.Jira_Project__c != null && updatedCase.Jira_Story_Id__c == null)
                {
					//create entry in dispatch case event with action CREATE
                    dispCaseCreateEvents.add(new Dispatch_Case__e(Target_System__c='Jira', Action__c='CREATE', Target_System_ID__c=null,SFDC_Case_ID__c=updatedCase.Id));
                }
                
                //check if Jira Story Id is not null and Priority field is updated
				if(oldCase.Priority != updatedCase.Priority && updatedCase.Jira_Story_Id__c != null)
				{
					//create entry in dispatch case event with action UPDATE
					dispCaseUpdateEvents.add(new Dispatch_Case__e(Target_System__c='Jira', Action__c='UPDATE', Target_System_ID__c=updatedCase.Jira_Story_Id__c,SFDC_Case_ID__c=updatedCase.Id));
			    }
                
            }
            
            // Call method to publish events
            List<Database.SaveResult> result1 = EventBus.publish(dispCaseCreateEvents);
            List<Database.SaveResult> result2 = EventBus.publish(dispCaseUpdateEvents);
            
            
            
              // Inspect publishing result for each dispatch case event with action CREATE
            for (Database.SaveResult sr : result1) 
            {
                if (sr.isSuccess()) //if event is published successfully
                    crtktcnt = crtktcnt + 1; //update cnt
                else //if events not published
                {
                    for(Database.Error err : sr.getErrors()) 
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }       
            }
            if(crtktcnt != 0)
			{
                System.debug('No. of successfully published events for Create Jira Incidents: '+crtktcnt);
				for(Dispatch_Case__e crtcs : dispCaseCreateEvents)
					dispCaseCrPubEvtLst.add(crtcs);
			}
           System.debug('Check@@ for Create'+dispCaseCrPubEvtLst); 
            
            // Inspect publishing result for each dispatch case event with action UPDATE
            for (Database.SaveResult sr : result2) 
            {
                if (sr.isSuccess()) //if event is published successfully
                    updtktcnt = updtktcnt + 1; //update cnt
                else //if events not published
                {
                    for(Database.Error err : sr.getErrors()) 
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }       
			}
			if(updtktcnt != 0)
			{
				System.debug('No. of successfully published events for Update Jira Incidents: '+updtktcnt);
				for(Dispatch_Case__e updcs : dispCaseUpdateEvents)
					dispCaseUpdPubEvtLst.add(updcs);
			}
             System.debug('Check@@ for Update'+dispCaseUpdPubEvtLst); 
        }
    }
      
    
    //method for sending chatter post to an existing Jira story
     public static void createJiraWorkitems(Map<Id, SObject> newItems)
	{
        String u1 = userInfo.getUserId(); //get user
		System.debug(u1);
		//check if not integration user to avoid recursion
		if(u1 != System.label.IntegrationUserId)
		{
            //create CreateFeedItem event list
			List<Create_FeedItem__e> feedItemEvents = new List<Create_FeedItem__e>();
			Double crwrkitmcnt=0; // to count CreateFeedItem events
            
              set<Id> csids = new Set<Id>();
            String s1;
            for(FeedItem fd:(List<Feeditem>)newItems.values()){
                s1 = String.valueOf(fd.parentId);
                System.debug('value@@'+s1);
                if(s1.startswith('500') && fd.parentId!=null){
                    csids.add(fd.parentid);
                }
            }
            if(csids.size()>0) {
                Map<Id,Case> csObjmap = new Map<Id,Case>([Select Id,Jira_Story_Id__c from case where id IN:csids]);
                
                for(FeedItem feed :(List<FeedItem>) newItems.values()) //checking inserted feeds
                {
                    
                    if(csObjmap.containskey(feed.parentId)) {
                        if(csObjmap.get(feed.parentid).Jira_Story_Id__c!=null) //check Jira story id
                        {
                        
                        //create entry in CreateFeedItem event
                        feedItemEvents.add(new Create_FeedItem__e(
                            //Body__c = body.replaceAll('\\<.*?\\>', ''),
                            Body__c = feed.Body.stripHtmlTags(),
                            SFDC_Case_ID__c = csObjmap.get(feed.parentid).id,
                            Parent_ID__c = csObjmap.get(feed.parentid).Jira_Story_Id__c,
                            Target_System__c = 'Jira',
                            Visibility__c = feed.Visibility
                        ));
                        
                    }
                }
            }
            }
            
            
            //call method to publish platform event for dispatching Jira work item
            List<Database.SaveResult> results = EventBus.publish(feedItemEvents);
              // Inspect publishing result for each event
            for (Database.SaveResult sr : results) 
			{
                if (sr.isSuccess()) //if event is published successfully
                    crwrkitmcnt = crwrkitmcnt + 1; //update cnt
                else //if event is not published 
                {
                    for(Database.Error err : sr.getErrors())
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }  
                
            }
              if(crwrkitmcnt != 0)
			{
                System.debug('No. of successfully published events for Create Jira WorkItems: '+crwrkitmcnt);
				for(Create_FeedItem__e cf : feedItemEvents)
					CrFeedItmPubEvtLst.add(cf);
			}
            
            System.debug('details@@@'+feedItemEvents);
            
    
        }
        
    }

}