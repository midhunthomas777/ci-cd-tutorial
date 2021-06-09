/************************************************************************************************* 
* File Name  : ChannelProgramMemberTriggerHandler_Test
* Description: Test class for ChannelProgramMemberTriggerHandler class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 14-Aug-2018     Satish Maddhi(TCS)	  			Initial development
*
*************************************************************************************************/
@isTest
public class ChannelProgramMemberTriggerHandler_Test {
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
    }
    
    static testMethod void Test_ChannelProgramMembersTrigger() {
        Id PartnerId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account Acc2 = new Account(Name='TestVAccount12',RecordTypeId=PartnerId,Partner_Region__c='NAMR',billingcountrycode ='US',BillingPostalCode='1234');
        Insert Acc2;
        Contact partcon = new Contact(FirstName='NAMR', LastName='Partner', email='NAMRtes2323@partner.com', accountId=Acc2.Id,RecordTypeId='01280000000LsIz');
        insert partcon;
        
        //Profile[] partnerPrf = [select Id,Name from Profile where Name in ('EMS Partner Profile NAMR','EMS Partner Profile LACR','EMS Partner Profile APAC','EMS Partner Profile EMEA')];
        Id namePartnerProfileId = [select Id,Name from Profile where Name in ('EMS Partner Profile NAMR')].Id;
        User partnerUser = new User(ContactId=partcon.Id, FirstName='NAMR', LastName='Partner', alias='abcd', email='NAMR12@partner.com', username='DRNAMR@partner.com', communityNickname='testGuy', profileId =namePartnerProfileId, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Theater__c='NAMR',Primary_Business_Group__c='Government'); 
        insert partnerUser;
        
        ChannelProgram chp = new ChannelProgram();
        chp.Category = 'MR';
        chp.Is_Federal__c = false;
        chp.Name = 'NA MR Program1';
        chp.Partner_Community_Types__c = 'Value Added Reseller';
        chp.Partner_Region__c = 'NAMR';
        insert chp;
        
        ChannelProgramLevel chpl = new ChannelProgramLevel();
        chpl.ProgramId = chp.id;
        chpl.Name = 'Gold';
        insert chpl;
        ChannelProgramLevel chpl2 = new ChannelProgramLevel();
        chpl2.ProgramId = chp.id;
        chpl2.Name = 'Platinum';
        insert chpl2;        
        
        ChannelProgramMember chpm = new ChannelProgramMember();
        chpm.LevelId = chpl.id;
        chpm.PartnerId = Acc2.id;
        chpm.ProgramId = chp.id;
        insert chpm;
        chpm.LevelId = chpl2.id;
        update chpm;
        delete chpm;
    }
}