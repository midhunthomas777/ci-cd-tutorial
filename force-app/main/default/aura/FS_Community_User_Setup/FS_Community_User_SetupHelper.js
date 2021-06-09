({
    /**
     * Change Log: 
     * 3 April 2020
     * Updateting defaultFieldsDisplay to remove contact id, if we already have the community user created no need to include 
     * This seems to throw an error when included 
     * [ "lightning:inputField" , 
             {"fieldName": 'ContactId',  "disabled":false, "value":  component.get("v.contactId") , "aura:id": "input_ContactId"}
            ], 
     * 
     */
    defaultNewUser:function(component,event,helper) {
        let fieldInputs = [ 
            [ "lightning:inputField" , 
             {"fieldName": 'FirstName', "disabled":false, "value":  component.get("v.contactRecord.FirstName") , "aura:id": "input_FirstName"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'LastName', "disabled":false, "value": component.get("v.contactRecord.LastName") , "aura:id": "input_LastName"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'Email', "disabled":false, "value":  component.get("v.contactRecord.Email") , "aura:id": "input_Email"}
            ],
            [ "lightning:inputField" , 
             {"fieldName": 'FederationIdentifier', "disabled":true, "value":  component.get("v.contactRecord.LDAP_Login__c") , "aura:id": "input_Email_Fed"}
            ],            
            [ "lightning:inputField" , 
             {"fieldName": 'Username',  "value":  component.get("v.contactRecord.Email") , "aura:id": "input_Username"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'Phone', "disabled":false, "value":  component.get("v.contactRecord.Phone") , "aura:id": "input_Phone"}
            ],
            [ "lightning:inputField" , 
             {"fieldName": 'CommunityNickname', "disabled":false, "value": component.get("v.contactRecord.FirstName") + " " + component.get("v.contactRecord.LastName"), "aura:id": "input_CommunityNickname"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'TimeZoneSidKey', "disabled":false, "aura:id": "input_TimeZoneSidKey"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'LocaleSidKey', "disabled":false,  "aura:id": "input_LocaleSidKey"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'EmailEncodingKey', "disabled":false, "aura:id": "input_EmailEncodingKey"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'ProfilLanguageLocaleKeyId', "disabled":false,  "aura:id": "input_ProfilLanguageLocaleKeyId"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'Alias', "disabled":false, "value":  ( component.get("v.contactRecord.FirstName").substring(0, 1) + component.get("v.contactRecord.LastName")).substr(0,8)  , "aura:id": "input_alias"}
            ]
            , 
            [ "lightning:inputField" , 
             {"fieldName": 'LanguageLocaleKey', "disabled":false,  "aura:id": "input_LanguageLocaleKey"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'ContactId', "disabled":false, "value":  component.get("v.contactId") , "aura:id": "input_ContactId"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'IsActive', "disabled":false, "value":  true , "aura:id": "input_isActive"}
            ]
            , 
            [ "lightning:inputField" , 
             {"fieldName": 'NeedsNewPassword', "disabled":false, "value":  true , "aura:id": "input_NeedsNewPassword"}
            ]
            
        ];
        return fieldInputs ;
    },
    defaultFieldsDisplay:function(component,event,helper){
        let fieldInputs = [ 
            [ "lightning:inputField" , 
             {"fieldName": 'FirstName',  "aura:id": "input_FirstName"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'LastName',  "aura:id": "input_LastName"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'Email',  "aura:id": "input_Email"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'Username', "aura:id": "input_Username"}
            ],            
            [ "lightning:inputField" , 
             {"fieldName": 'Phone', "aura:id": "input_Phone"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'CommunityNickname',   "aura:id": "input_CommunityNickname"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'TimeZoneSidKey', "aura:id": "input_TimeZoneSidKey"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'LocaleSidKey',  "aura:id": "input_LocaleSidKey"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'EmailEncodingKey', "aura:id": "input_EmailEncodingKey"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'ProfilLanguageLocaleKeyId',  "aura:id": "input_ProfilLanguageLocaleKeyId"}
            ], 
            [ "lightning:inputField" , 
             {"fieldName": 'Alias',  "aura:id": "input_alias"}
            ]
            , 
            [ "lightning:inputField" , 
             {"fieldName": 'LanguageLocaleKey',   "aura:id": "input_LanguageLocaleKey"}
            ], 
            
            [ "lightning:inputField" , 
             {"fieldName": 'IsActive', "aura:id": "input_isActive"}
            ],
                        
            [ "lightning:inputField" , 
             {"fieldName": 'FederationIdentifier', "aura:id": "input_Email_Fed"}
            ]
            , 
            [ "lightning:inputField" , 
             {"fieldName": 'NeedsNewPassword',  "aura:id": "input_NeedsNewPassword"}
            ]
            
        ];
        return fieldInputs ;    
    }, 
    showToast: function(title,message,type){
        var toastMessage = $A.get("e.force:showToast");
        toastMessage.setParams({
            "title": title,
            "message": message, 
            "type": type 
        });
        toastMessage.fire();
        
    },
    
    createUser: function(component, event, helper, eventFields) {
        var action = component.get('c.createUserFromContact'); 
        component.set("v.loadSpinner", true);
        action.setParams({
            'createUserObj': eventFields
        });        
        action.setCallback(this, function(response) {
            console.log('inside callback');
            component.set("v.loadSpinner", false);
            var state = response.getState();
            if(state=='SUCCESS'){ 
                var storeResponse = response.getReturnValue();
                $A.util.addClass( component.find('errorMessageAccordion'), 'slds-hide');
                this.onSuccessM(component, event, helper, storeResponse);
            } else {
                this.logErrors(component, response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    onSuccessM: function(component,event,helper, userId){
        component.set("v.userId",  userId); 
        helper.showToast("Success", "User was created successfully", "success" ); 
        let navigate = component.get("v.navigateFlow");
        navigate("NEXT");
        $A.get('e.force:refreshView').fire();
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
    },
})