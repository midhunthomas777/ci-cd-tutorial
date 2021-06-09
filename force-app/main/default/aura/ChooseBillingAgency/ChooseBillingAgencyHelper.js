({
    getHostAccData: function(component,event,helper) {
        var oppId = component.get("v.recordId");
        var MCNList = component.get("v.MCNList");
        var accIDMap = new Map();
        var action;
        if(!$A.util.isUndefinedOrNull(oppId)) {
            action = component.get("c.getHostAndSubAccDetails");
            action.setParams({oppID : component.get('v.recordId')});
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var resp = response.getReturnValue();
                console.log('Host and SubAcc data..'+JSON.stringify(resp));
                component.set('v.loadSpinner',false);
                //Assigning Host Acc Data to Columns
                var rowData = resp[0];
                console.log('Row Data...'+JSON.stringify(rowData));
                if(rowData.Account){
                    rowData.AccountName = rowData.Account.Name;
                    rowData.FTECount = rowData.Account.FTE__c;
                }
                if(rowData.CDH_Account__r && !rowData.CDH_Account__r.Name.startsWith('ERP')){
                    accIDMap[rowData.CDH_Account__c] = rowData.CDH_Account__r.RecordType.DeveloperName;
                    rowData.MCNAcc = rowData.CDH_Account__r.Name;
                }
                if(rowData.Purchasing_Entity__r){
                    rowData.PurchasingEntityName = rowData.Purchasing_Entity__r.Name;
                    accIDMap[rowData.Purchasing_Entity__c] = rowData.Purchasing_Entity__r.RecordType.DeveloperName;    
                }
                //Assigning Sub Accounts Data to Columns
                var subAccList = resp[0].Opportunity_Agency__r;
                if(!$A.util.isUndefinedOrNull(subAccList)){
                    component.set('v.subAccResLength',subAccList.length);
                    if(rowData.Opportunity_Agency__r){
                        for(var i=0;i<subAccList.length;i++){
                            var subAccData = subAccList[i];
                            subAccData.FTECount = subAccData.FTE__c;
                            subAccData.isCreateQuote = subAccData.Create_Quote__c;
                            if(subAccData.Sub_Account__r){
                                subAccData.SubAccountName = subAccData.Sub_Account__r.Name; 
                            }
                            if(subAccData.Sub_Account__r.RecordType.DeveloperName != "Prospect"){
                                if(subAccData.MCN_Account__r){
                                    subAccData.MCNAcc = subAccData.MCN_Account__r.Name;
                                    accIDMap[subAccData.MCN_Account__c] = 'MCN';
                                }
                            } else{
                                accIDMap[subAccData.Sub_Account__c] = 'Prospect';
                            }
                            if(subAccData.Billing_Agency__r)subAccData.BillingAgency = subAccData.Billing_Agency__r.Name; 
                        }  
                    }
                }                 
            }
            component.set('v.hostAccResult', rowData);
            //component.set('v.isRenderData',true);
            component.set('v.subAccData',subAccList);
            console.log('Acc ID MAp..'+accIDMap + '**'+accIDMap.size);
            if(!$A.util.isUndefinedOrNull(rowData.Purchasing_Entity__r) || (!$A.util.isUndefinedOrNull(rowData.CDH_Account__r) && !rowData.CDH_Account__r.Name.startsWith('ERP'))
               || !(accIDMap.size === 0)){
                this.getBillingAgencyValues(component,event,accIDMap);  
            }else if(accIDMap.size === 0){
                this.showToast(component,'There are no MCN Accounts.Please populate Primary Billing Entity or Motorola Customer Account on Opportunity','Error');
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getBillingAgencyValues : function(component,event,accIDMap) {
        var action = component.get("c.getMCNAccs");
        action.setParams({
            accIDMap : accIDMap
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resp = response.getReturnValue();
            if (state === "SUCCESS" && resp.length>0) {
                component.set('v.isRenderData',false);
                component.set('v.isRenderData',true);
                component.set('v.billingAgencyValues',resp);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveRows : function(component,event){
        var btnName = event.getSource().getLocalId();
        var action = component.get("c.saveOppSubAccRecords");
        component.set('v.loadSpinner',true);
        console.log('In save Rows..'+component.get('v.selectedHostId')+JSON.stringify(component.get('v.selectedSubAccIDList')+
                                                                        component.get('v.selectedBillingEntity')))
        action.setParams({
            selectedHostId : component.get('v.selectedHostId'),
            selectedSubAccIDList : component.get('v.selectedSubAccIDList'),
            selectedBillingEntity : component.get('v.selectedBillingEntity')
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            var resp = response.getReturnValue();
            component.set('v.loadSpinner',false);
            if (state === "SUCCESS") {
                console.log('Save Response..'+resp);
                if(resp === 'Succesfully updated') {
                 $A.get('e.force:refreshView').fire();
                this.showToast(component,'Records are Successully updated!','SUCCESS');
                component.set('v.selectedHostId','');
                component.set('v.isRenderData',false);
                component.set('v.isRenderData',true);
                //$A.get('e.force:refreshView').fire(); 
                } else if(!$A.util.isUndefinedOrNull(resp)){
                    $A.get('e.force:refreshView').fire();
                this.showToast(component,resp,'Error');
                component.set('v.selectedHostId','');
                component.set('v.isRenderData',false);
                component.set('v.isRenderData',true);
                }
            }else{
                this.showToast(component,'Some unexpected error occured','Error');
            }
            if(btnName == 'closeBtn'){
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component,message,messageType){
        component.set("v.loadSpinner",false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title"  : messageType+"!",
            "type"   : messageType,
            "message": message
        });
        toastEvent.fire();
    }
})