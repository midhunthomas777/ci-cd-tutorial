({
    getOrderByNumber : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        component.set("v.refreshTable", false);
        var orderNumberSet = this.getURLParameterValue().confirmation_number;
        var action = component.get("c.orderDetail");
        action.setParams({
            "confirmationNumber" : orderNumberSet,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out','INTERNAL'];
            var responseValue = response.getReturnValue();
            if(state === 'SUCCESS' && !errorCodes.includes(responseValue)){
                 var orderDetailDB = JSON.parse(responseValue);
                
                // Getting Order line status code to status mapping
                var actionStatus = component.get("c.getOrderLineStatusMapping");
                 actionStatus.setCallback(this, function(response) {
                     var state = response.getState();
                     if(state === 'SUCCESS' && !errorCodes.includes(response)){
                          var statusMapping = response.getReturnValue();
                         if(!$A.util.isEmpty(orderDetailDB.order_line_details)){
							orderDetailDB.order_line_details.forEach(function(record){
                                if(statusMapping[record.line_status]) { record.line_status = statusMapping[record.line_status]; }

                                if(!$A.util.isUndefinedOrNull(record.revise_ship_dt)){
                                    record.expected_ship_dt = new Date(record.revise_ship_dt);
                                } else if(!$A.util.isUndefinedOrNull(record.expected_ship_dt)){
                                    record.expected_ship_dt = new Date(record.expected_ship_dt);
                                }

                                if(!$A.util.isUndefinedOrNull(record.date_added)){
                                    record.date_added = new Date(record.date_added);
                                }
                   			});
                                                                                                                            
                      	}
                  	}else{
                		this.displayResponse(component,event,response);
                    }

					component.set('v.singleOrder',orderDetailDB.order_header);
					component.set('v.ordersDetailList', orderDetailDB.order_line_details);
					component.set('v.filteredData', orderDetailDB.order_line_details);
                    component.set("v.refreshTable", true);
					component.set("v.loadSpinner", false);
                     	
                 });
                 $A.enqueueAction(actionStatus);  
            }else{
                 this.displayResponse(component,event,response);
            } 
        });
        $A.enqueueAction(action);
    },
    setOrderLineItemColumns : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Line #', fieldName: 'line_number', type: 'number', sortable: true,cellAttributes: { alignment: 'center' }},
            {label: 'Part #', fieldName: 'item_number', type: 'text', sortable: true, wrapText: true},
            {label: 'Description', fieldName: 'item_description', type: 'text', sortable: true, cellAttributes: { alignment: 'left'}},
            {label: 'Ordered Qty', fieldName: 'line_ordered_qty', type: 'number', sortable: true, cellAttributes: { alignment: 'center'}},
            {label: 'Planned Ship Date', fieldName: 'expected_ship_dt', type: 'date', sortable: true, cellAttributes: { alignment: 'left'},typeAttributes: { day: '2-digit', month: 'short',  year: 'numeric'}},
            {label: 'Unit Price', fieldName: 'unit_price', type: 'currency', sortable: true},
            {label: 'Total', fieldName: 'extended_price', type: 'currency', sortable: true},
            {label: 'Date Added', fieldName: 'date_added', type: 'date', sortable: true,typeAttributes: { day: '2-digit', month: 'short',  year: 'numeric'}},
            {label: 'Unit of Measure', fieldName: 'unit_of_Measure', type: 'text', sortable: true},
   			{label: 'Line Status', fieldName: 'line_status', type: 'text',  sortable: true}
        ]);
    },
    getURLParameterValue: function() {
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        return paramValue;
    },
    filterOrderLineItems : function(component, event, helper){ 
        component.set("v.refreshTable", false);
        var data = component.get("v.ordersDetailList");
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
            // console.log('Invalid regular expression');
        }
        component.set("v.filteredData", results);  
        component.set("v.refreshTable", true);
    },
    viewAllOrders : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/orderlistpage"
        });
        urlEvent.fire();
    }, 
    viewTrackOrder : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        var trackOrderPageUrl = 
        urlEvent.setParams({
            "url": "/track-order?confirmation_number="+this.getURLParameterValue().confirmation_number
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