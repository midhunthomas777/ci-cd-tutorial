/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/16/18.
 */

public with sharing class Match_Attribute_Type_List
{
	@AuraEnabled
	public List<Match_Attribute_Type> types;

	public Match_Attribute_Type_List()
	{
		types = new List<Match_Attribute_Type>();
	}

	public Match_Attribute_Type findTypeByName(String name)
	{
		for(Match_Attribute_Type typeItem : types)
		{
			if (typeItem.name == name)
			{
				return typeItem;
			}
		}

		return null;
	}

	public void dumpModel(String title)
	{
		System.debug('Match_Attribute_Type_List: ' + title);
		Integer pos = 0;

		for(Match_Attribute_Type type: types)
		{
			pos++;
			type.dumpModel('Type ' + pos);
		}
	}
}