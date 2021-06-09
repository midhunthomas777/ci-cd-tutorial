/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francoiskorb on 7/6/18.
 */

public with sharing class Match_Flow_Model
{
	@AuraEnabled
	public String name, label, title, message;

	public void dumpModel(String heading)
	{
		System.debug('Dump flow: ' + heading);
		System.debug('    name      : ' + name);
		System.debug('    label     : ' + label);
		System.debug('    title     : ' + title);
		System.debug('    message   : ' + message);
	}
}