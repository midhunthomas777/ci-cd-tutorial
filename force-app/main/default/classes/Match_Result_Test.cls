/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/8/18.
 */

@IsTest
private class Match_Result_Test
{
	@IsTest
	static void testMatchResultBehavior()
	{
		Match_Return result = new Match_Return();
		System.assertEquals(true, result.success);

		result.messages.add(Match_TestConstants.TEST_MESSAGE);
		System.assertEquals(result.messages[0],Match_TestConstants.TEST_MESSAGE);

		Match_Attribute__c testAttribute = Match_Test_Util.createSkill(Match_TestConstants.TEST_SKILL_NAME);
		result.results.add(testAttribute);
		System.assertEquals(testAttribute, result.results[0]);
	}
}