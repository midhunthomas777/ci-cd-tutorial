/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 6/15/18.
 */

public with sharing class Match_Sort_List
{
	@AuraEnabled
	public String label;

	@AuraEnabled
	public List<Match_Sort_Model> sorts;

	public Match_Sort_List()
	{
		sorts = new List<Match_Sort_Model>();
	}

	public Match_Sort_Model getSort(String sortName)
	{
		for (Match_Sort_Model entry : sorts)
		{
			if (entry.name == sortName)
			{
				return entry;
			}
		}
		return null;
	}

	public void dumpModel(String title)
	{
		System.debug('Dump filter list: ' + title);

		System.debug('    label : ' + label);

		Integer count = 1;
		for (Match_Sort_Model entry: this.sorts)
		{
			entry.dumpModel('entry ' + count);
			count += 1;
		}
	}


}