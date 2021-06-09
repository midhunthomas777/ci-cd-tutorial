({
    doInit : function(component , event, helper){
        var recordId = component.get("v.recordId");
        window.open('/apex/AllRevenuesByOLI?id=' +recordId,'_blank');  
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 1
        );
    },
})