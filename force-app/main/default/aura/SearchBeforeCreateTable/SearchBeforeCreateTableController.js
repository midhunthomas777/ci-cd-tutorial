({
    invoke: function (component, event, helper) {
        component.set("v.errorMsg", null);
        component.set('v.columns', [
            { label: 'Type', fieldName: 'Type', initialWidth: 90, cellAttributes: { alignment: 'center', class: { fieldName: 'RecordType' } } },
            { label: 'Name', fieldName: 'Name', type: 'text' },
            { label: 'Customer Number', fieldName: 'MCN', type: 'text' },
            { label: 'Billing Street', fieldName: 'Street', type: 'text' },
            { label: 'Billing City', fieldName: 'City', type: 'text' },
            { label: 'Billing County', fieldName: 'County', type: 'text' },
            { label: 'Billing State', fieldName: 'State', type: 'text' },
            { label: 'Postal Code', fieldName: 'PostalCode', type: 'text' },
            { label: 'Billing Country', fieldName: 'Country', type: 'text' },
            { label: 'Industry Vertical', fieldName: 'Industry', type: 'text' }
        ]);
        helper.resetSection(component, event, helper);
        component.set("v.showSpinner", true);
        helper.getAccountMatches(component, event, helper);
        var salesProcess = component.get("v.oppSalesProcess");
        console.log('Opportunity salesProcess in do init===' + salesProcess);
    },

    getSelectedRows: function (component, event, helper) {
        component.set("v.errorMsg", null);
        var selectedRow = event.getParam("selectedRecord");
        var eventErrorMsg = event.getParam("errorMsg");
        var resultList = component.get('v.resultList');
        var resultData = component.get('v.resultData');
        var showDnBRecordsTable = component.get('v.showDnBRecordsTable');
        if (($A.util.isUndefinedOrNull(resultList) || $A.util.isEmpty(resultList)) && ($A.util.isUndefinedOrNull(resultData) || $A.util.isEmpty(resultData)) && showDnBRecordsTable) {
            component.set("v.errorMsg", eventErrorMsg);
        } else {
            component.set("v.errorMsg", null);
        }
        if (!$A.util.isUndefinedOrNull(selectedRow) && !$A.util.isEmpty(selectedRow)) {
            var type = selectedRow[0].Type;
            component.set("v.rowData", selectedRow[0]);
            var dnbAccount = component.get("v.rowData")[0].Account_Name;
            var newSFAccount = component.get("v.newSFAccount");
            if (newSFAccount) {
                component.set("v.newSFAccount", false);
            }
            if (!$A.util.isUndefinedOrNull(dnbAccount)) {
                component.set("v.resetSelection", false);
                component.set("v.resetSelection", true);
                // component.set("v.showcreateSFAccountRecord",false);
                component.set("v.showChooseSFAccBtn", false);
                component.set("v.showcreateAccFromDnB", true);
                component.set("v.showSearchForDnb", false);
                component.set("v.errorMsg", null);

            }
            component.set("v.AccountRecordId", selectedRow[0].AccountId);
            if (type == 'Fuzzy') {
                //component.set("v.showcreateSFAccountRecord",true);
                component.set("v.showcreateAccFromDnB", false);
                component.set("v.showChooseSFAccBtn", true);
                //component.set("v.showSearchForDnb",false);
                var resultdata = component.get('v.resultData');
                if (!$A.util.isUndefinedOrNull(resultdata) && !$A.util.isEmpty(resultdata)) {
                    component.set("v.showDnBRecordsTable", false);
                    component.set("v.showDnBRecordsTable", true);
                }

            } else if (type == 'Exact') {
                component.set("v.showChooseSFAccBtn", true);
            } else {
                component.set("v.isDBAccDisable", false);
                component.set("v.isChooseAccDisable", true);
            }
        }


    },
    selectSFAccount: function (component, event, helper) {
        var isLeadConvert = component.get("v.isLeadConvert");
        if (isLeadConvert) {
            helper.convertLead(component, event, helper);
        } else {
            var selectedAccountId = component.get("v.AccountRecordId");
            helper.navigateToSObject(component, event, helper, selectedAccountId);
        }
    },
    createSFAccountRecord: function (component, event, helper) {
        helper.createSFAccount(component, event, helper);
    },
    searchDnB: function (component, event, helper) {
        component.set("v.showSearchForDnb", false);

        var leadId = component.get("v.leadId");
        if (!$A.util.isUndefinedOrNull(leadId) && !$A.util.isEmpty(leadId)) {
            component.set("v.showcreateSFAccountRecord", true);
        }
        component.set("v.resetSelection", false);
        component.set("v.resetSelection", true);
        helper.searchFromDnB(component, event, helper);
    },
    dnbDetails: function (component, event, helper) {
        helper.searchFromDnBDetails(component, event, helper);
    },
    createDnBAccountRecord: function (component, event, helper) {
        var leadId = component.get("v.leadId");
        var userTheme = component.get("v.userTheme");
        var accRecordTypeId = component.get("v.accRecordTypeId");
        var accName = component.get("v.rowData")[0].Account_Name;
        var countryCode = component.get("v.countryCode");
        var stateCode = component.get("v.rowData")[0].Billing_State;
        var city = component.get("v.rowData")[0].Billing_City;
        var street = component.get("v.rowData")[0].Billing_Street;
        var postalCode = component.get("v.rowData")[0].Postal_Code;
        var county = component.get("v.rowData")[0].Billing_County__c;
        var industry = component.get("v.sicSetting.Industry__c");
        var segment = component.get("v.sicSetting.Current_Segment__c");
        var phone = component.get("v.phone");
        var tradeName = component.get("v.tradeName");
        var duns = component.get("v.dunsNumber");
        if(industry=='Unassigned'){
            industry='';
        }
        var website = "";
        var sic = "";
        if (typeof component.get("v.sicCode") !== "undefined") {
            sic = component.get("v.sicCode");
        }

        if (typeof component.get("v.website") !== "undefined") {
            website = component.get("v.website");
        }
        console.log(website);
        console.log(segment);
        console.log(tradeName);
        console.log(duns);
        console.log(phone);

        console.log("userTheme===>" + userTheme);
        if (!$A.util.isUndefinedOrNull(leadId) && !$A.util.isEmpty(leadId)) {
            helper.JSCreateDnBAcc(component, event, helper);
        } else if (userTheme === 'Theme3') {
            window.open(
                "/001/e?nooverride=1&RecordType=" +
                accRecordTypeId +
                "&acc2=" +
                accName +
                /*"&00N34000005SWzW=" +
                routeToMarket +*/
                "&acc17city=" +
                city +
                "&acc17street=" +
                street +
                "&acc17zip=" +
                postalCode +
                "&acc17country=" +
                countryCode +
                "&acc17state=" +
                stateCode +
                "&acc16=" +
                sic +
                "&acc12=" +
                website +
                "&acc7=" +
                industry+
                "&segment__c=" +
                segment+
                "&acc29=" +
                tradeName+
                "&DNBoptimizer__DNB_D_U_N_S_Number__c=" +
                duns+
                "&acc10=" +
                phone,
                "self"
            );
        } else {
            var createRecordEvent = $A.get("e.force:createRecord");
            if (createRecordEvent) {
                createRecordEvent.setParams({
                    "entityApiName": "Account",
                    "defaultFieldValues": {
                        'Name': component.get("v.rowData")[0].Account_Name,
                        'BillingCity': component.get("v.rowData")[0].Billing_City,
                        'BillingStreet': component.get("v.rowData")[0].Billing_Street,
                        'BillingPostalCode': component.get("v.rowData")[0].Postal_Code,
                        'BillingCountryCode': countryCode,
                        'BillingStateCode': component.get("v.rowData")[0].Billing_State,
                        'Billing_County__c' : component.get("v.rowData")[0].Billing_County__c,
                        /*'Primary_Route_to_Market__c': routeToMarket,*/
                        'Sic': sic,
                        'Website': website,
                        'Industry': industry,
                        'Phone': phone,
                        'DNBoptimizer__DNB_D_U_N_S_Number__c': duns,
                        'NameLocal': tradeName,
                        'Segment__c': segment
                    }
                });
                createRecordEvent.fire();
            } else {
                sforce.one.createRecord("Account", accRecordTypeId, {
                    'Name': component.get("v.rowData")[0].Account_Name,
                    'BillingCity': component.get("v.rowData")[0].Billing_City,
                    'BillingStreet': component.get("v.rowData")[0].Billing_Street,
                    'BillingPostalCode': component.get("v.rowData")[0].Postal_Code,
                    'BillingCountryCode': countryCode,
                    'BillingStateCode': component.get("v.rowData")[0].Billing_State,
                    'Billing_County__c': component.get("v.rowData")[0].Billing_County__c,
                    /*'Primary_Route_to_Market__c': routeToMarket,*/
                    'Sic': sic,
                    'Website': website,
                    'Industry': industry,
                    'Phone': phone,
                    'DNBoptimizer__DNB_D_U_N_S_Number__c': duns,
                    'Segment__c': segment
                });
                console.log("create record event not supported");
            }

        }
        component.set("v.CreateDnB", false);

    },
    handleCheck: function (component, event, helper) {
        var checkCmp = event.getSource().get('v.checked');
        component.set("v.newSFAccount", checkCmp);
        if (checkCmp == true) {
            var resultdata = component.get('v.resultData');
            if (!$A.util.isUndefinedOrNull(resultdata) && !$A.util.isEmpty(resultdata)) {
                component.set("v.showDnBRecordsTable", false);
                component.set("v.showDnBRecordsTable", true);
            }
            var resultList = component.get('v.resultList');
            if (!$A.util.isUndefinedOrNull(resultList) && !$A.util.isEmpty(resultList)) {
                component.set("v.resetSelection", false);
                component.set("v.resetSelection", true);
            }
            component.set("v.showcreateSFAccountRecord", true);
            component.set("v.showChooseSFAccBtn", false);
            component.set("v.showcreateAccFromDnB", false);

            component.set("v.rowData", null);
            helper.createSFAccount(component, event, helper);
        } else {
        }
    }
})