({
    shiptoInfo : function(component, event, helper) {
        var selectedValue = component.find("selected").get("v.value");
        if(selectedValue === 'yes'){
            component.set("v.RMARequestFormWrapper.ShipToAddress.companyName", component.get("v.RMARequestFormWrapper.userDetails.CompanyName"));
            component.set("v.RMARequestFormWrapper.ShipToAddress.shipAddress", component.get("v.RMARequestFormWrapper.userDetails.Contact.MailingStreet"));
            component.set("v.RMARequestFormWrapper.ShipToAddress.city", component.get("v.RMARequestFormWrapper.userDetails.City"));
            component.set("v.RMARequestFormWrapper.ShipToAddress.state", component.get("v.RMARequestFormWrapper.userDetails.State"));
            component.set("v.RMARequestFormWrapper.ShipToAddress.attn", component.get("v.RMARequestFormWrapper.userDetails.Contact.Name"));
            component.set("v.RMARequestFormWrapper.ShipToAddress.zipCode", component.get("v.RMARequestFormWrapper.userDetails.Contact.MailingPostalCode"));
        }
        else{
            component.set("v.RMARequestFormWrapper.ShipToAddress.companyName", null);
            component.set("v.RMARequestFormWrapper.ShipToAddress.shipAddress", null);
            component.set("v.RMARequestFormWrapper.ShipToAddress.city", null);
            component.set("v.RMARequestFormWrapper.ShipToAddress.state", null);
            component.set("v.RMARequestFormWrapper.ShipToAddress.attn", null);
            component.set("v.RMARequestFormWrapper.ShipToAddress.zipCode", null);
        }
    },
    addlineItemrow : function (component, event, helper) { 
        var existLineItems = component.get("v.RMARequestFormWrapper.lineItemWrapList") || [];
        existLineItems.push({
            'serialNumber': null,
            'Item': null,
            'description': null,
            'partNumber': null,
            'manfactureDate': null
        });
        component.set ("v.RMARequestFormWrapper.lineItemWrapList", existLineItems);
    },
    removeLineItem : function(component, event, helper) {
        var index = event.getSource().get("v.value");
        var existLineItems = component.get("v.RMARequestFormWrapper.lineItemWrapList") || [];
        existLineItems.splice(index, 1);
        component.set("v.RMARequestFormWrapper.lineItemWrapList", existLineItems);
    },
    validateUserInput: function(component, event, helper){
        var isValid = true;
        var textboxes = [];
        textboxes.push('customerAccountNumber', 'po', 'companyName', 'billingAddress', 'city', 'state', 'zip', 'contactname', 'contcatEmail', 'contactPhoneNumber', 'shipCompanyName', 'sitename', 'attn', 'shipToAddress', 'shipToCity', 'shipToState', 'problemdescription', 'manufacturedate', 'partNumber', 'zipCode');
        for (var i = 0; i < textboxes.length; i++) {
            let tb = component.find(textboxes[i]);
            if (tb !== undefined && tb.length == undefined  && (!tb.get('v.validity').valid)) {
                isValid = false;
                tb.reportValidity();
            }
        }
        isValid = component.find('lineItem').reduce(function (validSoFar, inputCmp) {
            inputCmp.reportValidity();
            return isValid && inputCmp.get('v.validity').valid;
        }, true);
        if(isValid)
        {
            component.set("v.isOpen",true);
        }
        else
        { 
            var message = "Please Enter All Required Fields.";
            this.showToast(component, message, 'error', 5000);
        }
    },
    showToast : function(component,message,messageType,duration){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title"  : messageType+"!",
            "type"   : messageType,
            "message": message,
            "duration" : duration
        });
        toastEvent.fire();
    },
    loadDefaultValues : function(component, event, helper) {
        var defaultValues = component.get("v.defaultRMARequestFormWrapper");
        component.set("v.RMARequestFormWrapper", JSON.parse(JSON.stringify(defaultValues)));
    }
})