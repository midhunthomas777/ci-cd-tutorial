({
    showToast : function(component,event,param){
        var toastEvent = $A.get("e.force:showToast");
        var applicationId = component.get('v.applicationId');
        if($A.util.isUndefinedOrNull(toastEvent)){
            console.log('unable to run toast message.');
        }else{
            toastEvent.setParams(param);
            toastEvent.fire();
        }
        
        window.setTimeout(
            $A.getCallback(function() {
                // smth after two seconds
                // check component.isValid() if you want to work with component
                if(component.isValid()){
                    component.set('v.isSubmitted',true);
                }
            }), 10000);
        //window.open("/channel/s/partneronboarding-detail-page?applicationId="+applicationId,"_self");  
    }
})