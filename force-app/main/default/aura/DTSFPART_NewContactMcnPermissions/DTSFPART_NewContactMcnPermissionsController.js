({
    doInit: function(component, event, helper) {
        var recordId = component.get('v.recordId');
        if ($A.util.isUndefinedOrNull(recordId) || $A.util.isEmpty(recordId)) {
            var pageRef = component.get('v.pageReference');
            var base64Context = pageRef.state.inContextOfRef;

            if (base64Context.startsWith('1.')) {
                base64Context = base64Context.substring(2);
            }
            var addressableContext = JSON.parse(window.atob(decodeURIComponent(base64Context)));
            component.set('v.recordId', addressableContext.attributes.recordId);
        }
    },
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