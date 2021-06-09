@istest

 public class AddPartnerExecutiveSharing_test
 {
 
   @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }
  
   public static testMethod void test_Add()
   {   
   Map<String,ChannelProgram> programMap = TestDataSetUpUtils.insertChannelProgram();
   Map<String,String> programLevelMap = TestDataSetUpUtils.insertChannelProgramLevel(programMap.values());      
        Account acnt;
        Contact con;
      
         RecordType rect=[Select r.Id From RecordType r where r.SobjectType='Account' and r.name='Partner'];
      
      //user user1 = [select Id from User where ContactId!= NULL and isActive=true LIMIT 1]; 
      
       User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
     
      System.runAs(thisUser)
      {  
       List<UserRole> useRoles = new List<UserRole>();      
      UserRole uRole = new UserRole(name='test_account Partner Manager');
      UserRole uRole1 = new UserRole(name='test_account Partner Executive');
      useRoles.add(uRole);
      useRoles.add(uRole1);
      insert useRoles;
      
       acnt = new Account(name='test_account');
       acnt.Role_Created__c=false;
       acnt.Type='Partner';
       acnt.RecordTypeId=rect.Id;
       //acnt.ownerId=user1.Id;
       insert acnt;
      
       Account testAcc = [Select id,Name from Account where id =: acnt.Id];

      testAcc.IsPartner = true;
      testAcc.Role_Created__c=true;
      //testAcc.name='test_Accnt1';
      update testAcc;
        
    }     
       
      
   }
   
   static testMethod void delete_Partner(){
   Id partRecordtypeId = GlobalUtility.recordTypeId('Account','Partner');
   MPP_Class_HLPR_AddGroupsToUser_Advanced.accountTriggerIsRunning = false;
       Account acnt = new Account(name='test_account');
       acnt.Role_Created__c=false;
       acnt.Type='Partner';
       acnt.RecordTypeId= partRecordtypeId ;
       //acnt.ownerId=user1.Id;
       insert acnt;
      
      delete acnt;
   }
     
   static testMethod void AccountShateTest()
    {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String UserName = orgId + dateString + randomInt;
        System.debug('Unique name' +UserName);
        User owner = [select Id from User where isActive=true and Isportalenabled=false limit 1];
        RecordType rt = [select Id from RecordType where SObjectType='Account' and DeveloperName='Partner' limit 1];//added by chandu
        RecordType rtop = [select Id from RecordType where SObjectType='Opportunity' and DeveloperName='Government_Standard' limit 1];
        //Accounts for Enterprise-Mobility Track, Mobility only and WNS only
        Account[] Acts = new Account[3];
        Acts[0] = new Account(Name='Test Systems Inc.',ownerId=owner.Id, RecordTypeId=rt.Id, Level__c='Primary Distributor',WNS_Track__c= true,Mobility_Track__c=true, Status__c='Active');
        Acts[1] = new Account(Name='XXXXXXXX',ownerId=owner.Id, RecordTypeId=rt.Id, Level__c='Authorized Reseller',WNS_Track__c= false,Mobility_Track__c=true, Status__c='Active');
        Acts[2] = new Account(Name='Test Systems Inc.',ownerId=owner.Id, RecordTypeId=rt.Id, Level__c='Authorized Reseller',WNS_Track__c= true,Mobility_Track__c=false, Status__c='Active');
        insert Acts;

        //Contacts for Enterprise-Mobility Track, Mobility only and WNS only
        Contact[] Conts = new Contact[3];
        Conts[0] = new Contact(FirstName='First', LastName='Last', email='last@company.com', accountId=Acts[0].Id, ownerId=owner.Id,RecordTypeId='01280000000LsIz' );
        Conts[1] = new Contact(FirstName='EMEAPARTNER', LastName='TEST', email='EMEAPARTNER@company.com', accountId=Acts[1].Id, ownerId=owner.Id,RecordTypeId='01280000000LsIz' );
        Conts[2] = new Contact(FirstName='APACPARTNER', LastName='TEST', email='APACPARTNER@company.com', accountId=Acts[2].Id, ownerId=owner.Id,RecordTypeId='01280000000LsIz' );
        insert Conts;

        //To get Profile ids
        String NA_PRMprofile;
        String EMEA_PRMprofile;
        String APAC_PRMprofile;
        String EMEA_CAprofile;
        Profile[] Prfles = [select Id,Name from Profile where Name in ('EMS Partner Profile NAMR','EMS Partner Profile APAC','EMEA Motorola Government Systems User') ];
        for(integer i=0;i<Prfles.size();i++){
            if(Prfles[i].Name == 'EMS Partner Profile NAMR'){
                NA_PRMprofile=Prfles[i].id;
            }
            else if(Prfles[i].Name == 'EMS Partner Profile APAC'){
                APAC_PRMprofile=Prfles[i].id;
            }
            else if(Prfles[i].Name == 'EMEA Motorola Government Systems User'){
                EMEA_CAprofile=Prfles[i].id;
            }
        }

        //User[] PUsers = new User[];
        User usr = new User(ContactId=Conts[0].Id, FirstName='First', LastName='Last', alias='abcd', email='Test1@Test.com', username=UserName+'@company.com', communityNickname='testGuy', profileId=NA_PRMprofile, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', Theater__c='NAMR'  ,Primary_Business_Group__c='Enterprise');
        //PUsers[1] = new User(FirstName='TEST', LastName='ChannelAdmin', alias='abcd', Core_ID__c='Test',email='Test3@Test.com', username=UserName+'@company1.com', communityNickname='testGuy2', profileId=EMEA_CAprofile, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Theater__c='EMEA',Primary_Business_Group__c='Enterprise');
       // PUsers[2] = new User(ContactId=Conts[2].Id, FirstName='Mobility', LastName='Partner', alias='abcd', email='Test4@Test.com', username=UserName+'@company12.com', communityNickname='testGuy3', profileId=APAC_PRMprofile, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',Theater__c='APAC',Primary_Business_Group__c='Enterprise');
        insert usr;
        //System.debug('Unique name' +UserName);
        //System.debug('User1'+PUsers[0]);
        //System.debug('User2'+PUsers[1]);
        //System.debug('User3'+PUsers[2]);
        //System.debug('User4'+PUsers[3]);
        

        AccountShare[] actsShare = new AccountShare[1];
        actsShare[0] = new AccountShare(UserOrGroupId=usr.Id, AccountId=Acts[0].Id, AccountAccessLevel='read', opportunityAccessLevel='read', contactAccessLevel='read');
        insert(actsShare);

        AccountTeamMember[] actTeamMem = new AccountTeamMember[1];
        actTeamMem[0] = new AccountTeamMember(UserId=owner.id, AccountId=Acts[0].Id, TeammemberRole='CAM ISV');
        insert(actTeamMem);
    }
    
    static testmethod void testaprd(){
    AccountTriggerHelper accntHelper = new AccountTriggerHelper();
    accntHelper.populateAPRD('EMEA',Date.newInstance(2010, 07, 15));    
    AccountTriggerHelper accntHelper1 = new AccountTriggerHelper();
    accntHelper1.populateAPRD('APAC',Date.newInstance(2010, 07, 15));
    }
 }