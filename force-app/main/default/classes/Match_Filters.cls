/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 5/30/18.
 */

public with sharing class Match_Filters
{
	public static Match_Filter_Data_List getFilterData(Match_Settings_Model metadata, String searchString)
	{
		Match_Filter_Data_List  filterDataList = new Match_Filter_Data_List();

		filterDataList.model                  = metadata;
		filterDataList.name                   = metadata.name;
		filterDataList.labelRequired          = metadata.source.requiredLabel;

		filterDataList.ratingGroups           = metadata.source.ratingGroups;
		filterDataList.labelRating            = metadata.source.ratingLabel;
		filterDataList.ratingFilterString     = metadata.source.ratingFilterSelect;

		filterDataList.labelConfidence        = metadata.source.confidenceLabel;
		filterDataList.confidenceFilterString = metadata.source.confidenceFilterSelect;

		String  filterObject = metadata.source.objectName;
		Decimal filterLimit  = metadata.source.filterList.pickListLimit;

		if (metadata.source.filterList.filters.size() > 0)
		{
			for(Match_Filter_Model filter : metadata.source.filterList.filters)
			{
				Match_Filter_Data entry = new Match_Filter_Data();

				entry.name       = filter.name;
				entry.label      = filter.label;
				entry.labelSet   = filter.labelSet;
				entry.filterType = filter.filterType;

				switch on filter.filterType {
					when 'Picklist' {
						System.debug('Loading picklist from metadata....');
						entry.entries = Match_Util.getPicklistValues(filterObject, filter.field.apiName);
						entry.entries.add(0, new Match_Util_Label_Value(entry.label, ''));
					}
					when 'Text' {
						System.debug('Loading picklist from data....');
						entry.entries = getFilterList(filterObject, filter.field.apiName, searchString, filterLimit);
						entry.entries.add(0, new Match_Util_Label_Value(entry.label, ''));
					}
				}

				entry.dumpModel('Filter data');

				filterDataList.filterData.add(entry);
			}
		}

		return filterDataList;
	}

	public static List<Match_Util_Label_Value> getFilterList(String objectName, String fieldName, String searchString, Decimal listLimit)
	{
		List<Match_Util_Label_Value> values = new List<Match_Util_Label_Value>();
		Integer recordLimit = (Integer)listLimit;
		String  fieldString = 'n.' + fieldName;

		String query = 'SELECT ' + fieldString + ' c, COUNT_DISTINCT(n.Id)' + ' FROM ' +  objectName + ' n';

		if (String.isNotBlank(searchString)) {
			query += ' AND (' + fieldString + ' LIKE \'%' + searchString + '%\')';
		}

		query += ' GROUP BY ' + fieldString + ' ORDER BY ' + fieldString + ' LIMIT ' + recordLimit;

		List<AggregateResult> results = Database.query(query);

		for (AggregateResult ar: results) {
			String entry = (String)ar.get('c');

			if (String.isNotBlank(entry)) {
				values.add(new Match_Util_Label_Value(entry, entry));
			}
		}

		return values;
	}
}