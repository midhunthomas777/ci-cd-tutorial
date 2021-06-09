/*
 * Copyright (c) 2018  7Summits Inc.
 */

/**
 * Created by francois korb on 3/21/18.
 */

@IsTest
public with sharing class Match_TestConstants
{
	public static final String CUSTOMER_COMMUNITY_USER	= 'Customer Community User';
	public static final String PARTNER_COMMUNITY_USER	= 'Partner Community User';
	public static final String COMPANY_COMMUNITY_USER   = 'Company Community Profile';

	public static final Integer TEST_SIZE               = 5;
	public static final String  testUserName            = 'tester@7s-001-pc-noemail.com';

	public static final String TEST_MESSAGE             = 'Test message';
	public static final String TEST_SKILL_NAME          = 'skill_1_test';

	public static       List<String> TestScenarios      = new List<String>{'Users'};
}