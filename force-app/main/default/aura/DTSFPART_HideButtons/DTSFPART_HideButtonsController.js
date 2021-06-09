({
    doInit: function (component) {
      const hideButtonsMethod = component.get("c.hideButtons");
      hideButtonsMethod.setParams({ recordId: component.get("v.recordId") });
      hideButtonsMethod.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
          const result = response.getReturnValue();
          component.set("v.hiddenButtons", result);
        }
      });
      $A.enqueueAction(hideButtonsMethod);
    }
  });