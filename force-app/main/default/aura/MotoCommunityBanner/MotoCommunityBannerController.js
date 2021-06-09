({
    doInit: function(component, event, helper) {
        
        helper.setUserInfo(component, event, helper);
        helper.setOrderCount(component, event, helper);
        helper.setCaseCount(component, event, helper);
        helper.setContractCount(component, event, helper);
        
        // create and set url's for the banner links
        /*var navService = component.find("navService");
        
        // case page
        navService.generateUrl({
            type: "comm__namedPage",
            attributes: {
                name: "Case_Detail_List__c"
            }
        }).then($A.getCallback(function(url) {
            component.set("v.casesUrl", url+"?s=open");
        }));
        
        // order page
        navService.generateUrl({
            type: "comm__namedPage",
            attributes: {
                name: "OrderListPage__c"
            }
        }).then($A.getCallback(function(url) {
            component.set("v.ordersUrl", url+"?s=open");
        }));
        
        
        // contract page
        navService.generateUrl({
            type: "comm__namedPage",
            attributes: {
                name: "ContractsPage__c"
            }
        }).then($A.getCallback(function(url) {
            component.set("v.contractsUrl", url);
        }));*/
        
        // TODO: lightning navigation service is working unexpectedly for community pages.
        // On first time page load and when we are going back using back button it is working fine
        // but in case we go on home page via home icon or logo it is not working
        // Either we can use navigateToURL which will also hard code url
        // setting relative urls here
        let baseUrl = $A.get("$Site").siteUrlPrefix;
        component.set("v.casesUrl", baseUrl+"/caselistpage?s=open");
        component.set("v.ordersUrl", baseUrl+"/orderlistpage?s=open");
        component.set("v.contractsUrl", baseUrl+"/contractspage?s=open");
        
    },
    
    handleCaseClick: function(component, event, helper) {
        debugger;
        console.log("handleCaseClick");
        
        event.preventDefault();
        component.find("navService").navigate({
            type: "comm__namedPage",
            attributes: {
                name: "Case_Detail_List__c"
            },
            state: {
                s: "open"
            }
        });
        
    },
    
    loadComponent:function(component,event,helper){
        helper.showComponent(component,event,helper);
    }
    
})