@isTest
private class MPP_TEST_TRG_AttributeToGroupProcessing {
  @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

    static testMethod void testAttributeToGroupProcessing() {
        Account a = new Account(Name='Test Systems Inc.', Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=true,BillingCountry='Brazil',Status__c='Active',Metal_Level__c = 'nothing', Partner_Region__c='NAMR',BillingCity='San Mateo',BILLINGPOSTALCODE='1010');
        insert a;
        
        Attribute_to_Group_Processing__c atgp = new Attribute_to_Group_Processing__c();
        atgp.Should_Run_Future_Method__c = false;
        atgp.Has_Run__c = false;
        atgp.Account_Id_Set__c = a.Id;
        insert atgp;
        
        atgp.Should_Run_Future_Method__c = true;
        
        try{
            update atgp;
            Attribute_to_Group_Processing__c testAtgp = [SELECT Has_Run__c FROM Attribute_to_Group_Processing__c WHERE Id = :atgp.Id];
            
        }catch (system.Exception e){
            system.debug('ERROR: ' + e.getMessage());
        }
    }
}