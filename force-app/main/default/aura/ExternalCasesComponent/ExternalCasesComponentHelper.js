({
    /****************************************************
      @description Set the columns of the case detail table
      */
    setColumns: function (component, event, helper) {
        component.set("v.columns", [{
                label: "Case Number",
                fieldName: "url",
                type: "url",
                sortable: "true",
                typeAttributes: {
                    target: "_blank",
                    label: {
                        fieldName: "number"
                    },
                    name: {
                        fieldName: "number"
                    }
                }
            },
            {
                label: "Date/Time Opened",
                fieldName: "opened_at",
                type: "date",
                sortable: "true",
                typeAttributes: {
                    day: "2-digit",
                    month: "short",
                    year: "numeric",
                    hour: "2-digit",
                    minute: "2-digit",
                    second: "2-digit",
                    hour12: true
                }
            },
            {
                label: "Contact Name",
                fieldName: "contactName",
                type: "text",
                sortable: "true"
            },
            {
                label: "Site",
                fieldName: "site",
                type: "text",
                sortable: "true"
            },
            {
                label: "State",
                fieldName: "account.u_shipping_state",
                type: "text",
                sortable: "true"
            },
            {
                label: "Subject",
                fieldName: "short_description",
                type: "text",
                sortable: "true"
            },
            {
                label: "Status",
                fieldName: "state",
                sortable: "true",
                type: "text"
            },
            {
                label: "Priority",
                fieldName: "priority",
                sortable: "true",
                type: "text"
            }
        ]);
    },
    /****************************************************
      @description Display all open cases
      */
    getCasesList: function (component, event, helper, paramMap) {
        // init the status list for filters
        let liststatus = ["All", "Open (Multiple Statuses)"];
        component.set("v.statuses", liststatus);

        component.set("v.loadSpinner", true);
        var action = component.get("c.caseList");
        var currentAccountId = component.get("v.recordId");
        action.setParams({
            requestParams: paramMap,
            accountId: currentAccountId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            var response = response.getReturnValue();
            var errorCodes = [
                "ERROR",
                "NOACCESS",
                "APIError",
                "Read timed out",
                "INTERNAL"
            ];
            if (state === "SUCCESS" && !errorCodes.includes(response)) {
                let cases = JSON.parse(response);

                if (cases.result.length > 0) {
                    let baseUrl = $A.get("$Site").siteUrlPrefix;
                    cases.result.forEach(function (record) {
                        record.url =
                            baseUrl + "/externalcasedetail?number=" + record.number; //+ '&accountId=' + currentAccountId;
                        record.site = record.account.display_value;
                        record.contactName = record.contact.display_value;
                        record.opened_at = new Date(record.opened_at); //DTSFCOM-296 : Converting to Date
                    });

                    for (var i = 0; i < cases.result.length; i++) {
                        if (!liststatus.includes(cases.result[i].state)) {
                            liststatus.push(cases.result[i].state);
                        }
                    }
                } else {
                    // no data
                    component.set("v.errorMsg", "No Records Found.");
                    component.set("v.loadNavigationBtns", false); //added to hide button on zero record
                }

                component.set("v.casesList", cases.result);
                component.set("v.unfilteredCaseList", cases.result);
                component.set("v.statuses", liststatus);

                // apply all filters
                this.applyAllFilters(component, event, helper);

                component.set("v.loadSpinner", false);
                component.set("v.refreshTable", true);
            } else {
                console.log(response);
                this.displayResponse(component, event, response);
            }
        });
        $A.enqueueAction(action);
    },
    /****************************************************
      @description Display  message if any error from server  
      */
    displayResponse: function (component, event, response) {
        var message = "";
        if (response == "NOACCESS") {
            message = "Insufficient Privileges, please try another one.";
        } else if (response == "APIError") {
            message =
                "Request has not been submitted successfully, please retry after some time.";
        } else {
            message = response;
        }
        this.showToast(component, message, "error");
        component.set("v.loadSpinner", false);
    },
    /****************************************************
      @description Display error message as toast
      */
    showToast: function (component, message, messageType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: messageType + "!",
            type: messageType,
            message: message
        });
        toastEvent.fire();
    },
    /****************************************************
      @description Filter the cases locally based on months
      */
    /* filterCases : function(component, event, helper ) { 
          component.set("v.refreshTable", false);  
          var fromDate = component.get("v.fromValue");      
          var toDate = component.get("v.toValue");
          var data = component.get("v.unfilteredCaseList");
          var results = data;
         
          if(!$A.util.isUndefinedOrNull(fromDate) && !$A.util.isEmpty(fromDate) && !$A.util.isUndefinedOrNull(toDate) && !$A.util.isEmpty(toDate)) {
              // setting To Date time attribute for the better comparison results as 
              // Order Date is date time field
              var toDateTime = new Date(toDate);
              toDateTime.setHours(23);
              toDateTime.setMinutes(59);
              toDateTime.setSeconds(59);   
               
              // filter checks each row, constructs new array where function returns true
              results = data.filter(row => (new Date(row.opened_at) >= new Date(fromDate))
                                        && (new Date(row.opened_at) <= toDateTime));

          }
              component.set("v.casesList", results);
              component.set("v.refreshTable", true); 
          
      },*/

    /****************************************************
      @description Display all the cases
      */
    viewAllCases: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: "/caselistpage"
        });
        urlEvent.fire();
    },
    /****************************************************
      @description create the Params Map
      */
    createMapFromObj: function (component, event, helper) {
        var paramMap = {};
        paramMap.sysparm_view = "extranet_export";
        paramMap.sysparm_display_value = "true";
        paramMap.account_param = "partner.u_motorola_enterprise_id=1099999999";
        // paramMap.sysparm_query = "ORDERBYDESCopened_at";

        // params with last six month close date
        let closeDate = this.getCloseDate();
        paramMap.sysparm_query =
            "closed_atISEMPTY^ORclosed_at>" + closeDate + "^ORDERBYDESCopened_at";
        paramMap.sysparm_fields =
            "number,opened_at,account.u_shipping_state,short_description,state,priority,contact,account";

        return paramMap;
    },
    /****************************************************
      @description Filter the cases based on search text
      */
    /*  searchFilter :  function(component, event, helper){ 
          component.set("v.refreshTable", false);   
          var data = component.get("v.unfilteredCaseList");
          var term = component.get("v.searchText");
          var columns = component.get("v.columns");
          var results = data;
          var regex;
          try {
                regex = new RegExp(term, "i");
              // filter checks each row, constructs new array where function returns true  
          	 results = data.filter(row =>{
                  for(let i=0; i<columns.length; i++){
              		var field = columns[i];
                  	if(regex.test(row[field.fieldName]))
                          return true;      			                  
                  }
      			return false;                	
              });
                  	
          
          } catch(e) {
              // invalid regex, use full list
              console.log('Invalid regular expression');
          }
          component.set("v.casesList", results);
          component.set("v.refreshTable", true);   
      },*/

    changePageSize: function (component, event, helper) {
        var selectedPageSize = component.get("v.selectedPageSize");
        component.set("v.dynamicPageSize", selectedPageSize);
    },
    /* filterByStatus :  function(component, event, helper){            
          component.set("v.refreshTable", false);   
          var data = component.get("v.unfilteredCaseList");
          var selectedStatus = component.get("v.selectedStatus");           
          var results = data;
          if(selectedStatus!='All')
          {
              try {
                  // filter checks each row, constructs new array where function returns true
                  results = data.filter(row=> (row.state == selectedStatus));
              } catch(e) {
                  // invalid regex, use full list
                  console.log('error in filtering');
              }
          }
          component.set("v.casesList", results);
          component.set("v.refreshTable", true);        
      },*/

    applyAllFilters: function (component, event, helper) {
        component.set("v.refreshTable", false);
        var fromDate = component.get("v.fromValue");
        var toDate = component.get("v.toValue");
        var searchText = component.get("v.searchText");
        var columns = component.get("v.columns");
        var selectedStatus = component.get("v.selectedStatus");

        var data = component.get("v.unfilteredCaseList");

        var results = data;

        //WIP- Mario to confirm for the open statues
        let openCaseStatues = [
            "New",
            "Assigned",
            "Pending",
            "Work in Progress",
            "Acknowledged",
            "Resolved"
        ];

        // setting To Date time attribute for the better comparison results as
        // Order Date is date time field
        var toDateTime = new Date(toDate);
        toDateTime.setHours(23);
        toDateTime.setMinutes(59);
        toDateTime.setSeconds(59);

        var regex = new RegExp(searchText, "i");

        results = data.filter(row => {
            var flagDate = true;
            var flagStatus = false;
            var flagSearch = false;

            // filter by from and to date
            if (fromDate && new Date(row.opened_at) < new Date(fromDate)) {
                flagDate = false;
            }
            if (toDate && new Date(row.opened_at) > toDateTime) {
                flagDate = false;
            }

            // filter by status
            if (
                !$A.util.isUndefinedOrNull(selectedStatus) &&
                !$A.util.isEmpty(selectedStatus) &&
                selectedStatus != "All"
            ) {
                if (row.state == selectedStatus) flagStatus = true;
                else if (
                    selectedStatus == "Open (Multiple Statuses)" &&
                    openCaseStatues.includes(row.state)
                )
                    flagStatus = true;
            } else {
                flagStatus = true;
            }

            // filter by search text
            if (
                !$A.util.isUndefinedOrNull(searchText) &&
                !$A.util.isEmpty(searchText)
            ) {
                for (let i = 0; i < columns.length; i++) {
                    var field = columns[i];
                    if (regex.test(row[field.fieldName])) flagSearch = true;
                }
            } else {
                flagSearch = true;
            }

            // show the rows which met all filter criteria
            return flagDate && flagStatus && flagSearch;
        });

        component.set("v.casesList", results);
        component.set("v.refreshTable", true);
    },

    getURLParameterValue: function () {
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function (part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
        return paramValue;
    },

    getCloseDate: function () {
        var d = new Date();
        d.setMonth(d.getMonth() - 6);
        var month = d.getMonth() + 1; // Since month is between 0-11 in javascript
        let closeDate = d.getFullYear() + "-" + month + "-" + d.getDate();
        return closeDate;
    }
});