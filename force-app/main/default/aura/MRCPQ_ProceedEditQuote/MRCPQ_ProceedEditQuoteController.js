({
    doInit : function(component, event, helper) {
        console.log('---- In doInit ProceededitQuote');
        console.log('recordId -'+component.get('v.recordId'));
        console.log('accountId -'+component.get('v.accountId'));
        console.log('mcnNumber -'+component.get('v.mcnNumber'));
        console.log('mcnId -'+component.get('v.mcnId'));
        
        helper.getSitePrefix(component);
        helper.getCPQPageURL(component);
        helper.getCPQSiteId(component);
        
        console.log('v.recordId - '+component.get('v.recordId'));
        console.log('v.getURL - '+component.get('v.getURL'));
        console.log('v.getPageURL - '+component.get('v.getPageURL'));
        console.log('v.cpqSiteId - '+component.get('v.cpqSiteId'));        
        
        
    },
    
    editquote : function(component, event, helper){
        /*helper.launchCPQ(component); 
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();*/
        
        helper.updateMCNonQuote(component);
       /* console.log('v.recordId - '+component.get('v.recordId'));
        console.log('v.getURL - '+component.get('v.getURL'));
        console.log('v.getPageURL - '+component.get('v.getPageURL'));
        console.log('v.cpqSiteId - '+component.get('v.cpqSiteId'));    
        var quoteId = component.get("v.recordId");        
        var geturl = component.get("v.getURL");
        var getPageUrl = component.get("v.getPageURL"); 
        var cpqSiteId =component.get("v.cpqSiteId"); 
        var editCPQURL = getPageUrl + "&siteId=" + cpqSiteId + "&Id=" + quoteId;
        console.log('editCPQURL = '+editCPQURL);
        window.open(editCPQURL,"_blank"); 
        $A.get("e.force:closeQuickAction").fire();*/
        //window.location.reload();
    }
})