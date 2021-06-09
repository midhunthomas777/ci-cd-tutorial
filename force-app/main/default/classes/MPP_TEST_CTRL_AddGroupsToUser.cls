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
private class MPP_TEST_CTRL_AddGroupsToUser {

    static testMethod void controllerNewTest() {
    	Attribute_Group_Mapping__c agm = new Attribute_Group_Mapping__c();
    	Group g = new Group(name = 'PC-Random');
    	insert g;
    	
    	Test.startTest();
    	//new test
    	MPP_Class_CTRL_AddGroupsToUser c = new MPP_Class_CTRL_AddGroupsToUser(new ApexPages.Standardcontroller(agm));
  		System.assertEquals(true, c.isNew);
  		c.groupSearch = 'Random';
  		c.searchGroups();
  		
  		c.idOfGroup = g.Id;
  		c.selectGroup();
  		
  		System.assertNotEquals(null, c.cancel());
  		
  		System.assertEquals(null, c.save());
  		
  		c.agm.Group__c = g.Name;
  		c.agm.GroupId__c = g.Id;
  		
  		c.agm.Community__c = 'something....';
  		
  		c.agm.Technology_Specialization__c = 'tech';
  		c.agm.Market_Specialization__c = 'market';
  		c.agm.Application_Specialization__c = 'app';
  		c.validateForm();
  		c.agm.Technology_Specialization__c = null;
  		c.agm.Market_Specialization__c = null;
  		c.agm.Application_Specialization__c = null;
  		c.agm.Technology_Specialization_Level__c = 'level';
  		c.agm.Market_Specialization_Level__c = 'level';
  		c.agm.Application_Specialization_Level__c = 'level';
  		c.validateForm();
  		c.agm.Technology_Specialization__c = 'tech';
  		c.agm.Market_Specialization__c = 'market';
  		c.agm.Application_Specialization__c = 'app';
  		
  		
  		c.save();
  		c.isNew = false;
  		c.save();
  		
    	Test.stopTest();
    }

    static testMethod void controllerUpdateTest() {
    	Attribute_Group_Mapping__c agm = new Attribute_Group_Mapping__c(Group__c = 'name');
    	insert agm;
    	
    	Test.startTest();
    	//update test
    	MPP_Class_CTRL_AddGroupsToUser c = new MPP_Class_CTRL_AddGroupsToUser(new ApexPages.Standardcontroller(agm));
  		System.assertEquals(false, c.isNew);
  		
  		//c.agm.Application_Specialization__c = 'something';
  		//System.assertNotEquals(null, c.save());

  		c.agm.Group__c = 'something different';
  		c.save();
  
    	Test.stopTest();
    }
}