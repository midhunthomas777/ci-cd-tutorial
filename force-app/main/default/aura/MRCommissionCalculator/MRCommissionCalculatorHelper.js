({
    SearchMCNAccountsHelper : function(component, event, helper) {
        component.set("v.loadSpinner", true);    
        var JSAccountName = component.find("CustomerAccountName").get("v.value");
        var JSAccountMCN = component.find("MotorolaCustomerNumber").get("v.value");
        var JSBillingCountry = component.get("v.BillingCountrySelected");
        var JSBillingState = component.get("v.BillingStateSelected");
        var JSCity = component.find("City").get("v.value");
        var JSPostalCode = component.find("PostalCode").get("v.value");
        var JSRoutetoMarket = component.get("v.RoutetoMarketSelected");
        var action = component.get('c.fetchMCN');
        action.setParams({
            "conAccountName" : JSAccountName,
            "conMCN":JSAccountMCN,
            "conBillingCountry" : JSBillingCountry,
            "conBillingState" : JSBillingState,
            "conCity" : JSCity,
            "conPostalCode" : JSPostalCode,
            "routeToMarket" : JSRoutetoMarket            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.loadSpinner", false);  
                component.set("v.MCNList", []);
                component.set("v.MCNList",response.getReturnValue());
                var MCNsize = component.get("v.MCNList");
                console.log('MCNsize'+MCNsize);
                if(this.validateSearchAccount(component, event, helper))
                {
                    component.set("v.Showmnc",true);
                    var childCompId = component.find("cmsDetailID");
                    childCompId.childmethod(component);
                }
            } 
        });
        $A.enqueueAction(action);
    },
    fetchStatePicklistValuesHelper : function(component, event, helper) {
        var JSBillingCountry = component.get("v.BillingCountrySelected");
        var BillingStateList = component.get("v.BillingState");
        var action = component.get('c.fetchStates');
        action.setParams({
            "conBillingCountry" : JSBillingCountry                       
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.BillingState",response.getReturnValue());
                console.log('state is'+JSON.stringify(component.get("v.BillingState")));
                component.set("v.BillingStateDisabled",false);
            } 
        });
        $A.enqueueAction(action);
    },
    validateSearchAccount : function(component, event, helper) {
        var JSAccountName = component.find("CustomerAccountName").get("v.value");
        var JSAccountMCN = component.find("MotorolaCustomerNumber").get("v.value");
        var JSPostalCode = component.find("PostalCode").get("v.value");
        var JSBillingCountry = component.get("v.BillingCountrySelected");
        var listMCN = component.get("v.MCNList");
        console.log('listMCN'+listMCN.length);
        var validSub = true;
        var errorLabel = "";
        var errorMessage = [];
        var errorString="";
        if(($A.util.isEmpty(JSAccountName) || JSAccountName === '')&& ($A.util.isEmpty(JSAccountMCN) || JSAccountMCN === '') ){
            validSub = false;
            errorString += "Please enter Customer Account name or Motorola Customer Number" ;   
        }
        else if(isNaN(JSAccountMCN)){
            validSub = false;
            errorString += "Please enter numeric number" ;   
        }else if(JSAccountName.length < 2 && ($A.util.isEmpty(JSAccountMCN) || JSAccountMCN === '')){
                validSub = false;
                errorString += "Please enter minimum 2 letters for Customer Account name" ;   
       }else if(JSPostalCode.length > 5 && JSBillingCountry ==='United States' ){
                validSub = false;
                errorString += "Please enter valid Zip/Postal Code";   
      }else if(listMCN.length > 100){
                    validSub = false;
                    errorString += "Result contains more than 100 records. Please apply more filters or enter Motorola Customer Number";   
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