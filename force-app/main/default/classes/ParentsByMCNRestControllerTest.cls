@isTest
private class ParentsByMCNRestControllerTest{
    
     @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }  

    static testMethod void withMCN() {
        
         ParentsByMCNRestController.MCNWrapper  controllerMCNWrapper = new ParentsByMCNRestController.MCNWrapper();
         List<ParentsByMCNRestController.MCNWrapper>  listControllerMCNWrapper = new List<ParentsByMCNRestController.MCNWrapper>();
         controllerMCNWrapper.mcn = '123456';         
         listControllerMCNWrapper.add(controllerMCNWrapper);
         controllerMCNWrapper = new ParentsByMCNRestController.MCNWrapper();
         controllerMCNWrapper.mcn = '1234567';
         listControllerMCNWrapper.add(controllerMCNWrapper);
         
         ParentsByMCNRestController.PersonWrapper personWrapper = new ParentsByMCNRestController.PersonWrapper();
         personWrapper.email ='a@b.com';
         
          Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id mcnRecId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Account Ac = new Account(Name='TestV',CDH_Owner_CoreID__c='NJPD36',Region__c='NA',Territory__c='T1',
                                 billingcountrycode ='US',RecordTypeID=prospectId,BillingPostalCode='1234',
                                 Billingcity='Test',Sic = '1041',Billing_County__c = 'US');        
        insert Ac;
        Account InsertMCN = new Account();
        InsertMCN.Name='TestMCN Record';
        InsertMCN.RecordTypeId = mcnRecId;
        InsertMCN.parentid = Ac.id;
        InsertMCN.Customer_or_Prospect_Account__c = Ac.id;
        InsertMCN.Motorola_Customer_Number__c = '123456';
        InsertMCN.ShippingCountry='United States';
        InsertMCN.ShippingState = 'Illinois';
        InsertMCN.Type = 'Direct Customer';
        InsertMCN.CDH_Owner_CoreID__c=null;
        insert InsertMCN;
        
        Account InsertMCNnew = new Account();
        InsertMCNnew.Name='TestMCN Record';
        InsertMCNnew.RecordTypeId = mcnRecId;
        InsertMCNnew.parentid = Ac.id;
        InsertMCNnew.Customer_or_Prospect_Account__c = Ac.id;
        InsertMCNnew.Motorola_Customer_Number__c = '1234567';
        InsertMCNnew.ShippingCountry='United States';
        InsertMCNnew.ShippingState = 'Illinois';
        InsertMCNnew.Type = 'Direct Customer';
        InsertMCNnew.CDH_Owner_CoreID__c=null;
        insert InsertMCNnew;
        
        Partner_Identifier__c partnerIden = new Partner_Identifier__c();
        partnerIden.Account__c =InsertMCN.id;
        partnerIden.ID_Number__c = '123456';
        insert partnerIden;
        
        Contact ConData = new Contact(FirstName='First',LastName='Last', Accountid=InsertMCN.id,RecordTypeId='01280000000LsIz',LDAP_Login__c='Ldaptr',TAG__C='ADP'/*,Master_Flag__c='Master'*/,email='abctest3@gmail.com');
        
        Technical_Site__c techSiteData = new Technical_Site__c();
        techSiteData.MCN_Account__c =InsertMCN.id;
        techSiteData.Customer__c=InsertMCNnew.Id;
        techSiteData.Site_ID__c  ='testtwo';
        insert techSiteData;
        
        ParentsByMCNRestController.CreateCaseWrapperRequest request = new ParentsByMCNRestController.CreateCaseWrapperRequest();
        request.ldap =ConData.LDAP_Login__c;
        request.mcn =controllerMCNWrapper.mcn;
        request.techSiteId = techSiteData.id;
        List<ParentsByMCNRestController.CreateCaseWrapperRequest> listRequest = new List<ParentsByMCNRestController.CreateCaseWrapperRequest>();
        listRequest.add(request);
        
        String JsonMsg=JSON.serialize(request);
          RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();    
           req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
           req.httpMethod = 'POST';//HTTP Request Type
           req.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = req;
           RestContext.response= res;
           
        List<ParentsByMCNRestController.CreateCaseWrapperResponse> responseDate =ParentsByMCNRestController.getParentssByMCNs(listControllerMCNWrapper,null,null);
         
   }
   static testMethod void withoutMCN() {
       ParentsByMCNRestController.PersonWrapper personWrapper = new ParentsByMCNRestController.PersonWrapper();
         personWrapper.email ='a@b.com';
        Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id mcnRecId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Account Ac = new Account(Name='TestV',CDH_Owner_CoreID__c='NJPD36',Region__c='NA',Territory__c='T1',
                                 billingcountrycode ='US',RecordTypeID=prospectId,BillingPostalCode='1234',
                                 Billingcity='Test',Sic = '1041',Billing_County__c = 'US');        
        insert Ac;
              
        Account InsertMCN = new Account();
        InsertMCN.Name='TestMCN Record';
        InsertMCN.RecordTypeId = mcnRecId;
        InsertMCN.parentid = Ac.id;
        InsertMCN.Customer_or_Prospect_Account__c = Ac.id;
        InsertMCN.Motorola_Customer_Number__c = '112233';
        InsertMCN.ShippingCountry='United States';
        InsertMCN.ShippingState = 'Illinois';
        InsertMCN.Type = 'Direct Customer';
        InsertMCN.CDH_Owner_CoreID__c=null;
        insert InsertMCN;
       
        Account InsertMCNnew = new Account();
        InsertMCNnew.Name='TestMCN Record';
        InsertMCNnew.RecordTypeId = mcnRecId;
        InsertMCNnew.parentid = Ac.id;
        InsertMCNnew.Customer_or_Prospect_Account__c = Ac.id;
        InsertMCNnew.Motorola_Customer_Number__c = '1234567';
        InsertMCNnew.ShippingCountry='United States';
        InsertMCNnew.ShippingState = 'Illinois';
        InsertMCNnew.Type = 'Direct Customer';
        InsertMCNnew.CDH_Owner_CoreID__c=null;
        insert InsertMCNnew;
        
        Partner_Identifier__c partnerIden = new Partner_Identifier__c();
        partnerIden.Account__c =InsertMCN.id;
        partnerIden.ID_Number__c = '123456';
        insert partnerIden;
               
        Contact ConData = new Contact(FirstName='First',LastName='Last', Accountid=InsertMCN.id,RecordTypeId='01280000000LsIz',LDAP_Login__c='Ldaptr',TAG__C='ADP',/*Master_Flag__c='Master',*/email='abctest3@gmail.com');
        insert ConData;
       
        Technical_Site__c techSiteData = new Technical_Site__c();
        techSiteData.MCN_Account__c =InsertMCN.id;
        techSiteData.Customer__c=InsertMCNnew.Id;
        techSiteData.Site_ID__c  ='test';
        insert techSiteData;
       
        Technical_Site__c techSiteDataNw = new Technical_Site__c();
        techSiteDataNw.MCN_Account__c =InsertMCN.id;
        techSiteDataNw.Customer__c= InsertMCNnew.Id;
        techSiteDataNw.Site_ID__c  =techSiteData.Id;
        insert techSiteDataNw;       
        
        ParentsByMCNRestController.CreateCaseWrapperRequest request = new ParentsByMCNRestController.CreateCaseWrapperRequest();
        List<ParentsByMCNRestController.CreateCaseWrapperRequest> requestList = new List<ParentsByMCNRestController.CreateCaseWrapperRequest>();
        request.ldap =ConData.LDAP_Login__c;
        request.mcn ='112233';
        request.techSiteId = techSiteData.id;
        requestList.add(request);
        
        String JsonMsg=JSON.serialize(request);
          RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();    
           req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
           req.httpMethod = 'POST';//HTTP Request Type
           req.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = req;
           RestContext.response= res;
         List<ParentsByMCNRestController.CreateCaseWrapperResponse> responseDate =ParentsByMCNRestController.getParentssByMCNs(null,requestList,null);  
       // List<ParentsByMCNRestController.CreateCaseWrapperResponse> responseDate =ParentsByMCNRestController.getParentssByMCNs(null,listControllerMCNWrapper,personWrapper);
   }
    static testMethod void withoutMCNPtnrAcc() {
        ParentsByMCNRestController.MCNWrapper  controllerMCNWrapper = new ParentsByMCNRestController.MCNWrapper();
         List<ParentsByMCNRestController.MCNWrapper>  listControllerMCNWrapper = new List<ParentsByMCNRestController.MCNWrapper>();
         controllerMCNWrapper.mcn = '123456';         
         listControllerMCNWrapper.add(controllerMCNWrapper);
         controllerMCNWrapper = new ParentsByMCNRestController.MCNWrapper();
         controllerMCNWrapper.mcn = '11223344';
         listControllerMCNWrapper.add(controllerMCNWrapper);
         
         ParentsByMCNRestController.PersonWrapper personWrapper = new ParentsByMCNRestController.PersonWrapper();
         personWrapper.email ='a@b.com';
         
         Id prospectId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        Id mcnRecId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Motorola Customer Number').getRecordTypeId();
        Id ptnrRecId =Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account Ac = new Account(Name='TestV',CDH_Owner_CoreID__c='NJPD36',Region__c='NA',Territory__c='T1',
                                 billingcountrycode ='US',RecordTypeID=prospectId,BillingPostalCode='1234',
                                 Billingcity='Test',Sic = '1041',Billing_County__c = 'US');        
        insert Ac;
       
         
        Account InsertPtnrAcc = new Account();
        InsertPtnrAcc.Name='TestPtnr Record';
        InsertPtnrAcc.RecordTypeId =prospectId;// ptnrRecId;
        InsertPtnrAcc.parentid = Ac.id;
        InsertPtnrAcc.Customer_or_Prospect_Account__c = Ac.id;
        InsertPtnrAcc.Motorola_Customer_Number__c = '11223344';
        InsertPtnrAcc.ShippingCountry='United States';
        InsertPtnrAcc.ShippingState = 'Illinois';
        InsertPtnrAcc.Type = 'Direct Customer';
        InsertPtnrAcc.BillingCountry= 'United States';
        InsertPtnrAcc.BillingState = 'Illinois';
        InsertPtnrAcc.BillingCity='Chicago';
        InsertPtnrAcc.Billing_County__c = 'US';
        InsertPtnrAcc.CDH_Owner_CoreID__c=null;
        insert InsertPtnrAcc;
        
        Account InsertMCNnew = new Account();
        InsertMCNnew.Name='TestMCN Record';
        InsertMCNnew.RecordTypeId = mcnRecId;
        InsertMCNnew.parentid = Ac.id;
        InsertMCNnew.Customer_or_Prospect_Account__c = Ac.id;
        InsertMCNnew.Motorola_Customer_Number__c = '1234567';
        InsertMCNnew.ShippingCountry='United States';
        InsertMCNnew.ShippingState = 'Illinois';
        InsertMCNnew.Type = 'Direct Customer';
        InsertMCNnew.CDH_Owner_CoreID__c=null;
        insert InsertMCNnew;
        
        Partner_Identifier__c partnerIden = new Partner_Identifier__c();
        partnerIden.Account__c =InsertPtnrAcc.id;
        partnerIden.ID_Number__c = '11223344';
        insert partnerIden;
        
        Contact ConData = new Contact(FirstName='First',LastName='Last', Accountid=InsertPtnrAcc.id,RecordTypeId='01280000000LsIz',LDAP_Login__c='Ldaptr',TAG__C='ADP',/*Master_Flag__c='Master',*/email='abctest3@gmail.com');
        
        Technical_Site__c techSiteData = new Technical_Site__c();
        techSiteData.MCN_Account__c =InsertPtnrAcc.id;
        techSiteData.Customer__c=InsertMCNnew.Id;
        techSiteData.Site_ID__c  ='testthree';
        insert techSiteData;
        
        ParentsByMCNRestController.CreateCaseWrapperRequest request = new ParentsByMCNRestController.CreateCaseWrapperRequest();
        request.ldap =ConData.LDAP_Login__c;
        request.mcn =controllerMCNWrapper.mcn;
        request.techSiteId = techSiteData.id;
        List<ParentsByMCNRestController.CreateCaseWrapperRequest> listRequest = new List<ParentsByMCNRestController.CreateCaseWrapperRequest>();
        listRequest.add(request);
        
        String JsonMsg=JSON.serialize(request);
          RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();    
           req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
           req.httpMethod = 'POST';//HTTP Request Type
           req.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = req;
           RestContext.response= res;
           
        List<ParentsByMCNRestController.CreateCaseWrapperResponse> responseDate =ParentsByMCNRestController.getParentssByMCNs(listControllerMCNWrapper,null,null);
         
       
   }
    
    static testMethod void withoutMCNCasesWithAcc() {
        ParentsByMCNRestController.PersonWrapper personWrapper = new ParentsByMCNRestController.PersonWrapper();
        personWrapper.email ='a123@b.com';
        Id recordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Internal Person Account').getRecordTypeId();
        Account acc= new Account(
          RecordTypeID=recordTypeId ,
          FirstName='Test FName',
          LastName='Test LName',
          PersonEmail='a123@b.com'
        ); 
        insert acc;
        
         List<ParentsByMCNRestController.CreateCaseWrapperResponse> responseDate =ParentsByMCNRestController.getParentssByMCNs(null,null,personWrapper);  
   }
   
    static testMethod void withoutMCNCasesWithOutAcc() {
        ParentsByMCNRestController.PersonWrapper personWrapper = new ParentsByMCNRestController.PersonWrapper();
        personWrapper.email ='a12345@b.com';
        List<ParentsByMCNRestController.CreateCaseWrapperResponse> responseDate =ParentsByMCNRestController.getParentssByMCNs(null,null,personWrapper);  
   } 

}