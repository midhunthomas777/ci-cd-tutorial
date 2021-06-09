/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
    metricsData : function(cmp, event, helper) {
        let action = cmp.get("c.fetchMetricsData");
        
        let fieldNameApi1 = cmp.get("v.fieldNameAPI1");
        let fieldNameApi2 = cmp.get("v.fieldNameAPI2");
        let fieldNameApi3 = cmp.get("v.fieldNameAPI3");
        let fieldNameApi4 = cmp.get("v.fieldNameAPI4");
        
        action.setParams({
            "fieldNameApi1"	:	fieldNameApi1,
            "fieldNameApi2"	:	fieldNameApi2,
            "fieldNameApi3"	:	fieldNameApi3,
            "fieldNameApi4"	:	fieldNameApi4
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                const resultant = JSON.parse(response.getReturnValue());
                if(resultant != null){
                    for (let i = 0; i < resultant.length; i++){
                        
                        let fieldValue;
                        let fieldType = resultant[i].fieldType;
                        let fieldTypeValue;
                        if(fieldType === 'CURRENCY'){
                            fieldTypeValue = fieldType.toLowerCase();
                            fieldValue = resultant[i].fieldMetricValue;
                        }  else if(fieldType === 'PERCENT'){
                            fieldTypeValue = fieldType.toLowerCase();
                            fieldValue = resultant[i].fieldMetricValue / 100;
                        } else {
                            fieldTypeValue = fieldType;
                            fieldValue = resultant[i].fieldMetricValue;
                        }
                        if(resultant[i].fieldApiName === fieldNameApi1){
                            cmp.set("v.metricValue1", fieldValue);
                            cmp.set("v.metricValueType1", fieldTypeValue);
                        }
                        else if(resultant[i].fieldApiName === fieldNameApi2){
                            cmp.set("v.metricValue2", fieldValue);
                            cmp.set("v.metricValueType2", fieldTypeValue);
                        }
                            else if(resultant[i].fieldApiName === fieldNameApi3){
                                cmp.set("v.metricValue3", fieldValue);
                                cmp.set("v.metricValueType3", fieldTypeValue);
                            }
                                else if(resultant[i].fieldApiName === fieldNameApi4){
                                    cmp.set("v.metricValue4", fieldValue);
                                    cmp.set("v.metricValueType4", fieldTypeValue);
                                }
                        
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})