@isTest
private class GenerateVertex_agrmt_Ext_Test{
    @testSetup
    static void testdatasetup() {
        List<TriggerSettings__c> tsc = new List<TriggerSettings__c>();
        tsc.add(new TriggerSettings__C(Name='UserTriggerDisabled',Isactive__C=false));
        Insert tsc;
    }
    
    static TestMethod void test1(){
        USER u = TestdatasetupUtils.createInternalUser();
        System.runAs(u){
            TestdatasetupUtils.insertCustomSettings();
            TestdatasetupUtils.activateAccTrigger();
            TestdatasetupUtils.activateContTrigger();
            TestdatasetupUtils.activateOpplineItemTrigger();
            TestDataSetUpUtils.activatPartnerCommunityOpportunityMasterTrigger();
            TestdatasetupUtils.activateOppTrigger();
            List<Account> lstAcc = TestDataSetUpUtils.createAccounts(1,Schema.SObjectType.Account.RecordTypeInfosByName.get('Prospect').RecordTypeId);
            list<contact> lstCont = TestDataSetUpUtils.createContacts(1,Schema.Sobjecttype.contact.getRecordTypeInfosByName().get('Partner').getRecordTypeId(),lstAcc);
            List<Opportunity> lstOpps = TestDataSetUpUtils.createOpportunities(1,Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Project').getRecordTypeId(),lstAcc);
            List<Presales__c> lstPreSale = TestDataSetUpUtils.CreatepreSaleRecords(1,Schema.Sobjecttype.Presales__c.getRecordTypeInfosByName().get('NA Presales Resource').getRecordTypeId(),lstOpps);
            LIST<Apttus__APTS_Agreement__c> lstAgrremetn=TestDataSetUpUtils.createAgreement(1,Schema.Sobjecttype.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Sales').getRecordTypeId(),lstAcc,lstPreSale[0],lstOpps);
            lstAgrremetn[0].Apttus__Status__c = 'Approved Request';
            update lstAgrremetn[0];
            Id agreeId = lstAgrremetn[0].Id;
            
            Generate_Vertex_agreement_Extension obj = new Generate_Vertex_agreement_Extension(new ApexPages.StandardController(lstAcc[0]));
            obj.createvertexAgreement();
            
            
            
            //   Apttus__APTS_Template__c vertex=new Apttus__APTS_Template__c(name='VERTEX');
            //   insert vertex;
            //   Apttus__TemplateDynamicSection__c apteDynamic=new Apttus__TemplateDynamicSection__c(Apttus__TemplateId__c=vertex.Id,Apttus__RulesetName__c='rule1');
            //    insert apteDynamic;
            //    Apttus__DocAssemblyRuleset__c  docrule=new Apttus__DocAssemblyRuleset__c(Apttus__ChildObject__c='child',Apttus__Description__c='text2',Apttus__BusinessObject__c='Apttus__APTS_Agreement__c');
            //   insert docrule;
            String MySessionID = UserInfo.getSessionID(); 
            String agreementId = '123456';
            Test.startTest();
          
            Agreement__c agreement = new Agreement__c();
            agreement.Name = 'Test Agreement';
            insert agreement;
            Apttus__APTS_Template__c templatesOb = new Apttus__APTS_Template__c(); 
            templatesOb.Name = 'VERTEX';
            insert templatesOb;
            ID templateId;
            String generatedDocId;
              Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

            Generate_Vertex_agreement_Extension.generateDoc( MySessionID , agreement.id);

            Test.stopTest();
            //  String ids=string.valueOf(lstAgrremetn[0].id);
            // Generate_Vertex_agreement_Extension.generateDoc(MySessionID,ids);
        }   
        
    }
}