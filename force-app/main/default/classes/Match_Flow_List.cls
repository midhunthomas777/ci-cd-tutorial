/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francoiskorb on 7/6/18.
 */

public with sharing class Match_Flow_List
{
	@AuraEnabled
	public String label;

	@AuraEnabled
	public List<Match_Flow_Model> flows;

	public Match_Flow_List()
	{
		label = '';
		flows = new List<Match_Flow_Model>();
	}

	public void dumpModel(String title, Boolean depth)
	{
		System.debug('Dump flow list: ' + title);
		System.debug('     name     : ' + label);

		if (depth)
		{
			Integer count = 1;
			for (Match_Flow_Model flow : flows)
			{
				flow.dumpModel('flow ' + count);
				count += 1;
			}
		}
	}
}