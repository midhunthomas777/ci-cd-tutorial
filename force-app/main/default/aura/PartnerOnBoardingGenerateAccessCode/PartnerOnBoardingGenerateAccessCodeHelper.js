({
	generateAccessCode : function(component, event) {
        var userTheme=component.get("v.userTheme");
        var recId=component.get("v.recordId");
	 if (userTheme === 'Theme3') {
            var action = component.get('c.generateAccessCode');      
            action.setParams({
                "partnerEmpowerId": component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var form = response.getReturnValue();
                    component.set("v.showSpinner", false); 
                    window.open("/"+recId,"_self");
                }
            });                
            $A.enqueueAction(action);
        }else{
            var action = component.get('c.generateAccessCode');      
            action.setParams({
                "partnerEmpowerId": component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var form = response.getReturnValue();
                    component.set("v.showSpinner", false); 
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
            });                
            $A.enqueueAction(action);
        }	
	}
})