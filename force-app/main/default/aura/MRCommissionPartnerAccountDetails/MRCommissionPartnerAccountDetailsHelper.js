({ 
    validatePartnerAccount : function(component, event, helper) {
         var selectedPartnerId= component.get("v.selectedpartnerId");
        var validSub = true;
        var errorLabel = "";
        var errorMessage = [];
        var errorString="";
        if(($A.util.isEmpty(selectedPartnerId) || selectedPartnerId === '')){
            validSub = false;
            errorString += "Please select partner account" ;   
        }
        if(!validSub){
            errorMessage.push(["aura:unescapedHtml", {
                value : "<h2 Style=\"font-size:20px\">"+errorString+"</h2>"
            }]);
            this.createAlertBox(component, errorMessage);
        }
        return validSub;
    },   
    createAlertBox : function(component, modalBody){ 
        $A.createComponents(modalBody,
                            function(newComponents){
                                var appValidationModal = component.find("Validation");
                                appValidationModal.set('v.body',newComponents);
                                appValidationModal.open();
                            });
    }
   
})