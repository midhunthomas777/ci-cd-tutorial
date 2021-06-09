({
    handleRecordUpdated: function(component, event, helper) {
        console.log('ObjRec:'+component.get("v.ObjRec"));
        helper.ModelToastMsg(component, event, helper); 
    }
})