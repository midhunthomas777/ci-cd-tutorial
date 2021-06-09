/* instead of multiple console.log use debugger */
/* that makes a lot of crap in console */
/* https://jira.mot-solutions.com/browse/DTPART-1493 */
/* cleaned up by Krzysztof Pintscher - feel free to reach out */

({
    doInit : function(component, event, helper) {
        helper.getCPQPageURL(component);
        helper.getCPQSiteId(component);
        helper.getQuoteInfo(component);
    },
    onProceedEdit : function(component, event, helper){
        let editCPQURL = component.get("v.getPageURL") + "&siteId=" + component.get("v.cpqSiteId") + "&Id=" + component.get("v.recordId");
        window.open(editCPQURL, "_blank"); 
        $A.get("e.force:closeQuickAction").fire();
    },

    onCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    /*
    getValueFromReturnMCNEvent : function(component, event, helper) {
        //Copied from editquote test SF-2759
        var quoteId = component.get("v.recordId");        
        var geturl = component.get("v.getURL");
        var getPageUrl = component.get("v.getPageURL"); 
        var cpqSiteId =component.get("v.cpqSiteId"); 
        var editCPQURL = getPageUrl + "&siteId=" + cpqSiteId + "&Id=" + quoteId;
        window.open(editCPQURL,"_blank"); 
        $A.get("e.force:closeQuickAction").fire();
        //Copied from editquote test SF-2759
        
        console.log('-----------In getValueFromReturnMCNEvent---------');
        var ShowResultValue = event.getParam("selectedMCN");
        console.log('ShowResultValue -'+ShowResultValue);
        component.set("v.MCNselected", ShowResultValue);
        console.log('MCNselected -'+component.get('v.MCNselected'));
        helper.updateQuoteWithMCN(component);
    }*/
})