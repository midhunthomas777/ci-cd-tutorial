/**
 * Created by brianpoulsen on 3/20/17.
 * Edited by Joe Callin on 8/12/2017.
 */
({
    getLabel : function(component, event, helper) {
        var text = component.get('v.text');
        helper.setLabel(component, text, 'text');
    },

    buildHeading : function(component, event, helper) {
        const tag = component.get('v.tag').substring(0,2).toLowerCase();
        const customClass = component.get('v.class');
        const align = component.get('v.align');
        const size = component.get('v.size');
        let headingClass;

        component.set('v.tag', tag);
        headingClass = (size !== 'none' ? 'slds-text-heading_' + size : '') +  ' slds-text-align_' + align + ' ' + customClass;

        component.set('v.headingClass', headingClass);
        component.set('v.isInit', true);
    }
})