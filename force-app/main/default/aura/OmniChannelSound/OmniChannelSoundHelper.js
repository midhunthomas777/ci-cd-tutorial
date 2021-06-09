({
    retrieveSound : function(component) {
        let action = component.get("c.getSound");
        action.setCallback(this, (response) => {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.selectedSound', response.getReturnValue());
                component.set('v.retrieveSoundFinished', true);
            } else {
                console.log('Failed to read omni channel sound');
            }
        });
        $A.enqueueAction(action);
    }, 
    playSound : function(component) {
        if (component.get('v.selectedSound') != null) {
            let soundStaticResource = '$Resource.'+component.get('v.selectedSound');
            let getSound = $A.get(soundStaticResource);
            let playASound = new Audio(getSound);
            playASound.play();
        }
    },
    retrieveSounds : function(component) {
        const action = component.get('c.getSounds');
        action.setCallback(this, (actionResult) => {
            if (actionResult.getState() === 'SUCCESS') {
                //component.set('v.selectedOnInit', true);
                component.set('v.availableSounds', actionResult.getReturnValue());
                component.set('v.retrieveSoundsFinished', true);
            }
        });
        $A.enqueueAction(action);
    },
    handleChangedSound: function(component, event) {
        const retrieveSoundFinished = component.get('v.retrieveSoundFinished');
        const retrieveSoundsFinished = component.get('v.retrieveSoundsFinished');
        const selectedSound = event.getParam('value');
    
        if (retrieveSoundFinished === true && retrieveSoundsFinished === true) {
            this.playSound(component);
            const action = component.get("c.setSelectedSound");
            action.setParam('sound', selectedSound);
            action.setCallback(this, (actionResult) => {
                if (actionResult.getReturnValue === 'SUCCESS') {
                    console.log('Selected omnichannel sound saved');
                }
            });
            $A.enqueueAction(action); 
        }
    }
})