({ 
    getSitePrefix : function(component) {
        var action = component.get("c.fetchSitePrefix");       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.getURL",response.getReturnValue());
                var prefixURL= component.get("v.getURL");
                if ($A.util.isUndefinedOrNull(prefixURL)) {     
                    component.set("v.isPartnerUser",false); 
                }
                console.log('getURL - ' + component.get("v.getURL"));                                 			
            }
        });
        $A.enqueueAction(action);  
    },
    moveToOpportunity : function(component) {
        var isPartnerUser=component.get("v.isPartnerUser");
        var recid = component.get("v.selectedOpportunityId");
        var quoteId = component.get("v.recordId");
        if($A.util.isUndefinedOrNull(recid)){
           if(isPartnerUser){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Please select an opportunity',
                    duration:' 500000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }else{
                component.set("v.message",true);
                component.set("v.errorMessage",'Please select an opportunity');
            }
        }
        else{
            component.find("Id_spinner").set("v.class" , 'slds-show');
            var action = component.get("c.moveQuoteToOpportunity");
            action.setParams({ 
                "selectedOppId": recid,
                "quoteId": quoteId
            });
            action.setCallback(this, function(response) {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                        if(storeResponse === 'Ok'){
                            if(!isPartnerUser){
                                window.open('/'+quoteId,'_self');
                            }else{
                                window.location.reload();
                            }
                        }else{
                            if(!isPartnerUser){
                                component.set("v.message",true);
                                component.set("v.errorMessage",'Record can not be updated due to error encountered in API');
                                setTimeout(function() {                           
                                window.open('/'+quoteId,'_self');
                                },5000)

                            }else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error Message',
                                    message: "Record can not be updated due to error encountered in API",
                                    duration:' 30000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire(); 
                            }
                        }
                }
            });
            $A.enqueueAction(action);
        }
    },
    newOpportunity : function(component){
        var oppURL;       
        var prefixURL= component.get("v.getURL");        
        var userTheme=component.get("v.userTheme");        
        //Start - SF-2205 - New Opportunity button on Quote "Move to Opportunity" popup doesn't work
        var action = component.get("c.isLoggedinPartnerUser");        
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {                
                var isloggedinPartnerUser = response.getReturnValue();                
                if(isloggedinPartnerUser === true){ 
                    component.set("v.isPartnerUser",true);                    
                }else{
                    component.set("v.isPartnerUser",false);                    
                }
            }
            var isPartnerUser = component.get("v.isPartnerUser");
            console.log('prefixURL==>'+prefixURL);
            console.log('After isPartnerUser==>'+ isPartnerUser);
            console.log('userTheme==>'+ userTheme);
            if(isPartnerUser===true){
                oppURL= prefixURL+'/s/opportunity/Opportunity/Recent' ;                
            }else{
                if(userTheme==="Classic"){
                    oppURL= prefixURL+'/006/o' ;                
                }else{                    
                	oppURL= prefixURL + '/lightning/o/Opportunity/list?filterName=Recent';
                }
            }
            window.open(oppURL, '_blank');   
            var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        	dismissActionPanel.fire();
        });        
        $A.enqueueAction(action);   
        //End SF-2205 - New Opportunity button on Quote "Move to Opportunity" popup doesn't work
    }
})