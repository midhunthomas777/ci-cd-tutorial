/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    doInit : function(component, event, helper) {      
        helper.getZoneId(component);
        helper.get_UserId(component);
        helper.get_SitePrefix(component);
    }
})