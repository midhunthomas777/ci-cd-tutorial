({
    getAccounts : function(component, helper){
        console.log('-- In getAccounts --');
        component.set("v.loadSpinner", true);    
        var isEditQuote = component.get('v.fromEditQuote');
        var oppoAccId = component.get('v.oppoAccId');
        console.log('isEditQuote = '+isEditQuote);
        console.log('oppoAccId = '+oppoAccId);
        var action = component.get('c.getLimitedAccounts');
        action.setStorable();
        var accountId;
        var recordId = component.get("v.recordId");//SF-2509             
        if(recordId.startsWith('006')){//SF-2509
            accountId = component.get("v.oppoAccId"); 
        }else if(recordId.startsWith('a8x')){//SF-2884
            accountId = component.get("v.oppoAccId");
        }else{
            accountId = component.get("v.recordId");    
        }         
        console.log('3 MCNList accountId===>'+accountId);
        action.setParams({"accountId": accountId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                console.log('response.getReturnValuelength===>' + response.getReturnValue().length);
                if(response.getReturnValue().length==1){
                    //component.set("v.loadSpinner", false);    
                    component.set('v.AccountData', response.getReturnValue());
                    component.set("v.motorolaCustomerNumber", component.get("v.AccountData[0].Motorola_Customer_Number__c"));
                    component.set("v.accountId", component.get("v.AccountData[0].ParentId"));
                    component.set("v.mcnId", component.get("v.AccountData[0].Id"));
                    document.getElementById("displayMCNList").style.display = "none";
                    
        			console.log('isEditQuote1 in helper = '+isEditQuote);
                    if(isEditQuote){
                        console.log('isEditQuote true - IF');
                        component.set("v.showProceedQuoteEdit", true); 
                    }
                    else{
                        console.log('isEditQuote true - ELSE');
                     	component.set("v.showCommissionInfo", true);     
                    }
                    
                    component.set("v.loadSpinner", false);    
                    
                } else {
                    var pageSize = component.get("v.pageSize");
                    component.set('v.AccountData', response.getReturnValue());
                    component.set("v.totalRecords", component.get("v.AccountData").length);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    var PaginationList = [];
                    var selected=[];
                    for(var i=0; i< pageSize; i++){
                        if(component.get("v.AccountData").length> i){
                            PaginationList.push(response.getReturnValue()[i]);
                            console.log('response.getReturnValue()[i]==>'+ response.getReturnValue()[i].Id );
                            console.log('component.get("v.recordInfo.CDH_Account__c")==>'+component.get("v.recordInfo.CDH_Account__c"));
                            if(recordId.startsWith('006')){//SF-2712
                                console.log('recordId startsWith 006');
                                if(response.getReturnValue()[i].Id == component.get("v.recordInfo.CDH_Account__c")){
                                    selected.push(response.getReturnValue()[i].Id);  
                                    console.log('Page selected==>'+JSON.stringify(selected) );
                                    component.set('v.selectedRows', selected); 
                                    component.set("v.motorolaCustomerNumber",response.getReturnValue()[i].Motorola_Customer_Number__c);
                                    component.set("v.accountId",response.getReturnValue()[i].ParentId);
                                    component.set("v.mcnId",response.getReturnValue()[i].Id);
                                    
                                    console.log('isEditQuote2 in helper = '+isEditQuote);
                                    if(isEditQuote){
                                        console.log('isEditQuote true - IF');
                                        component.set("v.showProceedQuoteEdit", true);
                                        var childCompId = component.find("editQuoteDetailID");
                                        childCompId.proceedToQuoteInitmethod(component);
                                    }
                                    else{
                                        console.log('isEditQuote true - ELSE');
                                        component.set("v.showCommissionInfo",true); 
                                        var childCompId = component.find("cmsDetailID");
                                        childCompId.childmethod(component);
                                    }
                                    
                                }
                            }
                            /*else{
                                        component.set("v.showProceedQuoteEdit",true)
                                        console.log('v.showProceedQuoteEdit ='+component.get('v.showProceedQuoteEdit'));
                            }
                            //SF-2759
                            else{
                                        component.set("v.showProceedQuoteEdit",true)
                                        console.log('v.showProceedQuoteEdit ='+component.get('v.showProceedQuoteEdit'));
                                        console.log('--Calling chilcomponent --');
                                        var childCompId = component.find("editQuoteDetailID");
                                        childCompId.proceedToQuoteInitmethod(component);
                                    }*/ //SF-2759
                        }
                    }
                    component.set('v.PaginationList', PaginationList);
                }
            } //If state=success ends
            component.set("v.loadSpinner", false);
        });
        $A.enqueueAction(action);
    },
    next : function(component, event){
        var sObjectList = component.get("v.AccountData");
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
        var sObjectList = component.get("v.AccountData");
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
    }
})