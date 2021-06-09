({
	doInit : function(component, event, helper) {
        helper.fetchRegions(component, event, helper);
        var recordId = component.get("v.recordId");
        var reln = 'Briefing_Room_Report__c = '+'\''+recordId+'\'';
        var andFilter = [];
        andFilter.push(reln);
        component.set('v.andFilters',andFilter);
        component.set("v.loadSpinner",false);
        component.set('v.columns', [
            {label: 'Executive BRR', fieldName: 'Executive_BRR__c',editable:'true', type: 'boolean'},
            {label: 'Account Name', fieldName: 'Account_URL__c', type: 'url',typeAttributes: {label: { fieldName: 'AccountName__c' },target: '_self'}},
            {label: 'State', fieldName: 'StateProvince__c',type: 'text'},
            {label: 'Opportunity Name', fieldName: 'Opportunity_Url__c', type: 'url',typeAttributes: {label: { fieldName: 'Opportunity_Name__c' },target: '_self'}},
            //{label: 'Stage', fieldName: 'Stage__c',type: 'text'},Owner_Name__c
            {label: 'Opporutnity Owner', fieldName: 'BookingsOwner__c',type: 'text'},
            //{label: "Forecast Note Date Time",fieldName: "Forecast_Note_Date_Time__c",type: "date", typeAttributes:{
            //    year: "numeric", month: "2-digit",day: "2-digit",hour: "2-digit",  minute: "2-digit"}},
            {label: 'Amount', fieldName: 'Amount__c',type: 'currency'},
            {label: 'Region', fieldName: 'Region__c',type: 'text'},
            {label: 'Territory', fieldName: 'Territory__c',type: 'text'},
            {label: 'BRR Notes', fieldName: 'BRR_Notes__c',type: 'text', wrapText: true }
            
        ]);
        component.set('v.loadTable',true);
	},
    
    getselectedRecId : function(component, event, helper) {
            console.log('test');
            var validationSuccess = $A.get("e.c:DynamicDataTableValidation");
            validationSuccess.setParams({
            "isValidated" : true
            });
            validationSuccess.fire();
          //  }
            console.log('test fire');
      
	},
    refreshTable : function(component, event, helper) {
        var andFilter = [];
        var recordId = component.get("v.recordId");
        var reln = 'Briefing_Room_Report__c = '+'\''+recordId+'\'';
        var regionSelected = component.get("v.regionSelected");
        console.log('regionSelected****'+regionSelected);
        andFilter.push(reln);
        if(regionSelected != null && regionSelected != '--None--'){
           var region  ='Region__c =' +'\''+component.get("v.regionSelected")+'\'';
           andFilter.push(region); 
        }
        var territorySelected = component.get("v.territorySelected");
        console.log('territorySelected****'+territorySelected);

        if(territorySelected != null && territorySelected != '--None--'){
           var territory ='Territory__c =' +'\''+component.get("v.territorySelected")+'\'';
           andFilter.push(territory); 
        }
        component.set('v.andFilters',andFilter);
        component.set('v.loadTable',false);
        component.set('v.loadTable',true);
    },
    
    changeRegion : function(component, event, helper) {
        var regionSelected = component.get("v.regionSelected");
        if(regionSelected != null && regionSelected != '--None--'){
            component.set("v.territorySelected",null);
            helper.fetchRegionTerritory(component, event, helper);
        }else{
            //component.find("Territory").set("v.value", "--None--");
			component.set("v.lstTerritory",null);
            component.set("v.territorySelected",null)
			var recordId = component.get("v.recordId");
            var reln = 'Briefing_Room_Report__c = '+'\''+recordId+'\'';
            var andFilter = [];
            andFilter.push(reln);
            component.set('v.andFilters',andFilter);
            component.set('v.loadTable',false);
            component.set('v.loadTable',true);
        }
    },
    changeTerritory : function(component, event, helper) {
    }
})