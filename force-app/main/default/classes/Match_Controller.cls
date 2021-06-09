/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 3/20/18.
 */

public with sharing class Match_Controller
{
	@AuraEnabled
	public static Match_Settings_Model getDataModel(String name)
	{
		Match_Settings settings    = new Match_Settings();
		Match_Settings_Model model = settings.getSettings(name);

		return model;
	}

	//	filterString
	//	    field1:value1,value2,..,value(n);field2:value1;
	//
	//	sortOrder
	//	    field:order;field:order
	//	        where order is asc|desc

	@AuraEnabled
	public static Match_List getMatchList(
		String  name,
		Decimal pageSize,
		Decimal currentPage,
		String  filterString,
		String  sortOrder)
	{
		Match_Settings settings       = new Match_Settings();
		Match_Settings_Model metaData = settings.getSettings(name.trim());

		return Match_Object_Controller.getMatchList(
			metaData,
			pageSize,
			currentPage,
			filterString,
			sortOrder);
	}

	@AuraEnabled
	public static Map<String, String> getMatchTargetList(
		String  name,
		String searchString)
	{
		Match_Settings settings       = new Match_Settings();
		Match_Settings_Model metaData = settings.getSettings(name.trim());

		Map<String, String> targetList = Match_Object_Controller.getTargetList(
			metaData,
			searchString);

		return targetList;
	}

	@AuraEnabled
	public static Match_Filter_Data_List getFilterData(String name, String searchString)
	{
		Match_Settings settings       = new Match_Settings();
		Match_Settings_Model metaData = settings.getSettings(name.trim());

		Match_Filter_Data_List filterData = Match_Filters.getFilterData(metaData, searchString);

		return filterData;
	}
}