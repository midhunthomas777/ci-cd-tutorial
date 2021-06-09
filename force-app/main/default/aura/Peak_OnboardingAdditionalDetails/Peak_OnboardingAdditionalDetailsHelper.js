/**
 * Created by: Dipendra Dadhich
 * Created Date: 19-08-2019. 
 */
 ({
     goToNext : function(component, event, helper) {
         var compEvent = component.getEvent("pageChange");
         compEvent.setParams({"message" : "4", "slide" : "Additional"});
         compEvent.fire();
     },
     goBack : function(component, event, helper) {
         var compEvent = component.getEvent("pageChange");
         compEvent.setParams({"message" : "2", "slide" : ""});
         compEvent.fire();
     },
     handleSubmit : function(component, event, helper) {
         event.preventDefault();
         var fields = event.getParam("fields");
         component.find("form").submit(fields);
     }
})