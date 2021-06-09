({
    createChild : function(component, childComponent) {
        const childComponentReference = childComponent.get('v.cmpDefRef')[0];

        if (!childComponentReference && childComponent.get('v.placeholderType') === "VISIBILITY_PLACEHOLDER") {
            let temporaryCards = component.get('v.temporaryCards');
            temporaryCards.push(childComponent);
            component.set('v.temporaryCards', temporaryCards);
            return;
        } else if (!childComponentReference) {
            return;
        }
        childComponent.destroy();

        const dynamicCardId = `card-id-${this.getDynamicId(component)}`;
        const childComponentSkeleton = this.createChildComponentMarkup(component, dynamicCardId, childComponentReference);

        $A.createComponents([
                [
                    'aura:html',
                    {
                        HTMLAttributes: {
                            'class': this.getColumnCssClasses(childComponentReference),
                            'aura:id': dynamicCardId
                        },
                        'aura:id': dynamicCardId,
                        'tag': 'div'
                    }
                ],
                childComponentSkeleton
            ],
            (components, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    if (childComponentReference.attributes.values.variant.value === 'basic') {
                        components[0].set('v.body', components[1]);
                        let basicCards = component.get('v.basicCards');
                        basicCards.push(components[0]);
                        component.set('v.basicCards', basicCards);
                    } else { //extended variant
                        components[0].set('v.body', components[1]);
                        let extendedCards = component.get('v.extendedCards');
                        extendedCards.push(components[0]);
                        component.set('v.extendedCards', extendedCards);
                    }
                }
            }
        )
    },
    
    getDynamicId : function(component) {
        let dynamiIdCounter = component.get('v.dynamicIdCounter');
        component.set("v.dynamicIdCounter", dynamiIdCounter + 1);
        return dynamiIdCounter;
    },

    createChildComponentMarkup : function(component, dynamicId, cmpDefRef) {
        let attributes = {};

        for (const [key, value] of Object.entries(cmpDefRef.attributes.values)) {
            attributes[key] = value.value
        }

        attributes['cardDynamicId'] = dynamicId;
        attributes['ondestroy'] = component.getReference("c.handleDestroy");

        return [
            cmpDefRef.componentDef.descriptor.replace('markup://', ''),
            attributes
        ];
    },

    getColumnCssClasses : function(childComponent) { 

        let smallSize = `slds-size_${this.getMobileSize(childComponent)}-of-12`;
        let mediumSize = `slds-medium-size--${this.getTabletSize(childComponent)}-of-12`;
        let largeSize = `slds-large-size--${this.getDesktopSize(childComponent)}-of-12`;

        return `slds-col--padded card ${smallSize} ${mediumSize} ${largeSize} slds-m-bottom_medium`;
    },

    getDesktopSize : function(childComponent) {
        try {
            return childComponent.attributes.values.desktopSize.value.replace('col-', '');
        } catch(error) {
            return '4';
        }
    },

    getTabletSize : function(childComponent) {
        try {
            return childComponent.attributes.values.tabletSize.value.replace('col-', '');
        } catch(error) {
            return '6';
        }
    },

    getMobileSize : function(childComponent) {
        try {
            return childComponent.attributes.values.mobileSize.value.replace('col-', '');
        } catch(error) {
            return '12';
        }
    },
})