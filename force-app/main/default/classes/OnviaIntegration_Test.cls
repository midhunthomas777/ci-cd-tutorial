@IsTest
public class OnviaIntegration_Test{
    
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

    public static testMethod void OnviaMethod1(){
        LM_GeoCodeMaxLimit__c objGeoCodeMaxLimit = new LM_GeoCodeMaxLimit__c(Name='GeoCode Limit',LM_limit__c=5);
        insert objGeoCodeMaxLimit;
        
        Campaign C1 =new Campaign(name='Onvia_Pursuits_Term_Contracts');
        Campaign C2 =new Campaign(name='Onvia_Pursuits_Bid');
        Campaign C3 =new Campaign(name='Onvia_Pursuits_Project_Preview');
        List<Campaign> InsertLst=new List<Campaign>();
        InsertLst.add(C1);
        InsertLst.add(C2);
        InsertLst.add(C3);
        
        Insert InsertLst;
        
        Lead l = new Lead(Region__c='NA',Company= 'Test' , FirstName= 'FIsrt Name',LastName = 'Last',Country = 'United States', 
                          Email = 'test.testing@tes.com',State = 'New York',
                          City = 'Amar',
                          Track__c = 'Radio',
                          
                          Phone = '9876543210',
                          Budget_Value__c = 234,
                          
                          LeadSource = 'Onvia Tool',
                          CurrencyIsoCode='USD',
                          Campaign_Code__c = 'Onvia_Pursuits_Project_Preview',
                          postalcode='32423423',
                          Status = 'Inquiry'
                         );
        Insert l;    
    }
    
}