({  
    doInit : function(component, event, helper){
        var RevenueInstance =  component.get('v.RevenueInstance');
        var firstItemYear = RevenueInstance.Revenue_Year__c;
        var oppFiscalMonth = component.get('v.oppFiscalMonth');
        if(!$A.util.isUndefinedOrNull(firstItemYear) && !$A.util.isEmpty(firstItemYear)){ 
            //SF-2631           
            RevenueInstance.Revenue_Month__c = oppFiscalMonth;
            console.log('oppFiscalMonth'+oppFiscalMonth);
            console.log('RevenueInstance.Revenue_Month__c'+RevenueInstance.Revenue_Month__c);
            component.set('v.RevenueInstance',RevenueInstance);            
            component.set("v.selectedMonthDisabled",false);
            component.set("v.firstItem",true);
            console.log('RevenueInstance complete***'+JSON.stringify(component.get('v.RevenueInstance')));
            
            //console.log('RevenueInstance complete'+JSON.serialize(component.get('v.RevenueInstance')));
        }
    },
    AddNewRow : function(component, event, helper){
        // fire the AddNewRowEvt Lightning Event 
        component.set("v.errMsg",null);
        component.getEvent("AddRowEvt").fire();     
    },
    removeRow : function(component, event, helper){
        // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    }, 
    validateYear : function(component, event, helper){
        component.set("v.loadSpinner", true);
        component.set("v.errorMsg",null);
        component.set("v.errMsg",null);
        var oppCloseDate = component.get("v.oppCloseDate");
        var dateYear = new Date(oppCloseDate).getFullYear();
        var yearVal = component.find('revYear').get("v.value");
        var isError = false;
        if(yearVal.length === 4 && yearVal >= dateYear && yearVal <=2050) {
            component.set("v.selectedMonthDisabled",false);
        }else if(yearVal.length === 4){
            component.set("v.errorMsg", "Please enter a Revenue Year during or after the Close Fiscal Year of the Opportunity and not later than 2050");
            isError =true;
        } else {
            component.set("v.selectedMonthDisabled",true);
        }
        component.set("v.loadSpinner", false);
        var isErrorEvt = $A.get("e.c:validateRevenueInsert");
        isErrorEvt.setParams({
            "errorMsg" :isError
        });
        isErrorEvt.fire();
    }, 
    
    changeMonth : function(component, event, helper){
        component.set("v.errorMsg",null);
        component.set("v.errMsg",null);
        
        var months = [
            'January', 'February', 'March', 'April', 'May',
            'June', 'July', 'August', 'September',
            'October', 'November', 'December'
        ];
        var oppCloseDate = component.get("v.oppCloseDate");
        var dateYear = new Date(oppCloseDate).getFullYear();
        // var dateMonth = new Date(oppCloseDate).getMonth()+1;
        var dateMonth = component.get("v.oppFiscalMonth");
        var fiscalMonth = months.indexOf(dateMonth);
        var fiscalMonthNum = fiscalMonth ? fiscalMonth + 1 : 0;
        var yearVal= component.find('revYear').get("v.value");
        var monthVal = component.find('revMonth').get("v.value");
        var month = months.indexOf(monthVal);
        var monthNum = month ? month + 1 : 0;
        var isError = false;
        if($A.util.isUndefinedOrNull(yearVal) || $A.util.isEmpty(yearVal)){
            component.set("v.errorMsg", "Please add year first");
            isError =true;
        }else{
            if(parseInt(yearVal) < dateYear){
                component.set("v.errorMsg", "Please enter a Revenue Year during or after the Close Fiscal Year of the Opportunity");
                isError = true;
            }else{
                if(parseInt(yearVal) === dateYear &&  monthNum < fiscalMonthNum ){
                    component.set("v.errorMsg", "Revenue can not be entered before the fiscal period of the Close Date");
                    isError = true;
                }else{
                    component.set("v.errorMsg",null);
                } 
            }
            
        }
        var isErrorEvt = $A.get("e.c:validateRevenueInsert");
        isErrorEvt.setParams({
            "errorMsg" :isError
        });
        isErrorEvt.fire();
    }
})