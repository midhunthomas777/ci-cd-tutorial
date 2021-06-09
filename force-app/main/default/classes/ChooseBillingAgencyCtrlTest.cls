@isTest
public class ChooseBillingAgencyCtrlTest {
    @isTest
    public static void getHostAndSubAccDetailsTest() {
        Id customerAccRectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id mcnAccrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id opprectypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        
        TestDataSetUpUtils.insertCustomSettings();
      
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,customerAccRectypeID);
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String,String> mcnAccIdAndTypeMap = new Map<String,String>();
        List<String> secondaryOppRecIDList = new List<String>();
        //TestDataSetUpUtils.createAccounts(1,customerAccrectypeID)
        oppList = TestDataSetUpUtils.createOpportunities(1,opprectypeID,accList);
        List<Account> mcnAccList = TestDataSetUpUtils.createMCNAccounts(1, mcnAccrectypeID, accList);
        List<Technical_Site__c> siteList = TestDataSetUpUtils.createSites(5,mcnAccList[0].id,accList[0].Id,'');
        List<SubAgency__c> secondaryOppRecList = TestDataSetUpUtils.createSubAgencyRecsWithSites(5,oppList,mcnAccList,siteList);
        System.debug('SubAcc Records..'+secondaryOppRecList);
        List<Opportunity> oppWithSubAccs = new List<Opportunity>();
        
        //preparing map to pass as parameter for getMCNAccs method
        for(Account acc : mcnAccList) {
            mcnAccIdAndTypeMap.put(acc.Id,'Motorola Customer Number');
        }
        //preparing List to pass as parameter for saveOppSubAccRecords method
        for(SubAgency__c secondaryOppRec : secondaryOppRecList) {
            secondaryOppRecIDList.add(secondaryOppRec.Id);
        }
        
       Test.startTest();
        oppWithSubAccs = ChooseBillingAgencyCtrl.getHostAndSubAccDetails(oppList[0].Id);
        List<Account> accResult = ChooseBillingAgencyCtrl.getMCNAccs(mcnAccIdAndTypeMap);
        String saveResult = ChooseBillingAgencyCtrl.saveOppSubAccRecords((String)oppList[0].Id,secondaryOppRecIDList,(String)mcnAccList[0].Id);
     Test.stopTest();
    }
   
    }