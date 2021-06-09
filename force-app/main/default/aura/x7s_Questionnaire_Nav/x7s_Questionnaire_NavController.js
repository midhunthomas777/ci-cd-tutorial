({
   handleChange : function(component, event, helper) {
      // When an option is selected, navigate to the next screen
      var response = event.getSource().get("v.label");
      component.set("v.selectedValue", response);
      var navigate = component.get("v.navigateFlow");
      navigate("NEXT");       
   }
    
})