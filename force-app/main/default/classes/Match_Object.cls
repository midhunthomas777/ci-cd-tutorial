/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 3/21/18.
 */

public with sharing class Match_Object
{
	@AuraEnabled
	public String name, label;

	@AuraEnabled
	public String objectName, childPrefix, childPostfix;

	@AuraEnabled
	public String excludeField;

	@AuraEnabled
	public String confidenceLabel, confidenceInfo, confidenceFilterSelect;
	@AuraEnabled
	public Decimal confidenceSequence;

	@AuraEnabled
	public String requiredLabel, requiredInfo;
	@AuraEnabled
	public Decimal requiredSequence;

	@AuraEnabled
	public String ratingLabel, ratingInfo, ratingFilterSelect;
	@AuraEnabled
	public Decimal ratingSequence, ratingGroups;
	@AuraEnabled
	public String[] groupIcons;

	@AuraEnabled
	public List<Match_Field> fields;

	@AuraEnabled
	public List<Match_Attribute_Type> types;

	@AuraEnabled
	public Match_Attribute_Type_List typeList;

	@AuraEnabled
	public Match_Filter_List filterList { get; set; }

	@AuraEnabled
	public Match_Sort_List sortList {get; set;}

	@AuraEnabled
	public Match_Flow_List flowList {get; set;}

	public Match_Object()
	{
		name                    = '';
		label                   = '';
		objectName              = '';
		childPrefix             = '';
		childPostfix            = '';
		excludeField            = '';

		confidenceLabel         = '';
		confidenceInfo          = '';
		confidenceSequence      = 0;
		confidenceFilterSelect  = '';

		requiredLabel           = '';
		requiredInfo            = '';
		requiredSequence        = 0;

		ratingLabel             = '';
		ratingInfo              = '';
		ratingSequence          = 0;
		ratingGroups            = 0;
		ratingFilterSelect      = '';

		groupIcons              = null;

		fields                  = new List<Match_Field>();
		typeList                = new Match_Attribute_Type_List();
		filterList              = new Match_Filter_List();
		sortList                = new Match_Sort_List();
		flowList                = new Match_Flow_List();
	}

	public Match_Field containsField(String targetId)
	{
		Match_Field result = null;

		for (Match_Field field : fields)
		{
			if (field.id == targetId)
			{
				result = field;
				break;
			}
		}

		return result;
	}

	public Match_Field findField(String name)
	{
		Match_Field result = null;

		for (Match_Field field : fields)
		{
			if (field.name == name)
			{
				result = field;
				break;
			}
		}

		return result;
	}

	public void dumpModel(String title)
	{
		System.debug('Dump Match_Object model  ' + title);
		System.debug('  object name    : ' + this.name);
		System.debug('  object label   : ' + this.label);
		System.debug('  sObject        : ' + this.objectName);
		System.debug('  object prefix  : ' + this.childPrefix);
		System.debug('  object postfix : ' + this.childPostfix);
		System.debug('  exclude field  : ' + this.excludeField);

		Integer pos = 0;

		for(Match_Field field : fields)
		{
			pos++;
			field.dumpModel('Field ' + pos);
		}

		typeList.dumpModel('TypeList');
		filterList.dumpModel('Filters');
		sortList.dumpModel('Sorts');
		flowList.dumpModel('Flows', true);
	}
}