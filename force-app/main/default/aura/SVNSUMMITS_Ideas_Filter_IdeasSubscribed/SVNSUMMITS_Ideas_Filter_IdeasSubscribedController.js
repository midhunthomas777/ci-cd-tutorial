({
    filterByIdeasSubscribedOn : function(component, event, helper) {
        helper.debug(component, '---- Ideas Subscribed On Filter  ----');

        const filter = component.get("v.subscribedIdeas");
        helper.debug(component, "    Filter: " + filter);

        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
            .setParams(
                {
                    listId        : component.get('v.listId'),
                    searchMySubscribedIdeas : filter ? 'Display My Subscribed Ideas Only' : ' '
                })
            .fire();
    }
})