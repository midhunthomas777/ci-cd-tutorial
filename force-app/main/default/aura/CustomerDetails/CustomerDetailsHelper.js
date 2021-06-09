({
    validate : function(component,event,helper){
    	var requesterEmail = component.get("v.userEmail");
        var coreId     	   = component.get("v.userCoreId");
        if(typeof requesterEmail == 'undefined' && typeof coreId == 'undefined'){
            var requesterInput = component.find("reqEmailId");
            var coreIdInput    = component.find("reqCoreId");
            requesterInput.showHelpMessageIfInvalid();
            coreIdInput.showHelpMessageIfInvalid();
            if(requesterInput.checkValidity() == true && coreIdInput.checkValidity() == true){
            	return true;
            }else{
                return false;
            }
        }else{
            return true;
        }
	}
 })