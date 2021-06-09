/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/8/18.
 */

@IsTest
private class Match_Skill_List_Test
{
	static testMethod void testMatchSkillListBehavior()
	{
		String skillName1 = 'skill1';
		String skillName2 = 'skill2';
		Match_Attribute__c testAttribbute = Match_Test_Util.createSkill(skillName1);

		Match_Skill_Model skillModel = new Match_Skill_Model(testAttribbute.Id, testAttribbute.Name, true, 'SkillType1');

		System.assertNotEquals(null, skillModel);
		skillModel.dumpModel('skillModel');

		Match_Skill_List skillList = new Match_Skill_List();
		System.assertNotEquals(null, skillList);

		skillList.itemList.add(skillModel);
		skillList.dumpModel('skillList');

		Match_Skill_Model skillModel2 = new Match_Skill_Model();
		skillModel2.name = skillName2;
		skillList.itemList.add(skillModel2);

		Match_Skill_Model foundItem = skillList.getSkillByName(skillName1);
		System.assertNotEquals(null, foundItem);
		foundItem = skillList.getSkillByName('skill');
		System.assertEquals(null, foundItem);

		foundItem = skillList.getSkillById(testAttribbute.Id);
		System.assertNotEquals(null, foundItem);

		foundItem = skillList.getSkillById('00001');
		System.assertEquals(null, foundItem);

		skillList.itemList.sort();
	}
}