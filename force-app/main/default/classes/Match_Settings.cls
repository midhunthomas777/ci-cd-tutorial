/*
	Copyright (c) 2018 7Summits Inc.
*/

/**
 * Created by francois korb on 3/20/18.
 */

public with sharing class Match_Settings
{
	public class Match_setting_Exception extends Exception {}

	private final String    DEFAULT_NAME        = 'Default';
	private final String    SETTINGS_NAME       = 'Match_Settings__mdt';
	private final String    SETTINGS_OBJECT     = 'Match_Object__mdt';
	private final String    SETTINGS_FIELD_SET  = 'Match_Field_Set__mdt';
	private final String    SETTINGS_FIELD      = 'Match_Field__mdt';
	private final String    SETTINGS_FILTER     = 'Match_Filter__mdt';
	private final String    SETTINGS_FILTER_SET = 'Match_Filter_Set__mdt';
	private final String    SETTINGS_FLOW       = 'Match_Flow__mdt';
	private final String    SETTINGS_FLOW_SET   = 'Match_Flow_Set__mdt';
	private final String    SETTINGS_ICON       = 'Match_Icon__mdt';
	private final String    SETTINGS_ICON_SET   = 'Match_Icon_Set__mdt';
	private final String    SETTINGS_SORT       = 'Match_Sort__mdt';
	private final String    SETTINGS_SORT_SET   = 'Match_Sort_Set__mdt';
	private final String    SETTINGS_TYPE       = 'Match_Attribute_Type__mdt';
	private final String    SETTINGS_TYPE_SET   = 'Match_Attribute_Type_Set__mdt';

	private final String    CHILD_POSTFIX       = 'Attributes';

	private final Integer   MAX_FIELDS          = 10;
	private final Integer   MAX_FILTERS         = 5;
	private final Integer   MAX_SORTS           = 5;
	private final Integer   MAX_FLOWS           = 5;
	private final Integer   MAX_ICONS           = 5;
	private final Integer   MAX_TYPES           = 3;

	public Match_Settings_Model getSettings(String name)
	{
		String setName = String.isBlank(name) ? DEFAULT_NAME : name;
		System.debug('getSettings(' + setName + ')');

		try {
			Match_Settings__mdt settings = getMatchSettings(setName);
			return setValues(settings);
		} catch (Match_setting_Exception ex) {
			System.debug('ERROR: Match Settings - getSettings: ' + ex.getMessage());
		}

		return null;
	}

	public Match_Settings__mdt getMatchSettings(String name)
	{
		String query = Match_Util_Metadata.buildQuery(SETTINGS_NAME, '') + ' WHERE DeveloperName = \'' + name + '\'';

		System.debug('settingsQuery: ' + query);

		try {
				Match_Settings__mdt settings = (Match_Settings__mdt) Database.query(query);
				return settings;
		}
		catch (QueryException ex)
		{
			throw new Match_setting_Exception('Settings not found for ' + name);
		}
	}

	@TestVisible
	private Match_Settings_Model setValues(Match_Settings__mdt settings)
	{
		System.debug('setValues for ' + settings);
		Match_Settings_Model model = new Match_Settings_Model();

		model.name          = settings.DeveloperName;
		model.label         = settings.MasterLabel;
		model.multiplier    = settings.Critical_Multiplier__c;


		if (String.isBlank(settings.Match_Object_Source__c)) { throw new Match_setting_Exception('METADATA ERROR:  Source object not defined for ' + model.name);}
		if (String.isBlank(settings.Match_Object_Target__c)) { throw new Match_setting_Exception('METADATA ERROR:  Target object not defined for ' + model.name);}

		model.source = setMatchObject(getMatchObject(settings.Match_Object_Source__c));
		model.target = setMatchObject(getMatchObject(settings.Match_Object_Target__c));

		if (settings.Data_Paging_Field__c != null)
		{
			// get the field from the source model - it may be part of the object field list
			model.pagingField = model.source.containsField(settings.Data_Paging_Field__c);

			if (model.pagingField == null)
			{
				// now we have to hunt for the field
				String fieldQuery = Match_Util_Metadata.buildQuery(SETTINGS_FIELD, '');
				fieldQuery += ' WHERE Id = \'' + settings.Data_Paging_Field__c + '\'';
				Match_Field__mdt field = (Match_Field__mdt) Database.query(fieldQuery);

				if (field != null)
				{
					model.pagingField = setFieldObject(field, 'Data_Paging_Field__c', 0);
				}
			}
		}

		return model;
	}

	@TestVisible
	private Match_Object__mdt getMatchObject(String Id)
	{
		List<String> subQueryParts = new List<String>();

		String query = Match_Util_Metadata.buildQuery(SETTINGS_OBJECT, String.join(subQueryParts, ','));
		query += ' WHERE Id = \'' + Id + '\'';

		System.debug('getMatchObject query: ' + query);

		Match_Object__mdt matchObject = (Match_Object__mdt)Database.query(query);

		return matchObject;
	}

	@TestVisible
	private Match_Object setMatchObject(Match_Object__mdt match)
	{
		Match_Object matchObject = new Match_Object();

		matchObject.label                   = match.MasterLabel;
		matchObject.name                    = match.DeveloperName;
		matchObject.objectName              = match.Object_Name__c;
		matchObject.childPrefix             = match.Child_Prefix__c;
		matchObject.childPostfix            = String.isBlank(match.Child_Postfix__c) ? CHILD_POSTFIX : match.Child_Postfix__c;

		matchObject.excludeField            = match.Exclude_Field_API_Name__c;

		matchObject.confidenceInfo          = match.Confidence_Info__c;
		matchObject.confidenceLabel         = match.Confidence_Label__c;
		matchObject.confidenceSequence      = match.Confidence_Sequence__c;
		matchObject.confidenceFilterSelect  = match.Confidence_Filter_Selection__c;

		matchObject.ratingGroups            = match.Rating_Groups__c;
		matchObject.ratingLabel             = match.Rating_Label__c;
		matchObject.ratingSequence          = match.Rating_Sequence__c;
		matchObject.groupIcons              = getGroupIcons(match);

		matchObject.requiredLabel           = match.Required_Label__c;
		matchObject.requiredSequence        = match.Required_Sequence__c;

		if (match.Field_Set__c != null)
		{
			String fieldSetQuery = Match_Util_Metadata.buildQuery(SETTINGS_FIELD_SET, '');
			fieldSetQuery += ' WHERE id = \'' + match.Field_Set__c + '\'';
			List<Match_Field_Set__mdt> fieldSets = (List<Match_Field_Set__mdt>)Database.query(fieldSetQuery);

			for (Match_Field_Set__mdt fieldSet : fieldSets)
			{
				for (Integer fieldPos = 1; fieldPos <= MAX_FIELDS; fieldPos++)
				{
					String fieldBase = 'Field_' + fieldPos;
					String fieldName = fieldBase + '__c';
					Id     fieldId   = (Id)fieldSet.get(fieldName);

					if (fieldId != null)
					{
						String fieldQuery = Match_Util_Metadata.buildQuery(SETTINGS_FIELD, '');
						fieldQuery += ' WHERE Id = \'' + fieldId + '\'';
						Match_Field__mdt field = (Match_Field__mdt) Database.query(fieldQuery);

						if (field != null)
						{
							String sequenceString = 'Field_' + fieldPos + '_Sequence__c';
							Decimal sequence      = (Decimal)fieldSet.get(sequenceString);

							matchObject.fields.add(setFieldObject(field, fieldBase, sequence));
						}
					}
				}
			}
		}


		if (match.Match_Filter_Set__c != null)
		{
			String filterSetQuery = Match_Util_Metadata.buildQuery(SETTINGS_FILTER_SET, '');
			filterSetQuery       += ' WHERE id = \'' + match.Match_Filter_Set__c + '\'';

			List<Match_Filter_Set__mdt> filterSets = (List<Match_Filter_Set__mdt>)Database.query(filterSetQuery);

			for (Match_Filter_Set__mdt filterSet : filterSets)
			{
				matchObject.filterList.label         = filterSet.Label;
				matchObject.filterList.pickListLimit = filterSet.Filter_List_Limit__c;

				for (Integer filterSetPos = 1; filterSetPos <= MAX_FILTERS; filterSetPos++)
				{
					String filterSetName = 'Match_Filter_' + filterSetPos + '__c';
					Id filterId = (Id) filterSet.get(filterSetName);

					if (filterId != null)
					{
						String filterQuery = Match_Util_Metadata.buildQuery(SETTINGS_FILTER, '');
						filterQuery       += ' WHERE Id = \'' + filterId + '\'';

						List<Match_Filter__mdt> filterSetItems = (List<Match_Filter__mdt>) Database.query(filterQuery);

						for (Match_Filter__mdt filterItem : filterSetItems)
						{
							Id filterFieldId  = (Id) filterItem.get('Match_Field__c');
							Match_Field field = matchObject.containsField(filterFieldId);

							if (field == null)
							{
								String fieldQuery = Match_Util_Metadata.buildQuery(SETTINGS_FIELD, '');
								fieldQuery       += ' WHERE Id = \'' + filterFieldId + '\'';

								Match_Field__mdt fieldMdt = (Match_Field__mdt) Database.query(fieldQuery);

								if (fieldMdt != null)
								{
									field = setFieldObject(fieldMdt, 'Match_Field__c', 0);
								}
							}
							if (field != null)
							{
								matchObject.filterList.filters.add(setFilterModel(filterItem, field));
							}
						}
					}
				}
			}
		}

		if (match.Match_Sort_Set__c != null)
		{
			String sortSetQuery = Match_Util_Metadata.buildQuery(SETTINGS_SORT_SET, '');
			sortSetQuery       += ' WHERE id = \'' + match.Match_Sort_Set__c + '\'';

			List<Match_Sort_Set__mdt> sortSets = (List<Match_Sort_Set__mdt>)Database.query(sortSetQuery);

			for(Match_Sort_Set__mdt sortSet : sortSets)
			{
				matchObject.sortList.label = sortSet.Label;

				for(Integer sortSetPos = 1; sortSetPos < MAX_SORTS; ++sortSetPos)
				{
					String sortSetName = 'Match_Sort_' + sortSetPos + '__c';
					Id sortId = (Id) sortSet.get(sortSetName);

					if (sortId != null)
					{
						String sortQuery = Match_Util_Metadata.buildQuery(SETTINGS_SORT, '');
						sortQuery       += ' WHERE Id = \'' + sortId + '\'';
						List<Match_Sort__mdt> sortSetItems = (List<Match_Sort__mdt>) Database.query(sortQuery);

						for (Match_Sort__mdt sortItem: sortSetItems)
						{
							Id sortFieldId    = (Id) sortItem.get('Match_Field__c');
							Match_Field field = matchObject.containsField(sortFieldId);

							if (field == null)
							{
								String fieldQuery = Match_Util_Metadata.buildQuery(SETTINGS_FIELD, '');
								fieldQuery       += ' WHERE Id = \'' + sortFieldId + '\'';

								Match_Field__mdt fieldMdt = (Match_Field__mdt) Database.query(fieldQuery);

								if (fieldMdt != null)
								{
									field = setFieldObject(fieldMdt, 'Match_Field__c', 0);
								}
							}
							if (field != null)
							{
								matchObject.sortList.sorts.add(setSortModel(sortItem, field));
							}
						}
					}
				}
			}
		}

		if (match.Match_Flow_Set__c != null)
		{
			String flowSetQuery = Match_Util_Metadata.buildQuery(SETTINGS_FLOW_SET, '');
			flowSetQuery       += ' WHERE id = \'' + match.Match_Flow_Set__c + '\'';

			List<Match_Flow_Set__mdt> flowSets = (List<Match_Flow_Set__mdt>)Database.query(flowSetQuery);

			for(Match_Flow_Set__mdt flowSet : flowSets)
			{
				matchObject.flowList.label = flowSet.Label;

				for (Integer flowSetPos = 1; flowSetPos <= MAX_FLOWS; ++flowSetPos)
				{
					String flowSetName = 'Match_Flow_' + flowSetPos + '__c';
					Id     flowId      = (Id)flowSet.get(flowSetName);

					if (flowId != null)
					{
						String flowQuery = Match_Util_Metadata.buildQuery(SETTINGS_FLOW, '');
						flowQuery       += ' WHERE Id = \'' + flowId + '\'';
						List<Match_Flow__mdt> flowSetItems = (List<Match_Flow__mdt>) Database.query(flowQuery);

						for(Match_Flow__mdt flowItem: flowSetItems)
						{
							matchObject.flowList.flows.add(setMatchFlow(flowItem));
						}
					}
				}
			}
		}

		if (match.Match_Attribute_Type_Set__c != null)
		{
			String typeSetQuery = Match_Util_Metadata.buildQuery(SETTINGS_TYPE_SET, '');
			typeSetQuery       += ' WHERE id = \'' + match.Match_Attribute_Type_Set__c + '\'';

			List<Match_Attribute_Type_Set__mdt> typeSets = (List<Match_Attribute_Type_Set__mdt>)Database.query(typeSetQuery);

			for (Match_Attribute_Type_Set__mdt typeSet : typeSets)
			{
				for (Integer typePos = 1; typePos <= MAX_TYPES; typePos++)
				{
					String typeName = 'Type_' + typePos + '__c';
					Id     typeId   = (Id)typeSet.get(typeName);

					if (typeId != null)
					{
						String typeQuery = Match_Util_Metadata.buildQuery(SETTINGS_TYPE, '');
						typeQuery += ' WHERE Id = \'' + typeId + '\'';
						Match_Attribute_Type__mdt attributeType = (Match_Attribute_Type__mdt) Database.query(typeQuery);

						if (attributeType != null)
						{
							matchObject.typeList.types.add(setAttributeType(attributeType));
						}
					}
				}
			}
		}

		return matchObject;
	}

	@TestVisible
	private Match_Flow_Model setMatchFlow(Match_Flow__mdt flowItem)
	{
		Match_Flow_Model flow = new Match_Flow_Model();

		flow.label   = flowItem.Label;
		flow.name    = flowItem.Name__c;
		flow.title   = flowItem.Title__c;
		flow.message = flowItem.Message__c;

		return flow;
	}

	@TestVisible
	private Match_Attribute_Type setAttributeType(Match_Attribute_Type__mdt attributeType)
	{
		Match_Attribute_Type newType = new Match_Attribute_Type();

		newType.id         = attributeType.Id;
		newType.name       = attributeType.MasterLabel;
		newType.multiplier = attributeType.Multiplier__c;

		return newType;
	}

	@TestVisible
	private Match_Filter_Model setFilterModel(Match_Filter__mdt filterItem, Match_Field field)
	{
		Match_Filter_Model model = new Match_Filter_Model();

		model.id          = filterItem.Id;
		model.name        = filterItem.DeveloperName;
		model.label       = filterItem.Label;
		model.operator    = filterItem.Field_Operator__c;
		model.filterType  = filterItem.Filter_Type__c;
		model.field       = field;

		if (String.isNotBlank(filterItem.Secondary_Label__c))
		{
			List<String> labels = new List<String>();

			for(String labelItem : Match_Util.getStringValues(filterItem.Secondary_Label__c))
			{
				labels.add(labelItem);
			}

			model.labelSet = labels;
		}

		return model;
	}

	@TestVisible
	private Match_Sort_Model setSortModel(Match_Sort__mdt sortItem, Match_Field field)
	{
		Match_Sort_Model model = new Match_Sort_Model();

		model.id        = sortItem.Id;
		model.name      = sortItem.DeveloperName;
		model.label     = sortItem.Label;
		model.direction = sortItem.Direction__c;
		model.field     = field;

		return model;
	}

	@TestVisible
	private Match_Field setFieldObject(Match_Field__mdt field, String fieldName, Decimal order)
	{
		Match_Field matchField = new Match_Field();

		matchField.id        = field.Id;
		matchField.name      = fieldName;
		matchField.apiName   = field.API_Name__c;
		matchField.label     = field.Label__c;
		matchField.fieldType = field.Type__c;
		matchField.align     = field.Alignment__c;
		matchField.info      = field.Info__c;
		matchField.sequence  = order;

		return matchField;
	}

	private List<String> getGroupIcons(Match_Object__mdt match)
	{
		List<String> icons = new List<String>();

		if (match.Group_Icon_Set__c != null)
		{
			String iconSetQuery = Match_Util_Metadata.buildQuery(SETTINGS_ICON_SET, '');
			iconSetQuery += ' WHERE id = \'' + match.Group_Icon_Set__c + '\'';

			List<Match_Icon_Set__mdt> iconSets = (List<Match_Icon_Set__mdt>)Database.query(iconSetQuery);

			for(Match_Icon_Set__mdt iconSet : iconSets)
			{
				for (Integer iconPos = 1; iconPos <= MAX_ICONS; iconPos++)
				{
					String iconName = 'Icon_' + iconPos + '__c';
					Id     iconId   = (Id)iconSet.get(iconName);

					if (iconId != null)
					{
						String iconQuery = Match_Util_Metadata.buildQuery(SETTINGS_ICON, '');
						iconQuery += ' WHERE Id = \'' + iconId + '\'';

						Match_Icon__mdt icon = (Match_Icon__mdt) Database.query(iconQuery);

						if (icon != null)
						{
							String name = 'Icon_Name__c';
							icons.add((String) icon.get(name));
						}
					}
				}
			}
		}

		return icons;
	}
}