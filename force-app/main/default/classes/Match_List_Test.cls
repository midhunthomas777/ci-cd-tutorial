/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/8/18.
 */

@IsTest
private class Match_List_Test
{
	@IsTest
	static void testMatchListBehavior()
	{
		Match_Model matchModel1 = new Match_Model();
		System.assertNotEquals(null, matchModel1);

		matchModel1.id       = '12345';
		matchModel1.name     = 'match1';
		matchModel1.critical = true;
		matchModel1.match    = 1;

		String skillName1 = 'skill1';
		String skillName2 = 'skill2';

		Match_Attribute__c testAttribute1 = Match_Test_Util.createSkill(skillName1);
		Match_Skill_Model skillModel1 = new Match_Skill_Model(testAttribute1.Id, testAttribute1.Name, true, 'SkillType1');

		Match_Attribute__c testAttribute2 = Match_Test_Util.createSkill(skillName2);
		Match_Skill_Model skillModel2 = new Match_Skill_Model(testAttribute2.Id, testAttribute2.Name, true, 'SkillType1');

		matchModel1.skills.add(skillModel1);
		matchModel1.skills.add(skillModel2);

		Match_List matchList = new Match_List();
		System.assertNotEquals(null, matchList);

		matchList.items.add(matchModel1);

		Match_Model matchModel2 = new Match_Model();

		matchModel2.id       = '23456';
		matchModel2.name     = 'match2';
		matchModel2.critical = false;
		matchModel2.match    = 1;

		matchList.items.add(matchModel2);
		matchList.dumpModel('matchList', true);

		matchList.items.sort();
		System.assertEquals(2, matchList.items.size());

		System.assertNotEquals(null, matchList.containsItem('12345'));
		System.assertEquals(null, matchList.containsItem('11111'));

		matchList.pageSize = Match_Util.checkPageSize(matchList.pageSize);
		matchList.limitDataSet(10, 1);
		System.assertEquals(2, matchList.items.size());

		matchList.criticalOnly();
		System.assertEquals(1, matchList.items.size());
	}
}