({
	getUpdateOppDetails :function(component,event,helper) {
        var action = component.get('c.getOpportunityDetails');
        action.setParams({
            "recordId": component.get('v.recordId')
        });  
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === 'SUCCESS'){
                component.set("v.oppCloseDateServer",resp[0].Opportunity.CloseDate);
                component.set("v.oppFiscalMonth",resp[0].Opportunity.Fiscal_Month__c);
                var oppCloseDateServer = component.get("v.oppCloseDateServer");
                var oppCloseDate = component.get("v.oppCloseDate");
                if(oppCloseDate != oppCloseDateServer){
                   component.set("v.errorMsg", "Please refresh this page to get latest Opportunity data.");
                }else{
                    this.cellValidations(component,event,helper);	
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    cellValidations :function(component,event, helper) {
        component.set("v.errorMsg",null);
        var selectedRec = event.getParam("selectedRecord");
        var editedValues = event.getParam("editedRecords");
        var onCellChange = event.getParam("cellRecord");
        var cellRecordId = event.getParam("callRecordId");
        console.log('editedValues'+JSON.stringify(editedValues));
        console.log('onCellChange'+JSON.stringify(onCellChange));
        
        if(!$A.util.isUndefinedOrNull(onCellChange) && !$A.util.isEmpty(onCellChange) ){
            var oppCloseDate = component.get("v.oppCloseDate");
            var oppCloseYear = new Date(oppCloseDate).getFullYear();
            var oppCloseDateMonth = new Date(oppCloseDate).getMonth();
            //var oppCloseDateYear = oppCloseDate.slice(0,4);
            var oppForecastYear = oppCloseYear+50;
            for(var key in onCellChange){
                var resp;
                resp=onCellChange[key];
                for(var key in resp){
                    var yearVal;
                    var recId; 
                    if(key==='Revenue_Year__c'){
                        yearVal = resp[key];
                        if( yearVal.length != 4) { 
                            component.set("v.errorMsg", "Revenue Year must be of 4 digits");
                        }
                        if(parseInt(yearVal) < oppCloseYear){
                            component.set("v.errorMsg", "Please enter a Revenue Year during or after the Close Fiscal Year of the Opportunity");
                        }
                        if(parseInt(yearVal) > oppForecastYear){
                            component.set("v.errorMsg", "Only 50 Year of Forecast is Allowed");
                        }
                    }
                    if(key === 'Revenue_Month_Number__c'){
                        var monthval = resp[key];
                        if(monthval > 12 || monthval < 1){
                            component.set("v.errorMsg", "Revenue Month must be in Range of 1 to 12");
                        } 
                        else if($A.util.isUndefinedOrNull(yearVal) || $A.util.isEmpty(yearVal) ){
                             helper.getNumRevenueYears(component,event, helper,cellRecordId,monthval,oppCloseYear);
                        }
                    }
                    if($A.util.isUndefinedOrNull(component.get("v.errorMsg")) || $A.util.isEmpty(component.get("v.errorMsg"))){
                        var validationSuccess = $A.get("e.c:DynamicDataTableValidation");
                        validationSuccess.setParams({
                            "isValidated" : true
                        });
                        validationSuccess.fire();
                    }
                }
            }
        }
    },
    getRevenueYear : function(component,event, helper,recId,monthval,oppCloseYear) {
        var months = [
            'January', 'February', 'March', 'April', 'May',
            'June', 'July', 'August', 'September',
            'October', 'November', 'December'
        ];
       	var dateMonth = component.get("v.oppFiscalMonth");
        var fiscalMonth = months.indexOf(dateMonth);
        var fiscalMonthNum = fiscalMonth ? fiscalMonth + 1 : 0;
        var action = component.get('c.getRevenueOldYear');
        action.setParams({
            "recordId": recId
        });  
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === 'SUCCESS'){
                var cellServerYear = parseInt(resp[0].Revenue_Year__c);
                if(cellServerYear === oppCloseYear){
                    var monthList = [];
                    monthList = component.get("v.revMonth");
                    var validMonthList = []; 
                    for (var i= fiscalMonthNum; i< monthList.length; i++){
                        validMonthList.push(monthList[i]);        
                    }
                    if(!validMonthList.includes(monthval)){
                        component.set("v.errorMsg", "Please enter a Revenue Month during or after the Close Fiscal Month of the Opportunity");
                        var validationSuccess = $A.get("e.c:DynamicDataTableValidation");
                        validationSuccess.setParams({
                            "isValidated" : false
                        });
                        validationSuccess.fire();
                    }
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    getNumRevenueYears : function(component,event, helper,recId,monthval,oppCloseYear) {
        var months = [
            'January', 'February', 'March', 'April', 'May',
            'June', 'July', 'August', 'September',
            'October', 'November', 'December'
        ];
       	var dateMonth = component.get("v.oppFiscalMonth");
        var fiscalMonth = months.indexOf(dateMonth);
        var fiscalMonthNum = fiscalMonth ? fiscalMonth + 1 : 0;
        var action = component.get('c.getRevenueOldYear');
        action.setParams({
            "recordId": recId
        });  
        action.setCallback(this, function(response){
            var state = response.getState();
            var resp = response.getReturnValue();
            if(state === 'SUCCESS'){
                var cellServerYear = parseInt(resp[0].Revenue_Year__c);
                if(cellServerYear === oppCloseYear){
                    if(monthval < fiscalMonthNum){
                        component.set("v.errorMsg", "Please enter a Revenue Month during or after the Close Fiscal Month of the Opportunity");
                        var validationSuccess = $A.get("e.c:DynamicDataTableValidation");
                        validationSuccess.setParams({
                            "isValidated" : false
                        });
                        validationSuccess.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
})