/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 3/20/18.
 */

// 05/22/2018 - Fran
// Using SeeAllData to get the tests to run using metadata declared objects
// Not too keen on SeeAllData band plan to refactor this over time
@IsTest(SeeAllData=true)
public class Match_Controller_Test
{


	static testMethod void test_getDataModel()
	{
		for (String name: Match_TestConstants.TestScenarios)
		{
			Match_Settings_Model metadata = Match_Controller.getDataModel(name);
			System.assertNotEquals(null, metadata);
		}
	}

	static testMethod void test_getMatchList()
	{
		for (String name: Match_TestConstants.TestScenarios)
		{
			Match_List matchList = Match_Controller.getMatchList(name, 10, 0, '', 'confidence');
			System.assertNotEquals(null, matchList);
		}
	}

	static testMethod void test_getMatchTargetList()
	{
		for (String name: Match_TestConstants.TestScenarios)
		{
			Map<String, String> targetList = Match_Controller.getMatchTargetList(name, '');
			System.assertNotEquals(null, targetList);
		}
	}

	static testMethod void test_getFilterData()
	{
		for (String name : Match_TestConstants.TestScenarios)
		{
			Match_Filter_Data_List filterDataList = Match_Controller.getFilterData(name, '');
			System.assertNotEquals(null, filterDataList);
			filterDataList.dumpModel(name);
		}
	}
}