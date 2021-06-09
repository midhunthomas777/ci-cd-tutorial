({
    doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.showAddRemoveFamilybtn");
        action.setParams({
            'recordID': recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());               
                if(response.getReturnValue() == true){
                    component.set("v.showAddRemovebtn",true);
                }
                else{
                    component.set("v.showAddRemovebtn",false);
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
    addRemoveProduct : function(component, event, helper) {
        component.set("v.openpop" , true);
    },
    close:function(component, event, helper){
        component.set("v.openpop" , false);
        //document.getElementById("Modal").style.display = "none";
        //window.location.reload();
    }
})