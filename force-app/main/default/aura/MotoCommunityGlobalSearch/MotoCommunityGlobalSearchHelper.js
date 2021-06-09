({
    navigateToSearch: function(searchTerm){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/global-search/" + searchTerm
        });
        urlEvent.fire();
	},
    validateSearchInput: function(searchTerm){
        return searchTerm && searchTerm !== "";
    }
})