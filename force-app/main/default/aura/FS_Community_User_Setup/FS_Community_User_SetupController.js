({
    /**
     * Change Log: 
     * 3 April 2020
     * Updated error handling logError
     * Added onPrevious to return to previous flow screen
     */
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); // stop form submission
        let userEditForm =  component.find("userEditForm") ; 
        let fields = event.getParam('fields');
        let profileId = component.get("v.profileId") ;     
        fields.ProfileId =  profileId ; 
        fields.Id =  (component.get("v.userId") != ''  ) ? component.get("v.userId")  : ''  ;
        console.log(JSON.stringify(fields));
        component.set("v.UserSObject", fields); 
        //component.find('userEditForm').submit(fields);
        helper.createUser(component, event, helper, fields);
    },
    contactLoaded : function(component, event, helper) {
        if(component.get("v.fieldList").length === 0){
            let fieldInputs = (component.get("v.userId")  ) ? helper.defaultFieldsDisplay(component)  :  helper.defaultNewUser(component)  ; 
            $A.createComponents(fieldInputs,
                                function(components, status, errorMessage){
                                    if (status === "SUCCESS") {
                                        component.set("v.fieldList", components)
                                    }
                                    else if (status === "INCOMPLETE") {
                                        console.log("No response from server or client is offline.")
                                        // Show offline error
                                    }
                                        else if (status === "ERROR") {
                                            console.log("Error: " + errorMessage);
                                        }
                                }  ) ;       
            
        }   
    },
    onPrevious: function(component,event,helper){
        let navigate = component.get("v.navigateFlow");
        navigate("BACK");
    }, 
    recordLoadError : function(component, event, helper) {
        console.log("Error occurred: " , JSON.parse(JSON.stringify(event.getParams() ))) ; 
    },
    logError : function(component, event, helper) {
        let warningMessage = "We received the below errors when attempting to save: \n" ;
        let fieldErrorMessages = JSON.parse(JSON.stringify( event.getParam("output").fieldErrors)) ;
        try{
            for (const property in fieldErrorMessages) {
                warningMessage+= "\n " +  property + " "  + JSON.stringify(fieldErrorMessages[property][0]) ;
            }
            $A.util.removeClass( component.find('errorMessageAccordion'), 'slds-hide');
            component.set("v.errorMessage", warningMessage);
        }catch(err){
            //Couldnt parse the error 
            $A.util.removeClass( component.find('errorMessageAccordion'), 'slds-hide');
            warningMessage += "We couldn't parse the error message correctly : \n" +JSON.stringify( event.getParam("output").fieldErrors) ;   
            component.set("v.errorMessage", warningMessage)
        }
        
        console.log("Error occurred: " ,JSON.parse(JSON.stringify(event.getParams() ))) ; 
    },
    onSuccess: function(component,event,helper, userId){
        component.set("v.userId",  userId); 
        helper.showToast("Success", "User was created successfully", "success" ); 
        let navigate = component.get("v.navigateFlow");
        navigate("NEXT");
    },
})