({
    /****************************************************
    @description Display details of the case selected by the user in the table
    */
    getCaseByNumber : function(component, event, helper) {
        component.set("v.loadSpinner", true);
        var caseNumberSet = this.getURLParameterValue().number;
        var accountId = this.getURLParameterValue().accountId;
        var action = component.get("c.caseDetail");
        //console.log('accountId --- > ' + accountId);
        action.setParams({
            "caseNumber" : caseNumberSet
            //"currentAccountId" : accountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var errorCodes = ['ERROR','NOACCESS','APIError','Read timed out','INTERNAL'];
            if(state === 'SUCCESS' && !errorCodes.includes(response)){
                var caseDetailDB = JSON.parse(response.getReturnValue());
                console.log(caseDetailDB);
                
                var caseDetail = caseDetailDB.result[0];
                if(!$A.util.isUndefinedOrNull(caseDetail)){
                    caseDetail.city = caseDetail["account.u_shipping_city"];
                    caseDetail.status = caseDetail["state"];
                    caseDetail.state = caseDetail["account.u_shipping_state"];
                    caseDetail.partnerName = caseDetail["partner.name"];
                    caseDetail.system = caseDetail["u_product.ci"];
                    caseDetail.siteNumber = caseDetail["account.u_erp_site_number"];
                }

                
                component.set('v.singleCase',caseDetail);
                component.set("v.loadSpinner", false);
            }else{
                console.log(response);
                this.displayResponse(component,event,response);
            } 
        });
        $A.enqueueAction(action);
    },
    
    /****************************************************
    @description Get the parameter value from the URL
    */
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
    /****************************************************
    @description Filter the Case List based on the user input
    */
  /*  filterCaseLineItems : function(component, event, helper){
        var data = component.get("v.filteredData"),
            term = component.get("v.filter"),
            results = data, regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row=>regex.test(row.item_description) || regex.test(row.line_status));
        } catch(e) {
            // invalid regex, use full list
        }
        component.set("v.filteredData", results);        
    },*/
    /****************************************************
    @description Display all the cases 
    */
    viewAllCases : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/caselistpage"
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