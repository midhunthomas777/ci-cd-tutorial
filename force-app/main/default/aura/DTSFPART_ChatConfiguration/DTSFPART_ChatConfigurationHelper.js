({
    htmlChatClasses: function() {
        return {
            onlineChatAgentClassName: 'helpButtonEnabled',
            offlineChatAgentClassName: 'helpButtonDisabled',
            navigationSupportLinksChatAvailable: 'chat-available',
            navigationSupportLinksChatPresent: 'chat-present',
            chatFloaterCssClass: 'flatButton',
            chatFloaterLWCCssClass: 'minimized-button'
        };
    },

    getChatConfigurationAndSetChatSettings: function(component) {
        let action = component.get("c.getChatRouting");
        let chatConfig = component.get('v.chatConfigName');

        action.setParams({ 
            configName: chatConfig 
        });
        
        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                window.ChatConfig = result;

                this.chatConfigurationCallback(component, result);
                this.getUser(component);
            } else if (state === "ERROR") {
                console.error($A.get("$Label.c.PP_ChatRoutingError"));
            }
        });

        $A.enqueueAction(action);
    },

    getUser: function(component) {
    	let action = component.get("c.getUser");

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === "SUCCESS") {                
                window.ChatConfig = {
                    ...window.ChatConfig,
                    'User': response.getReturnValue()
                }

            } else if (state === "ERROR") {
                console.error($A.get("$Label.c.PP_ChatRoutingError"));
            }
        });

        $A.enqueueAction(action);
    },

    chatConfigurationCallback: function(component, chatConfiguration) {
        if (chatConfiguration.Is_Display_Chat_Button__c) {
            this.displayChatIconInNavigationSupportLinks();
            this.setOfflineSupportLink(component, chatConfiguration);
            this.setTimeAfterPopupShouldAppear(component, chatConfiguration);
            this.addChatStatusListnerAndSetPopupAndNavSupportLinks(component, chatConfiguration);
            this.addClickListenerToOfflineChatButton(component);
        } else {
            this.hideChatFloater();
            this.setOfflineChatInNavigationSupportLinks();
            this.hideChatInNavigationSupportLinks();
        }
    },

    displayChatIconInNavigationSupportLinks: function() {
        if (document.body.classList.contains(this.htmlChatClasses().navigationSupportLinksChatPresent)) {
            document.body.classList.add(this.htmlChatClasses().navigationSupportLinksChatPresent); 
        }
    },

    hideChatInNavigationSupportLinks: function() {
        if (document.body.classList.contains(this.htmlChatClasses().navigationSupportLinksChatPresent)) {
            document.body.classList.remove(this.htmlChatClasses().navigationSupportLinksChatPresent); 
        }
    },

    setOnlineChatInNavigationSupportLinks: function() {
        if (document.body.classList.contains(this.htmlChatClasses().navigationSupportLinksChatAvailable)) {
            document.body.classList.add(this.htmlChatClasses().navigationSupportLinksChatAvailable); 
        }
    },

    setOfflineChatInNavigationSupportLinks: function() {
        if (document.body.classList.contains(this.htmlChatClasses().navigationSupportLinksChatAvailable)) {
            document.body.classList.remove(this.htmlChatClasses().navigationSupportLinksChatAvailable);
        }
    },

    setOfflineSupportLink: function(component, chatConfiguration) {
        component.set("v.offlineSupportUrl", chatConfiguration.Contact_Us_Form_Url__c);
    },

    setTimeAfterPopupShouldAppear: function(component, chatConfiguration) {
        component.set("v.displayPopupAfterTime", chatConfiguration.Banner_Time__c || 20); 
    },

    addClickListenerToOfflineChatButton: function(component) {
        let redirectOnClickToOfflineSupport = () => {
            this.redirectToOfflineSupportUrl(component, this.htmlChatClasses().offlineChatAgentClassName);
        };

        window.setTimeout(() => {
            let offlineChatButton = document.getElementsByClassName(this.htmlChatClasses().offlineChatAgentClassName)[0];

            if (offlineChatButton) {
                offlineChatButton.addEventListener("click", redirectOnClickToOfflineSupport);
            } else {
                this.addClickListenerToOfflineChatButton(component);
            }
        }, 500);
    },

    redirectToOfflineSupportUrl: function(component, offlineChatAgentClassName) {
        let offlineSupportUrl = component.get("v.offlineSupportUrl");
        let isAgentStillOffline = !!document.getElementsByClassName(offlineChatAgentClassName)[0];

        if (offlineSupportUrl && isAgentStillOffline) {
            window.open(offlineSupportUrl, '_blank');
        }
    },

    addChatStatusListnerAndSetPopupAndNavSupportLinks: function(component, chatConfiguration) {
        let isAgentOnline = false;
        let agentIsOnlineTime = 0;
        
        window.setInterval(() => {
            isAgentOnline = !!document.getElementsByClassName(this.htmlChatClasses().onlineChatAgentClassName)[0];
            
            if (isAgentOnline) {
                agentIsOnlineTime++;
    
                this.setOnlineChatInNavigationSupportLinks();
                this.displayChatPopup(component, agentIsOnlineTime, chatConfiguration);
            } else {
                this.setOfflineChatInNavigationSupportLinks();
            }
        }, 1000);//check every 1s that agent is online or offline
    },

    displayChatPopup: function(component, agentIsOnlineTime, chatConfiguration) {
        let timeAfterPopupShouldBeDisplay = component.get("v.displayPopupAfterTime");
        let wasPopupDisplayed = component.get('v.wasPopupDisplayed');

        if (chatConfiguration.Is_Banner_Needed__c &&
            agentIsOnlineTime > timeAfterPopupShouldBeDisplay && 
            !wasPopupDisplayed) {

            //event to communityChatPopup
            const pubsub = component.find('pubsub');
            pubsub.fireEvent('showChatPopup', true);

            component.set('v.wasPopupDisplayed', true);
        }
    },

    findChatFloater: function() {
        return document.getElementsByClassName(this.htmlChatClasses().chatFloaterCssClass)[0] || 
               document.getElementsByClassName(this.htmlChatClasses().chatFloaterLWCCssClass)[0];
    },

    hideChatFloater: function() {
        window.setTimeout(() => {
            let minimalizedChatButton = this.findChatFloater();

            if (minimalizedChatButton) {
                minimalizedChatButton.style.display = 'none';
            } else {
                this.hideChatFloater(component);
            }
        }, 500);
    },

    openChat: function() {
        let minimalizedChatButton = this.findChatFloater();
        
        if (minimalizedChatButton) {
            minimalizedChatButton.click();
        }
    },
})