/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 8/6/18.
 */

@IsTest
private class Match_Sort_List_Test
{

	static testMethod void test_SortList()
	{
		Match_Sort_List sortList = new Match_Sort_List();
		System.assertNotEquals(null, sortList);
		System.assertNotEquals(null, sortList.sorts);
	}

	static testMethod void test_Sort_getSort()
	{
		Match_Sort_List sortList = new Match_Sort_List();

		Match_Sort_Model sortItem = new Match_Sort_Model();
		sortItem.name = 'sort_1';
		sortItem.label = 'sort_1_label';
		sortItem.direction = 'ASC';

		sortList.sorts.add(sortItem);
		System.assertEquals(1, sortList.sorts.size());

		Match_Sort_Model found = sortList.getSort('sort_1');
		System.assertNotEquals(null, found);

		found = sortList.getSort('abc');
		System.assertEquals(null, found);
	}
}