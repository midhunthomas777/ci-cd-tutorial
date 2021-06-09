/************************************************************************************************* 
* File Name  : GenericWithoutSharing_Test
* Description: Test class for GenericWithoutSharing class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 14-Aug-2018     Satish Maddhi(TCS)	  			Initial development
*
*************************************************************************************************/

@isTest
public class GenericWithoutSharing_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testMethod void test_GenericWithoutsharing() {
        Id standardCon = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<Account> cusAcc = TestDataSetUpUtils.createAccounts(3,custRecTypeId);
        List<Contact> conLst = TestDataSetUpUtils.createContacts(1,standardCon,cusAcc);
        Id prosRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        List<Account> prosAcc = TestDataSetUpUtils.createAccounts(1, prosRecType);
        Id ProjectRTId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        List<opportunity> opplist = TestDataSetUpUtils.createOpportunities(1, ProjectRTId, prosAcc);
        
        List<Lead> leadlst = TestDataSetUpUtils.createLeadRecords(2);
        Map<Id,Lead> newLeadMap = new Map<Id,Lead>();
        for(Lead eachLead : leadlst) {
			newLeadMap.put(eachLead.id,eachLead);
        }
        GenericWithoutSharing ctrl = new GenericWithoutSharing();
        ctrl.convertLeadWithoutSharing(newLeadMap);
        ctrl.updateConvertedConRecTypeId(newLeadMap);
        ctrl.createContactShare(conLst);
        ctrl.insertPartners(opplist);
    }
}