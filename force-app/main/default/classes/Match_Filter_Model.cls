/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francois korb on 5/30/18.
 */

public with sharing class Match_Filter_Model
{
	@AuraEnabled
	public String id, name, label, operator, filterType;
	@AuraEnabled
	public String[] labelSet;

	@AuraEnabled
	public Match_Field field;

	public void dumpModel(String title)
	{
		System.debug('Dump filter: ' + title);
		System.debug('    Id        : ' + id);
		System.debug('    name      : ' + name);
		System.debug('    label     : ' + label);
		System.debug('    Api Name  : ' + field.apiName);
		System.debug('    Type      : ' + field.fieldType);
		System.debug('    Operator  : ' + operator);
		System.debug('    filterType: ' + filterType);

		if (labelSet != null)
		{
			for(String labelItem: labelSet)
			{
				System.debug('    label(s)  : ' + labelItem);
			}
		}
	}
}