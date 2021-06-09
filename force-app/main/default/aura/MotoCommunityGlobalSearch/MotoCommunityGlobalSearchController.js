({
    handleSearch: function(component, event, helper) {
        event.preventDefault();
        
        var searchTerm = component.get("v.searchTerm");
        component.set("v.searchTermInvalid", false);
        
        if(helper.validateSearchInput(searchTerm)){
        	helper.navigateToSearch(searchTerm);
        } else {
            component.set("v.searchTermInvalid", true);
        }
    }
})