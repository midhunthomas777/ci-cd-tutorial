({
    doInit: function (component, event, helper) {
        component.set("v.pageName", window.document.title);
        var paramMap = helper.createMapFromObj(component, event, helper);
        var pageName = component.get("v.pageName");
        if (pageName == "Home") {
            paramMap.sysparm_limit = "10";
            paramMap.sysparm_offset = "1";

            $A.util.addClass(component.find("title"), "extra-space");
        }
        //get only open cases if coming from open cases link
        var paramName = helper.getURLParameterValue().s;
        if (paramName == "open") {
            //  paramMap.sysparm_query = "closed_atISEMPTY^ORDERBYDESCopened_at";
            component.set("v.selectedStatus", "Open (Multiple Statuses)");
        }

        helper.setColumns(component, event, helper);
        helper.getCasesList(component, event, helper, paramMap);
    },
    viewAllCases: function (component, event, helper) {
        helper.viewAllCases(component, event, helper);
    },
    handleFilter: function (component, event, helper) {
        // helper.filterCases(component, event, helper);
        helper.applyAllFilters(component, event, helper);
    },
    /* handleSearch:function(component, event, helper){
          helper.searchFilter(component, event, helper); 
      },*/
    handlePageSizeChange: function (component, event, helper) {
        helper.changePageSize(component, event, helper);
    }
    /*
      handleFilterByStatus : function(component, event, helper){
          helper.filterByStatus(component, event, helper); 
      }*/
});