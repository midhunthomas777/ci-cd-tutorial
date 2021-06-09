({
    doInit : function(component, event, helper) {
        if ($A.get("$Site.context.viewType") === 'Editor') {
            component.set('v.isNotEditor', false);
            return;
        }
        let childrens = component.get('v.cardsPlaceholder')[0].get('v.body');
        childrens.forEach((children) => {
            if (children.get('v.cmpDefRef')) {
                helper.createChild(component, children);
            }
        });
        let temporaryChildrens = component.get('v.temporaryCards');
        if (!temporaryChildrens.length > 0) {
            return;
        }
        temporaryChildrens.forEach((children) => {
            if (children.get('v.cmpDefRef')) {
                children.addValueHandler({
                    value : 'v.loaded',
                    event: 'change',
                    method: function(event) {
                        helper.createChild(component, children);
                        children.destroy();
                    },
                    globalId: component.getGlobalId()
                });
            }
        });
    },

    handleDestroy : function(component, event, helper) {
        let cardToDestroy = component.find(event.getParam('cardDynamicId'))
        if (cardToDestroy) {
            cardToDestroy.destroy();
        }
    }
})