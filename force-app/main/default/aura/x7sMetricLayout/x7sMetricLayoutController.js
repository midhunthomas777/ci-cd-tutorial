/*
 * Copyright (c) 2019. 7Summits Inc.
*/
({
    init : function(cmp, event, helper) {
        let isUtility = cmp.get("v.iconName").includes('utility');
        if(isUtility){
            cmp.set('v.isUtility',true);
            let name = cmp.get("v.iconName");
            let indexval = name.indexOf(":")
            let category = name.substring(0, indexval);
            let iconName = name.substring(indexval+1);
            
            cmp.set('v.category',category);
            cmp.set('v.icon',iconName);
        }
        // Handling CSS
        if(cmp.get("v.isBold")){
            let cmpTarget = cmp.find('changeIt');
            $A.util.addClass(cmpTarget, 'fontbold');
        }
        else {
            let cmpTarget = cmp.find('changeIt');
            $A.util.removeClass(cmpTarget, 'fontbold');
        }
        
        //converting styles to lower case
        let allignment = cmp.get("v.titleAlignment");
        if(allignment != null){
            cmp.set("v.titleAlignment", allignment.toLowerCase());
        }
        let sizeofTitle = cmp.get("v.titleSize");
        if(sizeofTitle != null){
            cmp.set("v.titleSize", sizeofTitle.toLowerCase());
        }
    },
    
    navigateToUrl: function (component, event, helper) {
        // get target url
        let targetId = event.getSource().get("v.value");
        // navigate
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": targetId });
        urlEvent.fire();
    }
})