/*
2019-12-18 Created by Lorenzo Alali
IT control on INC2252716
Reason: Searching bu URL is possible in Lightning, not in Classic
Idea submitted on https://success.salesforce.com/ideaView?id=0873A0000015BJJQA2 
In the meantime, Lightning App "SearchApp.app" and "SearchAppController.js" were created as a workaround
If the Idea gets implemented by Salesforce, ok to retire this App
*/

({
	doInit : function(component, event, helper) {
        // Grab search query from URL
        var searchQuery = component.get("v.search");
        
        // Convert search query into SF expected format
        var stringToEncode = '{"componentDef":"forceSearch:search","attributes":{"term":"'+ searchQuery + '","scopeMap":{"type":"TOP_RESULTS"},"context":{"disableSpellCorrection":false,"SEARCH_ACTIVITY":{"term":"'+ searchQuery + '"}}}}';
        var encodedString = btoa(stringToEncode);
        
        // Redirect user (this only works from Lightning App, won't work from components)
        window.location = "/one/one.app?source=alohaHeader#" + encodedString;

	}
})