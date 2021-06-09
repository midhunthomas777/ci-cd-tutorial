/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
    metricsData : function(cmp, event, helper) {
        let action = cmp.get("c.reportData");
        
        let reportName1 = cmp.get("v.reportAPIName1");
        let reportName2 = cmp.get("v.reportAPIName2");
        let reportName3 = cmp.get("v.reportAPIName3");
        let reportName4 = cmp.get("v.reportAPIName4");
        let fieldName1 = cmp.get("v.fieldName1");
        let fieldName2 = cmp.get("v.fieldName2");
        let fieldName3 = cmp.get("v.fieldName3");
        let fieldName4 = cmp.get("v.fieldName4");
        let useAPIName1 = cmp.get("v.useFieldAPI1");
        let useAPIName2 = cmp.get("v.useFieldAPI2");
        let useAPIName3 = cmp.get("v.useFieldAPI3");
        let useAPIName4 = cmp.get("v.useFieldAPI4");
        
        action.setParams({
            "reportName1"	:	reportName1,
            "fieldName1"	:	fieldName1,
            "useAPIName1"	:	useAPIName1,
            "reportName2"	:	reportName2,
            "fieldName2"	:	fieldName2,
            "useAPIName2"	:	useAPIName2,
            "reportName3"	:	reportName3,
            "fieldName3"	:	fieldName3,
            "useAPIName3"	:	useAPIName3,
            "reportName4"	:	reportName4,
            "fieldName4"	:	fieldName4,
            "useAPIName4"	:	useAPIName4,
            
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            console.log('state '+state);
            if (state === 'SUCCESS') {
                const resultant = JSON.parse(response.getReturnValue());
                console.log('Result '+resultant);
                if(fieldName1 == null){
                    fieldName1='null';
                }
                if(fieldName2 == null){
                    fieldName2='null';
                }
                if(fieldName3 == null){
                    fieldName3='null';
                }
                if(fieldName4 == null){
                    fieldName4='null';
                }
                
                for(let i=0 ; i<resultant.length;i++)
                {
                    
                    if(reportName1 === resultant[i].reportName && fieldName1 === resultant[i].fieldName){
                        
                        cmp.set("v.metricValueType1",resultant[i].dataType.toLowerCase());
                        if(resultant[i].dataType.toLowerCase() == 'percent'){
                            cmp.set("v.metricValue1",resultant[i].value /100);
                        }
                        else if(resultant[i].dataType.toLowerCase() == 'init'){
                            cmp.set("v.metricValue1",resultant[i].value);
                            cmp.set("v.metricValueType1",'decimal');
                        }
                            else{
                                cmp.set("v.metricValue1",resultant[i].value);
                            }
                    }
                    if(reportName2 == resultant[i].reportName && fieldName2 == resultant[i].fieldName){
                        cmp.set("v.metricValueType2",resultant[i].dataType.toLowerCase());
                        if(resultant[i].dataType.toLowerCase() == 'percent'){
                            cmp.set("v.metricValue2",resultant[i].value /100);
                        }
                        else if(resultant[i].dataType.toLowerCase() == 'init'){
                            cmp.set("v.metricValue2",resultant[i].value);
                            cmp.set("v.metricValueType2",'decimal');
                        }
                            else{
                                cmp.set("v.metricValue2",resultant[i].value);
                            }
                    }
                    
                    if(reportName3 == resultant[i].reportName && fieldName3 == resultant[i].fieldName){
                        cmp.set("v.metricValueType3",resultant[i].dataType.toLowerCase());
                        if(resultant[i].dataType.toLowerCase() == 'percent'){
                            cmp.set("v.metricValue3",resultant[i].value /100);
                        }
                        else if(resultant[i].dataType.toLowerCase() == 'init'){
                            cmp.set("v.metricValue3",resultant[i].value);
                            cmp.set("v.metricValueType3",'decimal');
                        }
                            else{
                                cmp.set("v.metricValue3",resultant[i].value);
                            }
                    }
                    if(reportName4 == resultant[i].reportName && fieldName4 == resultant[i].fieldName){
                        cmp.set("v.metricValueType4",resultant[i].dataType.toLowerCase());
                        if(resultant[i].dataType.toLowerCase() == 'percent'){
                            cmp.set("v.metricValue4",resultant[i].value /100);
                        }
                        else if(resultant[i].dataType.toLowerCase() == 'init'){
                            cmp.set("v.metricValue4",resultant[i].value);
                            cmp.set("v.metricValueType4",'decimal');
                        }
                            else{
                                cmp.set("v.metricValue4",resultant[i].value);
                            }
                    }
                }
    
            }
        });
        $A.enqueueAction(action);
    }
})