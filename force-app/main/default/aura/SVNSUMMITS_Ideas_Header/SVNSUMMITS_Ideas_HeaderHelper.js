/*
 * Copyright (c) 2019. 7Summits Inc.
 */
({
    getCommonSettings: function(component) {
        let action = component.get("c.getCommonSettings");

        action.setCallback(this, function(actionResult) {
            let settings = actionResult.getReturnValue();
            component.set("v.debugMode", settings.debugMode);
            component.set('v.showCreate', settings.canCreateNew);
        });

        $A.enqueueAction(action);
    },

    getIdeaText : function(component) {
        let ideaTitleText = component.get("v.ideaTitle");
        let ideaTitleSet  = '';

        if (ideaTitleText.length > 16) {
            ideaTitleSet = ideaTitleText.substring(0, 16);
        } else {
            ideaTitleSet = ideaTitleText;
        }

        component.set("v.ideaTitle", ideaTitleSet);
    },

    // Determines whether we should show the filter row and mobile dropdown at all.
    showFilterRow: function(component, event, helper) {
        let showMyIdeas = component.get("v.showMyIdeas");
        let showCategoryFilter = component.get("v.showCategoryFilter");
        let showTopicFilter = component.get("v.showTopicFilter");
        let showStatusFilter = component.get("v.showStatusFilter");
        let showThemesFilter = component.get("v.showThemesFilter");
        let showViewSelector = component.get("v.showViewSelector");
        let showSortByFilter = component.get("v.showSortByFilter");
        let showFilterRow = showMyIdeas || showCategoryFilter || showTopicFilter || showStatusFilter || showThemesFilter || showViewSelector || showSortByFilter;
        component.set("v.showFilterRow", showFilterRow);
    }
});