/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/7/18.
 */

@IsTest
private class Match_Object_Controller_Test
{
	@IsTest
	static void testCalcRating()
	{
		Decimal ratingsGroups = 5;

		Decimal match = 0;
		Decimal rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(0, rating);

		match = 1;
		rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(ratingsGroups, rating);

		match  = 0.25;
		rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(2, rating);

		match  = 0.5;
		rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(3, rating);

		match  = 0.6;
		rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(3, rating);

		match  = 0.61;
		rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(4, rating);

		match = 0.75;
		rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(4, rating);

		match = 0.8;
		rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(4, rating);

		match  = 0.9;
		rating = Match_Object_Controller.calculateRating(ratingsGroups, match);
		System.assertEquals(5, rating);
	}

	testMethod static void test_checkObjectName()
	{
		String name = 'User';
		System.assertEquals('User__c', Match_Object_Controller.checkObjectName(name));
	}

	testMethod static void test_containsSkill()
	{
		List<Match_Attribute__c> testAttributes = Match_Test_Util.createTestSkills('skill', 2);

		Match_Skill_Model skillModel1 = new Match_Skill_Model(testAttributes[0].Id, testAttributes[0].Name, true, 'SkillType1');
		Match_Skill_Model skillModel2 = new Match_Skill_Model(testAttributes[1].Id, testAttributes[1].Name, true, 'SkillType1');

		List<Match_Skill_Model> skillList = new List<Match_Skill_Model>();
		skillList.add(skillModel1);
		skillList.add(skillModel2);

		System.assertEquals(true,  Match_Object_Controller.containsAttribute(skillList, testAttributes[0].Id));
		System.assertEquals(true,  Match_Object_Controller.containsAttribute(skillList, testAttributes[1].Id));
		System.assertEquals(false, Match_Object_Controller.containsAttribute(skillList, '12345'));
	}

	testMethod static void test_hasRequiredAttributes()
	{
		Match_Skill_List targetSkills = new Match_Skill_List();

		List<Match_Attribute__c> testAttributes = Match_Test_Util.createTestSkills('skill', 2);
		targetSkills.itemList.add(new Match_Skill_Model(testAttributes[0].Id, testAttributes[0].Name, true, 'SkillType1'));
		targetSkills.itemList.add(new Match_Skill_Model(testAttributes[1].Id, testAttributes[1].Name, true, 'SkillType1'));

		List<Match_Skill_Model> sourceSkills = new List<Match_Skill_Model>();

		sourceSkills.add(new Match_Skill_Model(testAttributes[0].Id, testAttributes[0].Name, true, 'SkillType1'));

		System.assertEquals(false, Match_Object_Controller.hasRequiredAttributes(targetSkills, sourceSkills));

		sourceSkills.add(new Match_Skill_Model(testAttributes[1].Id, testAttributes[1].Name, true, 'SkillType1'));
		System.assertEquals(true, Match_Object_Controller.hasRequiredAttributes(targetSkills, sourceSkills));
	}

	testMethod static void test_getAttributeMultiplier()
	{
		Match_Attribute_Type_List targetList = new Match_Attribute_Type_List();
		Match_Skill_Model skill = new Match_Skill_Model();

		Decimal multiplier = Match_Object_Controller.getAttributeMultiplier(null, null);
		System.assertEquals(1, multiplier);

		multiplier = Match_Object_Controller.getAttributeMultiplier(targetList, null);
		System.assertEquals(1, multiplier);

		multiplier = Match_Object_Controller.getAttributeMultiplier(null, skill);
		System.assertEquals(1, multiplier);

		multiplier = Match_Object_Controller.getAttributeMultiplier(targetList, skill);
		System.assertEquals(1, multiplier);
	}

	testMethod static void test_getAttributesName()
	{
		String prefix = 'User';
		String postfix = 'Attributes';
		String attributesName = Match_Object_Controller.getAttributesName(prefix, postfix);
		System.assertEquals('User_Attributes__r', attributesName);
	}
}