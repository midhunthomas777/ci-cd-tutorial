/* Test Class for CaseInboundRestController */

@isTest
public class CaseInboundRestController_Test {
    @testSetup
    static void testSetUp() {
        
        TestDataSetUpUtils.insertCustomSettings();
        List<TriggerSettings__c> tSC = new List<TriggerSettings__c>();
        tsc.add(new TriggerSettings__C(Name = 'FeedItemTriggerDisabled', IsActive__C=false));
        Insert tSC;          
    }
    
    @isTest
    static void testforPost(){
        
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        Id DevNameRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Motorola_Customer_Number').getRecordTypeId();
        List<Account> accList = TestDataSetUpUtils.createAccounts(2,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        Contact c1 = contactList.get(0);
        c1.LastName='LN_test';
        c1.Email ='EMtest@gmail.com';
        c1.FirstName = 'FN1_test';
        c1.Phone = '9163083597';
        c1.LDAP_Login__c = '344567';
        update c1;
        contactList.add(c1);
        
        Account CustAc = accList.get(1);
        CustAc.Parentid = accList.get(0).Id;
        CustAc.RecordTypeId = DevNameRecType;
        update CustAc;
        accList.add(CustAc);
        
        
        List<Technical_Site__c> tList = new List<Technical_Site__c>();    
        Technical_Site__c tsite = new Technical_Site__c();
        // tsite.Name = '5601 Allegan Co Dispatch3';
        tsite.Status__c = 'Inactive';
        tsite.Site_Type__c  = 'Inactive';
        tsite.Site_ID__c='7784356';
        tsite.MCN_Account__c = accList.get(0).id;
        tsite.Customer__c= accList.get(0).id;
        tsite.Primary_Street__c = 'testStreet';
        tsite.Primary_City__c='Pune';
        tsite.Primary_State_Province__c= 'MH';
        tsite.Primary_Country__c = 'India';
        tsite.Primary_Zip_Postal_Code__c = '411057';
        tsite.Customer__c= accList.get(0).id;
        tsite.Site_ID__c = String.valueOf(Math.random());
        tsite.Site_Usage__c = 'Headquarters';
        tList.add(tsite);
        
        Technical_Site__c tsite1 = new Technical_Site__c();
        
        tsite1.Status__c = 'Inactive';
        tsite1.Site_Type__c  = 'Inactive';
        tsite1.MCN_Account__c = accList.get(0).id;
        tsite1.Primary_Street__c = 'testStreet';
        tsite1.Primary_City__c='Pune';
        tsite1.Primary_State_Province__c= 'MH';
        tsite1.Primary_Country__c = 'India';
        tsite1.Customer__c= accList.get(0).id;
        tsite1.Site_ID__c = String.valueOf(Math.random());
        tsite1.Primary_Zip_Postal_Code__c = '411057';
        tsite1.Site_Usage__c = 'Technical';
        tList.add(tsite1);
        insert tList;
        
        //Group grp = [select id,relatedid,name,developername from Group where type='Queue' and developername='CPQ_Support' limit 1];
        
        
       
        CaseRequestWrapper reqWrp = new CaseRequestWrapper();
        
        reqWrp.caseOrigin='Phone';
        reqWrp.remedyId = 'test1234';
        reqWrp.dataSource = 'Portal';
        reqWrp.queueName = 'CPQ_Support';
        reqWrp.title = 'Remedy case';
        reqWrp.description ='case details';
        reqWrp.caseType1 = 'Technical Support';
        reqWrp.status = 'Open';
        reqWrp.techSiteId = '2323145';
        reqWrp.impact = 'Severity3';
        reqWrp.mcn= '4576344';
        //   reqWrp.queueName = grp.id;
        reqWrp.recordtype = 'MSI_Support_Case_Technical_Request';
        //  reqWrp.firstName = 'FN_test';
        // reqWrp.phone = '9843435678';
        reqWrp.email = 'EMtest@gmail.com';
        reqWrp.lastName = 'LN_test';
        
        String myJSON = JSON.serialize(reqWrp);
        
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            
            test.stopTest();
            
            
            
        }
        
        caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        System.assertEquals(thisCs.Subject, 'Remedy case');
       
        System.assertEquals(201, res.statusCode);
    }
    
