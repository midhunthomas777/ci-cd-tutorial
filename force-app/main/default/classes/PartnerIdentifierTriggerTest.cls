@isTest
private class PartnerIdentifierTriggerTest {
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }
    @isTest
    public static void PartnerIdentifierTest(){
        Id partRecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        list<Partner_Identifier__c> partnerIdList = new list<Partner_Identifier__c>();
        list<Partner_Identifier__c> partnerIdListUpdate = new list<Partner_Identifier__c>();
        list<Partner_Identifier__c> partnerIdListDelete = new list<Partner_Identifier__c>();
        Account acc=new Account(name='MPE_test_1',Partner_Account_Name__c='Compliance1',Type ='Partner',Partner_Region__c='APAC',
                                recordTypeId=partRecordtypeId,
            Partner_Zone__c = '1',Metal_Level__c = 'Gold', Annual_Program_Review_Date_APRD__c = system.today(),Inactivation_Email_Notification_Sent__c = false, 
            Hierarchy_Placement__c = 'Regional Account',BillingCountry = 'United States',Billingstate = 'Texas',Billingcity = 'San Mateo',Billing_County__c='US');
            insert acc;
       
        Partner_Identifier__c partner= new Partner_Identifier__c(Account__c = acc.id,ID_Number__c = '9999', ID_Type__c = 'Motorola Enterprise Number');
        partnerIdList.add(partner);
        Partner_Identifier__c partner1= new Partner_Identifier__c(Account__c = acc.id,ID_Number__c = '9990', ID_Type__c = 'Motorola Enterprise Number');    
        partnerIdList.add(partner1);
        Partner_Identifier__c partner2= new Partner_Identifier__c(Account__c = acc.id,ID_Number__c = '9900', ID_Type__c = 'Motorola Customer Number');   
        partnerIdList.add(partner2);
        insert partnerIdlist;
        for(Partner_Identifier__c p : partnerIdlist){
            if(p.ID_Number__c == '9999')
                p.ID_Type__c = 'Motorola Customer Number';
            partnerIdListUpdate.add(p);   
            if(p.ID_Number__c == '9990') 
            partnerIdListDelete.add(p);
        }
        Test.startTest();
        update partnerIdListUpdate;
        Test.stopTest();
        delete partnerIdListDelete;
    }
}