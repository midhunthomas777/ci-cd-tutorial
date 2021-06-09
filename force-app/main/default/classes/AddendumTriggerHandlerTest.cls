@isTest
public class AddendumTriggerHandlerTest {
    @isTest private static void updateAddendumToApplicationTest(){
        TestDataSetUpUtils.insertCustomSettings();
        //Empower_Application__c empower=TestDataSetUpUtils.createPartnerEmpower();
        Empower_Application__c empower = GlobalUtility_Test.createPartnerEmpower();
        Id changeReqAddendum = GlobalUtility.getRecordTypeIdByDeveloperName('Addendum__c', 'Change_Relationship');
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        
        Account partnerAccount=TestDataSetUpUtils.createPartnerAccount(PartnrRecordTypeId);
        Addendum__c addendum=new Addendum__c(Application__c=empower.Id,Status__c='Accepted',Account__c=partnerAccount.Id,
                                             Partner_Region__c='NA',Partner_Community_Type__c='Value Added Reseller',Technology_Segment__c='Mission Critical Radio Systems',Technology_Sub_Segment__c='FirstNet');
        insert addendum;
        Partner_Type__c pgminfo = new Partner_Type__c();
        pgminfo.Account__c = addendum.Account__c;
        pgminfo.Program__c = 'RADIO';
        pgminfo.Status__c = 'Active'; 
        pgminfo.Purchasing_Method__c='Tier 16';
        pgminfo.US_Federal__c=True;
        pgminfo.RHO__c=True;
        Test.startTest();
        
        insert pgminfo;
        
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c =addendum.Account__c;
        techspec.Partner_Program__c = pgminfo.Id;
        techspec.Technology_Specialization__c = 'Authorized';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c= 'Value Added Reseller';
        insert techspec;
        
        
        
        
        addendum.Partner_Community_Type__c='Value Added Distributor';
        addendum.Status__c='Signed';
        addendum.Application__c=null;
        addendum.RecordTypeId = changeReqAddendum;
        addendum.Technology_Segment__c='Consumer Radio';
        addendum.Technology_Sub_Segment__c='CallWorks';
        addendum.Authorized_to_Sign_Legal_Agreement__c='Yes';
        update addendum;
        
        
        empower.Company_Signature_Authority_Email__c= 'test@moto.com';
        empower.Company_Signature_Authority_First_Name__c= 'test';
        empower.Company_Signature_Authority_Last_Name__c= 'testmoto';
        update empower;
        Addendum__c addendumAPAC=new Addendum__c(Application__c=empower.Id,Status__c='Accepted',Account__c=partnerAccount.Id,
                                                 Partner_Region__c='APAC',Partner_Community_Type__c='Value Added Reseller',Technology_Segment__c='Business Radio',Technology_Sub_Segment__c=NULL);
        
        insert addendumAPAC;
        Test.stopTest();
        
        addendumAPAC.Status__c='Signed';
        addendumAPAC.Authorized_to_Sign_Legal_Agreement__c = 'No';
        update addendumAPAC;
        addendumAPAC.Application__c=null;
        update addendumAPAC;
        
        addendumAPAC.Application__c=empower.Id;
        //addendumAPAC.Company_Signature_Authority_Email__c  ='test@moto.com';
        addendumAPAC.Company_Signature_Authority_First_Name__c='test';
        addendumAPAC.Company_Signature_Authority_Last_Name__c='test';
        update addendumAPAC;
        
        addendumAPAC.Status__c='Denied';
        update addendumAPAC;
        delete addendum;
        delete addendumAPAC;
        undelete addendum;
        
    }
}