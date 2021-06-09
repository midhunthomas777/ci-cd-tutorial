({
    doInit: function (component) {
        component.set(
            'v.buttonLabel',
            $A.get('$Label.c.PP_Buttons_NewCase').toUpperCase()
        );
        let _location = new URL(window.location);
        let searchParams = _location.searchParams;
        if (searchParams.get('popup') === 'createCase') {
            $A.enqueueAction(component.get('c.checkCommunityType'));
        }
    },

    handlePubsubReady: function (component) {
        const pubsub = component.find('pubsub');
        const callback = $A.getCallback(function () {
            $A.enqueueAction(component.get('c.checkCommunityType'));
        });
        pubsub.registerListener('newCaseButton', callback);
    },

    settingsReady: function (component, event) {
        const settings = event.getSource();
        component.set('v.isCustomerHub', settings.service().isCustomerHub());
        component.set('v.isPartnerHub', settings.service().isPartnerHub());
    },

    checkCommunityType: function (component, event, helper) {
        if (component.get('v.isPartnerHub')) {
            helper.fireFlow(component);
        } else if (component.get('v.isCustomerHub')) {
            component.find('createNewCustomerCase').show();
        }
    },

    hideModal: function (component, event) {
        if (event.getParam('status').indexOf('FINISHED') !== -1) {
            component.get('v.flow').destroy();
            const modalPromise = component.get('v.modalPromise');
            modalPromise.then((modal) => {
                modal.close();
            });

            const outputVariables = event.getParam('outputVariables');
            let tabIndex = 1;
            for (let i = 0; i < outputVariables.length; i++) {
                const outputVar = outputVariables[i];
                if (outputVar.name === 'caseType') {
                    if (
                        outputVar.value === 'isOtherSalesSupportQuestion' ||
                        outputVar.value === 'isMRCommissionInquiry' ||
                        outputVar.value === 'isMRCustomerAccountUpdate' ||
                        outputVar.value === 'isMRQuoting'
                    ) {
                        tabIndex = 1;
                    } else if (
                        outputVar.value === 'isRepair' ||
                        outputVar.value === 'isLearning' ||
                        outputVar.value === 'isMyOnlineExperience' ||
                        outputVar.value === 'isPartnerEmpowerProgram' ||
                        outputVar.value === 'isOtherSupportQuestion' ||
                        outputVar.value === 'isMyAccountAndUsers' ||
                        outputVar.value === 'isOrderSupport'
                    ) {
                        tabIndex = 2;
                    } else if (
                        outputVar.value === 'isIncident' ||
                        outputVar.value === 'isServiceRequest'
                    ) {
                        tabIndex = 3;
                    }
                }
            }

            const navService = component.find('navService');
            const pageRef = {
                type: 'standard__objectPage',
                attributes: {
                    actionName: 'list',
                    objectApiName: 'Case'
                },
                state: {
                    tabset: tabIndex
                }
            };
            navService.navigate(pageRef, true);
        }
    }
});