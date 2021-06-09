({
    sendMessage: function (component, message) {
        component.find('clientEventMessageChannel').publish(message);
    },
    statusUpdate : function(component, status) {
        this.sendMessage(component, {
            type: 'PureCloud.User.updateStatus',
            data: { id: status },
        });
    },

    stateUpdate: function(component, action) {
        var id = component.get('v.interactionId');        
        this.sendMessage(component, {
            type: 'PureCloud.Interaction.updateState',
            data: {
                action: action,
                id: id
            }
        });
    },

    outputToConsole: function(component, message) {
        var timezone = $A.get("$Locale.timezone");
        //console.log('Time Zone Preference in Salesforce ORG :'+timezone);
        var mydate = new Date().toLocaleString("en-US", {timeZone: timezone})
        if(message) {
            var console = component.get('v.consoleMessages');
             component.set('v.consoleMessages', console + message + "###"+ "mydate: "+ mydate + "\r\n###");
             //console.log('Date Instance with Salesforce Locale timezone : '+mydate);
        }
    },

    addAttributes: function(component) {

        var id = component.get('v.interactionId');
        var attributesText = component.get('v.attributes');
        var attributes = {};

        try{
            attributes = JSON.parse(attributesText);
        } catch(e){
            console.log('Error parsing custom attributes: ' + JSON.stringify(e.message));
        }

        this.sendMessage(component, {
            type: 'PureCloud.Interaction.addCustomAttributes',
            data: {
                attributes: attributes,
                id: id
            }
        });
    },
    releaseCapacity:function(component,pureCloudId,userID){//,pureCloudId
        var action = component.get("c.changePhoneCallStatus");
        action.setParams({"taskPureCloudId":pureCloudId,"SFUserID":userID});
        action.setCallback(this, function(response) {
            
        })
        $A.enqueueAction(action);
    }
})