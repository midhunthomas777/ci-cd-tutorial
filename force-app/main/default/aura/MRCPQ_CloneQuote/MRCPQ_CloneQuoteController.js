({
    doInit : function(component, event, helper) {
        helper.getCPQPageURL(component);
    },
    
    clonequote:function(component, event, helper){
        var quoteId = component.get("v.recordId");
        var getPageUrl = component.get("v.getPageURL"); 
        var cloneCPQURL = getPageUrl + "&Id=" + quoteId + "&clone=true";  
        window.open(cloneCPQURL,"_blank"); 
        window.location.reload();
    }
    
})