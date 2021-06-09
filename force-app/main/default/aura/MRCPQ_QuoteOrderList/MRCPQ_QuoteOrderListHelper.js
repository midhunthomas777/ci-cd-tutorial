({
    getQuoteOrders : function(component, helper){
        component.set("v.loadSpinner", true);    
        var action = component.get('c.getCPQQuoteOrders');
        //action.setStorable();
        var oppId = component.get("v.recordId");    
        action.setParams({"opportunityId": oppId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                if(response.getReturnValue().length==0){
                    component.set("v.showError", true);
                    //document.getElementById("displayQuoteOrderList").style.display = "none";
                } else if(response.getReturnValue().length==1){
                    component.set('v.QuoteOrderData', response.getReturnValue());
                    component.set('v.PaginationList', response.getReturnValue());
                    var quotId = component.get("v.QuoteOrderData[0].quoteId");
                    component.set('v.quoteId', quotId);
                    //document.getElementById("displayQuoteOrderList").style.display = "none";
                    //component.set("v.displayProductFamilyButtons",true);
                } else {
                    var pageSize = component.get("v.pageSize");
                    //document.getElementById("displayQuoteOrderList").style.display = "block";
                    component.set('v.QuoteOrderData', response.getReturnValue());
                    component.set("v.totalRecords", component.get("v.QuoteOrderData").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    component.set("v.shownextpre",true);
                    var PaginationList = [];
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.QuoteOrderData").length> i){
                            PaginationList.push(response.getReturnValue()[i]);
                        }
                    }
                    component.set('v.PaginationList', PaginationList);
                }
                //Added on Story SF-2007
               // var totalSize=component.get("v.QuoteOrderData").length;//SF-2195 Incident INC2338264
                var quoteData=component.get("v.QuoteOrderData");
                var totalSize=component.get("v.QuoteOrderData")? component.get("v.QuoteOrderData").length : 0;//SF-2195 Incident INC2338264
                for(var i=0; i< totalSize; i++){
                    
                    if(quoteData[i].isPrimary==true)
                    {
                        component.set("v.quoteToRemove",quoteData[i].quoteId);
                    }
                }
  				//Ended on Story SF-2007
            }
            component.set("v.loadSpinner", false);
        });
        $A.enqueueAction(action);
    },
    next : function(component, event){
        var sObjectList = component.get("v.QuoteOrderData");
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
        var sObjectList = component.get("v.QuoteOrderData");
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
    includeCPQProducts : function(component) {
        component.set("v.loadSpinner", true);
        var action1 = component.get("c.addProductsToOppo");
        var oppId = component.get("v.recordId");
        var quoteId = component.get("v.quoteId");
        action1.setParams({
            "oppId" : oppId,
            "quoteId":quoteId
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response);
            console.log(response.getReturnValue());
            console.log(state);
            if (state === "SUCCESS") {
                component.set("v.loadSpinner", false);  
                component.set("v.successMsg", response.getReturnValue());
                if(component.get("v.successMsg") === 'Success'){
                    component.find('notifLib').showNotice({
                        "variant": "info",
                        "header": "Success",
                        "message": component.get("v.CPQsuccessMsgLabel"),
                        //Added by Venkat on Story SF-1880
                        closeCallback: function() {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": oppId
                            });
                            navEvt.fire();
                            $A.get('e.force:refreshView').fire();
                        }
                    });
                    //Ended on Story SF-1880
                }else{
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": component.get("v.successMsg")
                    });
                }
            }
            else{
                var ProductFamilyError = $A.get("{!$Label.c.ErrorIncludingProductFamily}");//Added by Meher as part of SF-1879
                component.set("v.loadSpinner", false);
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    //"message": "Error occurred while including in Product Family"
                    "message": ProductFamilyError
                });
            }
        });
        $A.enqueueAction(action1);
    },
    removeCPQProducts : function(component) {
        component.set("v.loadSpinner", true);
        var action1 = component.get("c.removeProductsToOppo");
        var oppId = component.get("v.recordId");
        var quoteId = component.get("v.quoteId");
        var quoteToRemove = component.get("v.quoteToRemove");//Added on Story SF-2007
        action1.setParams({
            "oppId" : oppId,
            //"quoteId":quoteId
            "quoteId":quoteToRemove//Added by Venkat as per story SF-2007
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loadSpinner", false);
                component.set("v.successMsg", response.getReturnValue());
                if(component.get("v.successMsg") === 'Success'){
                    component.find('notifLib').showNotice({
                        "variant": "info",
                        "header": "Success",
                        "message": component.get("v.CPQremoveMsgLabel"),
                        //Added on Story SF-1880
                        closeCallback: function() {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": oppId
                            });
                            navEvt.fire();
                            $A.get('e.force:refreshView').fire();
                        }
                    });
                    //Ended on Story SF-1880
                }else{
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": component.get("v.successMsg")
                    });
                }
            }
            else{
                var NoQuotesInProducts = $A.get("{!$Label.c.NoQuotesInProductFamilies}");//Added by Meher as part of SF-1879
                component.set("v.loadSpinner", false);
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    //"message": 'There are no Quotes that are included in Product Families.'
                    "message": NoQuotesInProducts
                });                
            }
        });
        $A.enqueueAction(action1);
    },
    //Added by Venkat on Story SF-1879
    getSuccessMsg : function(component) {
        var action = component.get("c.fetchSuccessMsg");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var metaData = response.getReturnValue();
                var i;
                for (i=0; i<metaData.length;i++)
                {
                    if(metaData[i].DeveloperName=="CPQ_SuccessMsg")
                    {
                        component.set("v.CPQsuccessMsg", metaData[i].Long_Text_Area__c);
                        component.set("v.CPQsuccessMsgLabel", metaData[i].Values__c);
                    }  
                    if(metaData[i].DeveloperName=="CPQ_SuccessMsg1")
                    {
                        component.set("v.CPQremoveMsg", metaData[i].Long_Text_Area__c);
                        component.set("v.CPQremoveMsgLabel", metaData[i].Values__c);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
});