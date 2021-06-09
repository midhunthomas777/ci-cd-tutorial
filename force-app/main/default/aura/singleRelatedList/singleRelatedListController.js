({
    init: function (cmp, event, helper) {
        helper.fetchData(cmp, event, helper);
        helper.initColumnsWithActions(cmp, event, helper)
    },
    
    handleColumnsChange: function (cmp, event, helper) {
        helper.initColumnsWithActions(cmp, event, helper)
    },
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('rowid'+row.Id);
        cmp.set("v.rowId",row.Id);
        var onRowActionHandler = cmp.get('v.onRowActionHandler');

        if(!onRowActionHandler){
            $A.enqueueAction(onRowActionHandler)                       
        }else{   
            switch (action.name) {
                case 'edit':
                    helper.editRecord(cmp,event,row);
                    
                    break;
                case 'delete':
                    helper.removeRecord(cmp, row)
                    break;
            }
        }
    },
    
    handleGotoRelatedList : function (cmp, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": cmp.get("v.parentRelationshipApiName"),
            "parentRecordId": cmp.get("v.recordId")
        });
        relatedListEvent.fire();
    },
   
	handleCreateRecord : function (cmp, event, helper) {
        var urlPrefix = $A.get("{!$Label.c.POCommunityPrefix}");
        var applicationId= cmp.get("v.recordId");
        var windowHash = window.location.href;
        var createRecordEvent = $A.get("e.force:createRecord");
          createRecordEvent.setParams({
            "entityApiName": cmp.get("v.sobjectApiName"),
            "defaultFieldValues": {
                [cmp.get("v.relatedFieldApiName")] : cmp.get("v.recordId")
            },
           "panelOnDestroyCallback": function(event) {
               console.log('inside panel');
            window.open(urlPrefix+"partneronboarding-detail-page?applicationId="+applicationId,"_self");
           }
        });
        createRecordEvent.fire();
	},   
        
	handleToastEvent  : function (cmp, event, helper) {
        var eventType = event.getParam('type');
        var eventMessage= event.getParam('message');
        if(eventType == 'SUCCESS' && eventMessage.includes(cmp.get('v.sobjectLabel'))){
            helper.fetchData(cmp, event, helper)
        	event.stopPropagation();            
        }        
	},
     save : function(cmp, event, helper) {
         var urlPrefix = $A.get("{!$Label.c.POCommunityPrefix}");
          var applicationId= cmp.get("v.recordId");
         console.log('inside save');
         cmp.find("edit").get("e.recordSave").fire();
         console.log('inside out');
         cmp.set("v.redirectOnEdit",false);
         window.open(urlPrefix+"partneronboarding-detail-page?applicationId="+applicationId,"_self");
    },
    cancelEdit:function(cmp, event, helper){
         cmp.set("v.redirectOnEdit",false);
    }
})