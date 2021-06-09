/**
 * Created by tricia.igoe on 4/9/20.
 */

({
    doInit: function(component, event, helper) {
        component.set('v.checkboxColumn', true);
        console.log(component.get("v.checkboxColumn"));
        helper.setTheColumns(component, event, helper);
        helper.getTopicId(component, event, helper);
        helper.getTheArticleList(component, event, helper);
    },
    handleSort: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    handleKeyUp: function (component, event, helper) {
        helper.searchList(component, event, helper);
    }
});