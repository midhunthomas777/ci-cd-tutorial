({
	enabledisableEmails : function(component, event, email, name) {
        if(name.includes("generic-email")){
            if(email == 'Other'){
                component.set("v.isGenericEmailDisable",false);
            }else{
                component.set("v.isGenericEmailDisable",true);
                component.set("v.item.emailInput","");
            }
        }else if(name.includes("individual-email")){
            if(email == 'Other'){
                component.set("v.isIndividualEmailDisable",false);
            }else{
                component.set("v.isIndividualEmailDisable",true);
                component.set("v.item.emailInput","");
            }
        }
    },
    enabledisableNames : function(component, event, email, name) {
        if(name.includes("generic-name")){
            if(email == 'Other'){
                component.set("v.isContactNameDisabled",false);
            }else{
                component.set("v.isContactNameDisabled",true);
                component.set("v.item.firstName","");
                component.set("v.item.lastName","");
            }
        }else if(name.includes("individual-name")){
            if(email == 'Other'){
                component.set("v.isContactNameDisabled",false);
            }else{
                component.set("v.isContactNameDisabled",true);
                component.set("v.item.firstName","");
                component.set("v.item.lastName","");
            }
        }
    },
})