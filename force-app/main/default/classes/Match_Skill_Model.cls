/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 3/21/18.
 */

public with sharing class Match_Skill_Model implements Comparable
{
	@AuraEnabled
	public String id, name, typeId, typeName;

	@AuraEnabled
	public Boolean critical;

	public Match_Skill_Model()
	{
		this.id         = '';
		this.name       = '';
		this.typeId     = '';
		this.typeName   = '';
		this.critical   = false;

	}

	public Match_Skill_Model(
		Id id,
		String name,
		Boolean critical,
		String typeName)
	{
		this.id         = String.valueOf(id);
		this.name       = name;
		this.critical   = critical;
		this.typeName   = typeName;
	}

	public void dumpModel(String title)
	{
		System.debug('Dump skill model  : ' + title);
		System.debug('  id              : ' + this.id);
		System.debug('  name            : ' + this.name);
		System.debug('  typeId          : ' + this.typeId);
		System.debug('  typeName        : ' + this.typeName);
		System.debug('  critical skills : ' + this.critical);
	}

	public Integer compareTo(Object param1)
	{
		return this.name > ((Match_Skill_Model)param1).name
			? 1 : this.name < ((Match_Skill_Model)param1).name ? -1 : 0;
	}
}