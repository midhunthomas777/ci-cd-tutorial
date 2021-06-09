({
    doInit : function(component, event, helper) {
        helper.setCookieListener(component);
        helper.getCartCookieValue(component);
        
        if ($A.get('$Site.context.viewType') === 'Editor') {
            return;
        }

        $A.createComponent(
            "ltng:require",
            {
                scripts: `${$A.get('$Resource.DTSFPART_PartnerCommunityHeader')}/header.js`,
            },
            function(script, status, error) {
                if (status === 'SUCCESS') {
                    let scripts = component.get('v.scripts');
                    scripts.push(script);
                    component.set('v.scripts', scripts);
                } else {
                    console.error(error);
                }
            }
        )

        document.addEventListener('click', (ev) => {
            let element = ev.composedPath()[0];
            if (element.closest('.header-show')) {
                return;
            }
            let visibleHeader = document.querySelector('.header-show');
            if (!visibleHeader) {
                return;
            }
            let triggerButton = visibleHeader.previousSibling;
            if (element === triggerButton) {
                return;
            }
            if (element.nextSibling && element.nextSibling.role === 'menu') {
                return;
            }

            let tealiumTrigger = component.find('tealium-trigger').getElement();
            tealiumTrigger.ANALITYCS.MENU.CLICK_AWAY(visibleHeader.dataset.uetLinkLabelPrefix.toLowerCase());
        }, true);
    },

    setMulesoftCredentials : function(component, event, helper) {
        component.set('v.mulesoftCredentials', event.getParam('arguments').mulesoftCredentials);
        helper.getNavigationItems(component);
    },

    closeMobileMenu : function(component, event, helper) {
        if (window.des) {
            window.des.header.hideLayer();
        }
    },

    closeSubmenus : function(component) {
        document.body.style.removeProperty('overflow');
        component.find('mobile-menu').closeSubmenus();
        if (!$A.util.hasClass(component.find('header-menu').getElement(), 'header-show')) {
            $A.util.addClass(component.find('header-menu-wrapper').getElement(), 'slds-is-relative');
            setTimeout($A.getCallback(() => {
                $A.util.removeClass(component.find('header-menu-wrapper').getElement(), 'slds-is-relative');
            }));
        }
    },

    closeMobileMenuAll : function(component) {
        component.find('mobile-menu').closeSubmenus();
        if (window.des) {
            window.des.header.hideLayer();
        }        
    },

    setCommunityUrl : function(component, event) {
        component.set('v.communityUrl', event.getParam('url'));
    },

    onSearchKey : function(component, event, helper) {
        if (event.type === "keydown" && event.code !== "Enter") {
            return;
        }
        helper.closeSearch(component);
    },

    onSearchClick : function(component, event, helper) {
        if (event.target.closest('.listContent')) {
            helper.closeSearch(component);
            return;
        }
        if (!event.target || !event.target.classList.contains('slds-form-element__control')) {
            return;
        }
        
        try {
            let search = component.get('v.search');
            let inputComp = search[0].get('v.body')[0].get('v.body')[0].find('searchInputDesktop');
            let inputHelper = inputComp.getDef().getHelper();

            let term = inputHelper.getInputValue(inputComp);
            if (inputComp.get("v.term") !== term) {
                inputComp.set("v.term", term);
            }
            
            if (!term || term.trim().length === 0) {
                return;
            }

            let tealiumTrigger = component.find('tealium-trigger').getElement();
            tealiumTrigger.ANALITYCS.MENU.SEARCH_GLASS(term);

            let firstActionConfig = inputComp.get("v.dataProvider[0]").get("v.headerActions[0]");
            let scopeMap = (firstActionConfig || {}).scopeMap;
            let context = (firstActionConfig || {}).context;

            
            if ($A.util.isEmpty(scopeMap)) {
                scopeMap = inputComp.get("v.scopeMap") || {};
            }
            if ($A.util.isEmpty(context)) {
                context = inputComp.get("v.context") || {};
            }
            inputComp.set("v.scopeMap", scopeMap);
            inputComp.set("v.context", context);
            inputComp.getConcreteComponent().getDef().getHelper().runSearch(inputComp, term, scopeMap, context);
            
            inputHelper.cancelFetchData(inputComp);
            
            window.setTimeout($A.getCallback(function () {
                inputHelper.hideList(inputComp);
            }), 0);

            
            inputHelper.lib.logging.log(
                inputComp,
                inputHelper.lib.interaction.SYNTHETIC_CLICK,
                inputComp.get('v.eventScope'),
                'search-mru-action-item',
                {
                    type: inputHelper.lib.action.SEARCH_OPTION,
                    method: 'enter',
                    term: term,
                    scopeName: scopeMap.name || scopeMap.type 
                });

        } catch (e) {
            console.error(e);
        }
    },

    handleTealiumClick : function(component, event) {
        let button = event.target;
        let dropdown = document.querySelector(`.${button.ariaControls}`);
        const isOpened = $A.util.hasClass(dropdown, 'header-show');
        if (isOpened) {
            button.dataset.uetLinkUrl = `@close ${dropdown.dataset.uetLinkLabelPrefix.toLowerCase()}`;
        } else {
            button.dataset.uetLinkUrl = `@open ${dropdown.dataset.uetLinkLabelPrefix.toLowerCase()}`;
        }
    },

    hideLayer : function() {
        if (window.des) {
            window.des.header.hideLayer();
        }
    }
    
})