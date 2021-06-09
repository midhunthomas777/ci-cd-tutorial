/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
	init : function(cmp, event, helper) {
        let display = cmp.get("v.noOfMetricsToDisplay");
        let val=[];
        for(let i=1; i<=display; i++){
            val.push(i);
        }
        cmp.set("v.displayList",val);
        
        const fieldNameAPI1 = cmp.get("v.fieldNameAPI1");
        const fieldNameAPI2 = cmp.get("v.fieldNameAPI2");
        const fieldNameAPI3 = cmp.get("v.fieldNameAPI3");
        const fieldNameAPI4 = cmp.get("v.fieldNameAPI4");
        if( fieldNameAPI1 != null || fieldNameAPI2 != null  || fieldNameAPI3 != null  || fieldNameAPI4 != null){
		helper.metricsData(cmp, event, helper);
        }
	}
})