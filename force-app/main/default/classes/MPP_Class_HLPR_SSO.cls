/*
Modified By : Sai Sampath
Date of Modified : 5-Nov-2015
Version: 2.0
Purpose : Change link on Partner Central Profile Page
Incident# : INC0715959
Description : changed url from http://membership.mot-solutions.com/mot/search/default.asp  to  
              https://myaccount.motorolasolutions.com/euri/update_profile.xhtml
*/
public with sharing class MPP_Class_HLPR_SSO {
    private static final String PROD_ORG_ID = '00D300000000zOcEAI';
    private static final String TEST_SSO_URL = 'https://mylogin-uat.motorolasolutions.com/SAMLRequestRedirect.asp?SPID=sp.salesforce.cs1';
    private static final String PROD_SSO_URL = 'http://login.salesforce.com';
    private static final String TEST_USER_URL = 'http://membership-uat.mot-solutions.com/mot/search/default.asp';
    private static final String PROD_USER_URL = 'https://myaccount.motorolasolutions.com/euri/update_profile.xhtml';
    
    public static PageReference redirectToSSO(){
        return new PageReference(getSSOLink());
    }
    
    public static PageReference redirectToUserEdit(){
        return new PageReference(getUserEditLink());
    }
    
    public static Boolean isProduction(){
        return (UserInfo.getOrganizationId() == PROD_ORG_ID);
    }
    
    public static String getSSOLink(){
        return (isProduction())?PROD_SSO_URL:TEST_SSO_URL;
    }
    
    public static String getUserEditLink(){
        return (isProduction())?PROD_USER_URL:TEST_USER_URL;
    }
}