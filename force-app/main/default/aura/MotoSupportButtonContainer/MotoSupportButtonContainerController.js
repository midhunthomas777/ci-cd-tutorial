/**
 * Created by WGVR43 on 18.06.2020.
 */

({
    handleButtonClick: function (component, event) {
        if(event.getSource().getLocalId() === "button1"){
            window.open(component.get("v.addressButton1"), "_top");
        } else {
            window.open(component.get("v.addressButton2"), "_top");
        }
    }
});