({
    onStatusChanged: function (component, event, helper) {
        console.log("Status changed.");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        if (userId != '') {
            component.set("v.userId", userId);
            console.log('##Got the User!!##');
        }
        var statusId = event.getParam('statusId');
        var channels = event.getParam('channels');
        var statusName = event.getParam('statusName');
        var statusApiName = event.getParam('statusApiName');
        console.warn('##statusId##' + statusId);
        console.log('##channels##' + channels);
        console.log('##statusName##' + statusName);
        console.log('##statusApiName##' + statusApiName);
        if (!$A.util.isUndefined(component.get("v.userId")) && statusId != '') {
            helper.changePureCloudStatus(component, userId, statusApiName);
            console.log('##YES!!##');
        }
    },

    onWorkloadChanged: function (component, event, helper) {
        console.log("Workload changed.");
        var configuredCapacity = event.getParam('configuredCapacity');
        var previousWorkload = event.getParam('previousWorkload');
        var newWorkload = event.getParam('newWorkload'); 
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var userIdPure = $A.get("$SObjectType.CurrentUser");
        var param = '';
        var callWeight = $A.get("$Label.c.PureCloud_Phone_Call_Weight");
        console.log('##CALL WEIGHT!!##'+callWeight);
        console.log('configuredCapacity-callWeight: '+ configuredCapacity-callWeight)
        console.log('**************');
        if (userId != '') {
            component.set("v.userId", userId);
            console.log('##Got the User!!##');
            console.log(userIdPure);
            console.log('##END of the User!!##');
        }
        console.log('##configuredCapacity##' + configuredCapacity);
        console.log('##previousWorkload##' + previousWorkload);
        console.log('##newWorkload##' + newWorkload);
        if(newWorkload == configuredCapacity && !$A.util.isUndefined(component.get("v.userId")) ){
            param = 'FULL';
            helper.changePureCloudStatusOnCapacity(component, userId, param);
            console.log('##YES!! from FULL CAPACITY##');
        }
        else if ((newWorkload <= configuredCapacity-callWeight)  && !$A.util.isUndefined(component.get("v.userId")) ){
            param = 'NOT FULL';
            helper.changePureCloudStatusOnCapacity(component, userId, param);
            console.log('##YES!! from NOT FULL CAPACITY##');
        }
    }
})