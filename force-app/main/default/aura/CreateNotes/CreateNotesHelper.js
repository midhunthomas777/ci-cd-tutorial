({
    createNote : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        //getting the candidate information
        var candidate = component.get("v.note");
        var noteTitle = component.get("v.note.Title");
        if($A.util.isUndefinedOrNull(noteTitle) || $A.util.isEmpty(noteTitle)){
            component.set('v.errorMsg','Please enter Title');
            component.set("v.loadSpinner", false);
        }else{
             component.set('v.errorMsg',null);
            //Calling the Apex Function
            var action = component.get("c.createContentNote");
            //Setting the Apex Parameter
            action.setParams({
                note : candidate,
                parentId : component.get("v.recordId")
            });
            //Setting the Callback
            action.setCallback(this,function(a){
                //get the response state
                var state = a.getState();
                component.set("v.loadSpinner", false);
                //check if result is successfull
                if(state == "SUCCESS"){
                    //Reset Form
                    var newCandidate = {'sobjectType': 'ContentNote',
                                        'Title': '',
                                        'Content': ''
                                       };
                    //resetting the Values in the form
                    component.set("v.note",newCandidate);
                    // window.location.reload();
                    helper.closeModel(component, event, helper);
                } else if(state == "ERROR"){
                    helper.closeModel(component, event, helper);
                }
            });   
            $A.enqueueAction(action);
        }
    },
    closeModel : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})