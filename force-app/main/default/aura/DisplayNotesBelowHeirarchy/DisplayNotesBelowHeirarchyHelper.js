({
    fetchNotes : function(component, event, helper) {
        var action = component.get('c.getNotesForUser');
        action.setParams({
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.loadSpinner", false);
            if (state === 'SUCCESS' && component.isValid()) {
                var respRes = response.getReturnValue();
                var contentNoteList = [];
                for (var i = 0; i < respRes.length; i++) {
                    contentNoteList.push({
                        Id :'/'+respRes[i].Id,
                        Title: respRes[i].Title,
                        TextPreview: respRes[i].TextPreview,
                        LastViewedDate: respRes[i].LastViewedDate,
                        CreatedByName: respRes[i].CreatedBy.Name,
                        LastModifiedByName: respRes[i].LastModifiedBy.Name
                    });
                }
                component.set("v.resultList",contentNoteList);
            }
        });
        $A.enqueueAction(action);
    }
})