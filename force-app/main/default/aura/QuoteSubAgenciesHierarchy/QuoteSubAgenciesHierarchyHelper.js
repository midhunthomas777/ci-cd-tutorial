({
    getData : function (cmp) {
        var action = cmp.get("c.getTreeGridData");
        action.setParams({
            opptyId: cmp.get("v.recordId") /* here it sends a null value*/
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var resp = response.getReturnValue();
                var expandedRows = resp["expandedRows"]; 
                var gridData = resp["gridData"];
                var tempjson = JSON.parse(JSON.stringify(gridData).split("quoteWrapList").join("_children"));
                cmp.set('v.gridData', tempjson);
                cmp.set('v.gridExpandedRows',expandedRows);
                console.log('expanded rows..'+expandedRows);
            }else if(state === "ERROR"){
                component.set("v.loadSpinner", false);
                var errors = response.getError();
                if(!($A.util.isUndefinedOrNull(errors) || $A.util.isEmpty(errors))){
                    component.set("v.errorMsg",errors[0].message);
                }else{
                    component.set("v.errorMsg","Some Exception Occured");
                }
                console.log(errors);
            }
        });
        $A.enqueueAction(action);
    }
})