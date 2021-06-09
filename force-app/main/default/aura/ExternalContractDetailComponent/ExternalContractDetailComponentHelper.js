({
    getContractByNumber : function(component, event, helper) {        
        component.set("v.loadSpinner", true);
        component.set("v.refreshTable", false);
        var singleContract;
        var contractNumberSet = this.getURLParameterValue().contract_number;
        var action = component.get("c.contractDetail");
        action.setParams({
            "contractNumber" : contractNumberSet,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out','INTERNAL'];
            if(state === 'SUCCESS' && !errorCodes.includes(response)){
                 	var contractDetailDB = JSON.parse(response.getReturnValue());
                	
                	if(contractDetailDB.length >0)
                    	singleContract = contractDetailDB[0];
                	
                	 contractDetailDB.forEach(function(record){
                         if(!$A.util.isUndefinedOrNull(record.SERVICE_START_DATE))
                        	record.SERVICE_START_DATE = new Date(record.SERVICE_START_DATE); 
                         
                     	 if(!$A.util.isUndefinedOrNull(record.SERVICE_END_DATE))
                         	record.SERVICE_END_DATE = new Date(record.SERVICE_END_DATE);                         
                    });

                    component.set('v.singleContract',singleContract);
					component.set('v.contractDetailList', contractDetailDB);
					component.set('v.filteredData', contractDetailDB);
                    component.set("v.refreshTable", true);
					component.set("v.loadSpinner", false); 
            }
            else{
                 console.log(response);
                 this.displayResponse(component,event,response);
            } 
        });

        $A.enqueueAction(action);
    },
    setContractLineItemColumns : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Part (Service) Number', fieldName: 'ITEM_NUMBER', type: 'text', sortable : 'true'},
            {label: 'Part (Service) Description', fieldName: 'ITEM_DESCRIPTION', type: 'text', sortable : 'true'},
            {label: 'Start Date', fieldName: 'SERVICE_START_DATE', type: 'date', sortable : 'true',typeAttributes: { day: '2-digit', month: 'short',  year: 'numeric'}},          
            {label: 'End Date', fieldName: 'SERVICE_END_DATE', type: 'date', sortable : 'true',typeAttributes: { day: '2-digit', month: 'short',  year: 'numeric'}},  
            {label: 'Quantity', fieldName: 'QUANTITY', type: 'number', sortable : 'true'},
            {label: 'Customer PO Number', fieldName: 'CUST_PO_NUMBER', type: 'number', sortable : 'true'}
        ]);
    },
    getURLParameterValue: function() {
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        console.log('paramValue-' + paramValue);
        return paramValue;
    },
    filterContractLineItems : function(component, event, helper){ 
        component.set("v.refreshTable", false);
        var data = component.get("v.contractDetailList");
        var term = component.get("v.filter");
        var columns = component.get("v.columns");
        var results = data;
        var regex;
        try {

            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true  
            results = data.filter(row =>{
                for(let i=0; i<columns.length; i++){
                    var field = columns[i];
                    if(regex.test(row[field.fieldName]))
                        return true;      			                  
                }
                return false;                	
            });
                    
        } catch(e) {
            // invalid regex, use full list
            console.log('Invalid regular expression');
        }
        component.set("v.filteredData", results);  
        component.set("v.refreshTable", true);
    },
    viewAllContracts : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/contractspage"
        });
        urlEvent.fire();
    }, 
    /****************************************************
    @description Display  message if any error from server  
    */
    displayResponse : function(component,event,response) {
        var message = '';
        if(response == 'NOACCESS') {
            message = 'Insufficient Privileges, please try another one.';
        } else if(response == 'APIError'){
            message = 'Request has not been submitted successfully, please retry after some time.';
        } else{
            message = response;
        }
        this.showToast(component, message,'error');
        component.set("v.loadSpinner", false);
    },
    /****************************************************
    @description Display error message as toast
    */
    showToast : function(component,message,messageType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title"  : messageType+"!",
            "type"   : messageType,
            "message": message
        });
        toastEvent.fire();
    }
})