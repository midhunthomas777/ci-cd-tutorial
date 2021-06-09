/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 4/11/18.
 */

public with sharing class Match_Model implements Comparable
{
	@AuraEnabled
	public String id, name, owner, criticalText;

	@AuraEnabled
	public Object Field_1, Field_2, Field_3, Field_4, Field_5, Field_6, Field_7, Field_8, Field_9, Field_10;

	@AuraEnabled
	public Object pagingField;

	@AuraEnabled
	public Boolean critical;

	@AuraEnabled
	public Decimal match, rating;

	@AuraEnabled
	public String ratingIcon;

	@AuraEnabled
	public List<Match_Skill_Model> skills { get; set; }


	public Match_Model()
	{
		this.id          = '';
		this.name        = '';
		this.owner       = '';
		this.critical    = false;
		this.match       = 0;
		this.rating      = 0;
		this.ratingIcon  = '';
		this.skills      = new List<Match_Skill_Model>();

		this.pagingField = null;
		this.Field_1     = null;
		this.Field_2     = null;
		this.Field_3     = null;
		this.Field_4     = null;
		this.Field_5     = null;
		this.Field_6     = null;
		this.Field_7     = null;
		this.Field_8     = null;
		this.Field_9     = null;
		this.Field_10    = null;
	}

	public Integer compareTo(Object param1)
	{
		Integer compare = 0;

		Match_Model compareTo = (Match_Model)param1;

		if (this.match > compareTo.match) { compare = -1; }
		else if (this.match < compareTo.match) { compare = 1; }
		else
		{
			if (this.critical && compareTo.critical || !this.critical && !compareTo.critical) { compare = 0; }
			else if (this.critical) { compare = 1; } else { compare = -1;}
		}

		return compare;
	}

	public void dumpModel(String title, Boolean depth)
	{
		System.debug('Dump model: ' + title);
		System.debug('  id           : ' + this.id);
		System.debug('  name         : ' + this.name);
		System.debug('  owner        : ' + this.owner);
		System.debug('  match        : ' + this.match);
		System.debug('  rating       : ' + this.rating);
		System.debug('  rating icon  : ' + this.ratingIcon);
		System.debug('  critical     : ' + this.critical);
		System.debug('  pagingField  : ' + this.pagingField);
		System.debug('  Field_1      : ' + this.Field_1);
		System.debug('  Field_2      : ' + this.Field_2);
		System.debug('  Field_3      : ' + this.Field_3);
		System.debug('  Field_4      : ' + this.Field_4);
		System.debug('  Field_5      : ' + this.Field_5);
		System.debug('  Field_6      : ' + this.Field_6);
		System.debug('  Field_7      : ' + this.Field_7);
		System.debug('  Field_8      : ' + this.Field_8);
		System.debug('  Field_9      : ' + this.Field_9);
		System.debug('  Field_10     : ' + this.Field_10);

		if (depth && this.skills.size() > 0)
		{
			Integer count = 1;
			for(Match_Skill_Model skill : this.skills)
			{
				skill.dumpModel('item #' + count);
				count += 1;
			}
		}
	}

}