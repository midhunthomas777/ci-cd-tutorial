/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 4/13/18.
 */

public with sharing class Match_Skill_List
{
	@AuraEnabled
	public List<Match_Skill_Model> itemList
	{
		get;
		set;
	}

	public List<String> idList
	{
		get;
		set;
	}

	public Match_Skill_List()
	{
		this.itemList = new List<Match_Skill_Model>();
		this.idList   = new List<String>();
	}

	public Match_Skill_Model getSkillById(String id)
	{
		for(Match_Skill_Model item : itemList)
		{
			if (item.id == id)
			{
				return item;
			}
		}

		return null;
	}

	public Match_Skill_Model getSkillByName(String name)
	{
		for(Match_Skill_Model item : itemList)
		{
			if (item.name == name)
			{
				return item;
			}
		}

		return null;

	}

	public void dumpModel(String title)
	{
		System.debug('Dump Match_Skill_List: ' + title);
		System.debug('  model.itemList`     : ' + this.itemList.size());

		if (itemList.size() > 0)
		{
			Integer count = 1;

			for(Match_Skill_Model item: this.itemList)
			{
				item.dumpModel('item ' + count);
				count += 1;
			}
		}
	}
}