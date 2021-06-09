({
    doInit : function(component, event, helper) {
        helper.getCyberSourceVFPageURL(component);
        helper.getAccess(component);
    },
    
    submitPayment:function(component, event, helper){
        var getPageURL = component.get("v.getPageURL"); 
        window.open(getPageURL,"_blank"); 
        $A.get("e.force:closeQuickAction").fire();
        //window.location.reload();
    }
})