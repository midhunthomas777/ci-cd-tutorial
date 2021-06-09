/************************************************************************************************* 
* File Name  : CreateAgreementDocumentclass_WizardTest
* Description: Test class for CreateAgreementDocumentclass_Wizard class
* Modification Log 
* ============================================================================= 
*   Date               Author                         Modification 
* ---------------------------------------------------------------------------------------
* 09-May-2018     Satish Maddhi(TCS)      Removed SeeAllData=true and increased code coverage
*
*************************************************************************************************/

@isTest
private class CreateAgreementDocumentclass_WizardTest{
    @testSetup
    static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
        TriggerSettings__c userTgr = new TriggerSettings__c();
        userTgr.name = 'UserTriggerDisabled';
        userTgr.Isactive__c = FALSE;
        insert userTgr;
        RecordType rt1 = [SELECT id,Name from RecordType where SobjectType='Account' AND Name='Motorola Entity' Limit 1];
        RecordType agrt1 = [select id,Name from RecordType where SobjectType='Apttus__APTS_Agreement__c' and Name='NDA' Limit 1];
        Account motoAcc = new Account(Name='moto account',recordtypeid=rt1.id);
        insert motoAcc;
        Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c(Name='Change Order Request Template');
        Insert  templatesOb;
        
        Apttus__APTS_Template__c templatesOb1 = new Apttus__APTS_Template__c(Name='NDA - Universal English'); 
        Insert  templatesOb1;
        
        Attachment attach=new Attachment();     
        attach.Name='Change Order Request Template';
        Blob bodyBlob=Blob.valueOf('Change Order Request Template');
        attach.body=bodyBlob;
        attach.parentId=templatesOb.id;
        insert attach;
        
