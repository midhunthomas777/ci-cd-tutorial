/**
 * @author		Paweł Woźniak
 * @created		2020-07-24
 * @updated		2020-09-21
 * @description	Data creation for tests for DTSFPART project
 */
@isTest
public without sharing class DTSFPART_TestDataSetUpUtils {

    public static final String PROFILE_ADMIN = 'System Administrator';
    public static final String PROFILE_PARTNER_ADMIN = 'EMS Partner Administrator Profile NAMR';
    public static final String ROLE_ADMIN = 'Worldwide Sales';
    public static final String USERNAME_ADMIN = 'ADMN21@motorolasolutions.com.unit.test';
    public static final String USERNAME_PARTNER = 'PATR21@motorolasolutions.com.unit.test';
    
    public static User createAdminUser() {
        String userId = USERNAME_ADMIN.substring(0,6);
        User adminUser = new User(
            Alias=userId,
            Email=USERNAME_ADMIN,
            Username=USERNAME_ADMIN,
            System_Integration__c=true, //enforced by user validation rule Nickname_CoreID_FedID_EmployeeNumber
            CommunityNickName=userId,
            Core_ID__c=userId,
            FederationIdentifier=userId,
            EmployeeNumber=userId,
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US'
        );
        UserRole role = [
            SELECT Id 
            FROM UserRole 
            WHERE Name = :ROLE_ADMIN
            LIMIT 1
        ];
        adminUser.UserRoleId = role.Id;
        Profile p = [
            SELECT Id
            FROM Profile 
            WHERE Name = :PROFILE_ADMIN
            LIMIT 1
        ];
        adminUser.ProfileId = p.Id;
        insert adminUser;
        return adminUser;
    }

    public static Contact createContact(String recordTypeId, Account acc, String persona, Boolean makeInsert) {
        Contact contact = new Contact(AccountId = acc.Id,
                RecordtypeId = recordTypeId,
                FirstName = 'Test',
                LastName = 'Partner Contact',
                Primary_Contact_Type__c = 'Sales',
                Contact_Type__c = 'sales',
                Email = 'test@test.com',
                Persona__c = persona
        );
        if (makeInsert) {
            insert contact;
        }
        return contact;
    }

    public static Contact createPartnerContact(Account partnerAcc, Boolean makeInsert) {
        Id PartnrConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Contact partnerContact = createContact(PartnrConRecordTypeId, partnerAcc, 'OwnerExecutive', false);

        if (makeInsert) {
            insert partnerContact;
        }
        return partnerContact;
    }

    public static User createUser(Contact cnt, String profile, Boolean makeInsert){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User user;

        // Run as current user to to avoid Mixed DML error
        System.runAs (thisUser) {

            Set<String> customerUserTypes = new Set<String> {profile};
            Profile p = [SELECT Id, name FROM Profile WHERE UserType in :customerUserTypes limit 1];
            user = new User(profileId = p.id, contactId = cnt.id, username = 'test123asdfresdf@noemail.com', email = 'tester@noemail.com.niran',
                    emailencodingkey = 'UTF-8', localesidkey = 'en_US', languagelocalekey = 'en_US',
                    timezonesidkey = 'America/Los_Angeles', alias = 'nuser', lastname = 'lastname', isActive = true/*,
                    UserRoleId = roleId*/);
            if (makeInsert == true) insert user;
        }
        return user;
    }

    public static User createPartnerUser(Contact cnt) {
        return createPartnerUser(cnt, true);
    }

    public static User createPartnerUser(Contact cnt, boolean makeInsert) {
        return createUser(cnt, 'PowerPartner', makeInsert);
    }

    public static User createPortalUserWithoutRole(Contact cont, Boolean makeInsert) {

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User newUser;
        System.runAs (thisUser) {
            Set<String> customerUserTypes = new Set<String> {'PowerPartner'};
            Profile p = [SELECT Id, name FROM Profile WHERE UserType in :customerUserTypes limit 1];
            newUser = new User(alias = 'test123', email = 'test123asdfresdf@noemail.com',
                    emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                    localesidkey = 'en_US', profileid = p.Id, country = 'United States', IsActive = true,
                    ContactId = cont.Id, username = 'tester@noemail.com.user',
                    timezonesidkey = 'America/Los_Angeles');

            if (makeInsert == true) insert newUser;
        }
        return newUser;
    }

    public static Account createPartnerAccount(String recordtypeId, Boolean makeInsert){
        Account instOfAcc = new Account();
        instOfAcc.Name = 'Test Account';
        instOfAcc.RecordTypeId = recordtypeId;
        instOfAcc.BillingStreet = '1110 E Algonquin Rd';
        instOfAcc.BillingState='Illinois';
        instOfAcc.BillingCity = 'Schaumburg';
        instOfAcc.BillingCountry = 'United States';
        instOfAcc.BillingPostalCode = '60173';
        instOfAcc.Motorola_Enterprise_ID__c = string.valueof(integer.valueof(math.random()*100000000))+'00';
        instOfAcc.Role_Created__c = true;

        instOfAcc.Industry = 'Manufacturing';
        instOfAcc.Region__c = 'NA';
        instOfAcc.Partner_Region__c = 'NAMR';
        instOfAcc.Territory__c = 'T2';
        instOfAcc.Metal_Level__c = 'Authorized';
        instOfAcc.Type = 'Partner';
        instOfAcc.MPE_Program_Status_New__c='Active';
        instOfAcc.Partner_Hub_Enabled__c = true;
        if (makeInsert == true) Database.insert(instOfAcc);
        return instOfAcc;
    }

    public static Account createCustomerHubAccount(Boolean makeInsert) {
        Account acc = createPartnerAccount(DTSFPART_Utils.getRecordTypeId('Account', 'SoldToAccount'), false);
        acc.Name = 'Test Customer Account';
        acc.Type = 'Direct Customer';
        if (makeInsert) Database.insert(acc);
        return acc;
    }

    public static Account createPartnerAccountWithTechSpec(){
        System.debug('Queries - createPartnerAccountWithTechSpec: ' + Limits.getQueries());//15
        Id partnerRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        System.debug('Queries - createPartnerAccountWithTechSpec: ' + Limits.getQueries());//15
        Account acc = createPartnerAccount(partnerRTId, false);
        acc.Sales_View_Upload_Mode__c = 'SV2';
        System.debug('Queries - createPartnerAccountWithTechSpec: ' + Limits.getQueries());//21
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Database.insert(acc, dml);
        System.debug('Queries - createPartnerAccountWithTechSpec: ' + Limits.getQueries());//23
        List<Partner_Type__c> ProgramInfoList = DTSFPART_TestDataSetUpUtils.createProgramInfoRecords(1, new List<Account> {acc});
        System.debug('Queries - createPartnerAccountWithTechSpec: ' + Limits.getQueries());//43
        Technology_Specialization__c techspec = new Technology_Specialization__c();
        techspec.Account__c = acc.Id;
        techspec.Partner_Program__c = ProgramInfoList[0].Id;
        techspec.Technology_Specialization__c = 'Business Radio';
        techspec.Technology_Specialization_Status__c =  'Active';
        techspec.Community_Type__c = 'Value Added Reseller';
        insert techspec;
        return acc;
    }

    public static List<Partner_Type__c> createProgramInfoRecords(Integer NumOfpgminfo, List<Account> AccountList) {
        List<Partner_Type__c> ProgramInfoList = new List<Partner_Type__c>();
        for(Account acc : AccountList) {
            for(Integer each=0; each < NumOfpgminfo; each++) {
                Partner_Type__c pgminfo = new Partner_Type__c();
                pgminfo.Account__c = acc.id;
                pgminfo.Program__c = 'RADIO';
                pgminfo.Status__c = 'Active'; 
                PGMINFO.Purchasing_Method__c='Tier 16';
                PGMINFO.US_Federal__c=True;
                PGMINFO.RHO__c=True;
                ProgramInfoList.add(pgminfo);
            }
        }
        Insert ProgramInfoList;
        return ProgramInfoList;
    }

    public static List<Account> createMCNAccounts(Integer NumOfAccounts, Id recordtypeId,List<Account> AccountList, Boolean makeInsert) {
        List<Account> MCNaccountList = new List<Account>();
        for(Account Acc1 : AccountList) {
            for(Integer eachAcc=0; eachAcc < NumOfAccounts; eachAcc++){
                Account acc = new Account();
                acc.Name='TestMCN'+eachAcc;
                acc.RecordTypeId = recordtypeId;
                acc.parentid = Acc1.id;
                acc.Customer_or_Prospect_Account__c = Acc1.id;
                acc.Motorola_Customer_Number__c = string.valueof(integer.valueof(math.random()*100000000))+'00';
                acc.ShippingCountry='United States';
                acc.ShippingState = 'Illinois';
                acc.ERP_Active__c=true;
                MCNaccountList.add(acc);
            }
        }
        if(makeInsert == true) insert MCNaccountList;
        return MCNaccountList;
    }

    public static List<MCN_Permission__c> createMcnPermissions(List<Account> mcnAccounts, String contactMcnPermissions, Boolean makeInsert) {
        List<MCN_Permission__c> mcnPermissions = new List<MCN_Permission__c>();
        for(Account mcn : mcnAccounts) {
            mcnPermissions.add(new MCN_Permission__c(
               MCN_Account__c = mcn.Id,
               Customer_OR_Partner_Account__c = mcn.ParentId,
               Contact_MCN_Permissions__c = contactMcnPermissions
            ));
        }

        if(makeInsert == true) {
            insert mcnPermissions;
            System.debug(mcnPermissions);
        }
        return mcnPermissions;
    }

    /* ============================================================================================ 
    Description    : Inserts Above_Price_Book__c records
    @params1       : number of Above_Price_Book__c to be inserted
	@params2  	   : Account to insert Above Price Book
	===============================================================================================*/
    public static List<Above_Price_Book__c> createAPBRecords(Integer noOfAPBRecords) {
        Id accrectypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
       User commUser = DTSFPART_TestDataSetUpUtils.createCommunityUser();
       List<Above_Price_Book__c> apbRecordList = new List<Above_Price_Book__c>();
       
           List<Account> accsList = DTSFPART_TestDataSetUpUtils.createAccounts(1, accrectypeID);
       for(Integer each=0; each < noOfAPBRecords; each++) {
           Above_Price_Book__c apbRecord = new Above_Price_Book__c();
           apbRecord.Customer_Name__c = 'Test Partner Account';
           apbRecord.ARZM__c = '1234';
           apbRecord.Is_Demo__c = true;
               apbRecordList.add(apbRecord);
       }
       if(!apbRecordList.isEmpty()) {
           System.runAs(commUser){
             insert apbRecordList;   
           }
          
       }
          
       return apbRecordList;
   }

    /* ============================================================================================ 
    Description    : Inserts MPEContact__c records with accounts
    @params1       : number of MPEContact__c to be inserted
    @params2       : account List
    @return        : MPEContact__c list
    ===============================================================================================*/
    public static List<MPEContact__c> createMPEContacts(Integer numberOfContacts, List<Account> accounts)
    {
        return createMPEContacts(numberOfContacts, accounts, true);
    }

    public static List<MPEContact__c> createMPEContacts(Integer numberOfContacts, List<Account> accounts, Boolean isInsert) {
        List<MPEContact__c> contactsToBeInserted = new List<MPEContact__c>();
        for(Account eachAccount : accounts) {
            for(Integer each=0; each < numberOfContacts; each++) {
                MPEContact__c eachMPEContact = new MPEContact__c();
                eachMPEContact.Account__c = eachAccount.Id; 
                eachMPEContact.Email__c = 'test@gmail.com';
                eachMPEContact.First_Name__c = 'test'; 
                eachMPEContact.Last_Name__c = 'contact';
                eachMPEContact.Status__c = 'Pending Registration';
                contactsToBeInserted.add(eachMPEContact); 
            }
        }
        
        if(!contactsToBeInserted.isEmpty() && isInsert) {
            insert contactsToBeInserted;
        }
        return contactsToBeInserted ;
    }

    public static User createPartnerPortalUser_AvoidMixedDML(String strContactId){
        
        User thisUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User partnerUser;

        // Run as current user to avoid Mixed DML error when Contact was inserted in the same scope.
        System.runAs (thisUser) {
            partnerUser = createPartnerPortalUser(strContactId);
        }
        return partnerUser;
    }

    
    /*
    * Method name   : createPartnerPortalUser
    * Description   : Creates partner portal user
    * Return Type   : User
    * Parameter : ContactId
    */
    public static User createPartnerPortalUser(String strContactId) {
        return createPartnerPortalUser(strContactId, true);
        /*Set<String> customerUserTypes = new Set<String> {'PowerPartner'};

    User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    User newUser;  
    System.runAs ( thisUser ) {
    UserRole ur = [Select Id,PortalType, PortalAccountId From UserRole where PortalType =: 'Partner' limit 1];
    Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
    newUser = new User(
    //UserRoleId = ur.Id,
    profileId = p.id,
    username = 'new'+strContactId+'Us9988uuy66ttre3r@yahoo.com',
    email = 'test@partner.com',
    emailencodingkey = 'UTF-8',
    localesidkey = 'en_US',
    languagelocalekey = 'en_US',
    timezonesidkey = 'America/Los_Angeles',
    alias='nuser',
    lastname='lastname',
    contactId = strContactId,
    UserRoleId = ur.id
    );
    insert newUser;  

    }
    return newUser;
    */
    }
    public static User createPartnerPortalUser(String strContactId, Boolean withSave){
        Id p = [select id from profile where name=:PROFILE_PARTNER_ADMIN].id;
        Id roleId = [Select Id From UserRole where PortalType = 'Partner' limit 1]?.Id;
        User newUser = new User(alias = 'test123', email='test123asdfresdf@noemail.com',
                                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                                ContactId = strContactId,
                                timezonesidkey='America/Los_Angeles', username=USERNAME_PARTNER);
        if (withsave==true) {
            insert newUser;
        }
        return newUser;
    }

    public static List<Account> createAccounts(Integer NumOfAccounts, Id recordtypeId) {
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Id partRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        for(Integer eachAcc=0; eachAcc < NumOfAccounts; eachAcc++){
            Account acc = new Account();
            acc.Name = 'Test Account' + eachAcc;
            acc.RecordTypeId = recordtypeId;
            acc.BillingStreet = '1110 E Algonquin Rd';
            acc.BillingState='Illinois';
            acc.BillingCity = 'Schaumburg';
            acc.BillingCountry = 'United States';
            acc.Billing_county__c = 'Cook';
            acc.BillingPostalCode = '60173';
            if(partRecTypeId == recordtypeId){
                acc.Motorola_Enterprise_ID__c = string.valueof(integer.valueof(math.random()*10000)*100);
            }else{
                acc.Motorola_Customer_Number__c = string.valueof(integer.valueof(math.random()*10000)*100);
            }            
            acc.Role_Created__c = true;
            acc.Industry = 'Manufacturing';
            acc.Segment__c = 'Construction';
            acc.Region__c = 'NA';
            acc.Partner_Region__c = 'NAMR';
            acc.Hierarchy_Placement__c='ERP Account';
            acc.Territory__c = 'T2';
            acc.Agency_Level__c = 'City';
            if(recordtypeId == '01280000000M0q4'){
                acc.Territory__c = 'CT2';
            }
            acc.Metal_Level__c = 'Authorized';
            acc.Type='Motorola Entity';
            acc.parentid=null;
            accountList.add(acc);
        }
        
        try {
            Database.insert(accountList, dml);

        } catch(DmlException e) {
            for(Account acc : accountList)
                acc.Motorola_Customer_Number__c=null;

            Database.insert(accountList, dml);
        }
        
        System.debug('accountList0====>' +accountList[0].Id +', '+accountList[0].Id +', '+accountList[0].Region__c +', '+accountList[0].Territory__c +', '+accountList[0].BillingCountry +', '+accountList[0].BillingState);
        return accountList;
    }
    
    public static User createCommunityUser(){
        Id PartnrRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account partneraccTest = new Account( Name='PartnerAcc',RecordTypeId = PartnrRecordTypeId,BillingStreet='12th Street',
                                             BillingCity='Schaumburg',BillingCountry='United States',BillingState = 'Illinois',
                                             BillingPostalCode='560100',Partner_Region__c='NAMR',Program_Level_Community__c='CallWorks');
        insert partneraccTest;
        partneraccTest.IsPartner = true;
        update partneraccTest;
        Id PartnrConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Contact partTestCont1 = new Contact(AccountId = partneraccTest.Id,RecordtypeId = PartnrConRecordTypeId,FirstName = 'Test',
                                            LastName = 'Partner Contact',Primary_Contact_Type__c='Sales',Contact_Type__c='sales',Persona__c='OwnerExecutive', Email='testuser@phmotorolasol.com');
        insert partTestCont1;
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'Customer Community User'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
        User communityUSER = new User(alias = 'partusr',email='standarduser@testorg.com',emailencodingkey='UTF-8', 
                                      lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',CommunityNickname='pusr1',
                                      ProfileId = profiles.get('Customer Community User'),timezonesidkey='America/Los_Angeles', 
                                      username='partnerusr@testorg.com', FederationIdentifier='partnerusr@testorg.com',
                                      Core_ID__c='partnerusr@testorg.com',contactId=partTestCont1.Id,PortalRole='');
        insert communityUSER;
        return communityUSER;
    }

    public static void insertCustomSettings() {
        List<TriggerSettings__c> tSC = new List<TriggerSettings__c>();
        tSC.add(new TriggerSettings__c(Name ='OpportunityTriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name ='BypassPartnerOpptyRegistration',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name ='CustomerAccountTriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='AITriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='UserTriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='ChannelProgramMemberTriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='LeadTriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='ProgramDetailDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='TechnologySubSegmentDisable',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='MRCommissionTriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='QuoteTriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='OpportunityLineItemTriggerDisabled',Isactive__c=false));
        tSC.add(new TriggerSettings__c(Name='AgreementTriggerDisabled',IsActive__c=false));
        tSC.add(new TriggerSettings__c(Name='ApplicationAccessTriggerDisabled',IsActive__c=false));
        tSC.add(new TriggerSettings__c(Name='CampaignInfluenceTriggerDisabled', IsActive__C=false));
        tSC.add(new TriggerSettings__c(Name='CAPPTriggerHandlerDisabled', IsActive__C=false));
        tSC.add(new TriggerSettings__c(Name='QuoteProductTriggerDisabled', IsActive__C=false));
        tSC.add(new TriggerSettings__c(Name='BidScrubTriggerHandlerDisabled', IsActive__C=false));
        tSC.add(new TriggerSettings__c(Name='PresalesTriggerDisabled', IsActive__C=false));        
        tSC.add(new TriggerSettings__c(Name='ProjectResourceTriggerDisabled', IsActive__C=false));
        tSC.add(new TriggerSettings__c(Name='PartnerLocationTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'PartnerOpportunityTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'RevenueTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'RunRateParentTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'FiscalMetadataTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'ContactTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'PartnerEmpowerAppTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'AddendumTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'CommissionSummaryTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'CaseTriggerDisabled', IsActive__C=false));//Added by Anand
        tsc.add(new TriggerSettings__C(Name = 'APIPartnerApplicationTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'AccountTeamMemberTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'OpportunityTeamMemberTriggerDisabled', IsActive__C=false));//Added by Anand 
        tsc.add(new TriggerSettings__C(Name = 'SRTriggerDisabled', IsActive__C=false));//Added by Srikanth
        tsc.add(new TriggerSettings__C(Name = 'CompetitorTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'OpportunitySubAccountTrigger', IsActive__C=false));//Added by Srikanth
        tsc.add(new TriggerSettings__C(Name = 'FeedItemTriggerDisabled', IsActive__C=false));//Added by Hemant
        tsc.add(new TriggerSettings__C(Name = 'ContentVersionTriggerMSI', IsActive__C=false));//Added by Hemant
        tsc.add(new TriggerSettings__C(Name = 'TaskTypeUpdateDisabled', IsActive__C=false));//Added by Hemant
        tsc.add(new TriggerSettings__C(Name = 'ContentDocumentLinkTrigger_MSI', IsActive__C=false));//Added by Hemant
        tsc.add(new TriggerSettings__C(Name = 'GoogleDriveCreation', IsActive__C=false));//Added by Saroja
        tsc.add(new TriggerSettings__C(Name = 'ProductTriggerDisabled', IsActive__C=false));//Added by Saroja
        tsc.add(new TriggerSettings__C(Name = 'ContentDocumentLinkTriggerDisabled', IsActive__C=false));//Added by Afzal
        tsc.add(new TriggerSettings__C(Name = 'AttachmentTriggerDisabled', IsActive__C=false));//Added by Adil
        tsc.add(new TriggerSettings__C(Name = 'ContactPermissionsTriggerDisabled', IsActive__C=false));
        tsc.add(new TriggerSettings__C(Name = 'SiteTriggerDisabled', IsActive__C=false));//Added by Swarupa
        tsc.add(new TriggerSettings__C(Name = 'MPETriggerDisabled', IsActive__C=false));//Added by Sagar
        Insert tSC;
    }

    public static List<Contact> createContacts(Integer NumOfContacts, Id recordtypeId, List<Account> AccountList) {
        List<Contact> contactList = new List<Contact>();
        for(Account acc : AccountList) {
            for(Integer each=0; each < NumOfContacts; each++){
                Contact con = new Contact();
                con.AccountId = acc.Id;
                con.RecordtypeId = recordtypeId;
                con.ldap_login__c = 'masters';
                con.FirstName = 'Test FName' + each;
                con.LastName = 'Test LName' + each;
                con.email = 'TestLname'+each+'@gmail.com';
                con.Tag__c = 'SFDCPartnerAdmin'; // Modified Tag__c value as per DTPART-87
                con.Persona__c = 'OwnerExecutive';
                contactList.add(con);
            }
        }
        Insert contactList;
        return contactList;
    }
}