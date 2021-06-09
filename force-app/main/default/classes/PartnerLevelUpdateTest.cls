@isTest
private class PartnerLevelUpdateTest{
 @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

    static TestMethod void partnerLevelTest(){
        
        Test.startTest();
        List<Account> acc11 = new List<Account>();
        List<Account> acc22 = new List<Account>();
        
        RecordType rec =[Select r.Id From RecordType r where r.SobjectType='Account' and r.name='Partner'];
        
        
        Account acc1 = new Account(RecordTypeId =rec.id,Name = 'Sample1',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active',Partner_Status_Mobility__c='Active');
        Account acc2 = new Account(RecordTypeId =rec.id,Name = 'Sample2',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Inactive',PartnerStatus_Radio__c='Inactive',PartnerStatus_WNS__c='Inactive',Partner_Status_Mobility__c='Inactive');
        Account acc3 = new Account(RecordTypeId =rec.id,Name = 'Sample3',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');
        Account acc4 = new Account(RecordTypeId =rec.id,Name = 'Sample4',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');

        Account acc5 = new Account(RecordTypeId =rec.id,Name = 'Sample5',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');
        Account acc6 = new Account(RecordTypeId =rec.id,Name = 'Sample6',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');
        Account acc7 = new Account(RecordTypeId =rec.id,Name = 'Sample7',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');
        Account acc8 = new Account(RecordTypeId =rec.id,Name = 'Sample8',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');
        
        Account acc9 = new Account(RecordTypeId =rec.id,Name = 'Sample9',Certificate_Status__c='Compliant',Partner_Track__c='Distributor');
        Account acc10 = new Account(RecordTypeId =rec.id,Name = 'Sample10',Certificate_Status__c='Compliant',Partner_Track__c='Distributor');
        Account acc12 = new Account(RecordTypeId =rec.id,Name = 'Sample12',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',Main_Phone_Number__c='2650934',Fax_Number__c='3342329');
        Account acc14 = new Account(RecordTypeId =rec.id,Name = 'Sample14',Certificate_Status__c='Compliant',Partner_Track__c='Distributor');
        
        Account acc15 = new Account(RecordTypeId =rec.id,Name = 'Sample15',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',Main_Phone_Number__c='9848087575',Fax_Number__c ='1251210');        
        Account acc16 = new Account(RecordTypeId = rec.id,Name = 'Sample1',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');
        Account acc17 = new Account(RecordTypeId = rec.id,Name = 'Sample17',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');
        Account acc18 = new Account(RecordTypeId = rec.id,Name = 'Sample18',Certificate_Status__c='Compliant',Partner_Track__c='Distributor',PartnerStatus_SCADA__c='Active',PartnerStatus_Radio__c='Active',PartnerStatus_WNS__c='Active');
                        
        acc11.add(acc1);      
        acc11.add(acc2);
        acc11.add(acc3);
        acc11.add(acc4);        
        acc11.add(acc5);
        acc11.add(acc6);
        acc11.add(acc7);
        acc11.add(acc8);
        acc11.add(acc9);
        acc11.add(acc10);
        acc11.add(acc12);
        acc11.add(acc14);
        acc11.add(acc15);
        acc11.add(acc16);
        acc11.add(acc17);
        acc11.add(acc18);
                
        insert acc11;
               

        acc1.Certificate_Status__c = 'Non-Compliant';
        acc1.Partner_Track__c='Provider';
        acc22.add(acc1);
                                   
        acc12.Partner_Track__c = 'MSP Premier';
        acc22.add(acc12);
        
        acc14.Certificate_Status__c = 'Non-Compliant';
        acc22.add(acc14);
        
        acc15.Main_Phone_Number__c='9052350934';
        acc15.Fax_Number__c='1001253';
        acc22.add(acc15);
               
        update acc22;
        
        acc22.clear();
               
        acc15.Certificate_Status__c = 'Non-Compliant';
        acc14.Partner_Track__c = 'Reseller';
        acc17.Certificate_Status__c='';
  
        acc22.add(acc17);
        acc22.add(acc15);
        acc22.add(acc14);

        update acc22;
        
               
        List<Partner_Type__c> pType11 = new List<Partner_Type__c>();
        List<Partner_Type__c> ptype22 = new List<Partner_Type__c>();
              
        Partner_Type__c pType1 = new Partner_Type__c(Program__c = 'Mobility',Account__c = acc1.Id,Partner_Level__c = 'Premier Super Partner',Status__c='Active',Compliance_Status__c='Compliant',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType2 = new Partner_Type__c(Program__c = 'RADIO',Account__c = acc1.Id,Partner_Level__c = 'Premier Super Partner',Status__c='InActive',Compliance_Status__c='Compliant',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType3 = new Partner_Type__c(Program__c = 'WNS',Account__c = acc1.Id,Partner_Level__c = 'Premier Super Partner',Status__c='InActive',Support_Services__c=true,Advanced_Services__c=true);        
        Partner_Type__c pType4 = new Partner_Type__c(Program__c = 'SCADA',Account__c = acc1.Id,Partner_Level__c = 'Premier Super Partner',Status__c='InActive',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType5 = new Partner_Type__c(Program__c = 'Mobility',Account__c = acc2.Id,Partner_Level__c = 'Alliance Partner',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType6 = new Partner_Type__c(Program__c = 'WNS',Account__c = acc2.Id,Partner_Level__c = 'Premium',Status__c='Active',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType7 = new Partner_Type__c(Program__c = 'Radio',Account__c = acc2.Id, Status__c='Active',Compliance_Status__c='Compliant',Partner_Level__c = 'Gold',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType8 = new Partner_Type__c(Program__c = 'Scada',Account__c = acc2.Id, Status__c='Active',Compliance_Status__c='Compliant',Partner_Level__c = 'Business Partner',Partner_Track__c='Distributor',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType9 = new Partner_Type__c(Program__c = 'Mobility',Account__c = acc9.Id, Status__c='Active',Compliance_Status__c='Compliant', Partner_Track__c='Distributor',Partner_Level__c = 'Premier Solution Partner',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType10 = new Partner_Type__c(Program__c = 'WNS',Account__c = acc9.Id, Status__c='Active',Compliance_Status__c='Compliant', Partner_Track__c='Distributor',Partner_Level__c = 'Alliance Partner',Support_Services__c=true,Advanced_Services__c=true);
        Partner_Type__c pType12 = new Partner_Type__c(Program__c = 'Radio',Account__c = acc9.Id, Status__c='Active',Compliance_Status__c='Compliant', Partner_Track__c='Distributor',Partner_Level__c = 'Bronze',Advanced_Services__c=true,Support_Services__c=true);
        Partner_Type__c pType18 = new Partner_Type__c(Program__c = 'Scada',Account__c = acc9.Id,Partner_Level__c = 'Premier Super Partner',Status__c='InActive',Compliance_Status__c='Compliant',Support_Services__c=true,Advanced_Services__c=true);
        
        system.debug('#####' + ptype8);
        pType11.add(pType1);
        pType11.add(pType2);
        pType11.add(pType3);
        
        pType11.add(pType4);
        pType11.add(pType5);
        pType11.add(pType6);
        pType11.add(pType7);
        pType11.add(pType8);
        pType11.add(pType9);
        pType11.add(pType10);
        pType11.add(pType12);
        pType11.add(pType18);
        
        insert pType11;
        
        pType1.Status__c ='Inactive';
        ptype22.add(pType1);
        
        pType2.Status__c='Active'; 
        pType2.Support_Services__c=false;
        pType2.Advanced_Services__c=false;
        ptype22.add(pType2); 
        
        pType3.Support_Services__c=false;
        pType3.Advanced_Services__c=false;
        ptype22.add(pType3); 
        
        Update ptype22;
               

        List<Partner_Location__c> partLoc = new List<Partner_Location__c>();
        // Commenting temporarily for deploying address type mult select piclist conversion
        Partner_Location__c part1 = new Partner_Location__c(Account__c=acc12.id, Country1__c='India',Address_Type__c='HQ',Phone__c='43253');
        //Partner_Location__c part1 = new Partner_Location__c(Account__c=acc12.id, Country1__c='India',Phone__c='43253');
        partLoc.add(part1);
        insert partLoc;  
  
        acc22.clear();
        acc12.Main_Phone_Number__c='2350934';
        acc12.Fax_Number__c='312329' ;
        acc22.add(acc12); 
  
        update acc22;
  
        //Product_Offered__c prd1 = new Product_Offered__c(Account__c=acc1.Id,Product_Offering__c='Support Services');
        //insert prd1;
  
        //PartnerLevelUpdate.UpdateLevel(acc11);
        //PartnerLevelUpdate.UpdatePartnerLevel(pType22);
        
   Test.stopTest();      
        
    }
}