({
    doInit : function(component, event, helper) {
        var action = component.get("c.getCurrentUserLinks");
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resp =response.getReturnValue();
            console.log('resp'+JSON.stringify(resp));
            if (response.getState() === "SUCCESS") {
                if(!(response.getReturnValue()  === "")) {
                    var resp= response.getReturnValue();
                    console.log('resp*****'+JSON.stringify(resp));
                    var externalLinks =[];
                    var toolLinks =[];
                    Object.keys(resp).forEach(function(key) {
                        resp[key].URL__c = key;
                        if(resp[key].Link_Type__c == 'External'){
                            externalLinks.push(resp[key]);
                        }else{
                            toolLinks.push(resp[key]);
                        }
                    });
                    externalLinks.sort(function(a, b){
                        return a.Order_of_Display__c-b.Order_of_Display__c;
                    })
                    component.set("v.externalLinks",externalLinks);
                    toolLinks.sort(function(a, b){
                        return a.Order_of_Display__c-b.Order_of_Display__c;
                    })
                    component.set("v.toolLinks",toolLinks);
                    console.log(' link*******'+JSON.stringify(component.get("v.externalLinks")));
                }
            } else{
                console.log('Error retreiving the Metadata');
            }
        });
        $A.enqueueAction(action);
        component.set("v.loadSpinner",false);
    }
})