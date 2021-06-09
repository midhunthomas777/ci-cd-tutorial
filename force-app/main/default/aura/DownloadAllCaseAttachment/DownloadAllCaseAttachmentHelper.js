({
	init : function(component,event,helper) {
        
          console.log('in init function');
          var action = component.get("c.getInitialValue"); 
          action.setParams({
			pId: component.get("v.recordId")
          });
          action.setCallback(this, function(a) {
			var downloadurl = a.getReturnValue();
              console.log(a.getReturnValue());
			if(a.getReturnValue().length>0){
				console.log(downloadurl);
                var urlEvent = $A.get("e.force:navigateToURL");
     			   urlEvent.setParams({
        	      "url": downloadurl
            });
       		    urlEvent.fire();
			}else{
				console.log('retrieved no initial value');
                this.showErrorToast(component,event,helper);
			}
			return;
		});
        
          $A.enqueueAction(action); 
        
        },
     showErrorToast : function(component, event, helper) {
       // var self = this;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'File',
            message: 'No Files Found!',
            type: 'error',
        });
        toastEvent.fire();
    }
    
})