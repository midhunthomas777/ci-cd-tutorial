({
    updateMenuItemsWithHref : function (component) {
        let menuItems = component.get('v._menuItems');
        let menuItemsInfoMap = component.get('v._privateMenuItemById');
        if (!menuItemsInfoMap || !menuItems) {
            return;
        }
        this.setHomeMenuItem(component, menuItems[0]);

        menuItems.forEach((menuItem) => {
            if (!$A.util.isUndefinedOrNull(menuItem)) {
                if (!$A.util.isUndefinedOrNull(menuItem.subMenu)) {
                    menuItem.subMenu.forEach((subMenuItem) => {
                        if (!$A.util.isUndefinedOrNull(subMenuItem)) {
                            let subMenuItemInfo = menuItemsInfoMap[subMenuItem.id];
                            this.handleHrefForMenuItem(subMenuItem, subMenuItemInfo);
                        }
                    });
                } else {
                    let menuItemInfo = menuItemsInfoMap[menuItem.id];
                    this.handleHrefForMenuItem(menuItem, menuItemInfo);
                }
            }
        });
        /* Force child component to re-render */
        component.set('v.menuItemsInternal', menuItems);

    },

    handleHrefForMenuItem : function (menuItem, menuItemInfo) {
        if (!$A.util.isUndefinedOrNull(menuItem)
            && !$A.util.isUndefinedOrNull(menuItemInfo)) {
            if (!$A.util.isUndefinedOrNull(menuItemInfo.actionValue)) {
                menuItem.href = menuItemInfo.actionValue;
                menuItem.actionType = menuItemInfo.actionType;
            }
        }
    },

    setHomeMenuItem : function(component, homeItem) {
        if (component.get('v.addHomeIcon')) {
            homeItem.icon = 'utility:home';
        } else {
            delete homeItem.icon;
        }
        homeItem.type = 'home';
    }

})