({
    doInit : function (component, event, helper) {
        let action = component.get("c.getNavigationMenu");
        if ($A.get('$Site.context.viewType') !== 'Editor') {
            action.setStorable();
        }
        action.setParams({
            navigationLinkSetIdOrName: component.get("v.navigationLinkSetId"),
            addHomeMenuItem: true,
            includeImageUrl: false,
            menuItemTypesToSkip: ["SystemLink", "Event"],
            masterLabel: component.get('v._defaultMenuMasterLabel')
        });
        action.setCallback(this, (result) => {
            if ("SUCCESS" === result.getState()) {
                let returnValue = result.getReturnValue();
                let publicMenuItems = returnValue.externalMenuItems;
                let privateMenuItemById = returnValue.internalMenuItemById;
                helper.highlightActiveMenuItem(publicMenuItems, privateMenuItemById, { objectName: null, filterId: null }, helper);
                component.set('v._privateMenuItemById', privateMenuItemById);
                component.set('v._menuItems', publicMenuItems);
                helper.updateMenuItemsWithHref(component);
            }
        });
        $A.enqueueAction(action);
    },

    onItemSelected : function (component, event) {
        component.getSuper().navigate(event.getParam('id') ? event.getParam('id') : 0);
    },

    onWalkmeInfo : function(component, event) {
        component.find('walkme').setWalkmePermissions(event.getParam('permissions'));
    }
})