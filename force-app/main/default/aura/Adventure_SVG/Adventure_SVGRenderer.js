({
  afterRender: function (component, helper) {
      this.superAfterRender();
      helper.renderIcon(component, helper);
  },
})