/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 4/12/18.
 */

public with sharing class Match_Util
{
	public static final Decimal DEFAULT_PAGE_SIZE   = 10;
	public static final Decimal DEFAULT_LIST_LIMIT  = 10000;
	public static final Decimal DEFAULT_OFFSET_SIZE = 2000;

	// Parse source string into key, value pairs
	//
	//	source string format
	//	    field1:value1;field2:value1;
	private static final String FIELD_SEPARATOR = ';';
	private static final String VALUE_SEPARATOR = ':';
	private static final String VALUE_DELIMITER = ',';
	private static final String RANGE_SEPARATOR = '-';

	public static String getParseStringValue(String source, String key)
	{
		String valueString = '';

		Map<String, String> valueMap = parseString(source);
		if (valueMap.size() > 0)
		{
			if (valueMap.containsKey(key))
			{
				valueString = valueMap.get(key);
			}
		}

		return valueString.trim();
	}

	public static Map<String, String> parseString(String source)
	{
		Map<String, String> tokens = new Map<String, String>();

		if (String.isNotBlank(source))
		{
			List<String> sourceParts = source.split(FIELD_SEPARATOR);

			for(Integer i = 0; i < sourceParts.size(); i++)
			{
				String fieldName  = sourceParts[i].substringBefore(VALUE_SEPARATOR);
				String fieldValue = sourceParts[i].substringAfter(VALUE_SEPARATOR);

				tokens.put(fieldName, fieldValue);
			}
		}

		return tokens;
	}

	public static List<String> getStringValues(String valueString)
	{
		List<String> stringValues = null;

		if (String.isNotBlank(valueString))
		{
			stringValues = new List<String>();

			for (String value: valueString.split(VALUE_DELIMITER))
			{
				stringValues.add(value);
			}
		}

		return stringValues;
	}

	public static List<Decimal> getDecimalValues(String valueString)
	{
		List<Decimal>  decimalValues = null;

		if (String.isNotBlank(valueString))
		{
			decimalValues   = new List<Decimal>();

			for (String value: valueString.split(VALUE_DELIMITER))
			{
				decimalValues.add(Decimal.valueOf(value));
			}
		}

		return decimalValues;
	}

	public static List<Decimal> getRangeValues(String range)
	{
		List<Decimal>  decimalValues = null;

		if (String.isNotBlank(range))
		{
			decimalValues   = new List<Decimal>();

			for(String value: range.split(RANGE_SEPARATOR))
			{
				decimalValues.add(Decimal.valueOf(value));
			}
		}

		return decimalValues;
	}

	public static Boolean hasAttribute(String sourceString, String attribute)
	{
		return String.isNotBlank(sourceString) && sourceString.indexOf(attribute) != -1;
	}

	public static Decimal checkPageSize(Decimal pageSize)
	{
		return (pageSize == null || pageSize < 1) ? Match_Util.DEFAULT_PAGE_SIZE : pageSize;
	}

	public static Decimal checkCurrentPage(Decimal currentPage)
	{
		return (currentPage == null || currentPage < 1) ? 1 : currentPage;
	}

	public static String buildQueryFields(String[] fieldList)
	{
		 return String.join(fieldList, VALUE_DELIMITER);
	}

	public static String getLimitClause(Decimal limitValue)
	{
		return ' LIMIT ' + limitValue;
	}

	public static String getOffsetClause(Decimal searchOffset)
	{
		return ' OFFSET ' + searchOffset;
	}

	public static List<Match_Util_Label_Value> getPicklistValues(String object_name, String field_name) {
		List<Match_Util_Label_Value> values = new List<Match_Util_Label_Value>();
		String[] types = new String[]{object_name};
		Schema.DescribeSObjectResult[] results = Schema.describeSObjects(types);
		for(Schema.DescribeSObjectResult res : results) {
			for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
				if (entry.isActive()) {
					String value = entry.getValue();
					values.add(new Match_Util_Label_Value(value, value));
				}
			}
		}
		return values;
	}

}