/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 5/30/18.
 */

public with sharing class Match_Filter_List
{
	@AuraEnabled
	public String label;

	@AuraEnabled
	public Decimal pickListLimit;

	@AuraEnabled
	public List<Match_Filter_Model> filters {get; set;}

	public Match_Filter_List()
	{
		filters = new List<Match_Filter_Model>();
	}

	public Match_Filter_Model getFilter(String filterName)
	{
		for (Match_Filter_Model filter : filters)
		{
			if (filter.name == filterName)
			{
				return filter;
			}
		}
		return null;
	}

	public void dumpModel(String title)
	{
		System.debug('Dump filter list: ' + title);

		System.debug('    label : ' + label);
		System.debug('    limit : ' + pickListLimit);

		Integer count = 1;
		for (Match_Filter_Model entry: this.filters)
		{
			entry.dumpModel('entry ' + count);
			count += 1;
		}
	}
}