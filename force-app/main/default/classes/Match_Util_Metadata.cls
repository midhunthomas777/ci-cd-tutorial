/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 3/22/18.
 */

public with sharing class Match_Util_Metadata
{
	@TestVisible
	public static String getNameSpacePrefix()
	{
		String namespacePrefix = [SELECT NamespacePrefix FROM ApexClass WHERE Name = 'Match_Util_Metadata' LIMIT 1].NamespacePrefix;

		return String.isNotBlank(namespacePrefix) ? namespacePrefix + '__' : '';
	}

	public static String buildQuery(String objectName, String additionalFields)
	{
		String                nameSpace      = getNameSpacePrefix();
		DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(nameSpace + objectName).getDescribe();

		List<String>    fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
		String          fields     = String.join( fieldNames, ',' );

		if (String.isNotBlank(additionalFields))
		{
			fields += ',' + additionalFields;
		}

		String query = ' SELECT ' +  fields +  ' FROM ' +  describeResult.getName();

		return query;
	}

	public static String buildSubQuery(String objectName, String fieldList)
	{
		List<String> queryStrings = new List<String>();

		// use regex command and space to find custom fields
		for (String field : fieldList.split('[, ]'))
		{
			if (field.endsWith('__c'))
			{
				queryStrings.add(objectName+'.'+field);
			}
		}

		return String.join(queryStrings, ',');
	}
}