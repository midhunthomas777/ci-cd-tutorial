/**************************************************************************************
Apex Class Name:  PartnershipRecordCtrlTest
Version   : 1.0  
Created Date   : 26 Apr 2019 
Function   : Test Class for PartnershipRecordCtrl
Modification Log: 
-----------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Suveen         26 Apr 2019               Original Version
*************************************************************************************/
@isTest
public class PartnershipRecordCtrlTest {
    @testSetup 
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    private static testmethod void DownloadFile2(){
        String responseBody = '[{"P_STATUS_MSG":null,"P_STATUS_FLAG":"Success"}]';
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' AND r.DeveloperName= 'Partner'];
        //creating a partner Account
        Account partAcc= TestDataSetUpUtils.createPartnerAccount(rect.Id);
        Account acc = [SELECT Partner_Membership_Id__c FROM Account WHERE Id=:partAcc.Id LIMIT 1];
        //creating a Partner_Report_File
        Partnership_Record__c   NewFile = new Partnership_Record__c();
        NewFile.Name = 'TestFile2';
        NewFile.Partner_Empower_ID__c = acc.Partner_Membership_Id__c;
        NewFile.File_Id__c = '15W9puJ8o8qgikAkHMaUYCK6WBAh3yLMN4-SrZIEa6I';
        NewFile.File_Type__c = 'Certification Report';
        NewFile.Mime_Type__c = 'Microsoft Excel';
        insert NewFile;
        Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody));
        test.startTest();
        PartnershipRecordGoogleDriveCtrl.downloadFile(NewFile.Id);
        test.stopTest();
    }
    
    private static testmethod void DownloadFile3(){
        String responseBody = '[{"P_STATUS_MSG":null,"P_STATUS_FLAG":"Success"}]';
        RecordType rect=[SELECT r.Id FROM RecordType r WHERE r.SobjectType='Account' AND r.DeveloperName= 'Partner'];
        //creating a partner Account
        Account partAcc= TestDataSetUpUtils.createPartnerAccount(rect.Id);
        Account acc = [SELECT Partner_Membership_Id__c FROM Account WHERE Id=:partAcc.Id LIMIT 1];
        //creating a Partner_Report_File
        Partnership_Record__c   NewFile = new Partnership_Record__c();
        NewFile.Name = 'TestFile3';
        NewFile.Partner_Empower_ID__c = acc.Partner_Membership_Id__c;
        NewFile.File_Id__c = '15W9puJ8o8qgikAkHMaUYCK6WBA3yLMN4-SrZIEa6I';
        NewFile.File_Type__c = 'Revenue Report';
        NewFile.Mime_Type__c = 'PDF';
        insert NewFile;
        Test.setMock(HttpCalloutMock.class, new EInvoiceControllerMockTest(200,responseBody)); 
        test.startTest();
        PartnershipRecordGoogleDriveCtrl.downloadFile(NewFile.Id);
        test.stopTest();
    }
}