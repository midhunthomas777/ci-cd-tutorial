({
    handleModalClose: function(component, event, helper) {
        // workaround to unblock UI after modal close
        setTimeout(function() {
            $A.get('e.force:closeQuickAction').fire();
        }, 1000);

        var workspaceAPI = component.find('workspace');
        workspaceAPI
            .getFocusedTabInfo()
            .then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
            .catch(function(error) {
                window.history.back();
            });
    }
});