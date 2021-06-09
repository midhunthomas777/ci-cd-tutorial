({
    getOrderTrackingDetails : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var orderNumberSet = this.getURLParameterValue().confirmation_number;
        var action = component.get("c.orderTracking");
        action.setParams({
            "confirmationNumber" : orderNumberSet,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out','INTERNAL'];
            if(state === 'SUCCESS' && !errorCodes.includes(response)){
				var orderTrackingDetailDB = JSON.parse(response.getReturnValue());
                
                // Getting Order line status code to status mapping
                var actionStatus = component.get("c.getOrderLineStatusMapping");
                 actionStatus.setCallback(this, function(response) {
                     var state = response.getState();
                     if(state === 'SUCCESS' && !errorCodes.includes(response)){
                          var statusMapping = response.getReturnValue();
                         if(!$A.util.isEmpty(orderTrackingDetailDB.order_line_details)){
							orderTrackingDetailDB.order_line_details.forEach(function(record){
                        		if(statusMapping[record.line_status]!=null && statusMapping[record.line_status]!='undefined')
                                    record.line_status = statusMapping[record.line_status];
                                  
                                 // set tracking number to N/A if it doesn't exist
                                if ($A.util.isUndefinedOrNull(record.tracking_number)) {
                                    record.tracking_number = null;
                                    record.carrier_url = null;
                                } else if ($A.util.isUndefinedOrNull(record.carrier_url)) { // carrier url should be blank
                                    record.carrier_url = " ";
                                }
                   			});
                                                                                                                            
                      	}
                  	}
                     else
                     {
                        console.log(response);
                		this.displayResponse(component,event,response);
                     }
                     console.log(orderTrackingDetailDB);
                     component.set('v.singleOrderTracking',orderTrackingDetailDB.order_header);
                     component.set('v.orderTrackingDetailList', orderTrackingDetailDB.order_line_details);
	                 component.set("v.loadSpinner", false);
                 });
                 $A.enqueueAction(actionStatus);                            

            }else{
                 console.log(response);
                 this.displayResponse(component,event,response);
            } 
        });
        $A.enqueueAction(action);
    },
    setTrackingLineItemColumns : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Line #', fieldName: 'line_number', type: 'number', sortable: true,cellAttributes: { alignment: 'center' }},
            {label: 'Line Status', fieldName: 'line_status', type: 'text', sortable: true},
            {label: 'Part #', fieldName: 'item_number', type: 'text', sortable: true},
            {label: 'Description', fieldName: 'item_description', type: 'text', sortable: true},
            {label: 'Ship Qty', fieldName: 'line_shipped_qty', type: 'number', sortable: true,cellAttributes: { alignment: 'center' }},
            {label: 'Carrier', fieldName: 'shipping_carrier', type: 'text', sortable: true},
            {label: 'Tracking #', fieldName: 'carrier_url', type: 'url', typeAttributes:{ label:{fieldName: 'tracking_number'} , target:"_blank",name:{fieldName: 'tracking_number'}}},
         	{label: 'Shipped on', fieldName: 'shipped_dt', type: 'date', sortable: true},
            {label: 'Ship #', fieldName: 'packing_list', type: 'text', sortable: true}        
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
   
    setOrderDetailURL : function(component, event, helper){ 
    	 var orderDetailUrl = '/externalorderdetail?confirmation_number='+this.getURLParameterValue().confirmation_number;
    	 component.set('v.orderDetailUrl',orderDetailUrl);
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