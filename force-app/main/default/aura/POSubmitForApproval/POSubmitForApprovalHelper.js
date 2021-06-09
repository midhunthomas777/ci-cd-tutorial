({
    showToast : function(param){
        var toastEvent = $A.get("e.force:showToast");
        if($A.util.isUndefinedOrNull(toastEvent)){
            console.log('unable to run toast message.');
        }else{
            toastEvent.setParams(param);
            toastEvent.fire();
        }
    },
	
})