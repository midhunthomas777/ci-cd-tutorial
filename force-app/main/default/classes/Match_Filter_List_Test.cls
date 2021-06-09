/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 8/6/18.
 */

@IsTest
private class Match_Filter_List_Test
{
	static testMethod void testFilterList()
	{
		Match_Filter_List filterList = new Match_Filter_List();
		System.assertNotEquals(null, filterList);
		System.assertNotEquals(null, filterList.filters);
	}

	static testMethod void test_FilterList_getFilter()
	{
		Match_Filter_List filterList = new Match_Filter_List();

		Match_Filter_Model filter = new Match_Filter_Model();
		filter.name = 'filter_1';
		filter.label = 'label 1';
		filter.operator = 'equals';
		filter.filterType = 'test';
		filterList.filters.add(filter);

		Match_Filter_Model found = filterList.getFilter('filter_1');
		System.assertNotEquals(null, found);
		found = filterList.getFilter('abc');
		System.assertEquals(null, found);
	}
}