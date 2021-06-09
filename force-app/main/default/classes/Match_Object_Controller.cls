/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 4/11/18.
 */

public with sharing class Match_Object_Controller
{
	public static Match_List getMatchList(
		Match_Settings_Model metaData,
		Decimal pageSize,
		Decimal currentPage,
		String  filterString,
		String  sortString)
	{
		System.debug('getMatchList(' + metaData.name +', ' + pageSize + ', ' + currentPage + ', ' + filterString + ', ' + sortString + ')');
		metaData.dumpModel('metaData', true);

		Match_List model = new Match_List();

		pageSize    = Match_Util.checkPageSize(pageSize);
		currentPage = Match_Util.checkCurrentPage(currentPage);
		Decimal searchOffset = pageSize * (currentPage - 1);

		Match_Object sourceObject = metaData.source;
		Match_Object targetObject = metaData.target;

		String targetId = Match_Util.getParseStringValue(filterString, 'targetId');

		if (String.isBlank(targetId))
		{
			Map<String, String> targetSkillMap = Match_Object_Controller.getTargetList(metaData, '');
			if (targetSkillMap.size() > 0)
			{
				for (String item : targetSkillMap.keySet())
				{
					// take the first target skill
					targetId = targetSkillMap.get(item); break;
				}
			}
		}

		Match_Skill_List targetSkills = getSkillSet(targetObject, targetId);
		targetSkills.dumpModel('target skills for ' + targetId);

		// variable used to bind target ID's in the query
		List<String> targetIdList = targetSkills.idList;
		System.debug('targetIdList: ' + targetIdList);

		// Calculate LIMIT
		Decimal recordCount = getTotalCandidates(sourceObject);
		Decimal limitValue  = recordCount > Match_Util.DEFAULT_LIST_LIMIT ? Match_Util.DEFAULT_LIST_LIMIT : recordCount;
		model.paginationLimit = limitValue;

		System.debug('Hi-Vol Record count   = ' + recordCount);
		System.debug('Hi-Vol Limit value    = ' + limitValue);

		// build the compound query
		String  query = getMatchSelectClause(sourceObject, metaData.pagingField, targetIdList);
		query += getMatchFromClause(sourceObject);
		query += getMatchWhereClause(sourceObject.filterList, filterString, sourceObject.excludeField);
		query += getMatchSortClause(sourceObject, sortString, metaData.pagingField);
		query += Match_Util.getLimitClause(limitValue);
		query += Match_Util.getOffsetClause(searchOffset);

		System.debug('getMatchHostList - query: ' + query);

		Boolean useRatingIcons = metaData.source.groupIcons.size() > 0;

		List<SObject> matchAttributes = (List<SObject>) Database.query(query);

		for(SObject matchObject : matchAttributes)
		{
			String matchItemId = (String)matchObject.get('Id');

			// avoid the target in the list
			// System.debug('Checking for same ID - targetId: ' + targetId + ', sourceId: '+ matchItemId);
			if (matchItemId.substring(0, 15).compareTo(targetId.substring(0, 15)) != 0)
			{
				Match_Model matchItem = new Match_Model();

				matchItem.id    = matchItemId;

				if (metaData.pagingField != null)
				{
					getFieldValue(matchItem, matchObject, metaData.pagingField, 0);
				}

				// handle the metadata defined  fields
				Integer fieldPos = 1;
				for(Match_Field field : sourceObject.fields)
				{
					if (field != null && String.isNotBlank(field.name))
					{
						getFieldValue(matchItem, matchObject, field, fieldPos);
					}
					fieldPos++;
				}

				String attributesName = getAttributesName(sourceObject.childPrefix, sourceObject.childPostfix);
				List<SObject> children = (List<SObject>) matchObject.getSObjects(attributesName);

				if (children != null)
				{
					for (SObject child : children)
					{
						SObject relationObj = child.getSObject('Match_Attribute__r');
						Id      skillId     = (Id) relationObj.get('Id');

						if (!containsAttribute(matchItem.skills, skillId))
						{
							matchItem.skills.add(new Match_Skill_Model(skillId, (String) relationObj.get('Name'), (Boolean) child.get('Critical__c'), (String) child.get('Type__c')));
						}
					}

					//System.debug('on target object: ' + matchItem.name);
					matchItem.match = calculateMatch(metaData, matchItem.skills, targetSkills);

					if (matchItem.match > 0)
					{
						matchItem.rating       = metaData.source.ratingGroups > 0 ? calculateRating(metaData.source.ratingGroups, matchItem.match) : 0;
						if (useRatingIcons)
						{
							matchItem.ratingIcon = metaData.source.groupIcons[matchItem.rating.intValue()-1];
						}
						matchItem.critical     = hasRequiredAttributes(targetSkills, matchItem.skills);
						matchItem.criticalText = matchItem.critical ? 'Yes' : 'No';

						//matchItem.dumpModel('adding skill');
						model.items.add(matchItem);
					}
					else
					{
						System.debug('  **** no match found -- query needs tuning');
					}
				}
			}
		}

		// Remember the last item for pagination
		if (model.items.size() > 0)
		{
			model.paginationValue = model.items[model.items.size()-1].pagingField;
		}

		// FILTERS
		// critical  skills only
		if (Match_Util.hasAttribute(filterString, 'critical')) { model.criticalOnly();}

		// rating range
		if (Match_Util.hasAttribute(filterString, 'rating')){model.ratingRange(Match_Util.getParseStringValue(filterString, 'rating'));}

		// confidence range
		if (Match_Util.hasAttribute(filterString, 'confidence')) {model.matchRange(Match_Util.getParseStringValue(filterString, 'confidence'));}

		// SORT
		// order by Confidence
		if (Match_Util.hasAttribute(sortString, 'confidence')){ model.items.sort();}

		// capture total for pagination
		Integer totalItems = model.items.size();

		// return only page size items to the lighting component
		if (totalItems > (Integer)pageSize) { model.limitDataSet(pageSize, currentPage);}

		model.total           = totalItems;
		model.pageCount       = Math.max(Math.ceil(totalItems / pageSize), 1);
		model.pageSize        = pageSize;
		model.pageCurrent     = currentPage;
		model.pageHasNext     = (pageSize * currentPage) < totalItems;
		model.pageHasPrevious = searchOffset > 0;
		model.processed       = recordCount;

		model.dumpModel('getMatchList', false);

		return model;
	}

	public static Map<String, String> getTargetList(
		Match_Settings_Model metaData,
		String searchString)
	{
		Map<String, String> targetList = new Map<String, String>();
		String query = 'SELECT Id, Name FROM ' + metaData.target.objectName;
		String search = '%' + searchString + '%';

		if (String.isNotBlank(searchString))
		{
			query += ' AND Name LIKE :search';
		}

		query += ' ORDER BY Name';

		List<SObject> targetItems = (List<SObject>) Database.query(query);
		for (SObject targetItem : targetItems)
		{
			targetList.put((String)targetItem.get('Name'), (String)targetItem.get('Id'));
		}

		return targetList;
	}

	@TestVisible
	private static Decimal calculateMatch(
		Match_Settings_Model metaData,
		List<Match_Skill_Model> sourceSkills,
		Match_Skill_List targetSkills)
	{
		//System.debug('calculateMatch');

		Decimal weightCritical   = metaData.multiplier != null ? metaData.multiplier : 1;
		Decimal weightMultiplier = 1.0;

		Decimal match       = 0;
		Decimal weight      = 1;
		Decimal sourceMatch = 0;
		Decimal targetMatch = targetSkills.itemList.size() * weightCritical;

		if (targetMatch > 0)
		{
			for(Match_Skill_Model skill : sourceSkills)
			{
				Match_Skill_Model entry = targetSkills.getSkillById(skill.id);

				if (entry != null)
				{
					weightMultiplier = getAttributeMultiplier(metaData.target.typeList, skill);
					weight = entry.critical ? weightCritical : weightMultiplier;

					sourceMatch += (1 * weight);
					//System.debug('found match for: ' + skill.id + ', multiplier: ' + weightMultiplier + ', weight: ' + weight);
				}
			}

			//System.debug(' -- source skills = ' + targetMatch);
			//System.debug(' -- target skills = ' + sourceMatch);

			match = sourceMatch / targetMatch;
			//System.debug('    match = ' + match);
		}

		return match;
	}

	@TestVisible
	private static Decimal getAttributeMultiplier(Match_Attribute_Type_List targetList, Match_Skill_Model skill)
	{
		if (skill == null || skill.typeName == null)
		{
			//System.debug(' ** getAttributeMultiplier attribute type not defined, defaulting to 1');
			return 1;
		}

		if (targetList == null || targetList.types == null || targetList.types.size() == 0)
		{
			//System.debug(' ** getAttributeMultiplier Target attribute type list not defined, defaulting to 1');
			return 1;
		}

		//System.debug(' ** getAttributeMultiplier for: ' + skill.typeName);
		Match_Attribute_Type attributeType = targetList.findTypeByName(skill.typeName);

		if (attributeType == null)
		{
			//System.debug(' ** attribute type not found for ' + skill.typeName);
			return 1;
		}

		return attributeType.multiplier != null ? attributeType.multiplier : 1;
	}

	@TestVisible
	private static Decimal calculateRating(Decimal ratingsGroups, Decimal match)
	{
		Decimal interval = 100 / ratingsGroups;
		Decimal rating   = Math.ceil((match / interval) * 100);

		//System.debug('Rating for ' + match + ' = ' + rating);

		return rating;
	}

	@TestVisible
	private static Boolean hasRequiredAttributes(Match_Skill_List targetSkills, List<Match_Skill_Model> sourceSkills)
	{
		Boolean critical = true;

		for (Match_Skill_Model skill : targetSkills.itemList)
		{
			if (skill.critical)
			{
				if (!containsAttribute(sourceSkills, skill.id))
				{
					critical = false;
					break;
				}
			}
		}

		return critical;
	}

	@TestVisible
	private static Boolean containsAttribute(List<Match_Skill_Model> attributes, String id)
	{
		Boolean matched = false;

		for(Match_Skill_Model attribute : attributes)
		{
			if (attribute.id == id)
			{
				matched = true;
				break;
			}
		}

		return matched;
	}

	@TestVisible
	private static void getFieldValue(Match_Model matchItem, SObject matchObject, Match_Field field, Integer fieldPos)
	{
		String fieldName  = field.apiName;
		Object fieldValue = null;

		//System.debug('getting field value for ' + field.name + ' (' + field.apiName + ')');

		if (fieldName.indexOf('.') != -1)
		{
			String[] fieldParts = fieldName.split('\\.');
			SObject  owner      = matchObject.getSObject(fieldParts[0]);

			if (owner != null)
			{
				fieldValue = (Object) owner.get(fieldParts[1]);
			}
		}
		else
		{
			fieldValue = (Object) matchObject.get(fieldName);
		}

		if (fieldValue != null)
		{
			if (fieldPos == 0)  { matchItem.pagingField = fieldValue;}
			if (fieldPos == 1)  { matchItem.Field_1     = fieldValue;}
			if (fieldPos == 2)  { matchItem.Field_2     = fieldValue;}
			if (fieldPos == 3)  { matchItem.Field_3     = fieldValue;}
			if (fieldPos == 4)  { matchItem.Field_4     = fieldValue;}
			if (fieldPos == 5)  { matchItem.Field_5     = fieldValue;}
			if (fieldPos == 6)  { matchItem.Field_6     = fieldValue;}
			if (fieldPos == 7)  { matchItem.Field_7     = fieldValue;}
			if (fieldPos == 8)  { matchItem.Field_8     = fieldValue;}
			if (fieldPos == 9)  { matchItem.Field_9     = fieldValue;}
			if (fieldPos == 10) { matchItem.Field_10    = fieldValue;}
		}
	}

	@TestVisible
	private static Match_Skill_List getSkillSet(Match_Object skillObject, String targetId)
	{
		Match_Skill_List skillList = new Match_Skill_List();

		String skillObjectName = checkObjectName(skillObject.objectName);
		String childObjectName = skillObject.childPrefix + '_Attribute__c';

		String query = 'SELECT Id, Name, Critical__c, Type__c, ' + skillObjectName + ', Match_Attribute__c FROM ' + childObjectName;
		if (String.isNotBlank(targetId))
		{
			query += ' WHERE ' + skillObjectName + ' = \'' + targetId + '\'';
		}
		System.debug('getSkillSet query: ' + query);

		SObject[] skills = Database.query(query);

		for(SObject skillItem : skills){
			skillList.idList.add((Id) skillItem.get('Match_Attribute__c'));
		}

		List<Match_Attribute__c> attributes = [SELECT Id, Name  FROM Match_Attribute__c WHERE Archived__c  = FALSE AND Id IN :skillList.idList ORDER BY Id];

		skillList.idList .clear();

		for (SObject skillItem : skills)
		{
			Id skillId = (Id) skillItem.get('Match_Attribute__c');

			// check for duplicate skills
			Match_Skill_Model newSkill = new Match_Skill_Model();

			newSkill.critical = (Boolean) skillItem.get('Critical__c');
			newSkill.typeName = (String)  skillItem.get('Type__c');

			for (Match_Attribute__c newAttr : attributes)
			{
				if (newAttr.Id == skillId)
				{
					newSkill.id   = newAttr.Id;
					newSkill.name = newAttr.Name;

					break;
				}
			}

			if (!containsAttribute(skillList.itemList, newSkill.id))
			{
				skillList.itemList.add(newSkill);
				skillList.idList.add(newSkill.id);
			}
		}

		return skillList;
	}

	@TestVisible
	private static String checkObjectName(String name)
	{
		return name.endsWith('__c') ? name : name + '__c';
	}

	// Required attribute fields
	private static String[] Attribute_Fields = new String[] {
		'id',
		'Name',
		'Critical__c',
		'Match_Attribute__r.Name',
		'Type__c'
	};

	@TestVisible
	private static String getMatchSelectClause(Match_Object sourceObject, Match_Field pagingField, List<String> targetIdList)
	{
		String selectClause = '';
		List<String> fields = new List<String>();

		// std fields
		fields.add('SELECT Id');
		if (pagingField != null)
		{
			fields.add(pagingField.apiName);
		}

		if (String.isNotBlank(sourceObject.excludeField))
		{
			fields.add(sourceObject.excludeField);
		}

		for(Match_Field field : sourceObject.fields)
		{
			if (field != null && String.isNotBlank(field.apiName))
			{
				if (!fields.contains(field.apiName))
				{
					fields.add(field.apiName);
				}
			}
		}

		String targetAttributesName = getAttributesName(sourceObject.childPrefix, sourceObject.childPostfix);

		selectClause += Match_Util.buildQueryFields(fields);
		selectClause += ', (SELECT ' + Match_Util.buildQueryFields(Attribute_Fields);
		selectClause += ' FROM ' + targetAttributesName;

		if (targetIdList.size() > 0)
		{
			selectClause += ' WHERE Match_Attribute__c IN :targetIdList';
		}
		selectClause += ') ';

		System.debug('getMatchSelectClause: ' + selectClause);

		return selectClause;
	}

	@TestVisible
	private static String getMatchFromClause(Match_Object sourceObject)
	{
		String fromClause = ' FROM ' + sourceObject.objectName;
		System.debug('getMatchFromClause: ' + fromClause);

		return fromClause;
	}

	@TestVisible
	private static String getMatchWhereClause(Match_Filter_List filterList, String filterString, String excludeField)
	{
		//System.debug('getMatchWhereClause: ' +  filterList +',' + filterString);
		List<String> whereParts = new List<String>();

		if (String.isNotBlank(filterString) && filterList != null)
		{
			Map<String, String> filterMap = Match_Util.parseString(filterString);

			for(String filterName : filterMap.keySet())
			{
				Match_Filter_Model filter = filterList.getFilter(filterName);

				if (filter != null)
				{
					String delimiter    = filter.filterType == 'Date' ? '' : '\'';
					String[] valueParts = Match_Util.getStringValues(filterMap.get(filterName));
					String startValue   = '';
					String endValue     = '';
					String filterAction = '';

					if (valueParts.size() > 0)
					{
						if (String.isNotBlank(valueParts[0]))
						{
							startValue = valueParts[0] + (filter.filterType == 'Date' ? 'T00:00:00Z' : '');
						}

						if (valueParts.size() > 1)
						{
							if (String.isNotBlank(valueParts[1]))
							{
								endValue = valueParts[1] + (filter.filterType == 'Date' ? 'T23:59:59Z' : '');
							}
						}

						switch on filter.operator
						{
							when 'Equals'
							{
								filterAction = ' = ' + delimiter + startValue + delimiter;
							}
							when 'Contains'
							{
								filterAction = ' LIKE \'%' + String.valueOf(startValue) + '%\'';
							}
							when 'GreaterThan'
							{
								filterAction = ' > ' + delimiter + startValue + delimiter;
							}
							when 'GreaterEqual'
							{
								filterAction = ' >= ' + delimiter + startValue + delimiter;
							}
							when 'LessThan'
							{
								filterAction = ' < ' + delimiter + startValue + delimiter;
							}
							when 'LessEqual'
							{
								filterAction = ' <= ' + delimiter + startValue + delimiter;
							}
							when 'Between'
							{
								if (String.isNotBlank(startValue))
								{
									filterAction = ' >= ' + delimiter + startValue + delimiter;
								}

								if (String.isNotBlank(endValue))
								{
									if (String.isNotBlank(startValue))
									{
										filterAction += ' AND ' + filter.field.apiName + ' <= ' + delimiter + endValue + delimiter;
									} else
									{
										filterAction = ' <= ' + delimiter + endValue + delimiter;
									}
								}
							}
						}

						if (String.isNotBlank(filterAction))
						{
							whereParts .add(filter.field.apiName + filterAction);
						}
					}
				}
			}
		}

		if (String.isNotBlank(excludeField))
		{
			whereParts.add(excludeField + ' = FALSE');
		}

		String whereClause = whereParts.size() > 0 ? ' WHERE ' + String.join(whereParts, ' AND ') : '';
		System.debug('getMatchWhereClause: ' + whereClause);

		return whereClause;
	}

	@TestVisible
	private static String getMatchSortClause(Match_Object sourceObject, String sortString, Match_Field pagingField)
	{
		//System.debug('Sort string : ' + sortString);
		List<String> sortParts = new List<String>();

		if (pagingField != null)
		{
			sortParts.add(pagingField.apiName);
		}

		if (String.isNotBlank(sortString))
		{
			Map<String, String> sortSet = Match_Util.parseString(sortString);

			for(String sortLabel : sortSet.keySet())
			{
				Match_Field sortField = sourceObject.findField(sortLabel);

				if (sortField != null)
				{
					String sortOrder = sortSet.get(sortLabel);
					sortParts.add(sortField + sortOrder == 'asc' ? ' ASC' : ' DESC');
				}
			}
		}

		String sortClause = sortParts.size() > 0 ? (' ORDER BY ' +  String.join(sortParts, ',')) : '';
		System.debug('getMatchSortClause: ' + sortClause);

		return sortClause;
	}

	@TestVisible
	private static Decimal getTotalCandidates(Match_Object sourceObject)
	{
		Decimal recordCount = 0;
		String  recordQuery = 'SELECT COUNT(ID) entityCount  FROM ' + sourceObject.objectName ;

		for (AggregateResult result: Database.query(recordQuery))
		{
			recordCount += (Decimal)result.get('entityCount');
		}

		return recordCount;
	}

	@TestVisible
	private static String getAttributesName(String prefix, String postfix)
	{
		String formatString = '{0}_{1}__r';
		List<String> params = new String[] {prefix, postfix};
		return String.format(formatString, params);
	}
}