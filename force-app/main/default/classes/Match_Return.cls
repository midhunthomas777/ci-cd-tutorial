/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 5/8/18.
 */

public with sharing class Match_Return
{
	@AuraEnabled public Boolean isSuccess;
	@AuraEnabled public String message;
	@AuraEnabled public String recordId;

	@AuraEnabled public Boolean       success  { get; set; } // success or failure
	@AuraEnabled public List<String>  messages { get; set; } // messages to display
	@AuraEnabled public List<SObject> results  { get; set; } // results to iterate over - use

	public Match_Return()
	{
		success  = true;
		messages = new List<String>();
		results  = new List<SObject>();
	}
}