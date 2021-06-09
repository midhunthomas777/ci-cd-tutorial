/**
 * Created by melindagrad on 8/2/18.
 * Copyright (c) 2018. 7Summits Inc.
 */
({
    init: function(component, event, helper) {
        var currentIndex = helper.getStepParameter(component, event, helper);
        var peakContentObject = component.get('v.peakContentObject');

        // Check if the current step actually exists.
        // If not, reset the value back to zero.
        if ($A.util.isUndefinedOrNull(peakContentObject[0].adventureStepWrapper[currentIndex])
            || $A.util.isEmpty(peakContentObject[0].adventureStepWrapper[currentIndex])) {
            currentIndex = 0;
        }

        if (!$A.util.isUndefinedOrNull(peakContentObject[0].adventureStepWrapper[currentIndex])
            || !$A.util.isEmpty(peakContentObject[0].adventureStepWrapper[currentIndex])) {
            component.set('v.currentIndex', currentIndex);
            component.set('v.currentStep', peakContentObject[0].adventureStepWrapper[currentIndex].id);
            component.set('v.currentName', peakContentObject[0].adventureStepWrapper[currentIndex].stepName);
        }

        component.set('v.isInit', true);
    },
    handleRenderEvent: function(component, event, helper) {
        var type = event.getParam('type');

        if(type === 'header'){
            var steps = component.get('v.peakContentObject[0].adventureStepWrapper').length;
            var currentIndex = component.get('v.currentIndex');

            helper.prepareHeaders(component, event, helper);
            helper.fireAnimateEvent(component, event, helper, steps, currentIndex);
        }else if(type === 'module'){
            helper.moduleItems(component, event, helper);
        }
    },
    showModules: function (component, event, helper) {
        helper.showModules(component,event, helper);
    }
})