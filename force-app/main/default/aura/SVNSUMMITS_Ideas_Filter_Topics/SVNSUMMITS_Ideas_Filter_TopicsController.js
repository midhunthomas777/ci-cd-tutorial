/*
 * Copyright (c) 2019. 7Summits Inc.
 */
/**
 * Created by francois korb on 9/21/16.
 */
({
    // Initialize page filters
    initializeFilters : function(component, event, helper) {
	    let topicValues = component.get('v.TopicValue');

	    if (topicValues && topicValues.trim() !== '') {
		    component.set('v.topicNamesList', topicValues.split(','));
	    } else {
		    helper.doCallout(component, "c.getTopicNamesList", {}, true, '', true)
			    .then($A.getCallback(function (list) {
				    helper.debug(component, 'Topics loaded');
				    component.set("v.topicNamesList", list);
			    }));
	    }
 	},

    // Method to filter list of ideas on basis of topics
    filterByTopics : function(component, event, helper) {
        helper.debug(component, '---- Filter By Topic ----');

        let filter = component.get('v.topicSelect');
        let clear  = component.get("v.labelFilter");

        helper.debug(component, '    filter: ' + filter);

	    $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
		    .setParams(
		    	{
				    listId         : component.get('v.listId'),
				    searchByTopics : filter === clear ? ' ' : filter
		    	})
		    .fire();

    }
});