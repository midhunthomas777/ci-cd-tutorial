({
    doInit : function(component, event, helper) {
        if ($A.get("$Site.context.viewType") === 'Editor') {
            return;
        }  

        let tabsetParam;
        let tabsetKeys;

        let childrens = component.get('v.content')[0].get('v.body');
        if (!childrens.length > 0) {
            return;
        }
        try {
            let tabset = false;
            childrens.forEach((child) => {
                if (typeof child.get('v.body')[0].isInstanceOf === 'function' && child.get('v.body')[0].isInstanceOf('forceCommunity:tabset')) {
                    tabset = child;
                }
            });
            if (!tabset) {
                return;
            }
            let tabsetConfig = JSON.parse(tabset.get('v.body')[0].get('v.tabsetConfig'));
            tabsetParam = `tabset-${tabsetConfig.UUID.substring(0, 5)}`;
            tabsetKeys = tabsetConfig.tabs.map((tab) => tab.tabKey);

            const url = new URL(window.location.href);
            if (url.searchParams.has('tabset')) {
                const selectedTabIndex = parseInt(url.searchParams.get('tabset')) - 1;
                url.searchParams.delete('tabset');            
                url.searchParams.set(tabsetParam, tabsetConfig.tabs[selectedTabIndex].tabKey);
                window.history.replaceState({}, '', url.toString());
            }
        } catch(e) {
            console.error(e);
        }

        setTimeout($A.getCallback(() => {
            if (tabsetParam) {
                component.find('tabsetReference').setTabsetReference(tabsetParam, tabsetKeys);
            }
        }));
    },

    hideSiblings : function(component, event, helper) {
        let parentElement = event.composedPath()[0].parentElement;
        let wrapper = parentElement.parentElement;
        [...wrapper.children].forEach((children) => {
            if (children === parentElement) {
                return;
            }
            children.classList.add('slds-hide');
        });
    },

    showSiblings : function(component, event, helper) {
        let parentElement = event.composedPath()[0].parentElement;
        let wrapper = parentElement.parentElement;
        [...wrapper.children].forEach((children) => {
            if (children === parentElement) {
                return;
            }
            children.classList.remove('slds-hide');
        });
    },

    onResetScroll : function(component, event, helper) {
        event.stopPropagation();
        let evaluator = new XPathEvaluator();
        let expression = evaluator.createExpression('//section[contains(@class, "active")]//div[@class="slds-scrollable_y"]');
        let result = expression.evaluate(document, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE);
        if (result.snapshotLength > 0) {
            result.snapshotItem(0).scrollTop = 0;
        }
    },

    reRender : function(component) {
        component.set('v.shouldRender', false);
        $A.get('e.force:refreshView').fire();
        setTimeout($A.getCallback(function(){
            component.set('v.shouldRender', true);
        }));
    }
})