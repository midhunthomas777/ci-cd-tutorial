/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 6/8/18.
 */

public with sharing class Match_Filter_Data
{
	@AuraEnabled
	public String name, label, filterType;

	@AuraEnabled
	public List<String> labelSet;

	@AuraEnabled
	public List<Match_Util_Label_Value> entries;

	public Match_Filter_Data()
	{
		entries = new List<Match_Util_Label_Value>();
	}

	public void dumpModel(String title)
	{
		System.debug('Dump filter data: ' + title);
		System.debug('    name : ' + name);
		System.debug('    label: ' + label);
		System.debug('    type : ' + filterType);

		System.debug('  Data (' + entries.size() + ')');

		Integer count = 1;
		for (Match_Util_Label_Value entry : entries)
		{
			entry.dumpModel('entry: ' + count);
			count++;
		}
	}
}