/*
 * Copyright (c) 2018. 7Summits Inc. 
 */

/**
 * Created by francoiskorb on 8/9/18.
 */

@IsTest
private class Match_UserAttributeWizardTest
{
	public static testMethod void testGetAttributesGroupByType()
	{
		List<String> listOfTypes = new List<String> {'Location', 'Skill', 'Preference'};
		List<Match_Attribute__c> listOfAttributes = Match_Test_Util.createAttribute(listOfTypes);

		//debug 15 attributes are inserted
		listOfAttributes = [SELECT Id FROM Match_Attribute__c];
		System.assert(listOfAttributes != null && listOfAttributes.size() == 15);

		//get attributes from controller
		String dataAsJSON = Match_UserAttributeWizard.getAttributesGroupByType('Location', 'User_Attribute__c', 'User__c', UserInfo.getUserId());
		List<Match_UserAttributeWizard.AttributeCategoryWrapper> mapOfAttributes = (List<Match_UserAttributeWizard.AttributeCategoryWrapper>) JSON.deserialize(dataAsJSON, List<Match_UserAttributeWizard.AttributeCategoryWrapper>.class);

		System.assert(mapOfAttributes[0].category == 'Location');
		System.assert(mapOfAttributes[0].listOfAttributes != null && mapOfAttributes[0].listOfAttributes.size() == 5);

		//check for multiple types
		dataAsJSON = Match_UserAttributeWizard.getAttributesGroupByType('Location,Skill', 'User_Attribute__c', 'User__c', UserInfo.getUserId());
		mapOfAttributes = (List<Match_UserAttributeWizard.AttributeCategoryWrapper>) JSON.deserialize(dataAsJSON, List<Match_UserAttributeWizard.AttributeCategoryWrapper>.class);

		System.assert(mapOfAttributes != null && mapOfAttributes.size() == 2);

		System.assert(mapOfAttributes[0].category == 'Location');
		System.assert(mapOfAttributes[0].listOfAttributes != null && mapOfAttributes[0].listOfAttributes.size() == 5);

		System.assert(mapOfAttributes[1].category == 'Skill');
		System.assert(mapOfAttributes[1].listOfAttributes != null && mapOfAttributes[1].listOfAttributes.size() == 5);
	}

	public static testMethod void testSaveUserAttributes()
	{
		List<String> listOfTypes = new List<String> {'Location', 'Skill', 'Preference'};
		List<Match_Attribute__c> listOfAttributes = Match_Test_Util.createAttribute(listOfTypes);

		//debug 15 attributes are inserted
		listOfAttributes = [SELECT Id,Type__c FROM Match_Attribute__c];
		System.assert(listOfAttributes != null && listOfAttributes.size() == 15);


		Match_UserAttributeWizard.AttributeWrapper data1 = new Match_UserAttributeWizard.AttributeWrapper(listOfAttributes[0], null, false);
		Match_UserAttributeWizard.AttributeWrapper data2 = new Match_UserAttributeWizard.AttributeWrapper(listOfAttributes[1], null, false);
		Match_UserAttributeWizard.AttributeWrapper data3 = new Match_UserAttributeWizard.AttributeWrapper(listOfAttributes[2], null, false);

		data1.isSelected = true;
		data2.isSelected = true;
		List<Match_UserAttributeWizard.AttributeWrapper> listOfData = new List<Match_UserAttributeWizard.AttributeWrapper> {data1, data2, data3};

		//try to save records with an invalid target object name
		System.debug('Saving invalid attribute for current user');
		Match_Return response = Match_UserAttributeWizard.saveUserAttributes('invalidObject__c', 'User__c', UserInfo.getUserId(), JSON.serialize(listOfData));
		System.assert(response.isSuccess == false);
		System.assert(response.message == 'Target Object does not exist');

		//try to save records with a valid target object name
		System.debug('Saving valid attribute for current user');
		response = Match_UserAttributeWizard.saveUserAttributes('User_Attribute__c', 'User__c', UserInfo.getUserId(), JSON.serialize(listOfData));
		System.assert(response.isSuccess == true);

		//get the data again and check if already selected
		String dataAsJSON = Match_UserAttributeWizard.getAttributesGroupByType(listOfAttributes[0].Type__c, 'User_Attribute__c', 'User__c', UserInfo.getUserId());
		List<Match_UserAttributeWizard.AttributeCategoryWrapper> mapOfAttributes = (List<Match_UserAttributeWizard.AttributeCategoryWrapper>) JSON.deserialize(dataAsJSON, List<Match_UserAttributeWizard.AttributeCategoryWrapper>.class);

		mapOfAttributes[0].listOfAttributes[0].isSelected = false;
		response = Match_UserAttributeWizard.saveUserAttributes('User_Attribute__c', 'User__c', UserInfo.getUserId(), JSON.serialize(mapOfAttributes[0].listOfAttributes));
		System.assert(response.isSuccess == true);
	}
}