({
    getCAPPRecords : function(component, helper){
        console.log('getCAPPRecords');
        var action = component.get("c.getCAPPRecords");
        var fields = 'Id, Name, Vendor__c, Vendor__r.Name, Vendor_Product_Line__c,Vendor_Product_Line__r.Name, RecordType.Name, CAPP_Change__c,  Opportunity_Auto_Created_or_Modified_Fr__r.Name, Reviewed_by_Sales__c, Opportunity_Auto_Created_or_Modified_Fr__c, Purchase_Year__c, RADIO_INFRASTRUCTURE_1__c';
        component.set("v.errorMsg", "");
        action.setParams({
            "fields": fields,
            "OpptyId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            component.set("v.loadSpinner", false);           
            var state = response.getState();
            var respRes = response.getReturnValue();
            var cappResult = [];
            console.log('CAPP Records>>'+JSON.stringify(response.getReturnValue()));
            if (state === 'SUCCESS') {
                for (var i = 0; i < respRes.length; i++) {
                    cappResult.push({
                        name: respRes[i].Name,
                        recordId: respRes[i].id,
                        VendorId: respRes[i].Vendor__c,
                        Vendor: respRes[i].Vendor__r.Name,                        
                        RecordTypeName : respRes[i].RecordType.Name,
                        PurchaseYear: respRes[i].Purchase_Year__c,
                        Type: respRes[i].RADIO_INFRASTRUCTURE_1__c,
                        CAPPChange: respRes[i].CAPP_Change__c,
                        linkName: '/'+respRes[i].Id,
                        linkVendor: '/'+respRes[i].Vendor__c,
                        VendorProductLine: (respRes[i].Vendor_Product_Line__c !== undefined && respRes[i].Vendor_Product_Line__c !== '') ? respRes[i].Vendor_Product_Line__r.Name:'',
                        linkVendorProduct: (respRes[i].Vendor_Product_Line__c !== undefined && respRes[i].Vendor_Product_Line__c !== '') ? '/'+respRes[i].Vendor_Product_Line__c:'',
                    });
                }
                console.log('CAPP Results>>'+JSON.stringify(cappResult));
                component.set("v.cappList", cappResult);
                component.set("v.cappListLength", cappResult.length);
            }else{
                console.log("Error : "+response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})