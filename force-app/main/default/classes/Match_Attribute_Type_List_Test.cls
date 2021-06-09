/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/17/18.
 */

@IsTest
private class Match_Attribute_Type_List_Test
{
	static testMethod void testAttributeTypeList()
	{
		Match_Attribute_Type_List typeList = new Match_Attribute_Type_List();
		System.assertNotEquals(null, typeList);

		typeList.types = Match_Test_Util.createAttributeTypes('type', 5);
		System.assertNotEquals(null, typeList.findTypeByName('type1'));
		System.assertEquals(null, typeList.findTypeByName('abc'));

		typeList.dumpModel('unit test');
	}
}