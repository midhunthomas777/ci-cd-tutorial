//test class for JiraIntegrationService
@isTest
public class JiraIntegrationService_Test {
    
     //configuring custom settings
    @testSetup
    static void testSetUp()
    {  
        TestDataSetUpUtils.insertCustomSettings();
        List<TriggerSettings__c> tSC = new List<TriggerSettings__c>();
        tsc.add(new TriggerSettings__C(Name = 'FeedItemTriggerDisabled', IsActive__C=false));
        Insert tSC;        
    } 
    
    //method to test create and update Jira story logic
    static testmethod void createupdJirastory(){
        
        Test.startTest();
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
          //Query necessary record types specific to Jira integration
        Id recordtype1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Application_Support').getRecordTypeId();
        Id recordtype2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Admin_Service_Case').getRecordTypeId();
        
        List<Case> csList = new List<case>();
        List<Case> csList1 = new List<case>();
        
        
        Case cs = new Case();
        cs.AccountId = accList.get(0).Id;
        cs.ContactId = contactList.get(0).Id;
        cs.Subject = 'Test Jira outbound';
        
        //cs.Customer_Number__c = string.valueof(integer.valueof(math.random()*1000000000)*100);
        cs.Description = 'Test when Jira project is empty';
       // cs.Case_Type_1__c = 'Incident';
        cs.Status = 'Open';
        cs.Impact__c = 'Severity 3';
        cs.recordtypeid = recordtype1;
        //cs.Jira_Story_Id__c = '142425';
        csList.add(cs);
        
          Case cs1 = new Case();
        cs1.AccountId = accList.get(0).Id;
        cs1.ContactId = contactList.get(0).Id;
        cs1.Subject = 'Test Jira outbound create';
        cs1.Description = 'Test Jira story ID is not blank';
      //  cs1.Case_Type_1__c = 'Incident';
        cs1.Status = 'New';
        cs1.Impact__c = 'Severity 3';
       // cs1.Severity__c = 'Severity3';
        cs1.Jira_Story_Id__c = '142437';
        cs1.recordtypeid = recordtype2;
        csList.add(cs1);
        
          Case cs2 = new Case();
        cs2.AccountId = accList.get(0).Id;
        cs2.ContactId = contactList.get(0).Id;
        cs2.Subject = 'Test Jira update';
        cs2.Description = 'Test Jira story ID is not blank: Update Case';
       // cs2.Case_Type_1__c = 'Incident';
        cs2.Status = 'Open';
     //   cs2.Customer_Number__c = string.valueof(integer.valueof(math.random()*1000000000)*100);
        
        cs2.Impact__c = 'Severity 3';
        cs2.Jira_Story_Id__c = '142427';
        cs2.recordtypeid = recordtype2;
        csList.add(cs2);
        
       
        insert csList; 
       
        system.assertEquals(3, csList.size());
        
         //updating necessary case fields for above cases for trigerring case dispatch functionality
        cs.Jira_Project__c = 'Product Order Ability'; 
        csList1.add(cs);
        cs1.Priority = 'Severity 4';
        cs2.Priority = 'Severity 4';
        csList1.add(cs1);
        
        update csList1;
        
        System.assertequals(1, JiraIntegrationService.dispCaseCrPubEvtLst.size());//validate dispatch case create event if published
        System.assertequals(1, JiraIntegrationService.dispCaseUpdPubEvtLst.size());
        test.stopTest();
        
    }
    
    
    //Feeditem trigger after insert functionlity
    static testmethod void createJiraWorkitemsTest(){
        test.startTest();
         Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        //Query necessary record types specific to Jira integration
        Id recordtype1 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('MSI_Support_Case_Application_Support').getRecordTypeId();
        Id recordtype2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Admin_Service_Case').getRecordTypeId();
        
        
        List<case> csList = new List<Case>();
        
        Case cs = new Case();
        cs.AccountId = accList.get(0).id;
        cs.ContactId = contactList.get(0).Id;
        cs.Subject = 'Test FeedItem1';
        cs.Description = 'Test FeedItem1';
        cs.Status = 'Open';
        cs.Impact__c = 'Severity 3';
        cs.Jira_Story_Id__c = '142425';
        cs.RecordTypeId = recordtype1;
        csList.add(cs);
        
        Case cs1 = new Case();
        cs1.AccountId = accList.get(0).id;
        cs1.ContactId = contactList.get(0).Id;
        cs1.Subject = 'Test FeedItem2';
        cs1.Description = 'Test FeedItem2';
        cs1.Status = 'Open';
        cs1.Impact__c = 'Severity 3';
        cs1.RecordTypeId = recordtype2;
      //  cs1.Jira_Story_Id__c = '142467';
        csList.add(cs1);
        
        insert csList;
        
         //Create feeditems for cases to test dispatch workitem functionality
        List<FeedItem> fdList = new List<FeedItem>();
        if(csList.size() > 0){
            for(Case c1: csList){
                if(c1.Jira_Story_Id__c!=null){
                 FeedItem item = new FeedItem(
                    parentId = c1.id, // where to post message
                    createdById = UserInfo.getUserId(), 
                    body = 'FeedItem created for test');
                fdList.add(item);
            }
            }
            
            
            insert fdList;
            System.assertEquals(1, fdList.size());
            System.assertEquals(2, csList.size());
            System.assertequals(1, JiraIntegrationService.CrFeedItmPubEvtLst.size()); //validate create feeditem publish event
            
        }
        
        test.stopTest();

    }
    
     static testmethod void crtWrkItemsbulk(){
        
         test.startTest();
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
    
         List<case> csList = new List<Case>();
        Case cs = new Case();
        cs.AccountId = accList.get(0).id;
        cs.ContactId = contactList.get(0).Id;
        cs.Subject = 'Test FeedItem1';
        cs.Description = 'Test FeedItem1';
        cs.Status = 'Open';
        cs.Impact__c = 'Severity 3';
        cs.Jira_Story_Id__c = '142425';
        // cs.RecordTypeId = recordtype1;
        csList.add(cs);
        
        insert csList;
        //Create feeditems for cases to test dispatch workitem functionality
        List<FeedItem> fdList = new List<FeedItem>();
			
        if(csList.size()>0){
            for (Case cs1:csList) {
                if(cs1.Jira_Story_Id__c!=null) {
                    for(Integer i=0;i<200;i++) {
                        FeedItem item = new FeedItem(
                            parentId = cs1.id, 
                            createdById = UserInfo.getUserId(), 
                            body = 'FeedItem created for test'+i,
                            visibility='AllUsers');
                        fdList.add(item);
                        
                    }
                }
            }
            insert fdList;
        }
         test.stopTest();
 			System.assertEquals(200, fdList.size());
            System.assertEquals(1, csList.size());
            System.assertequals(200, JiraIntegrationService.CrFeedItmPubEvtLst.size()); //validate create feeditem publish event
                 
    }

}