        Attachment attach1=new Attachment();     
        attach1.Name='NDA - Universal English';
        Blob bodyBlob1=Blob.valueOf('NDA - Universal English');
        attach1.body=bodyBlob1;
        attach1.parentId=templatesOb1.id;
        insert attach1;
    }
    public static testMethod void validateCreateAgreementDocumentclass_Wizard_eNDA(){
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Apttus__APTS_Agreement__c' and Name='NDA' Limit 1];
        Profile p1 = [select id from profile where name='System Administrator'];  
        Id MotEntRecType = [select id from recordtype where developername = 'Motorola_Entity' and SobjectType = 'Account' limit 1].id;
        Account acct1 = new Account(Name='Test ME'); 
        acct1.Billingstreet = '1400 Fashion Island Blvd';
        acct1.Namelocal ='Test ME';
        acct1.Billingcity = 'San Mateo';
        acct1.Billingstate = 'Illinois';
        acct1.BillingCountry = 'United States';
        acct1.BillingPostalCode = '94404'; 
        acct1.Phone ='12345';
        acct1.RecordTypeid= MotEntRecType ;
        insert acct1;
        
        User sysuser=[select id from user where profile.name='System Administrator' and isactive=true limit 1];
        System.runAs(sysuser){        
        User thisUser=new User(LastName='lastname',ProfileId=p1.Id,Alias='cspu',EmailEncodingKey='UTF-8',
        TimeZoneSidKey='America/New_York',Core_ID__c = 'ABCDD',LocaleSidKey='en_US',LanguageLocaleKey='en_US',Email='ttest@test.com',
        UserName='testzing@test.com',Primary_Business_Group__c='Government');
        insert thisUser;}
        user u1=[select id from user where username='testzing@test.com'];
        System.runAs(sysuser){
        User user1 = new User ();
        user1.FirstName = 'Testuser'; 
        user1.LastName = 'One'; 
        user1.Username = 'Testuserone@motorolasolutions.com';
        user1.Email =  'Testuserone@motorolasolutions.com';
        user1.Alias = 'TOne1';
        user1.TimeZoneSidKey = 'America/Los_Angeles'; 
        user1.LocaleSidKey = 'en_US'; 
        user1.EmailEncodingKey = 'UTF-8'; 
        user1.ProfileId = p1.id; 
        user1.LanguageLocaleKey ='en_US'; 
        user1.Primary_Business_Group__c='Government';         
        user1.Core_ID__c='fffv';
        user1.CommunityNickname='fffv';
        user1.FederationIdentifier='fffv';
        user1.EmployeeNumber='fffv';
        user1.System_Integration__c = True;
        insert user1;} 
        
        Apttus__APTS_Agreement__c eNDAAgmt1 = new Apttus__APTS_Agreement__c();
        
        eNDAAgmt1.Name='Testing eNDA Agreement';
        eNDAAgmt1.RecordTypeID=rt1.id;
        eNDAAgmt1.Agreement_Title__c = 'Testing eNDA';
        eNDAAgmt1.CreatedBy = u1;
        eNDAAgmt1.MSI_Signatory_eNDA__c = 'Test Signatory';
        eNDAAgmt1.MSI_Entity_eNDA__c = 'Test Motorola Entity';
        eNDAAgmt1.Description_of_Project_Program__c = 'Testing Purpose';
        eNDAAgmt1.m_Business_Unit__c = 'Government';
        eNDAAgmt1.m_GTM_Region__c = 'North America';
        eNDAAgmt1.Language_Selection__c= 'English';
        eNDAAgmt1.Business_Contact__c = u1.id;
        eNDAAgmt1.Apttus__Description__c = 'ssss';
        eNDAAgmt1.m_Responsible_Attorney__c = '00580000003Qb86AAC';
       // eNDAAgmt1.Created_from_Wizard__c = True; 
        eNDAAgmt1.Motorola_Entity_Account__c = acct1.id;
        
        insert eNDAAgmt1;
               
        Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c(Name='NDA - Universal English'); 
        Insert  templatesOb; 
        
        Id eNDAId = eNDAAgmt1.id;
        id recordtypeId = rt1.id;
        Id NDASpecialistID = u1.id;
        System.runAs(u1){
        test.startTest();
        try{
            CreateAgreementDocumentclass_Wizard.updateAgreement(eNDAId,recordtypeId);
        } catch(Exception exp){}
        test.stopTest();
        }
    }
    public static testMethod void MyNewAgreeMethod() {
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Apttus__APTS_Agreement__c' and Name='NDA' Limit 1];          
        ID eNDARecordTypeID = [select Id from RecordType where Name = 'eNDA' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1].id;
        Profile p1 = [select id from profile where name='System Administrator' Limit 1];  
        
        Id MotEntRecType = [select id from recordtype where developername = 'Motorola_Entity' and SobjectType = 'Account' limit 1].id;
        Account acct1 = new Account(Name='Test ME'); 
        acct1.Billingstreet = '1400 Fashion Island Blvd';
        acct1.Namelocal ='Test ME';
        acct1.Billingcity = 'San Mateo';
        acct1.Billingstate = 'Illinois';
        acct1.BillingCountry = 'United States';
        acct1.BillingPostalCode = '94404'; 
        acct1.Phone ='12345';
        acct1.RecordTypeid= MotEntRecType ;
        insert acct1;
        
        Id ProcurementRecType = [select id from recordtype where developername = 'Procurement' and SobjectType = 'Account' limit 1].id;
        Account acct2 = new Account(Name='Test Contract'); 
        acct2.Billingstreet = '1400 Fashion Island Blvd';
        acct2.Namelocal ='Test CP1';
        acct2.Billingcity = 'San Mateo';
        acct2.Billingstate = 'Illinois';
        acct2.BillingCountry = 'United States';
        acct2.BillingPostalCode = '94404'; 
        acct2.Phone ='12345';
        acct2.RecordTypeid= ProcurementRecType;
        insert acct2;
        User sysuser=[select id from user where profile.name='System Administrator' and isactive=true limit 1];
        System.runAs(sysuser){
            User user1 = new User ();
            user1.FirstName = 'Testuser'; 
            user1.LastName = 'One'; 
            user1.Username = 'Testuserone@motorolasolutions.com';
            user1.Email =  'Testuserone@motorolasolutions.com';
            user1.Alias = 'TOne1';
            user1.TimeZoneSidKey = 'America/Los_Angeles'; 
            user1.LocaleSidKey = 'en_US'; 
            user1.EmailEncodingKey = 'UTF-8'; 
            user1.ProfileId = p1.id; 
            user1.LanguageLocaleKey ='en_US'; 
            user1.Primary_Business_Group__c='Government';            
            user1.Core_ID__c='fffv';
            user1.CommunityNickname='fffv';
            user1.FederationIdentifier='fffv';
            user1.EmployeeNumber='fffv';
            user1.System_Integration__c = True;
            insert user1;
        }

        user u1=[select id from user where username='Testuserone@motorolasolutions.com'];
        Apttus__APTS_Agreement__c eNDAAgmt1 = new Apttus__APTS_Agreement__c();
        
        //eNDAAgmt1.Name='Testing eNDA Agreement';
        eNDAAgmt1.RecordTypeID=rt1.id;
        eNDAAgmt1.Agreement_Title__c = 'Testing eNDA';
        eNDAAgmt1.CreatedBy = u1;
        eNDAAgmt1.MSI_Signatory_eNDA__c = 'Test Signatory';
        eNDAAgmt1.MSI_Entity_eNDA__c = 'Test Motorola Entity';
        eNDAAgmt1.Description_of_Project_Program__c = 'Testing Purpose';
        eNDAAgmt1.m_Business_Unit__c = 'Government';
        eNDAAgmt1.m_GTM_Region__c = 'North America';
        eNDAAgmt1.Language_Selection__c= 'English';
        eNDAAgmt1.Business_Contact__c = u1.id;
        eNDAAgmt1.Apttus__Description__c = 'ssss';
        eNDAAgmt1.EU_PII_Transfer__c = 'Yes';
        eNDAAgmt1.m_Responsible_Attorney__c = '00580000003Qb86AAC';
        eNDAAgmt1.m_Country_of_Deployment__c = 'United States';
        eNDAAgmt1.Procurement_Category__c = 'Technical Services';
        eNDAAgmt1.Apttus__Total_Contract_Value__c = 250010;
        eNDAAgmt1.m_GTM_Region__c = 'North America';
        eNDAAgmt1.Contracting_Party_Account__c = acct2.id;
        //eNDAAgmt1.Proc_Wiz_PreApproval_Cond__c = 750;
        eNDAAgmt1.Apttus__Description__c = null;
        eNDAAgmt1.Created_from_Wizard__c = True;
        eNDAAgmt1.Supplier_Requires_Ownership_Rights__c = 'Yes';
        eNDAAgmt1.Apttus__Total_Contract_Value__c = 555;
        eNDAAgmt1.Amendment_Change_Order_Value__c = 222;
        eNDAAgmt1.Apttus__Contract_Start_Date__c = Date.today()+10;
        eNDAAgmt1.Motorola_Entity_Account__c = acct1.id;
        insert eNDAAgmt1;
        String MysessionId='';
        String MyAgreeId=eNDAAgmt1.Id;
        String RId=rt1.id;

        //Apttus__APTS_Template__c templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'NDA - Universal English' limit 1];
        Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c();  
        templatesOb.name = 'NDA - Universal English' ;
        templatesOb.Apttus__Type__c = 'Agreement';
        insert templatesOb; 
        Apttus__APTS_Template__c templatesOb123 = new Apttus__APTS_Template__c(Name='IT SOW Procurement Template'); 
        Insert templatesOb123; 
        
        eNDAAgmt1.Procurement_Category__c = 'HR Services';
        eNDAAgmt1.Motorola_Entity_Account__c = acct1.id;
        try{
        update eNDAAgmt1;
        } catch(Exception exp){}
        
        Attachment attach=new Attachment();     
        attach.Name='Change Order Request Template';
        Blob bodyBlob=Blob.valueOf('NDA - Universal English');
        attach.body=bodyBlob;
        attach.parentId=templatesOb.id;
        insert attach;
         
        // user u=[Select Id from User where  isactive=true and profile.name='System Administrator' limit 1];
       
        //CreateAgreementDocumentclass_Wizard cadw=new CreateAgreementDocumentclass_Wizard();
        test.startTest();
        CreateAgreementDocumentclass_Wizard.generatedoc(MysessionId,MyAgreeId,RId);
        String EmailId='Test@test.com';
        Id creator=UserInfo.getUserId();
        try{
        CreateAgreementDocumentclass_Wizard.procSendEmail(MysessionId,MyAgreeId,EmailId,creator);
        } catch(Exception exp){}
        try{
        CreateAgreementDocumentclass_Wizard.updateAgreement(eNDAAgmt1.id,eNDARecordTypeID);
        } catch(Exception exp){}
        try{
        CreateAgreementDocumentclass_Wizard.updateProcAgreement(eNDAAgmt1.id,eNDARecordTypeID);
        } catch(Exception exp){}
        Test.stopTest();
    }
    
    public static testMethod void MyNewAgreeMethod1() {
        RecordType rt1 = [select id,Name from RecordType where SobjectType='Apttus__APTS_Agreement__c' and Name='NDA' Limit 1];          
        ID eNDARecordTypeID = [select Id from RecordType where Name = 'eNDA' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1].id;
        Profile p1 = [select id from profile where name='System Administrator' Limit 1];  
        
        Id MotEntRecType = [select id from recordtype where developername = 'Motorola_Entity' and SobjectType = 'Account' limit 1].id;
        Account acct1 = new Account(Name='Test ME'); 
        acct1.Billingstreet = '1400 Fashion Island Blvd';
        acct1.Namelocal ='Test ME';
        acct1.Billingcity = 'San Mateo';
        acct1.Billingstate = 'Illinois';
        acct1.BillingCountry = 'United States';
        acct1.BillingPostalCode = '94404'; 
        acct1.Phone ='12345';
        acct1.RecordTypeid= MotEntRecType ;
        insert acct1;
        
        Id ProcurementRecType = [select id from recordtype where developername = 'Procurement' and SobjectType = 'Account' limit 1].id;
        Account acct2 = new Account(Name='Test Contract'); 
        acct2.Billingstreet = '1400 Fashion Island Blvd';
        acct2.Namelocal ='Test CP1';
        acct2.Billingcity = 'San Mateo';
        acct2.Billingstate = 'Illinois';
        acct2.BillingCountry = 'United States';
        acct2.BillingPostalCode = '94404'; 
        acct2.Phone ='12345';
        acct2.RecordTypeid= ProcurementRecType;
        insert acct2;
        User sysuser=[select id from user where profile.name='System Administrator' and isactive=true limit 1];
        System.runAs(sysuser){
            User user1 = new User ();
            user1.FirstName = 'Testuser'; 
            user1.LastName = 'One'; 
            user1.Username = 'Testuserone@motorolasolutions.com';
            user1.Email =  'Testuserone@motorolasolutions.com';
            user1.Alias = 'TOne1';
            user1.TimeZoneSidKey = 'America/Los_Angeles'; 
            user1.LocaleSidKey = 'en_US'; 
            user1.EmailEncodingKey = 'UTF-8'; 
            user1.ProfileId = p1.id; 
            user1.LanguageLocaleKey ='en_US'; 
            user1.Primary_Business_Group__c='Government';           
            user1.Core_ID__c='fffv';
            user1.CommunityNickname='fffv';
            user1.FederationIdentifier='fffv';
            user1.EmployeeNumber='fffv';
            user1.System_Integration__c = True;
            insert user1;
        }

        user u1=[select id from user where username='Testuserone@motorolasolutions.com'];
        Apttus__APTS_Agreement__c eNDAAgmt1 = new Apttus__APTS_Agreement__c();
        
        //eNDAAgmt1.Name='Testing eNDA Agreement';
        eNDAAgmt1.RecordTypeID=rt1.id;
        eNDAAgmt1.Agreement_Title__c = 'Testing eNDA';
        eNDAAgmt1.CreatedBy = u1;
        eNDAAgmt1.MSI_Signatory_eNDA__c = 'Test Signatory';
        eNDAAgmt1.MSI_Entity_eNDA__c = 'Test Motorola Entity';
        eNDAAgmt1.Description_of_Project_Program__c = 'Testing Purpose';
        eNDAAgmt1.m_Business_Unit__c = 'Government';
        eNDAAgmt1.m_GTM_Region__c = 'North America';
        eNDAAgmt1.Language_Selection__c= 'English';
        eNDAAgmt1.Business_Contact__c = u1.id;
        eNDAAgmt1.Apttus__Description__c = 'ssss';
        eNDAAgmt1.EU_PII_Transfer__c = 'Yes';
        eNDAAgmt1.m_Responsible_Attorney__c = '00580000003Qb86AAC';
        eNDAAgmt1.m_Country_of_Deployment__c = 'United States';
        eNDAAgmt1.Procurement_Category__c = 'Technical Services';
        eNDAAgmt1.Apttus__Total_Contract_Value__c = 250010;
        eNDAAgmt1.m_GTM_Region__c = 'North America';
        eNDAAgmt1.Contracting_Party_Account__c = acct2.id;
        //eNDAAgmt1.Proc_Wiz_PreApproval_Cond__c = 750;
        eNDAAgmt1.Apttus__Description__c = null;
        eNDAAgmt1.Created_from_Wizard__c = True;
        eNDAAgmt1.Supplier_Requires_Ownership_Rights__c = 'Yes';
        eNDAAgmt1.Apttus__Total_Contract_Value__c = 555;
        eNDAAgmt1.Amendment_Change_Order_Value__c = 222;
        eNDAAgmt1.Apttus__Contract_Start_Date__c = Date.today()+10;
        eNDAAgmt1.Motorola_Entity_Account__c = acct1.id;
        insert eNDAAgmt1;
        String MysessionId='';
        String MyAgreeId=eNDAAgmt1.Id;
        String RId=rt1.id;

        //Apttus__APTS_Template__c templatesOb = [Select Id from Apttus__APTS_Template__c where Name like 'NDA - Universal English' limit 1];
        Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c();  
        templatesOb.name = 'NDA - Universal English' ;
        templatesOb.Apttus__Type__c = 'Agreement';
        insert templatesOb; 
        Apttus__APTS_Template__c templatesOb123 = new Apttus__APTS_Template__c(Name='IT SOW Procurement Template'); 
        Insert templatesOb123; 
        
        eNDAAgmt1.Procurement_Category__c = 'Tradeshows, Meetings, & Events';
        eNDAAgmt1.Motorola_Entity_Account__c = acct1.id;
        try{
            update eNDAAgmt1;
        } catch(Exception exp){}
        
        Attachment attach=new Attachment();     
        attach.Name='Change Order Request Template';
        Blob bodyBlob=Blob.valueOf('NDA - Universal English');
        attach.body=bodyBlob;
        attach.parentId=templatesOb.id;
        insert attach;
         
        test.startTest();
        String EmailId='Test@test.com';
        Id creator=UserInfo.getUserId();
        try{
            CreateAgreementDocumentclass_Wizard.procSendEmail(MysessionId,MyAgreeId,EmailId,creator);
        } catch(Exception exp){}
        Test.stopTest();
    }
}