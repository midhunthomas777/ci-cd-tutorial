/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 3/21/18.
 */

@IsTest
public with sharing class Match_Util_Test
{

	static testMethod void test_checkPageSize()
	{
		Decimal pageSize = 0;
		pageSize = Match_Util.checkPageSize(pageSize);
		System.assertEquals(10, pageSize);
	}

	static testMethod void test_checkCurrentPage()
	{
		Decimal currentPage = 0;
		currentPage = Match_Util.checkCurrentPage(currentPage);
		System.assertEquals(1, currentPage);
	}

	static testMethod void test_getLimitClause()
	{
		Decimal searchOffset = 25;
		String limitClause = Match_Util.getLimitClause(searchOffset);
		System.assert(limitClause.indexOf(String.valueOf(searchOffset)) != -1);
	}

	static testMethod void test_getParseStringValue()
	{
		String filterString = 'targetId: 1234567890';
		String targetId = Match_Util.getParseStringValue(filterString, 'targetId');
		System.assertEquals('1234567890', targetId);
	}

	static testMethod void test_hasAttribute()
	{
		String filterString = 'targetId: 1234567890';

		System.assertEquals(false, Match_Util.hasAttribute(filterString, 'critical'));
		System.assertEquals(true,  Match_Util.hasAttribute(filterString, 'targetId'));
	}

	static testMethod void test_parseString()
	{
		String testString = 'field1:value1';
		Map<String,String> testMap = Match_Util.parseString(testString);
		System.assertNotEquals(null, testMap);
		System.assert(testMap.containsKey('field1'));
		String value = testMap.get('field1');
		System.assertEquals('value1', value);

		testString += ';field2:value2;';
		testMap = Match_Util.parseString(testString);
		System.assert(testMap.containsKey('field1'));
		System.assert(testMap.containsKey('field2'));
		String value2 = testMap.get('field2');
		System.assertEquals('value2', value2);
	}

	static testMethod void test_buildQueryFields()
	{
		String testField1 = 'field1';
		String testField2 = 'field2';
		List<String> fieldList = new List<String>();

		fieldList.add(testField1);
		String query = Match_Util.buildQueryFields(fieldList);
		System.assert(query.indexOf(testField1) != -1);

		fieldList.add(testField2);
		query = Match_Util.buildQueryFields(fieldList);
		System.assert(query.indexOf(testField1) != -1);
		System.assert(query.indexOf(testField2) != -1);
		System.assert(query.indexOf(',') != -1);
	}

	static testMethod void test_getDecimalRange()
	{
		String rangeString = '1,2,3,4,5';

		List<Decimal> range = Match_Util.getDecimalValues(rangeString);
		System.debug('range: ' + range);
		System.assertEquals(5, range.size());

		rangeString = '1,3,5';
		range = Match_Util.getDecimalValues(rangeString);
		System.debug('range: ' + range);
		Boolean result = range.contains((Decimal)1);
		System.debug('result: ' + result);
		System.assertEquals(true, result);
		System.assert(range.contains((Decimal)3));
		System.assert(range.contains((Decimal)5));
	}

	static testMethod void test_getRangeValues()
	{
		String rangeString = '1-20';
		List<Decimal> range = Match_Util.getRangeValues(rangeString);
		System.debug('range: ' + range);
		System.assertEquals(2, range.size());
		System.assertEquals(1, range[0]);
		System.assertEquals(20, range[1]);
	}
}