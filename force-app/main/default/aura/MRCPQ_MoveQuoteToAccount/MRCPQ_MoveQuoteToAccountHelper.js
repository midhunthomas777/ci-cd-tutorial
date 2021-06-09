({
    SearchHelper: function(component, event) {
        // show spinner message
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.fetchAccount");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword")
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server 
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                    component.set("v.errorMessage","No Records Found...");
                } else {
                    //component.set("v.Message", false);
                    var pageSize = component.get("v.pageSize");
                    component.set('v.searchResult', storeResponse);
                    component.set("v.totalRecords", component.get("v.searchResult").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.searchResult").length> i){
                            PaginationList.push(storeResponse[i]);
                        }
                    }
                    component.set('v.PaginationList', PaginationList);
                    component.set("v.Message", false);
                    component.set("v.displayMCNList", true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    ChildHelper: function(component, event,helper) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var dTable = component.find("accountTable");
        var selectedRows = dTable.getSelectedRows();
        var resp;
        for(var key in selectedRows){
            resp=selectedRows[key];
        }
        for(var key in resp){
            if(key==='Id'){
                component.set("v.selectedParent",resp[key]);
            }
        }
        var action = component.get("c.fetchMCNAccount");
        action.setParams({
            'searchKeyWord': component.get("v.selectedParent")//selectedRow[0].Id
        });
        action.setCallback(this, function(response) {
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.mcnMessage", true);
                    component.set("v.mcnDisplayMessage", false);
                } else {
                    //component.set("v.Message", false);
                    var pageSize = component.get("v.childpageSize");
                    component.set('v.childrenResult', storeResponse);
                    component.set("v.childtotalRecords", component.get("v.childrenResult").length);
                    component.set("v.childstartPage",0);
                    component.set("v.childendPage",pageSize-1);
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.childrenResult").length> i){
                            PaginationList.push(storeResponse[i]);
                        }
                    }
                    component.set('v.childPaginationList', PaginationList);
                    component.set("v.mcnDisplayMessage", true);
                    component.set("v.mcnMessage", false);
                }
                // set searchResult list with return value from server.
                //  component.set("v.childrenResult", storeResponse); 
            }
        });
        
        var mcnXaxis=window.scrollX + document.querySelector('#displayChild').getBoundingClientRect().left // X
        var mcnYaxis= window.scrollY + document.querySelector('#displayChild').getBoundingClientRect().top // Y
        window.scrollTo(mcnXaxis, mcnYaxis);
        $A.enqueueAction(action);
    },
    
    updateDetailsOnQuote:function(component){
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.updateQuote");
        var quoteId = component.get('v.recordId');
        var theme = component.get('v.userTheme');
        var selectedParent = component.get('v.selectedParent');
        var selectedChild = component.get('v.selectedChild');
        console.log('quoteId#########'+ quoteId);
        action.setParams({
            'quoteId':quoteId ,
            'accId':selectedParent,
            'mcnNumber':selectedChild
        });
        
        action.setCallback(this, function(response) {
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            var recordId= component.get('v.recordId');
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if(storeResponse === 'Ok'){
                    console.log('Operation Completed Successfully!');
                    if(theme!='Classic'){
                        window.location.reload();
                    }else{
                        window.open('/'+quoteId,'_self');
                    }
                }else{
                    if(theme!='Classic'){
                        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
                        dismissActionPanel.fire(); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message: "Record can not be updated due to error encountered in API",
                            duration:' 30000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire(); 
                    }else{
                        component.set("v.Message", true);
                        component.set("v.errorMessage","Record can not be updated due to error encountered in API");
                    }
                }
            } else {
                alert('Unknown error while updating the Quote');
            }
        });
        
        $A.enqueueAction(action);
    },
    
    
    Reset: function(component) {
        component.set("v.mcnMessage", false);
        component.set("v.mcnDisplayMessage", false);   
    },
    
    next : function(component, event){
        var sObjectList = component.get("v.searchResult");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    previous : function(component, event){   
        var sObjectList = component.get("v.searchResult");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
    mcnNext : function(component, event){
        var sObjectList = component.get("v.childrenResult");
        var end = component.get("v.childendPage");
        var start = component.get("v.childstartPage");
        var pageSize = component.get("v.childpageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(sObjectList.length > i){
                Paginationlist.push(sObjectList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.childstartPage",start);
        component.set("v.childendPage",end);
        component.set('v.childPaginationList', Paginationlist);
    },
    mcnPrevious : function(component, event){   
        var sObjectList = component.get("v.childrenResult");
        var end = component.get("v.childendPage");
        var start = component.get("v.childstartPage");
        var pageSize = component.get("v.childpageSize");
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                Paginationlist.push(sObjectList[i]);
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.childstartPage",start);
        component.set("v.childendPage",end);
        component.set('v.childPaginationList', Paginationlist);
    }
    
})