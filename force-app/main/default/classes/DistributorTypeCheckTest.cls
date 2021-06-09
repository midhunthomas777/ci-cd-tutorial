@isTest
private class DistributorTypeCheckTest {

      @testSetup
      static void testSetUp() {
        TestDataSetUpUtils.insertCustomSettings();
      }
        
      public static testMethod void DistributorTypeCheck_test() {
      
                 
            List<Account> acc11 = new List<Account>();
            List<Account> acc22 = new List<Account>();
            
             RecordType rec =[Select r.Id From RecordType r where r.SobjectType='Account' and r.name='Partner'];
                 
          // Start Test
          test.startTest();
          
          // Create Staged Program Member
          Account acc1 = new Account(Name='Testing Account1',Type = 'Partner', RecordTypeId = rec.id,Company_Description__c = 'Testing Description1', Distributor_Partner__c = False );           
          Account acc2 = new Account(Name='Testing Account2',Type = 'Partner', RecordTypeId = rec.id,Company_Description__c = 'Testing Description2', Distributor_Partner__c = False ); 

            acc11.add(acc1);     
            acc11.add(acc2);
          
           
          insert acc11;
          
          List<Partner_Type__c> ptype11 = new List<Partner_Type__c>();
          
          Partner_Type__c pType1 = new Partner_Type__c(Program__c = 'Mobility',Account__c = acc1.Id,Partner_Level__c = 'Premier Super Partner',
          Partner_Track__c='Distributor',Status__c='Active',   Compliance_Status__c='Compliant');
          Partner_Type__c pType2 = new Partner_Type__c(Program__c = 'RADIO',Account__c = acc2.Id,Partner_Level__c = 'Premier Super Partner',
          Partner_Track__c='Reseller',Status__c='Active',Compliance_Status__c='Compliant');
          
          ptype11.add(pType1);
          ptype11.add(pType2);
          
          insert ptype11;         
          
          
          
         
          DistributorTypeCheck distriCheck = new DistributorTypeCheck();
          distriCheck.query = 'select id,Account__c from Partner_Type__c where Partner_Track__c=\'Distributor\' and Account__r.Distributor_Partner__c=False Limit 1';
          Id batchTestId = Database.executeBatch(distriCheck);
          system.debug('***batchTestId :'+batchTestId);
          
          // Stop test
          test.stopTest();
      }
      }