@isTest
private class AssociateSDSGraphDataWithAccountTest{
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

    static testMethod void AssociateSDSGraphDataWithAccountTest(){
       List<Partner_Identifier__c> partnerIdentifierLst = new List<Partner_Identifier__c>();
       List<Account> accountLst = new List<Account>();
       List<EDW_SDS_Extract__c> edwSdsLst = new List<EDW_SDS_Extract__c>();
       List<SDS_Graphs_Data__c> sdsGraphDataLst = new List<SDS_Graphs_Data__c>();
       
        SDS_Graph_Data_Mapping__c  SDSMap1=new SDS_Graph_Data_Mapping__c ();
        SDSMap1.Region__c='NAMR';
        SDSMap1.EDW_Api_Name__c='Vendor_Number__c';
        SDSMap1.File_Name__c='SI Spend';
        SDSMap1.Is_Active__c=true;
        SDSMap1.Field_Api_Name__c='Vendor_Number__c';
        SDSMap1.Col_Header_Name__c='Vendor Number';
        SDSMap1.name='6';
        SDSMap1.Data_Type__c='Text';
        insert SDSMap1;
        
        SDS_Graph_Data_Mapping__c  SDSMap2=new SDS_Graph_Data_Mapping__c ();
        SDSMap2.Region__c='NAMR';
        SDSMap2.EDW_Api_Name__c='SI_Spend_Refresh_Date__c';
        SDSMap2.File_Name__c='SI Spend';
        SDSMap2.Is_Active__c=true;
        SDSMap2.Field_Api_Name__c='Refresh_Date__c';
        SDSMap2.Col_Header_Name__c='Refresh Date';
        SDSMap2.name='9';
        SDSMap2.Data_Type__c='Date';
        insert SDSMap2;
        
        SDS_Graph_Data_Mapping__c  SDSMap3=new SDS_Graph_Data_Mapping__c ();
        SDSMap3.Region__c='NAMR';
        SDSMap3.EDW_Api_Name__c='Year__c';
        SDSMap3.File_Name__c='SI Spend';
        SDSMap3.Is_Active__c=true;
        SDSMap3.Field_Api_Name__c='Year__c';
        SDSMap3.Col_Header_Name__c='Year';
        SDSMap3.name='8';
        SDSMap3.Data_Type__c='Text';
        insert SDSMap3;
        
        SDS_Graph_Data_Mapping__c  SDSMap4=new SDS_Graph_Data_Mapping__c ();
        SDSMap4.Region__c='NAMR';
        SDSMap4.EDW_Api_Name__c='GRAND_Total__c';
        SDSMap4.File_Name__c='SI Spend';
        SDSMap4.Is_Active__c=true;
        SDSMap4.Field_Api_Name__c='Total__c';
        SDSMap4.Col_Header_Name__c='Grand Total';
        SDSMap4.name='7';
        SDSMap4.Data_Type__c='Currency';
        insert SDSMap4;
        
       RecordType theRecordType = [Select Id from RecordType where Name='Partner' and SobjectType='Account' limit 1];
       Account accTest = new Account(name = 'Test1', type='Partner', RecordTypeId=theRecordType.Id, AccountNumber='123456');
       insert accTest;
       
       Partner_Identifier__c  PI1 = new Partner_Identifier__c();
       PI1.ID_Type__c = 'Motorola Enterprise Number';
       PI1.ID_Number__c = '1122334400';
       PI1.Account__c = accTest.Id;
       insert PI1;
       
       Partner_Identifier__c  PI2 = new Partner_Identifier__c();
       PI2.ID_Type__c = 'Vendor Number';
       PI2.ID_Number__c = '112200';
       PI2.Account__c = accTest.Id;
       insert PI2;

       Partner_Identifier__c  PI3 = new Partner_Identifier__c();
       PI3.ID_Type__c = 'Motorola Enterprise Number';
       PI3.ID_Number__c = '1120034457';
       PI3.Account__c = accTest.Id;
       insert PI3;
       
       Partner_Identifier__c  PI4 = new Partner_Identifier__c();
       PI4.ID_Type__c = 'Vendor Number';
       PI4.ID_Number__c = '112235';
       PI4.Account__c = accTest.Id;
       insert PI4;
       
       EDW_SDS_Extract__c ESE1 = new EDW_SDS_Extract__c();
       ESE1.Vendor_Number__c = '112233';
       ESE1.GRAND_Total__c = 5000;
       ESE1.Year__c = string.valueof(system.today().year());
       ESE1.SI_Spend_Refresh_Date__c = system.today();
       ESE1.File_Name__c = 'SI Spend';
       ESE1.Account__c = accTest.Id;
       ESE1.EDW_Region__c = 'NAMR';
       insert ESE1;
       
       EDW_SDS_Extract__c ESE3 = new EDW_SDS_Extract__c();
       ESE3.Vendor_Number__c = '112233';
       ESE3.GRAND_Total__c = 5000;
       ESE3.Year__c = string.valueof(system.today().year());
       ESE3.SI_Spend_Refresh_Date__c = system.today();
       ESE3.File_Name__c = 'MR Federal Detail';
       ESE3.Account__c = accTest.Id;
       ESE3.EDW_Region__c = 'NAMR';
       insert ESE3;
       
       SDS_Graphs_Data__c SGD1 = new SDS_Graphs_Data__c();
       SGD1.Account__c = accTest.Id;
       SGD1.Motorola_Enterprise_ID__c = '1120034457';
       SGD1.Vendor_Number__c = '112235';
       SGD1.File_Name__c = 'SI Spend';
       SGD1.SDS_Region__c= 'NAMR';
       SGD1.Refresh_Date__c = system.today();
       SGD1.Apex_Job_ID__c = '707S000000CIJdC';
       SGD1.Total__c = 5000;
       //SGD1.Year__c = string.valueof(system.today().year());
       SGD1.Year__c = '2013';
       insert SGD1;
       delete SGD1;

       
       
       
       Account accTest2 = new Account(name = 'Test1', type='Partner', RecordTypeId=theRecordType.Id, AccountNumber='123457');
       insert accTest2;
       
       Partner_Identifier__c  PI5 = new Partner_Identifier__c();
       PI5.ID_Type__c = 'Motorola Enterprise Number';
       PI5.ID_Number__c = '1102334465';
       PI5.Account__c = accTest2.Id;
       insert PI5;
       
       Partner_Identifier__c  PI6 = new Partner_Identifier__c();
       PI6.ID_Type__c = 'Vendor Number';
       PI6.ID_Number__c = '102107';
       PI6.Account__c = accTest2.Id;
       insert PI6;

       Partner_Identifier__c  PI7 = new Partner_Identifier__c();
       PI7.ID_Type__c = 'Motorola Enterprise Number';
       PI7.ID_Number__c = '1122034467';
       PI7.Account__c = accTest2.Id;
       insert PI7;
       
       Partner_Identifier__c  PI8 = new Partner_Identifier__c();
       PI8.ID_Type__c = 'Vendor Number';
       PI8.ID_Number__c = '112019';
       PI8.Account__c = accTest2.Id;
       insert PI8;
       
       EDW_SDS_Extract__c ESE2 = new EDW_SDS_Extract__c();
       ESE2.Vendor_Number__c = '624368';
       ESE2.GRAND_Total__c = 6000;
       ESE2.Year__c = string.valueof(system.today().year()+1);
       ESE2.SI_Spend_Refresh_Date__c = system.today();
       ESE2.File_Name__c = 'SI Spend';
       ESE2.Account__c = accTest2.Id;
       ESE2.EDW_Region__c = 'NAMR';
       insert ESE2;
       
       SDS_Graphs_Data__c SGD2 = new SDS_Graphs_Data__c();
       SGD2.Account__c = accTest2.Id;
       SGD2.Vendor_Number__c = '112019';
       SGD2.File_Name__c = 'SI Spend';
       SGD2.SDS_Region__c= 'NAMR';
       SGD2.Refresh_Date__c = system.today();
       SGD2.Total__c = 6000;
       //SGD2.Year__c = string.valueof(system.today().year());
       SGD2.Year__c='2011';
       insert SGD2;

       
       SGD2.Year__c = string.valueof(system.today().year()+1);
       update SGD2;

       
       Account accTest3 = new Account(name = 'Test1', type='Partner', RecordTypeId=theRecordType.Id, AccountNumber='123457');
       insert accTest3;
       
       Partner_Identifier__c  PI9 = new Partner_Identifier__c();
       PI9.ID_Type__c = 'Motorola Enterprise Number';
       PI9.ID_Number__c = '1122330475';
       PI9.Account__c = accTest3.Id;
       insert PI9;
       
       Partner_Identifier__c  PI10 = new Partner_Identifier__c();
       PI10.ID_Type__c = 'Vendor Number';
       PI10.ID_Number__c = '112003';
       PI10.Account__c = accTest3.Id;
       insert PI10;

       Partner_Identifier__c  PI11 = new Partner_Identifier__c();
       PI11.ID_Type__c = 'Motorola Enterprise Number';
       PI11.ID_Number__c = '1022330477';
       PI11.Account__c = accTest3.Id;
       insert PI11;
       
       Partner_Identifier__c  PI12 = new Partner_Identifier__c();
       PI12.ID_Type__c = 'Vendor Number';
       PI12.ID_Number__c = '012055';
       PI12.Account__c = accTest3.Id;
       insert PI12;
       
       EDW_SDS_Extract__c ESE4 = new EDW_SDS_Extract__c();
       ESE4.Vendor_Number__c = '604030';
       ESE4.GRAND_Total__c = 6000;
       ESE4.Year__c = string.valueof(system.today().year()+1);
       ESE4.SI_Spend_Refresh_Date__c = system.today();
       ESE4.File_Name__c = 'SI Spend';
       ESE4.Account__c = accTest3.Id;
       ESE4.EDW_Region__c = 'NAMR';
       insert ESE4;
       
       SDS_Graphs_Data__c SGD3 = new SDS_Graphs_Data__c();
       SGD3.Account__c = accTest3.Id;
       SGD3.Vendor_Number__c = '012055';
       SGD3.File_Name__c = 'SI Spend';
       SGD3.SDS_Region__c= 'NAMR';
       SGD3.Refresh_Date__c = system.today();
       SGD3.Total__c = 6000;
       //SGD3.Year__c = string.valueof(system.today().year());
       SGD3.Year__c='2012';
       insert SGD3;

       
    }
}