({
    filterByIdeasCommentedOn : function(component, event, helper) {
        helper.debug(component, '---- Ideas Comment On Filter  ----');

        const filter = component.get("v.commentedIdeas");
        helper.debug(component, "    Filter: " + filter);

        $A.get("e.c:SVNSUMMITS_Ideas_Filters_Event")
            .setParams(
                {
                    listId        : component.get('v.listId'),
                    searchMyCommentedIdeas : filter ? 'Display My Commented Ideas Only' : ' '
                })
            .fire();
    }
})