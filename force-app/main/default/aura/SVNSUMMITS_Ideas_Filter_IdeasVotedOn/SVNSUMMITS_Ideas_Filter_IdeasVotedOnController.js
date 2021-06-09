/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    filterByIdeasVotedOn : function(component, event, helper) {
        helper.debug(component, '---- Ideas Voted On Filter  ----');

        const filter = component.get("v.votedIdeas");
        helper.debug(component, "    Filter: " + filter);

        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
            .setParams(
                {
                    listId        : component.get('v.listId'),
                    searchMyIdeas : filter ? 'Display My Voted Ideas Only' : ' '
                })
            .fire();
    }

})