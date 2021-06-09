/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 5/30/18.
 */

@IsTest
private class Match_Filters_Test
{
	@IsTest
	static void testBehavior()
	{
		Match_Filter_List filterList = new Match_Filter_List();

		System.assertNotEquals(null, filterList);
		System.assertNotEquals(null, filterList.filters);
	}
}