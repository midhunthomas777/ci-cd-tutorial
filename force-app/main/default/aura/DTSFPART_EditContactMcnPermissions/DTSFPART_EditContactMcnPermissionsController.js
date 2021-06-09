({
    handleModalClose: function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();

        var workspaceAPI = component.find('workspace');
        workspaceAPI
            .getFocusedTabInfo()
            .then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
            .catch(function(error) {
                console.log(error);
                window.history.back();
            });
    }
});