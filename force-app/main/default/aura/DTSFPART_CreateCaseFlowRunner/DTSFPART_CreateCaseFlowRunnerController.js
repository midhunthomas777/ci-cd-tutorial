({
  doInit: function (component, event, helper) {
    const flow = component.find("flowData");
    flow.startFlow("Create_Case");
  },
  hideModal: function (component, event, helper) {
    if (event.getParam("status").indexOf("FINISHED") !== -1) {
      const closeAction = $A.get("e.force:closeQuickAction");
      closeAction.fire();
    }
  }
});