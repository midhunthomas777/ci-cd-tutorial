({
    fireFlow: function (component) {
        $A.createComponent(
            'lightning:flow',
            {
                onstatuschange: component.getReference('c.hideModal')
            },
            (flow, status, errorMessage) => {
                if (status === 'SUCCESS') {
                    flow.startFlow('Create_Case');
                    component.set('v.flow', flow);
                    var modalPromise = component
                        .find('overlayLib')
                        .showCustomModal({
                            header: $A.get('$Label.c.PP_CreateCase'),
                            body: flow,
                            showCloseButton: true,
                            closeCallback: function () {
                                if (!!component.get('v.flow')) {
                                    component.get('v.flow').destroy();
                                }
                            }
                        });
                    component.set('v.modalPromise', modalPromise);
                }
            }
        );
    }
});