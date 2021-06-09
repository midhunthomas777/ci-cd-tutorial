/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/8/18.
 */

@IsTest
public with sharing class Match_Test_Util
{
	public static Match_Filter_Model createMatchFilter(String name, Match_Field field)
	{
		Match_Filter_Model filter = new Match_Filter_Model();

		filter.name = name;
		filter.field = field;

		return filter;
	}

	public static Match_Field createMatchField(String name)
	{
		Match_Field field = new Match_Field();

		field.name = name;

		return field;
	}

	public static List<Match_Attribute__c> createTestSkills(String nameBase, Integer count)
	{
		List<Match_Attribute__c> attributes = new List<Match_Attribute__c>();

		for (Integer index=0; index < count; index++)
		{
			Match_Attribute__c attribute = new Match_Attribute__c();

			attribute.Name = nameBase + index;
			attribute.Archived__c = false;

			attributes.add(attribute);
		}

		insert attributes;
		return attributes;
	}

	public static Match_Attribute__c createSkill(String name)
	{
		Match_Attribute__c attribute = new Match_Attribute__c();

		attribute.Name = name;
		attribute.Archived__c = false;

		insert attribute;
		return attribute;
	}

	public static List<Match_Attribute_Type> createAttributeTypes(String baseName, Integer count)
	{
		List<Match_Attribute_Type> typeList = new List<Match_Attribute_Type>();

		for (Integer index = 0; index < count; index++)
		{
			Match_Attribute_Type attribute = new Match_Attribute_Type();
			attribute.name = baseName + index;

			typeList.add(attribute);
		}

		return typeList;
	}

	public static List<Match_Attribute__c> createAttribute(List<String> listOfTypes)
	{
		List<Match_Attribute__c> listOfAttributes = new List<Match_Attribute__c>();

		for (String type : listOfTypes)
		{
			for (Integer x = 0; x < 5; x++)
			{
				Match_Attribute__c attribute = new Match_Attribute__c();
				attribute.Type__c = type;
				attribute.Name = 'Test' + x;
				listOfAttributes.add(attribute);
			}
		}

		insert listOfAttributes;
		return listOfAttributes;
	}
}