({
    createSFAccount: function (component, event, helper) {
        var leadId = component.get("v.leadId");
        if (!$A.util.isUndefinedOrNull(leadId) && !$A.util.isEmpty(leadId)) {
            helper.JSCreateSFAcc(component, event, helper);
        } else {
            if ($A.util.isUndefinedOrNull(component.get("v.rowData")) || $A.util.isEmpty(component.get("v.rowData"))) {
                helper.createAccountFromScratch(component, event, helper);
            }
        }
    },
    JSCreateDnBAcc: function (component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.errorMsg", null);
        var leadId = component.get("v.leadId");
        var doNotCreateOpportunity = component.get("v.doNotCreateOpportunity");
        var oppRecordTypeId = component.get("v.oppRecordTypeId");
        console.log('Opportunity Record Type Id createDnBAccount ===' + oppRecordTypeId);
        var action = component.get("c.createDnBAccount");
        console.log(component.get("v.countyName"));
        action.setParams({
            "leadId": leadId,
            "doNotCreateOpp": doNotCreateOpportunity,
            "leadSourceVal": component.get("v.leadSourceValue"),
            "Name": component.get("v.rowData")[0].Account_Name,
            "BillingCountry": component.get("v.rowData")[0].Country,
            "BillingStateCode": component.get("v.rowData")[0].Billing_State,
            "BillingCity": component.get("v.rowData")[0].Billing_City,
            "BillingStreet": component.get("v.rowData")[0].Billing_Street,
            "BillingPostalCode": component.get("v.rowData")[0].Postal_Code,
            "oppRecordTypeId": oppRecordTypeId,
            "oppSalesProcess": component.get("v.oppSalesProcess"),
            'sicCode': component.get("v.sicCode"),
            'website': component.get("v.website"),
            'Industry': component.get("v.industry"),
            'billingCounty': component.get("v.countyName")
        });
        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            var state = response.getState();
            var respRes = response.getReturnValue();
            if (state === "SUCCESS") {
                if (
                    !$A.util.isUndefinedOrNull(respRes) &&
                    !$A.util.isEmpty(respRes) &&
                    respRes.startsWith("001")
                ) {
                    this.navigateToSObject(component, event, helper, respRes);
                } else {
                    component.set(
                        "v.errorMsg",
                        "Error occurred while processing your request.Please contact your Administrator."
                    );
                }
            } else {
                component.set(
                    "v.errorMsg",
                    "Error occurred while processing your request.Please contact your Administrator."
                );
            }
        });
        $A.enqueueAction(action);
    },
    JSCreateSFAcc: function (component, event, helper) {
        console.log('Entered create sf account==');
        component.set("v.showSpinner", true);
        component.set("v.errorMsg", null);
        var leadId = component.get("v.leadId");
        var doNotCreateOpportunity = component.get("v.doNotCreateOpportunity");
        var oppRecordTypeId = component.get("v.oppRecordTypeId");
        console.log('Opportunity Record Type Id createSFAccount ===' + oppRecordTypeId);
        var salesProcess = component.get("v.oppSalesProcess");
        console.log('Opportunity salesProcess in helper===' + salesProcess);
        var action = component.get("c.createSFAccount");
        action.setParams({
            "leadId": leadId,
            "doNotCreateOpp": doNotCreateOpportunity,
            "leadSourceVal": component.get("v.leadSourceValue"),
            "oppRecordTypeId": oppRecordTypeId,
            "oppSalesProcess": component.get("v.oppSalesProcess")
        });
        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            var state = response.getState();
            var respRes = response.getReturnValue();
            if (state === 'SUCCESS') {
                console.log('return value of sfaccount method' + respRes);
                if (!$A.util.isUndefinedOrNull(respRes) && !$A.util.isEmpty(respRes) && respRes.startsWith('001')) {
                    this.navigateToSObject(component, event, helper, respRes);
                } else {
                    console.log('respRes*****' + respRes);
                    component.set("v.errorMsg", 'Error occurred while processing your request.Please contact your Administrator.');
                }
            }
            else {
                component.set("v.errorMsg", 'Error occurred while processing your request.Please contact your Administrator.');
            }
        });
        $A.enqueueAction(action);
    },
    convertLead: function (component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.errorMsg", null);
        var selectedAccountId = component.get("v.AccountRecordId");
        var leadId = component.get("v.leadId");
        var doNotCreateOpportunity = component.get("v.doNotCreateOpportunity");
        var oppRecordTypeId = component.get("v.oppRecordTypeId");
        console.log('Opportunity Record Type Id convertExactOrFuzzySFMatch ===' + oppRecordTypeId);
        var action = component.get("c.convertExactOrFuzzySFMatch");
        action.setParams({
            "leadId": leadId,
            "accountId": selectedAccountId,
            "doNotCreateOpp": doNotCreateOpportunity,
            "oppRecordTypeId": oppRecordTypeId,
            "leadSourceVal": component.get("v.leadSourceValue"),
            "oppSalesProcess": component.get("v.oppSalesProcess")
        });
        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            var state = response.getState();
            var respRes = response.getReturnValue();
            console.log('state==>' + state);
            console.log('respRes==>' + respRes);
            if (state === 'SUCCESS') {
                if (!$A.util.isUndefinedOrNull(respRes) && !$A.util.isEmpty(respRes) && respRes.startsWith('001')) {
                    this.navigateToSObject(component, event, helper, respRes);
                } else {
                    component.set("v.errorMsg", 'Error occurred while processing your request.Please contact your Administrator.');
                }
            }
            else {
                component.set("v.errorMsg", 'Error occurred while processing your request.Please contact your Administrator.');
            }
        });
        $A.enqueueAction(action);
    },
    getAccountMatches: function (component, event, helper) {
        var action = component.get("c.getAccounts");
        var fields = 'Id,Name,Motorola_Customer_Number__c,Region__c,Federal_Division__c,Territory__c,RecordType.Name,Primary_Route_to_Market__c,BillingPostalCode,BillingStreet,BillingCity,BillingState,BillingStateCode,BillingCountry,BillingCountryCode,Industry,Billing_County__c';
        var recordTypeNames = ['Prospect', 'SoldToAccount'];
        var accRecordTypeId = component.get("v.accRecordTypeId");
        if(!$A.util.isUndefinedOrNull(accRecordTypeId) && !$A.util.isEmpty(accRecordTypeId) && accRecordTypeId === '01280000000M0pzAAC'){
            recordTypeNames = ['Procurement'];
        }
        action.setParams({
            "accName": component.get("v.accountName"),
            "country": component.get("v.countryName"),
            "state": component.get("v.stateName"),
            "city": component.get("v.cityName"),
            "fields": fields,
            "county": component.get("v.countyName"),
            "recordTypeNames": recordTypeNames,
            "resultLimit": '100'
        });
        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            var state = response.getState();
            var respRes = response.getReturnValue();
            var exactOrfuzzyList = [];
            console.log("response");
            console.log("State: " + state);
            if (state === 'SUCCESS' && ($A.util.isUndefinedOrNull(respRes[0].Error) || $A.util.isEmpty(respRes[0].Error))) {
                console.log("if");
                console.log("length: " + respRes.length);
                for (var i = 0; i < respRes.length; i++) {
                    console.log("for " + i);
                    exactOrfuzzyList.push({
                        Type: respRes[i].Type,
                        RecordType: respRes[i].Account.RecordType.Name + ' ' + respRes[i].Type,
                        Name: respRes[i].Account.Name,
                        MCN: respRes[i].Account.Motorola_Customer_Number__c,
                        Street: respRes[i].Account.BillingStreet,
                        City: respRes[i].Account.BillingCity,
                        County: respRes[i].Account.Billing_County__c,
                        State: respRes[i].Account.BillingState,
                        Country: respRes[i].Account.BillingCountry,
                        PostalCode: respRes[i].Account.BillingPostalCode,
                        CountryCode: respRes[i].Account.BillingCountryCode,
                        StateCode: respRes[i].Account.BillingStateCode,
                        Industry: respRes[i].Account.Industry,
                        AccountId: respRes[i].Account.Id,
                        Id: respRes[i].Account.Id,
                        FederalDivision: respRes[i].Account.Federal_Division__c,
                        Territory: respRes[i].Account.Territory__c,
                        RoutetoMarket: respRes[i].Account.Primary_Route_to_Market__c,
                        Region: respRes[i].Account.Region__c
                    });
                    if (exactOrfuzzyList[i].Type == 'Exact') {
                        exactOrfuzzyList[i].displayIconName = 'action:approval';
                        component.set("v.noExactMatch", false);
                        console.log('is Exact match==' + component.get('v.noExactMatch'));
                    } else if (exactOrfuzzyList[i].Type == 'Fuzzy') {
                        exactOrfuzzyList[i].displayIconName = 'action:check';
                        component.set("v.showSearchForDnb", true);
                        console.log('is Not Exact match==' + component.get('v.noExactMatch'));
                    }
                }
                component.set("v.resultList", exactOrfuzzyList);
                component.set("v.resultListLength", exactOrfuzzyList.length);
                console.log('callback = ' + JSON.stringify(component.get("v.resultList")));
            } else if (respRes.length == 1 && respRes[0].Error == 'No Records') {
                helper.searchFromDnB(component, event, helper);
                component.set("v.showSearchForDnb", false);

            } else {
                console.log('Bad/No Response');
            }
            component.set("v.isAccountSearched", true);
        });
        $A.enqueueAction(action);
    },
    searchFromDnB: function (component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.showChooseSFAccBtn", false);
        component.set("v.showcreateSFAccountRecord", true);
        var JSAccountName = component.get("v.accountName");
        var JScountryCode = component.get("v.countryISOCode");
        var JSBillingState = component.get("v.stateCode");
        var JSBillingCity = component.get("v.cityName");
        var JSBillingCounty = component.get("v.countyName");
        var JSBillingStreet = component.get("v.streetName");
        var JSPostalCode = component.get("v.postalCode");
        var action = component.get("c.dnbSearch");
        action.setParams({
            "values": {
                "name": JSAccountName,
                "countryISOAlpha2Code": JScountryCode,
                "addressLocality": JSBillingCity,
                "addressRegion": JSBillingState,
                "county": JSBillingCounty,
                "postalCode": JSPostalCode,
                "candidateMaximumQuantity": '100'
            },
            "urlExtension": '/v1/match/cleanseMatch?'
        });

        action.setCallback(this, function (dnbResponse) {
            component.set("v.errorMsg", null);
            component.set("v.showSpinner", false);
            var state = dnbResponse.getState();
            if (state === 'SUCCESS') {
                var records = dnbResponse.getReturnValue();
                if (records != null) {
                    component.set("v.exactMatch", true);
                    var jsonData = JSON.parse(records);
                    console.log('jsonData--> ' + JSON.stringify(jsonData));
                    console.log('match candidates data' + jsonData.matchCandidates[0]);
                    var responseData = jsonData.matchCandidates;
                    var len = responseData.length;
                    component.set("v.dnbResultListLength", len);
                    console.log('responseData===' + JSON.stringify(responseData));
                    console.log('response data length' + len);
                    var respRows = [];
                    for (var i = 0; i < len; i++) {
                        console.log('primary name --->' + responseData[i].organization.primaryName);
                        console.log('country --->' + responseData[i].organization.primaryAddress.addressCountry.name);
                        respRows.push({
                            Account_Name: responseData[i].organization.primaryName,
                            Country: responseData[i].organization.primaryAddress.addressCountry.name,
                            Billing_Street: responseData[i].organization.primaryAddress.streetAddress.line1,
                            Billing_City: responseData[i].organization.primaryAddress.addressLocality.name,
                            Billing_State: responseData[i].organization.primaryAddress.addressRegion.abbreviatedName,
                            Postal_Code: responseData[i].organization.primaryAddress.postalCode,
                            Country_Code: responseData[i].organization.primaryAddress.addressCountry.isoAlpha2Code,
                            DUNS_Num: responseData[i].organization.duns,
                            displayIconName: 'action:update_status',
                            Type: 'DnB'
                        });
                        component.set('v.resultData', respRows);

                    }
                    if (records.length == 0) {
                        var errorMessage = "No Records Found"
                        Console.log(errorMessage);
                    } else {
                        component.set("v.showDnBRecordsTable", true);
                        component.set("v.isCreateAccDisable", true);
                        component.set("v.isChooseAccDisable", true);
                        component.set("v.isDBAccDisable", false);
                        component.set('v.dnbColumns', [
                            { label: ' Type', fieldName: 'Type', initialWidth: 90, cellAttributes: { alignment: 'center', class: 'Type' } },
                            { label: 'NAME', fieldName: 'Account_Name', type: 'text' },
                            { label: 'BILLING STREET', fieldName: 'Billing_Street', type: 'text' },
                            { label: 'BILLING CITY', fieldName: 'Billing_City', type: 'text' },
                            { label: 'BILLING STATE', fieldName: 'Billing_State', type: 'text' },
                            { label: 'BILLING COUNTRY', fieldName: 'Country', type: 'text' },
                            { label: 'POSTAL CODE', fieldName: 'Postal_Code', type: 'text' },
                            { label: "DUNS #", fieldName: "DUNS_Num", type: "text" }
                        ]);
                    }
                } else {
                    component.set("v.showDnBRecordsTable", true);
                }
            } else if (state === "INCOMPLETE") {
                console.log("Error: " + errorMessage);
            } else if (state === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });
        $A.enqueueAction(action);
    },
    searchFromDnBDetails: function (component, event, helper) {
        console.log(component.get("v.rowData")[0]);
        component.set("v.showSpinner", true);
        component.set("v.showChooseSFAccBtn", false);
        component.set("v.showcreateSFAccountRecord", true);
        var JSAccountName = component.get("v.accountName");
        var JScountryCode = component.get("v.countryISOCode");
        var JSBillingState = component.get("v.stateCode");
        var JSBillingCity = component.get("v.cityName");
        var JSBillingStreet = component.get("v.streetName");
        var JSPostalCode = component.get("v.postalCode");
        var Duns = component.get("v.rowData")[0].DUNS_Num;

        console.log(component.get("v.rowData")[0].DUNS_Num);
        console.log(Duns);
        component.set("v.dunsNumber",Duns);
        var action = component.get("c.dnbSearchDetails");
        action.setParams({
            duns: Duns,
            urlExtension: "/v1/search/criteria?"
        });

        action.setCallback(this, function (dnbResponse) {
            component.set("v.errorMsg", null);
            component.set("v.showSpinner", false);
            var state = dnbResponse.getState();
            if (state === "SUCCESS") {
                var records = dnbResponse.getReturnValue();
                if (records != null) {
                    var jsonData = JSON.parse(records);
                    console.log("jsonData--> " + JSON.stringify(jsonData));
                    console.log("match candidates data" + jsonData.searchCandidates[0]);
                    var responseData = jsonData.searchCandidates;
                    var len = responseData.length;
                    console.log("responseData===" + JSON.stringify(responseData));
                    console.log("response data length" + len);
                    
                    
                    component.set("v.countryCode",responseData[0].organization.primaryAddress.addressCountry.isoAlpha2Code);
                    try{
                        component.set("v.sicCode",responseData[0].organization.primaryIndustryCodes[0].usSicV4);
                    	console.log("usV4Sic==="+component.get("v.sicCode"));
                    }catch(err) {
                        console.log(err.message);
                    }
                    try {
                        component.set("v.phone",'+'+responseData[0].organization.telephone[0].isdCode+responseData[0].organization.telephone[0].telephoneNumber);
                    }catch(err) {
                        console.log(err.message);
                    }
                    try {
                        component.set("v.tradeName",responseData[0].organization.tradeStyleNames[0]);
                    }catch(err) {
                        console.log(err.message);
                    }
                    try {
                        component.set("v.website", responseData[0].organization.domain);

                    }catch(err) {
                        console.log(err.message);
                    }      
                        
                    if(component.get("v.sicCode")){
                     helper.getIndustryVertical(component, event, helper);
                       
                    }else{
                        $A.enqueueAction(component.get("c.createDnBAccountRecord"));
                    }


                    if (records.length == 0) {
                        var errorMessage = "No Records Found";
                        Console.log(errorMessage);
                    }
                } else {
                    component.set("v.showDnBRecordsTable", true);
                }
            } else if (state === "INCOMPLETE") {
                console.log("Error: " + errorMessage);
            } else if (state === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });
        $A.enqueueAction(action);
    },
    getIndustryVertical: function (component, event, helper) {
        var sic = component.get("v.sicCode");
        var action = component.get("c.getIndustry");
        action.setParams({
            sic: sic
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log(resp);
                component.set("v.sicSetting", resp);
                $A.enqueueAction(component.get("c.createDnBAccountRecord"));

            } else if (state === "INCOMPLETE") {
                console.log("Error: " + errorMessage);
            } else if (state === "ERROR") {
                console.log("Error: " + errorMessage);
            }
        });
        $A.enqueueAction(action);
    },
    getCountryCode: function (component, event, helper) {
        console.log('Country Name==' + component.get("v.countryName"));
        var countryName = component.get("v.countryName");
        var action = component.get('c.CountryISOCode');
        action.setParams({
            countryName: countryName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var resp = response.getReturnValue();
                component.set("v.countryISOCode", resp);
            }
        });
        $A.enqueueAction(action);

    },
    getStateCode: function (component, event, helper) {
        var stateName = component.get("v.stateName");
        var action = component.get('c.StateCode');
        action.setParams({
            stateName: stateName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var resp = response.getReturnValue();
                component.set("v.stateCode", resp);
            }
        });
        $A.enqueueAction(action);
    },
    resetSection: function (component, event, helper) {
        component.set("v.isAccountSearched", false);
        component.set("v.isChooseAccDisable", true);
        component.set("v.showDnBRecordsTable", false);
        component.set("v.resultList", []);
        component.set("v.resultData", []);
        component.set("v.resultListLength", 10);
        component.set("v.dnbResultListLength", 10);
        component.set("v.noExactMatch", true);
        component.set("v.isDBAccDisable", true);
        component.set("v.isCreateAccDisable", true);
    },
    navigateToSObject: function (component, event, helper, accRecId) {
        var userTheme = component.get("v.userTheme");
        if (userTheme === 'Theme3') {
            window.open('/' + accRecId, 'self');
        } else {
            var navigationEvent = $A.get("e.force:navigateToSObject");
            if (navigationEvent) {
                navigationEvent.setParams({
                    "recordId": accRecId,
                    "slideDevName": "detail"
                });
                navigationEvent.fire();
            } else {
                sforce.one.navigateToSObject(accRecId, "detail");
            }
        }

    },
    createAccountFromScratch: function (component, event, helper) {
        var userTheme = component.get("v.userTheme");
        var accName = component.get("v.accountName");
        var cityName = component.get("v.cityName");
        var countyName = component.get("v.countyName");
        var streetName = component.get("v.streetName");
        var postalCode = component.get("v.postalCode");
        var countryISOCode = component.get("v.countryISOCode");
        var stateCode = component.get("v.stateCode");
        /*var routeToMarket = component.get("v.routeToMarket");*/
        var accRecordTypeId = component.get("v.accRecordTypeId");

        if (userTheme === 'Theme3') {
            window.open('/001/e?nooverride=1&RecordType=' + accRecordTypeId + '&acc2=' + accName + '&00N34000005SWzW=' + /*routeToMarket */+
                '&acc17city=' + cityName + '&acc17county' + countyName + '&acc17street=' + streetName + '&acc17zip=' + postalCode + '&acc17country=' + countryISOCode + '&acc17state=' + stateCode, 'self');
        } else {
            var createRecordEvent = $A.get("e.force:createRecord");
            if (createRecordEvent) {
                createRecordEvent.setParams({
                    "entityApiName": "Account",
                    "defaultFieldValues": {
                        'Name': accName,
                        'BillingCity': cityName,
                        'BillingCounty' : countyName,
                        'BillingStreet': streetName,
                        'BillingPostalCode': postalCode,
                        'BillingCountryCode': countryISOCode,
                        'BillingStateCode': stateCode/*,
                        'Primary_Route_to_Market__c': routeToMarket*/

                    }
                });
                createRecordEvent.fire();
            } else {
                sforce.one.createRecord('Account', accRecordTypeId, {
                    'Name': accName,
                    'BillingCity': cityName,
                    'BillingCounty': countyName,
                    'BillingStreet': streetName,
                    'BillingPostalCode': postalCode,
                    'BillingCountryCode': countryISOCode,
                    'BillingStateCode': stateCode/*,
                    'Primary_Route_to_Market__c': routeToMarket*/
                });
            }
        }
    }
});