@isTest
public class PartnerTriggerTests {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    public static testMethod void testRunner(){
        
        User newOwner = [Select Id,Name from User where profile.name='System Administrator' AND IsActive=true limit 1];
        Opportunity opp = new Opportunity(Name='TestOpp1',StageName='Prospect',ForecastCategoryName='Non Commit',owner=newOwner,First_Ship_Date__c = System.today()+1,closedate = System.today(),Type='Standard');
        Insert opp;
        Id oppId=opp.Id;
        //Id acctId = [Select Id from Account where owner.isActive=true and RecordtypeId='01280000000UCx6' limit 1].Id; //Modified by Harish
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                              AND DeveloperName = 'Partner'];
        List<Account> partnerAcc =  TestDataSetUpUtils.createAccounts(1, recType.id);
        Id acctId = partnerAcc[0].Id;
        Partners2__c[] newPtrs = new Partners2__c[2];
        newPtrs[0] = new Partners2__c(Opportunity__c=oppId, Account__c=acctId, Role__c='Primary Channel Partner');
        newPtrs[1] = new Partners2__c(Opportunity__c=oppId, Account__c=acctId, Role__c='Primary Distributor');
        
        Database.SaveResult[] sr2 = Database.insert(newPtrs);
        Id[] ptrIds = new Id[]{sr2[0].getId(),sr2[1].getId()};
            
            Partners2__c[] ptrs = [Select Id, Account__c, Opportunity__c from Partners2__c where Id in :ptrIds];
        
        ptrs[0].Role__c='Primary Distributor';
        update(ptrs[0]);
        
        ptrs[0].Role__c='Primary Channel Partner';
        ptrs[1].Role__c='Primary Distributor';
        update(ptrs);
        
        delete(ptrs[0]);
        delete(ptrs[1]);
        
    }
    
    public static testMethod void testRunner1(){
        User newOwner = [Select Id,Name from User where profile.name='System Administrator' AND IsActive=true limit 1];
        Opportunity opp = new Opportunity(Name='TestOpp1',StageName='Prospect',ForecastCategoryName='Non Commit',owner=newOwner,First_Ship_Date__c = System.today()+1,closedate = System.today(),Type='Standard');
        Insert opp;
        Id oppId=opp.Id;
        //Id acctId = [Select Id from Account where owner.isActive=true and RecordtypeId='01280000000UCx6' limit 1].Id; //Modified by Harish
        Recordtype recType = [SELECT Id,DeveloperName,Name,SobjectType FROM RecordType WHERE SobjectType = 'Account'
                              AND DeveloperName = 'Partner'];
        List<Account> partnerAcc =  TestDataSetUpUtils.createAccounts(1, recType.id);
        Id acctId = partnerAcc[0].Id;
        Partners2__c[] newPtrs = new Partners2__c[2];
        newPtrs[0] = new Partners2__c(Opportunity__c=oppId, Account__c=acctId, Role__c='Primary Channel Partner');
        newPtrs[1] = new Partners2__c(Opportunity__c=oppId, Account__c=acctId, Role__c='Primary Carrier');
        
        Database.SaveResult[] sr2 = Database.insert(newPtrs);
        Id[] ptrIds = new Id[]{sr2[0].getId(),sr2[1].getId()};
            
        Partners2__c[] ptrs = [Select Id, Account__c, Opportunity__c from Partners2__c where Id in :ptrIds];
        
        ptrs[0].Role__c='Primary Distributor';
        update(ptrs[0]);
        
        ptrs[0].Role__c='Primary Channel Partner';
        ptrs[1].Role__c='Primary Carrier';
        update(ptrs);
        
        delete(ptrs[0]);
        delete(ptrs[1]);
        
    }
    
}