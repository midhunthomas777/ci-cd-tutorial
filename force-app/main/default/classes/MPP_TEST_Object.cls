/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MPP_TEST_Object {
    @testSetup
   static void testSetUp() {
       TestDataSetUpUtils.insertCustomSettings();
   }
    /*static testMethod void mppObjectTest() {
      Account a = MPP_TEST_DataHelper.getAccountWithDefaults();
      Contact c = MPP_TEST_DataHelper.getContactWithDefaults(a.Id);
      User u = MPP_TEST_DataHelper.getDefaultPortalUser(c.Id);
        cms__Sites__c site = MPP_CCT_TEST_Constants.makeSiteWithDefaults();
        cms__Content_Layout__c cl = MPP_CCT_TEST_Constants.makeContentLayoutWithDefaults();
        cms__Content_Type__c ct =  MPP_CCT_TEST_Constants.makeContentTypeWithDefaults(site.id);
        cms__Content__c content = MPP_CCT_TEST_Constants.makeContentWithDefaults(cl.Id, ct.Id, site.id); 
      
      
      Test.startTest();
      System.runAs(u){
        MPP_Object.CustomUser cu = new MPP_Object.CustomUser(u);
        cu = new MPP_Object.CustomUser();
        cu.getField('userId');
        cu.checkNull('');

      MPP_Object.UserEmpoweringTools et = new MPP_Object.UserEmpoweringTools(u.Id);

      User user = MPP_Object.mapCustomUserToUser(cu);
      
      MPP_Object.ContentWrapper cw = new MPP_Object.ContentWrapper(content);
      MPP_Object.ContentWrapper cw1 = new MPP_Object.ContentWrapper(content);
      List<MPP_Object.ContentWrapper> cwList = new List<MPP_Object.ContentWrapper>{cw, cw1};
      
      cwList.sort();

      }
      Test.stopTest(); 
      
    }*/
    
    static testMethod void mppObjectTest2() {
      User user = [Select Id FROM User WHERE  ContactId = null AND isActive = true LIMIT 1];
      Test.startTest();
      System.runAs(user){
      MPP_Object.UserEmpoweringTools et = new MPP_Object.UserEmpoweringTools(user.Id);
      MPP_Object.CustomUser et1 = new MPP_Object.CustomUser();
      et1.getField('userId');
      et1.checkNull('');
      User user1 = MPP_Object.mapCustomUserToUser(et1);
      }
      Test.stopTest();
      
    }
    
}