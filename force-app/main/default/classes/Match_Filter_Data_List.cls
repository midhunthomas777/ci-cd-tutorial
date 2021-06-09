/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 6/13/18.
 */

public with sharing class Match_Filter_Data_List
{
	@AuraEnabled
	public Match_Settings_Model model;

	@AuraEnabled
	public String name, labelRequired, labelRating, labelConfidence;

	@AuraEnabled
	public String confidenceFilterString, ratingFilterString;

	@AuraEnabled
	public Decimal ratingGroups;

	@AuraEnabled
	public List<Match_Filter_Data> filterData;

	public Match_Filter_Data_List()
	{
		name                    = '';

		labelRequired           = '';

		ratingGroups            = 0;
		labelRating             = '';
		ratingFilterString      = '';

		labelConfidence         = '';
		confidenceFilterString  = '';

		filterData              = new List<Match_Filter_Data>();
	}

	public void dumpModel(String title)
	{
		System.debug('Dump filter data list: ' + title);

		System.debug('    name   : ' + name);
		System.debug('    ratings: ' + ratingGroups);

		Integer count = 1;
		for(Match_Filter_Data filter : filterData)
		{
			filter.dumpModel('filter ' + count);
			count++;
		}
	}
}