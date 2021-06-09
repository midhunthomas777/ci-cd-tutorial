@isTest
public class AreaOfFocus_CheckForKeyPlayerRoleTest
{
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }

static testMethod void validateAreaOfFocus_CheckForKeyPlayerRole() {
Account acc = new Account(Name= 'a',Billingcity = 'San Mateo',Billingstate = 'Texas',BillingCountry = 'United States',BillingPostalCode='123');
insert acc;
Focus_Area__c fa1 = new Focus_Area__c(Name= 'fa', Account__c = acc.Id);
insert fa1;
Focus_Player__c fp1 = new Focus_Player__c(Role__c ='Executive Sponsor',R_A__c = 'Opportunistic',Focus_Area__c = fa1.Id);
Focus_Player__c fp2 = new Focus_Player__c(Role__c ='Marketing Player',R_A__c = 'Working',Focus_Area__c = fa1.Id);
Focus_Player__c fp3 = new Focus_Player__c(Role__c ='Logistical Player',R_A__c = 'Valued',Focus_Area__c = fa1.Id);
Focus_Player__c fp4 = new Focus_Player__c(Role__c ='Strategic Coach',R_A__c = 'Interdependent',Focus_Area__c = fa1.Id);
Focus_Player__c fp5 = new Focus_Player__c(Role__c ='Anti-Sponsor',R_A__c = 'Organizational',Focus_Area__c = fa1.Id);
Focus_Player__c fp6 = new Focus_Player__c(Role__c ='Other',R_A__c = 'Opportunistic',Focus_Area__c = fa1.Id);
insert fp1;
insert fp2;
insert fp3;
insert fp4;
insert fp5;
insert fp6;
fp1.Role__c ='Marketing Player';
fp1.R_A__c = 'Working';
update fp1;
fp2.Role__c ='Logistical Player';
fp1.R_A__c = 'Valued';
update fp2;
fp3.Role__c ='Strategic Coach';
fp1.R_A__c = 'Interdependent';
update fp3;
fp4.Role__c ='Anti-Sponsor';
fp1.R_A__c = 'Organizational';
update fp4;
fp5.Role__c ='Other';
fp1.R_A__c = 'Working';
update fp5;
fp6.Role__c ='Logistical Player';
fp1.R_A__c = 'Interdependent';
update fp6;
delete fp1;
delete fp2;
delete fp3;
delete fp4;
delete fp5;
delete fp6;
}
}