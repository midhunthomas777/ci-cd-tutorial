/*
     Copyright (c) 2018. 7Summits Inc.
     Created by 7Summits - Melinda Grad on 7/25/18.
 */

public with sharing class Adventure_Peak_BaseController
{

    // Get the site prefix (for displaying links/assets)
    @AuraEnabled
    public static String getSitePrefix(){
        return Adventure_Utils.getSitePrefix();
    }

    // Determine if guest or logged in
    @AuraEnabled
    public Static Boolean isGuestUser() {
        return Adventure_Utils.isGuestUser();
    }

    // Get current year from server
    @AuraEnabled
    public Static Integer getYear() {
        return Adventure_Utils.getYear();
    }
}