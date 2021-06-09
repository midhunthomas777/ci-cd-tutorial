/**
 * Created by melindagrad on 8/2/18.
 * Copyright (c) 2018. 7Summits Inc.
 */
({

    showModules : function (component, event, helper) {
        var currentStep = event.currentTarget.dataset.value;
        var headerHeights = component.get('v.headerHeights');
        var currentIndex = parseInt(event.currentTarget.dataset.index);
        var currentName = event.currentTarget.dataset.name;
        var steps = component.get('v.peakContentObject[0].adventureStepWrapper').length;
        component.set('v.currentStep', currentStep);
        component.set('v.currentIndex', currentIndex);
        component.set('v.currentName', currentName);
        helper.fireAnimateEvent(component, event, helper, steps, currentIndex);
        if(!$A.util.isUndefinedOrNull(headerHeights) && !$A.util.isEmpty(headerHeights)){
          this.setHeader(component, event, helper);
          this.setModule(component, event, helper);
        }
    },
    prepareHeaders: function(component, event, helper) {
        var items = component.find('step-header_content');
        var headerHeights = [];
        for(var i = 0; i < items.length; i++){
            headerHeights.push(items[i].getElement());
        }
        component.set('v.headerHeights', headerHeights);
        helper.setHeader(component, event, helper);
    },
    prepareModules: function(component, event, helper) {
        var items = component.find('step-module_content');
        var moduleHeights = [];
        for(var i = 0; i < items.length; i++){
            moduleHeights.push(items[i].getElement());
        }
        component.set('v.moduleHeights', moduleHeights);
        helper.setModule(component, event, helper);
    },
    setHeader: function(component, event, helper) {
        var headerHeights = component.get('v.headerHeights');
        var currentIndex = parseInt(component.get('v.currentIndex'));
        var headerMinHeight = parseInt(component.get('v.headerMinHeight'));
        var headerOffset = component.get('v.headerOffset');
        var alignment = (headerOffset + (parseInt(headerHeights[currentIndex].clientHeight) - headerMinHeight));
        alignment = alignment > headerOffset ? alignment : headerOffset;
        // currentheaderSlide.setAttribute('style', 'left: ' + alignment + 'px;padding-right:' + alignment + 'px');
        component.set('v.currentHeaderHeight', headerHeights[currentIndex].clientHeight);
        component.set('v.currentHeaderOffset', alignment);


    },
    setModule: function(component, event, helper) {
        var moduleHeights = component.get('v.moduleHeights');
        var currentIndex = parseInt(component.get('v.currentIndex'));
        component.set('v.currentModuleHeight', moduleHeights[currentIndex].clientHeight);
    },
    moduleItems: function(component, event, helper) {
        var containers = component.find('module-container');
        var steps = component.get('v.peakContentObject')[0].adventureStepWrapper;
        var containerList = [];
        for(var i = 0; i < steps.length; i++){
            var modules = [];
            for(var x = 0; x < steps[i].stepModuleWrapperList.length; x++){
                modules.push(containers[0].getElement());
                containers.splice(0,1);
            }
            containerList.push(modules);
        }
        for(var y = 0; y < containerList.length; y++){
            for(var z = 0; z < containerList[y].length; z++){
                if(z >= 4){
                    var currContainer = containerList[y][z];
                    var aboveContainer = containerList[y][z-4];
                    var offset = (currContainer.offsetTop - (aboveContainer.clientHeight + aboveContainer.offsetTop)) * -1;
                    currContainer.setAttribute('style', 'margin-top:' + offset + 'px');
                }
            }
        }
        helper.prepareModules(component, event, helper);
    },
    fireAnimateEvent: function(component, event, helper, steps, currentIndex) {
        var action = $A.get('e.c:Adventure_AnimateEvent');
        action.setParams({
            steps: steps,
            currentIndex: currentIndex
        });
        action.fire();
    },
    getStepParameter: function (component, event, helper) {
        var stepParameter = parseInt(helper.getUrlParameter('step'), 10);

        // Check if `stepParameter` is a number and proper range, then decrement the value.
        if (!isNaN(stepParameter) && stepParameter > 0) {
            return stepParameter - 1;
        }

        // Otherwise, zero is the answer.
        return 0;
    }
})