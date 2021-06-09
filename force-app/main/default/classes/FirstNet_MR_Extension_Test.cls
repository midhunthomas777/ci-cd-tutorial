@Istest
private class FirstNet_MR_Extension_Test
{
 @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

static testMethod void Method1()
{
    
     /*DataActivity__c Temps1 = new DataActivity__c (Name='DeactivateMain',DeactivateTrigger__c=True);
    insert Temps1;
    
     DataActivity__c Temps2 = new DataActivity__c (Name='DeactivateTrigger',DeactivateTrigger__c=True);
    insert Temps2;*/
    
    SicCodeMapping__c TempS3 =new SicCodeMapping__c(Name='0111',Current_Segment__c='Agriculture and Forestry',Industry__c='Natural Resources',Industry_Description__c='Wheat farm',SicCode__c='0111');
    Insert TempS3;
    Account Acc= new Account(Name='Test',Billingcountry='India',Billingcity='TestCity',Partner_Distributor_email__c='T@T.com');
    Account act = new Account(Name='Test1',Billingcountry='India',Billingcity='TestCity1',Partner_Distributor_email__c='T1@T.com');    
    Apexpages.StandardController sc = new Apexpages.standardController(act);
        Insert Acc;
        Insert act;
    Account A1 = [Select OwnerID From Account where ID = :act.id];
        // Instantiate the extension
        FirstNet_MR_Extension ext = new FirstNet_MR_Extension(sc);
        ext.createFirstNetMR();
        Recordtype RT = [select Id from RecordType where Name = 'Reseller/Distributor' and SobjectType = 'Apttus__APTS_Agreement__c' Limit 1];
        Apttus__APTS_Agreement__c newAgreement = New Apttus__APTS_Agreement__c();
    Territory_Master__c TM = New Territory_Master__c(State_Code__c='KS',State_Province__c='Kansas');
        Insert TM;
      ID attorneyId = [select Id from user where name ='Kimberly Hakim' limit 1].id;
     newAgreement.Name = 'FirstNet MR Addendum';
     newAgreement.Agreement_Title__c = 'FirstNet MR Addendum';
     newAgreement.RecordTypeID = RT.Id;
     newAgreement.Apttus__Subtype__c = 'Channel Partner (includes legacy G&PS, WNS and EMb Channel Partners)';
     newAgreement.m_Business_Unit__c = 'Government';
     newAgreement.m_GTM_Region__c = 'North America';
     newAgreement.m_State_Name__c = 'Test';
     newAgreement.m_State_and_Local_Territory__c = 'Territory';
     newAgreement.Apttus__Account__c = act.id;
     newAgreement.Motorola_Entity_Account__c = '0018000001DSz8J';
     newAgreement.m_Responsible_Attorney__c = attorneyId;
     newAgreement.Customer_Signatory_Email__c = acc.Partner_Distributor_email__c;
     newAgreement.Ready_For_Submission__c = True;
     newAgreement.Ready_For_eSignature__c = True;
     newAgreement.Apttus__Workflow_Trigger_Viewed_Final__c = True;
     newAgreement.Apttus__Contract_Start_Date__c =  system.today();
     newAgreement.Apttus__Perpetual__c = True;
     newAgreement.Business_Contact__c = A1.OwnerId; 
     newAgreement.Apttus__Total_Contract_Value__c = 0;
     newAgreement.Motorola_Contract_Signatory__c = 'Scott Adler';
     Test.startTest();
     insert newAgreement;
    newAgreement.Apttus__Status__c = 'Approved Request';
     update newAgreement;
    Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c(Name='FirstNet MR Addendum'); 
     Insert  templatesOb; 
     Test.stopTest();   
 
}
        
}