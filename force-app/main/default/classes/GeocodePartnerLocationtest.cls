@isTest
Private class GeocodePartnerLocationtest
{
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testmethod void GeocodePartLoctest()
    {
        Account acc = new Account(name='test account',BillingCountry = 'United States',Billingstate = 'Texas',Billingcity = 'San Mateo');                
        insert acc;
        
        //List<Partner_Location__c> partloc= new List<Partner_Location__c>(); 
        Partner_Location__c partloc1 = new Partner_Location__c(Account__c=acc.Id,Address_Line1__c='Beverly Hills',Address_Line2__c='Test',Address_Line3__c='Test',State__c='Florida',City__c='Beverly Hills',Country1__c='United States',Postal_code__c='34464');
        insert partloc1;
        //partloc.add(partloc1);
        Partner_Location__c partloc2 = new Partner_Location__c(Account__c=acc.Id,Address_Line1__c='Manikonada',Address_Line2__c='Test',Address_Line3__c='Test',State__c='AP',City__c='Hyderabad',Country1__c='India',Postal_code__c='500081');
        insert partloc2;
        //partloc.add(partloc2);
        //insert partloc;
        
        partloc1.Address_Line1__c=null;
        Update partloc1;
        partloc1.Address_Line2__c=null;
        Update partloc1;
        partloc1.Address_Line3__c=null;
        Update partloc1; 
    }
}