    @isTest
    static void testforTechSite(){
        
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        Id DevNameRecType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Motorola_Customer_Number').getRecordTypeId();
        List<Account> accList = TestDataSetUpUtils.createAccounts(2,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        Contact c1 = contactList.get(0);
        c1.LastName='LN_test';
        c1.Email ='EMtest@gmail.com';
        c1.FirstName = 'FN1_test';
        c1.Phone = '9163083597';
        c1.LDAP_Login__c = '344567';
        update c1;
        contactList.add(c1);
        
        Account CustAc = accList.get(1);
        CustAc.Parentid = accList.get(0).Id;
        CustAc.RecordTypeId = DevNameRecType;
        update CustAc;
        accList.add(CustAc);
        
        
        List<Technical_Site__c> tList = new List<Technical_Site__c>();    
        Technical_Site__c tsite = new Technical_Site__c();
        // tsite.Name = '5601 Allegan Co Dispatch3';
        tsite.Status__c = 'Inactive';
        tsite.Site_ID__c='7784356';
        tsite.MCN_Account__c = accList.get(0).id;
        tsite.Customer__c = accList.get(0).id;
        tsite.Primary_Street__c = 'testStreet';
        tsite.Primary_City__c='Pune';
        tsite.Primary_State_Province__c= 'MH';
        tsite.Primary_Country__c = 'India';
        tsite.Site_Type__c = 'Inactive';
        tsite.Primary_Zip_Postal_Code__c = '411057';
        tsite.Site_Usage__c = 'Technical';
        tList.add(tsite);
        
        
        insert tList;
        
        //Group grp = [select id,relatedid,name,developername from Group where type='Queue' and developername='CPQ_Support' limit 1];
        
        
             
        CaseRequestWrapper reqWrp = new CaseRequestWrapper();
       
        reqWrp.caseOrigin='Phone';
        reqWrp.remedyId = 'test1234';
        reqWrp.dataSource = 'Portal';
        reqWrp.queueName = 'test_1';
        reqWrp.title = 'Remedy case';
        reqWrp.description ='case details';
        reqWrp.caseType1 = 'Technical Support';
        reqWrp.status = 'Open';
        reqWrp.techSiteId = '7784356';
        reqWrp.impact = 'Severity 3';
        // reqWrp.mcn= '4576344';
        //   reqWrp.queueName = grp.id;
        reqWrp.recordtype = 'MSI_Support_Case_Technical_Request';
        //  reqWrp.firstName = 'FN_test';
        // reqWrp.phone = '9843435678';
        reqWrp.email = 'EMtest@gmail.com';
        reqWrp.lastName = 'LN_test';
        
        String myJSON = JSON.serialize(reqWrp);
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
           
            
            
        }
          caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in testforTechSite::'+resp1);
        Id csId = resp1.result.caseId;
        System.debug('CaseId###'+csId);
        
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
      
        System.assertEquals(201, res.statusCode);
        
        
    }
    
    
    @istest
    static void testForContact() {
        
        
        
            
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        Account ac = accList.get(0);
        ac.Motorola_Customer_Number__c = '3345678923';
        update ac;
        
        List<Contact> cList = new List<Contact>();
        Contact c = contactList.get(0);
        c.Phone='114568';
        c.FirstName='test';
        c.LastName='Contact';
        c.LDAP_Login__c ='2387654';
        c.Email = 'con2@abc.com';
        update c;
        cList.add(c);
        
        Contact c1 = contactList.get(1);
        c1.Phone='114555';
        c1.FirstName='test';
        c1.LastName='Contact';
        c1.LDAP_Login__c ='23876565';
        c1.Email = 'con6@abc.com';
        update c1;
        cList.add(c1);
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        // reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.contactId = contactList[0].id;
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        String myJSON1 = JSON.serialize(reqWrp1);
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            System.debug('User in testForContact'+Userinfo.getUserId());
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
          
            
        }
        
          caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in testForContact::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
       // System.assertEquals(thisCs.Subject, 'Remedy case');
       
        System.assertEquals(201, res.statusCode);
        
    }
    
    @isTest
    static void testforPost1() {
        
       
            Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
            List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
            Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
            List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
            Account ac = accList.get(0);
            ac.Motorola_Customer_Number__c = '3345678921';
            update ac;
            
            List<Contact> cList = new List<Contact>();
            Contact c = contactList.get(0);
            c.Phone='114568';
            c.FirstName='test';
            c.LastName='contact';
            c.LDAP_Login__c ='2387654';
            update c;
            cList.add(c);
            
            Contact c1 = contactList.get(1);
            c1.Phone='114568';
            c1.FirstName='test';
            c1.LastName='contact';
            c1.LDAP_Login__c ='23876565';
            update c1;
            cList.add(c1);
            
            
            //Assuming there is no matching technical site Id
            Technical_Site__c tsite = new Technical_Site__c();
            //tsite.Name = '5601 Allegan Co Dispatch3';
            tsite.Status__c = 'Inactive';
            tsite.Site_ID__c='7784356';
            tsite.MCN_Account__c = ac.id;
            tsite.Customer__c= ac.id;
            tsite.Primary_Street__c = 'testStreet';
            tsite.Primary_City__c='Pune';
            tsite.Primary_State_Province__c= 'MH';
            tsite.Primary_Country__c = 'India';
            tsite.Primary_Zip_Postal_Code__c = '411057';
            tsite.Site_Type__c = 'Inactive';
            tsite.Site_Usage__c = 'Technical';
            insert tsite;
            
            
            
            CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
           reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        // reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.contactId = contactList[0].id;
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        String myJSON1 = JSON.serialize(reqWrp1);
            
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(myJSON1);
            request.addHeader('Content-Type','application/json');
            
            RestContext.request = request;
            RestContext.response = res;
            
             System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
           
            
        }
    
        
          caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in testforPost1::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
       // System.assertEquals(thisCs.Subject, 'Remedy case');
       
        System.assertEquals(201, res.statusCode);
        
    }
    
    @isTest
    static void testforPost3() {
        
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        Account ac = accList.get(0);
        Contact c = contactList.get(0);
        
        
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.firstName = 'test';
        reqWrp1.lastName = 'Contact';
        //  reqWrp1.phone = '1233456';
        reqWrp1.email = 'newCon@xyz.com';
        
        String myJSON1 = JSON.serialize(reqWrp1);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
            
        }
        
        caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in testforPost3::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
        
    }
    
    @istest
    static void testforPost4() {
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        Account ac = accList.get(0);
        Contact c = contactList.get(0);
        c.LDAP_Login__c = '365';
        update c;
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.firstName = 'test';
        reqWrp1.lastName = 'Contact';
        reqWrp1.phone = '1233456';
        reqWrp1.email = 'newCon@xyz.com';
        
        String myJSON1 = JSON.serialize(reqWrp1);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
            
            
        }
        
         caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in testforPost4::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
    }
    
    
    
    @isTest
    static void nullContactwithmcn() {
        
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Account a1 = accList.get(0);
        a1.Motorola_Customer_Number__c = '2334567676';
        update a1;
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
     //   reqWrp1.caseType1 = 'Administrative';
        reqWrp1.status = 'Open';
        reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.mcn = '2334567676';
        
        String myJSON1 = JSON.serialize(reqWrp1);
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            test.stopTest();
            
            
        }
        
           caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in nullContactwithmcn::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
    }
    
    @isTest
    static void nullConwithoutMcn(){
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        Contact c = contactList.get(0);
        c.Phone='114568';
        c.FirstName='test';
        c.LastName='contact';
        c.Email = 'con3@test.com';
        c.LDAP_Login__c = '78678';
        update c;
        contactList.add(c);
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        //  reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        // reqWrp1.mcn = '2334567676';
        reqWrp1.lastName = 'contact5';
        reqWrp1.email = 'con5@test.com';
        
        String myJSON1 = JSON.serialize(reqWrp1);
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            
            test.startTest();
            CaseInboundRestController.createCase();
           
            
            test.stopTest();
           
            
        }
        
        caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in nullConwithoutMcn::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
         
    }
    
    
    @istest
    static void ContactwithMcn() {
        
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        
        Account a1 = accList.get(0);
        a1.Motorola_Customer_Number__c = '3345678923';
        update a1;
        accList.add(a1);
        
        Contact c = contactList.get(0);
        c.Phone='114568';
        c.FirstName='test';
        c.LastName='contact';
        c.Email = 'con3@test.com';
        
        c.LDAP_Login__c = '78678';
        update c;
        contactList.add(c);
        
        Contact c1 = contactList.get(1);
        c1.Phone='11456889';
        c1.FirstName='test';
        c1.LastName='Contact';
        c1.Email = 'con4@test.com';
        // c1.LDAP_Login__c = '78677';
        update c1;
        contactList.add(c1);        
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
       // reqWrp1.caseType1 = 'Administrative';
        reqWrp1.status = 'Open';
        // reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.mcn = '33456789234';
        reqWrp1.lastName = 'Contact';
        reqWrp1.phone = '114568';
        reqWrp1.email = 'con3@test.com';
        
        String myJSON1 = JSON.serialize(reqWrp1);
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
            
            
        }
        
          caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in ContactwithMcn::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
    }
    
    @isTest
    static void MSIContacttest(){
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList);
        
        Id contctId = contactList.get(0).Id;

        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        // reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.contactId = contctId;
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        String myJSON1 = JSON.serialize(reqWrp1);
        
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
            
            
            
        }
        
          caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in MSIContacttest::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
        
        
    }
    
 @istest
    static void testforPost5() {
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        Contact con = new Contact();
                con.AccountId = accList.get(0).Id;
                con.RecordtypeId = contactRecordTypeID;
                con.ldap_login__c = 'masters';
                con.FirstName = 'Test FName0' ;
                con.LastName = 'Test LName0';
                con.FirstNameLocal = 'Test';
                con.email = 'TestLname'+String.valueOf(Math.random())+'@gmail.com';
                con.Tag__c = 'SFDC Partner Admin';
                con.LastNameLocal = 'Partner Contact';
        		con.Phone='1233456';
                insert con;
        
        Account ac = accList.get(0);
        Contact c = contactList.get(0);
        c.LDAP_Login__c = '365';
        update c;
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.firstName = 'Test FName0';
        reqWrp1.lastName = 'Test LName0';
        reqWrp1.phone = '1233456';
        reqWrp1.email = 'newCon@xyz.com';
        
        String myJSON1 = JSON.serialize(reqWrp1);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
            
            
        }
        
        caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in testforPost4::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
    }
    
 @istest
    static void testforPost6() {
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(1,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        Contact con = new Contact();
                con.AccountId = accList.get(0).Id;
                con.RecordtypeId = contactRecordTypeID;
                con.ldap_login__c = 'masters';
                con.FirstName = 'Test FName0' ;
                con.LastName = 'Test LName0';
                con.FirstNameLocal = 'Test';
                con.email = 'TestLname'+String.valueOf(Math.random())+'@gmail.com';
                con.Tag__c = 'SFDC Partner Admin';
                con.LastNameLocal = 'Partner Contact';
        		con.Phone='1233456';
                insert con;
        
        Account ac = accList.get(0);
        Contact c = contactList.get(0);
        c.LDAP_Login__c = '365';
        update c;
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.firstName = 'Test FName';
        reqWrp1.lastName = 'Test LName0';
        reqWrp1.phone = '1233456';
        reqWrp1.email = con.email;
        
        String myJSON1 = JSON.serialize(reqWrp1);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
            
            
        }
        
        caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in testforPost4::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
    }
    
 @istest
    static void testforPost7() {
        
        Id RecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();  
        List<Account> accList = TestDataSetUpUtils.createAccounts(2,RecordTypeId);
        Id contactRecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId(); 
        List<Contact> contactList = TestDataSetUpUtils.createcontacts(2,contactRecordTypeID,accList); 
        Contact con = new Contact();
                con.AccountId = accList.get(0).Id;
                con.RecordtypeId = contactRecordTypeID;
                con.ldap_login__c = 'masters';
                con.FirstName = 'Test FName0' ;
                con.LastName = 'Test LName0';
                con.FirstNameLocal = 'Test';
                con.email = 'TestLname1@gmail.com';
                con.Tag__c = 'SFDC Partner Admin';
                con.LastNameLocal = 'Partner Contact';
        		con.Phone='1233456';
                insert con;
        Contact con1 = new Contact();
                con1.AccountId = accList.get(0).Id;
                con1.RecordtypeId = contactRecordTypeID;
                con1.ldap_login__c = 'masters1';
                con1.FirstName = 'Test FName0' ;
                con1.LastName = 'Test LName0';
                con1.FirstNameLocal = 'Test';
                con1.email = 'TestLname2@gmail.com';//con.email;//'TestLname'+String.valueOf(Math.random())+'@gmail.com';
                con1.Tag__c = 'SFDC Partner Admin';
                con1.LastNameLocal = 'Partner Contact';
        		con1.Phone='1233456';
                insert con1;
        Account ac = accList.get(0);
        Contact c = contactList.get(0);
        c.LDAP_Login__c = '365';
        update c;
        
        CaseRequestWrapper reqWrp1 = new CaseRequestWrapper();
        reqWrp1.caseOrigin='Phone';
        reqWrp1.remedyId = 'test1234';
        reqWrp1.dataSource = 'Portal';
        reqWrp1.title = 'Remedy case';
        reqWrp1.description ='case details';
        reqWrp1.recordtype = 'MSI_Support_Case_Technical_Request';
        reqWrp1.caseType1 = 'Technical Support';
        reqWrp1.status = 'Open';
        reqWrp1.techSiteId = '7784356';
        reqWrp1.impact = 'Severity3'; 
        reqWrp1.firstName = 'Test FName0';
        reqWrp1.lastName = 'Test LName0';
        reqWrp1.phone = '1233456';
        reqWrp1.email = con.email;
        
        String myJSON1 = JSON.serialize(reqWrp1);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = URL.getSalesforceBaseUrl() + '/services/apexrest/CaseRESTService/v1';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON1);
        request.addHeader('Content-Type','application/json');
        
        RestContext.request = request;
        RestContext.response = res;
        System.runAs(new User(Id = System.label.IntegrationUserId)) {
            test.startTest();
            CaseInboundRestController.createCase();
            
            test.stopTest();
            
            
        }
        
        caseResponseWrapper resp1 = (caseResponseWrapper)JSON.deserializeStrict(res.responseBody.toString(),caseResponseWrapper.class);
        System.debug('Response returned in testforPost4::'+resp1);
        Id csId = resp1.result.caseId;
        Case thisCs = [Select Id,Subject from case where Id=:csId];
        System.assert(thisCs!=null);
        // System.assertEquals(thisCs.Subject, 'Remedy case');
        
        System.assertEquals(201, res.statusCode);
    }
    
    
}