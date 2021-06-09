/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Created by francoiskorb on 6/15/18.
 */

public with sharing class Match_Sort_Model
{
	@AuraEnabled
	public String id, name, label, direction;

	@AuraEnabled
	public Match_Field field;

	public Match_Sort_Model()
	{
		direction = 'DESC';
	}

	public void dumpModel(String title)
	{
		System.debug('Dump filter: ' + title);
		System.debug('    Id        : ' + id);
		System.debug('    name      : ' + name);
		System.debug('    label     : ' + label);
		System.debug('    field     : ' + field.apiName);
		System.debug('    direction : ' + direction);
	}

}