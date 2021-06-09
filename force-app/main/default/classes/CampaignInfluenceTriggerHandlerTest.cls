@isTest
public class CampaignInfluenceTriggerHandlerTest {
    @testSetup static void methodName(){
        TestDataSetUpUtils.insertCustomSettings();
        LM_StateCode__c lmSCode= new LM_StateCode__c();
        lmSCode.Country__c ='Canada';
        lmSCode.Name = 'Alberta';
        lmSCode.State_Code__c = 'AB';
        insert lmSCode;
        
    }
    
    private static testMethod void updateInfluenceValueTest(){
        
        Test.startTest();
        
        //Insert lead
        RecordType objLeadRecType = [Select Id from RecordType where sObjectType='Lead' And DeveloperName='Global_Lead_Record' limit 1];
        Lead objlead = new Lead();
        objlead.Company = 'IT';
        objlead.Status = 'Marketing Lead';
        objlead.Track__c = 'Radio';
        objlead.Region__c = 'NA';
        objlead.LastName = 'Test';
        objlead.Industry = 'Education';
        objlead.Email = 'test@gmail.com';
        objlead.Country='Canada';
        objlead.State = 'Alberta';
        objlead.Street = 'New Colony';
        objlead.Territory__c = 'T1';
        objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead.City ='test';
        objlead.Visitor_Info__c = 'Test Visitor';
        objlead.Technology_Segment__c = 'Accessories & Energy';
        objlead.RecordTypeId = objLeadRecType.ID;
        objlead.Campaign_Code__c = 'Onvia_Pursuits_Term_Contracts';
        objlead.Overdue_Status__c = 'Overdue';
        objlead.Countrycode = 'CA';
        objlead.Statecode = 'AB';
        objlead.Lead_Value__c = 50;
        objlead.Partner_Assigned_Status__c = 'Reassign';
        objlead.Close_Date__c = Date.valueOf(System.now());
        insert objlead;
        
        //insert Campaign
        List<Campaign> campLst = new List<Campaign>();
        campLst.add(new Campaign(Name='Onvia_Pursuits_Term_Contracts'));
        campLst.add(new Campaign(Name='Onvia_Pursuits_Term_Bids'));
        insert campLst;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(objlead.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        lc.setOwnerId(UserInfo.getUserId());
        
        Database.LeadConvertResult lcr = Database.convertLead(lc,false);
        System.debug('LeadCOnvert Errors'+lcr.getErrors());  
        System.assert(lcr.isSuccess());
        Lead convLead = [Select Id ,ConvertedAccountId, ConvertedOpportunityId, ConvertedContactId from Lead WHERE Id =:objlead.Id];
       
        List<CampaignMember> camMemLst = new List<CampaignMember>();
        camMemLst.add(new CampaignMember(CampaignId = campLst[0].Id,ContactId=convLead.ConvertedContactId));
        camMemLst.add(new CampaignMember(CampaignId = campLst[1].Id,ContactId=convLead.ConvertedContactId));
        insert camMemLst;
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        
        oppIds.add(convLead.ConvertedOpportunityId);
        conIds.add(convLead.ConvertedContactId);
        
        CampaignInfluenceTriggerHandler citm = new CampaignInfluenceTriggerHandler();
        citm.insertEvenDistributonInfluences(oppIds,conIds);
        
        Test.stopTest();
    }
    
}