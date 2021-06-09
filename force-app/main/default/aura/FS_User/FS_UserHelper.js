({
    showToast: function(title,message,type){
        var toastMessage = $A.get("e.force:showToast");
        toastMessage.setParams({
            "title": title,
            "message": message, 
            "type": type 
        });
        toastMessage.fire();
        $A.get('e.force:refreshView').fire();
    },
    onSuccessM: function(component,event,helper){
        this.showToast("Success", "User was successfully deactivated", "success"); 
    },
    logErrors : function(component, errors) {
        let warningMessage = "We received the below errors when attempting to save:" ;
        let htmlTagRegex = new RegExp("<[/a-zAZ0-9]*>", "g");
        console.log(JSON.stringify(errors));
        errors.forEach( error => {
            warningMessage += "\n" + error.message.replace(htmlTagRegex, '');
        });
        $A.util.removeClass( component.find('errorMessageAccordion'), 'slds-hide');
        component.set("v.errorMessage", warningMessage);
    }
})