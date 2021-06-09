/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
    init: function (cmp, event, helper) {
        let display = cmp.get("v.metrictoDisplay");
        let val=[];
        for(let i=1; i<=display; i++){
            val.push(i);
        }
        cmp.set("v.displayList",val);
        
        const reportName1 = cmp.get("v.reportAPIName1");
        const reportName2 = cmp.get("v.reportAPIName2");
        const reportName3 = cmp.get("v.reportAPIName3");
        const reportName4 = cmp.get("v.reportAPIName4");
        if( reportName1 != null || reportName2 != null  || reportName3 != null  || reportName4 != null)
        {
            helper.metricsData(cmp, event, helper);
        }
    },
    
    redirect: function (cmp, event, helper) {
        
    }
})